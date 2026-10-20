const express = require('express');
const { getDb } = require('../database/init');
const { authMiddleware, requireRoles } = require('../middleware/auth');

const router = express.Router();
router.use(authMiddleware);

// ── Student / Borrower: file a new incident report ───────────────────────────
// Accessible to any authenticated user (student/borrower filing against their own loan)
router.post('/', async (req, res) => {
  try {
    const pool = getDb();
    const { transaction_id, incident_type, description } = req.body;
    const reporterUserId = req.user.user_id;

    if (!transaction_id || !incident_type) {
      return res.status(400).json({ error: 'transaction_id and incident_type are required' });
    }

    const validTypes = ['Lost', 'Torn', 'Damaged', 'Other'];
    if (!validTypes.includes(incident_type)) {
      return res.status(400).json({ error: `incident_type must be one of: ${validTypes.join(', ')}` });
    }

    // Verify the transaction belongs to this borrower (students can only report their own loans)
    const [[tx]] = await pool.query(
      `SELECT t.id, t.status
       FROM transactions t
       INNER JOIN borrowers br ON t.borrower_id = br.id
       WHERE t.id = ? AND br.id_no = ?`,
      [transaction_id, reporterUserId]
    );

    // Circulation staff may also file on behalf of any transaction
    const isStaff = ['ADMIN', 'LIBRARIAN', 'CIRCULATION_IN_CHARGE'].includes(req.user.access_right);
    let transaction = tx;
    if (!transaction && isStaff) {
      const [[staffTx]] = await pool.query(
        `SELECT id, status FROM transactions WHERE id = ?`,
        [transaction_id]
      );
      transaction = staffTx;
    }

    if (!transaction) {
      return res.status(404).json({ error: 'Transaction not found or does not belong to you' });
    }
    if (transaction.status === 'Returned') {
      return res.status(400).json({ error: 'Cannot file an incident report on an already returned book' });
    }

    // Prevent duplicate pending reports on the same transaction
    const [existing] = await pool.query(
      `SELECT id FROM book_incident_reports
       WHERE transaction_id = ? AND status = 'Pending'`,
      [transaction_id]
    );
    if (existing.length > 0) {
      return res.status(409).json({ error: 'There is already a pending incident report for this borrow record' });
    }

    const [result] = await pool.query(
      `INSERT INTO book_incident_reports
         (transaction_id, reported_by_user_id, incident_type, description, status, created_at)
       VALUES (?, ?, ?, ?, 'Pending', NOW())`,
      [transaction_id, reporterUserId, incident_type, description || null]
    );

    res.status(201).json({ id: result.insertId, message: 'Incident report filed successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ── Student / Borrower: view own incident reports ────────────────────────────
router.get('/my-reports', async (req, res) => {
  try {
    const pool = getDb();
    const userIdNo = req.user.user_id;

    const [rows] = await pool.query(
      `SELECT
         ir.id,
         ir.transaction_id,
         ir.incident_type,
         ir.description,
         ir.status,
         ir.action_taken,
         ir.staff_notes,
         ir.created_at,
         ir.resolved_at,
         b.title      AS book_title,
         b.author     AS book_author,
         b.barcode    AS book_barcode,
         t.loan_date,
         t.due_date
       FROM book_incident_reports ir
       INNER JOIN transactions t ON ir.transaction_id = t.id
       INNER JOIN books        b ON t.book_id = b.id
       INNER JOIN borrowers   br ON t.borrower_id = br.id
       WHERE br.id_no = ?
       ORDER BY ir.created_at DESC`,
      [userIdNo]
    );

    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ── Circulation staff only from here ─────────────────────────────────────────
router.use(requireRoles(['ADMIN', 'LIBRARIAN', 'CIRCULATION_IN_CHARGE']));

// ── Staff: list all incident reports (with optional status filter) ────────────
router.get('/', async (req, res) => {
  try {
    const pool = getDb();
    const { status = null, search = '' } = req.query;
    const like = `%${String(search).trim()}%`;

    let statusClause = '';
    const params = [like, like, like, like, like];
    if (status) {
      statusClause = 'AND ir.status = ?';
      params.push(status);
    }

    const [rows] = await pool.query(
      `SELECT
         ir.id,
         ir.transaction_id,
         ir.reported_by_user_id,
         ir.incident_type,
         ir.description,
         ir.status,
         ir.action_taken,
         ir.staff_notes,
         ir.resolved_by_user_id,
         ir.created_at,
         ir.resolved_at,
         b.title      AS book_title,
         b.author     AS book_author,
         b.barcode    AS book_barcode,
         t.loan_date,
         t.due_date,
         t.status     AS loan_status,
         CONCAT(br.firstname, ' ', br.lastname) AS borrower_name,
         br.id_no AS borrower_id_no
       FROM book_incident_reports ir
       INNER JOIN transactions t ON ir.transaction_id = t.id
       INNER JOIN books        b ON t.book_id = b.id
       INNER JOIN borrowers   br ON t.borrower_id = br.id
       WHERE (? = '%%' OR br.firstname LIKE ? OR br.lastname LIKE ? OR br.id_no LIKE ? OR b.title LIKE ?)
       ${statusClause}
       ORDER BY FIELD(ir.status, 'Pending', 'Action Required', 'Resolved', 'Dismissed'), ir.created_at DESC`,
      params
    );

    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ── Staff: resolve or dismiss an incident report ─────────────────────────────
router.patch('/:id/resolve', async (req, res) => {
  const pool = getDb();
  const conn = await pool.getConnection();
  try {
    const { action_taken, staff_notes } = req.body;
    const resolvedBy = req.user.user_id;

    const validActions = ['Replacement Required', 'No Action Needed', 'Dismissed'];
    if (!action_taken || !validActions.includes(action_taken)) {
      return res.status(400).json({ error: `action_taken must be one of: ${validActions.join(', ')}` });
    }

    await conn.beginTransaction();

    // Fetch the report
    const [[report]] = await conn.query(
      `SELECT id, transaction_id, status FROM book_incident_reports WHERE id = ?`,
      [req.params.id]
    );
    if (!report) {
      await conn.rollback();
      return res.status(404).json({ error: 'Incident report not found' });
    }
    if (report.status === 'Resolved' || report.status === 'Dismissed') {
      await conn.rollback();
      return res.status(400).json({ error: 'This incident report has already been completed or dismissed' });
    }

    // Check if the transaction is already returned
    const [[tx]] = await conn.query(`SELECT status FROM transactions WHERE id = ?`, [report.transaction_id]);

    let newStatus = 'Resolved';
    if (action_taken === 'Dismissed') {
      newStatus = 'Dismissed';
    } else if (action_taken === 'Replacement Required') {
      newStatus = tx?.status === 'Returned' ? 'Resolved' : 'Action Required';
    } else if (action_taken === 'No Action Needed') {
      newStatus = 'Resolved';
    }

    // Update the incident report
    await conn.query(
      `UPDATE book_incident_reports
       SET status = ?, action_taken = ?, staff_notes = ?,
           resolved_by_user_id = ?, resolved_at = ${newStatus === 'Resolved' ? 'NOW()' : 'NULL'}
       WHERE id = ?`,
      [newStatus, action_taken, staff_notes || null, resolvedBy, req.params.id]
    );

    // Unlock the transaction so check-in can proceed
    await conn.query(
      `UPDATE transactions SET incident_locked = 0 WHERE id = ?`,
      [report.transaction_id]
    );

    await conn.commit();

    // Return full updated report
    const [[updated]] = await conn.query(
      `SELECT
         ir.*,
         b.title  AS book_title,
         b.author AS book_author,
         b.barcode AS book_barcode,
         CONCAT(br.firstname, ' ', br.lastname) AS borrower_name,
         br.id_no AS borrower_id_no
       FROM book_incident_reports ir
       INNER JOIN transactions t ON ir.transaction_id = t.id
       INNER JOIN books        b ON t.book_id = b.id
       INNER JOIN borrowers   br ON t.borrower_id = br.id
       WHERE ir.id = ?`,
      [req.params.id]
    );

    res.json(updated);
  } catch (err) {
    await conn.rollback();
    res.status(500).json({ error: err.message });
  } finally {
    conn.release();
  }
});

module.exports = router;

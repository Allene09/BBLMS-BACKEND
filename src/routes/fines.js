const express = require('express');
const { getDb } = require('../database/init');
const { authMiddleware, requireRoles } = require('../middleware/auth');

const router = express.Router();
router.use(authMiddleware);
router.use(requireRoles(['ADMIN', 'LIBRARIAN', 'CIRCULATION_IN_CHARGE']));

// ── Helper: generate receipt number ──────────────────────────────────────────
function generateReceiptNo(id) {
  const now = new Date();
  const datePart = now.toISOString().slice(0, 10).replace(/-/g, '');
  const seq = String(id).padStart(4, '0');
  return `RCPT-${datePart}-${seq}`;
}

// ── GET /api/fines/unpaid ─────────────────────────────────────────────────────
// Returns returned transactions with fines, plus currently overdue transactions
router.get('/unpaid', async (req, res) => {
  try {
    const { search = '' } = req.query;
    const pool = getDb();
    const like = `%${String(search).trim()}%`;

    const [rows] = await pool.query(
      `SELECT
         t.id              AS transaction_id,
         t.loan_date,
         t.due_date,
         t.return_date,
         t.fine_amount,
         t.past_due_fines,
         t.total_fine,
         t.fine_paid,
         t.status          AS loan_status,
         b.id              AS book_id,
         b.title           AS book_title,
         b.author          AS book_author,
         b.barcode         AS book_barcode,
         br.id             AS borrower_id,
         br.id_no          AS borrower_id_no,
         CONCAT(br.firstname, ' ', br.lastname) AS borrower_name,
         GREATEST(DATEDIFF(COALESCE(t.return_date, CURDATE()), t.due_date), 0) AS days_overdue
       FROM transactions t
       INNER JOIN books     b  ON t.book_id     = b.id
       INNER JOIN borrowers br ON t.borrower_id = br.id
       WHERE (
           (t.status = 'Returned' AND t.total_fine > 0 AND t.fine_paid = 0)
           OR
           (t.status IN ('Loaned', 'Overdue') AND t.due_date < CURDATE())
         )
         AND (? = '%%' OR
              br.firstname  LIKE ? OR
              br.lastname   LIKE ? OR
              br.id_no      LIKE ? OR
              b.title       LIKE ? OR
              b.barcode     LIKE ?)
       ORDER BY t.status DESC, t.due_date ASC`,
      [like, like, like, like, like, like]
    );

    const dailyFineRate = Number(process.env.DAILY_FINE_RATE || 5);
    const formattedRows = rows.map((row) => {
      if (row.loan_status === 'Overdue' || (row.loan_status === 'Loaned' && row.days_overdue > 0)) {
        const estimated = Number((row.days_overdue * dailyFineRate).toFixed(2));
        return { ...row, loan_status: 'Overdue', total_fine: estimated };
      }
      return row;
    });

    res.json(formattedRows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ── GET /api/fines/payments ───────────────────────────────────────────────────
// Full payment history with borrower and book details
router.get('/payments', async (req, res) => {
  try {
    const { search = '' } = req.query;
    const pool = getDb();
    const like = `%${String(search).trim()}%`;

    const [rows] = await pool.query(
      `SELECT
         fp.id,
         fp.receipt_no,
         fp.transaction_id,
         fp.fine_amount,
         fp.amount_paid,
         fp.change_given,
         fp.payment_type,
         fp.payment_status,
         fp.received_by_user_id,
         fp.notes,
         fp.paid_at,
         t.loan_date,
         t.due_date,
         t.return_date,
         b.title           AS book_title,
         b.barcode         AS book_barcode,
         CONCAT(br.firstname, ' ', br.lastname) AS borrower_name,
         br.id_no          AS borrower_id_no
       FROM fine_payments fp
       INNER JOIN transactions t  ON fp.transaction_id = t.id
       INNER JOIN books        b  ON t.book_id         = b.id
       INNER JOIN borrowers    br ON t.borrower_id     = br.id
       WHERE (? = '%%' OR
              fp.receipt_no   LIKE ? OR
              br.firstname    LIKE ? OR
              br.lastname     LIKE ? OR
              br.id_no        LIKE ? OR
              b.title         LIKE ?)
       ORDER BY fp.paid_at DESC`,
      [like, like, like, like, like, like]
    );

    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ── POST /api/fines/pay ───────────────────────────────────────────────────────
// Process a cash fine payment. Body: { transaction_id, amount_paid, notes? }
router.post('/pay', async (req, res) => {
  const pool = getDb();
  const conn = await pool.getConnection();
  try {
    const { transaction_id, amount_paid, notes } = req.body;
    const receivedBy = req.user.user_id;

    // ── Validate input ────────────────────────────────────────────────────────
    if (!transaction_id) {
      return res.status(400).json({ error: 'transaction_id is required' });
    }
    const amountPaidNum = parseFloat(amount_paid);
    if (isNaN(amountPaidNum) || amountPaidNum <= 0) {
      return res.status(400).json({ error: 'amount_paid must be a positive number' });
    }

    // ── Fetch transaction ─────────────────────────────────────────────────────
    const [[tx]] = await conn.query(
      `SELECT t.id, t.total_fine, t.fine_paid, t.status, t.due_date,
              CONCAT(br.firstname, ' ', br.lastname) AS borrower_name,
              br.id_no AS borrower_id_no,
              b.title  AS book_title
       FROM transactions t
       INNER JOIN borrowers br ON t.borrower_id = br.id
       INNER JOIN books     b  ON t.book_id     = b.id
       WHERE t.id = ?`,
      [transaction_id]
    );

    if (!tx) {
      return res.status(404).json({ error: 'Transaction not found' });
    }
    if (tx.fine_paid === 1) {
      return res.status(400).json({ error: 'Fine has already been paid for this transaction' });
    }

    let fineAmount = Number(tx.total_fine);
    let wasOverdue = false;

    // Dynamically calculate fine if still overdue
    if (['Loaned', 'Overdue'].includes(tx.status) && fineAmount === 0) {
      const dueDate = new Date(tx.due_date);
      // Use UTC to calculate days accurately to avoid timezone offset issues
      const now = new Date();
      const utcNow = Date.UTC(now.getFullYear(), now.getMonth(), now.getDate());
      const utcDue = Date.UTC(dueDate.getFullYear(), dueDate.getMonth(), dueDate.getDate());
      const overdueDays = Math.max(Math.floor((utcNow - utcDue) / (1000 * 60 * 60 * 24)), 0);
      
      if (overdueDays > 0) {
        const dailyFineRate = Number(process.env.DAILY_FINE_RATE || 5);
        fineAmount = Number((overdueDays * dailyFineRate).toFixed(2));
        wasOverdue = true;
      }
    }

    if (fineAmount === 0) {
      return res.status(400).json({ error: 'This transaction has no outstanding fine' });
    }
    if (amountPaidNum < fineAmount) {
      return res.status(400).json({
        error: `Amount paid (${amountPaidNum.toFixed(2)}) is less than the fine amount (${fineAmount.toFixed(2)})`,
      });
    }

    // If it was overdue, check it in first using the stored procedure
    // Note: sp_checkin_book commits its own transaction
    if (wasOverdue) {
      const returnDate = new Date().toISOString().split('T')[0];
      await conn.query('CALL sp_checkin_book(?, ?, ?, 0, ?)', [
        transaction_id, returnDate, fineAmount, 'Auto-returned during fine payment'
      ]);
    }

    // Start transaction for payment recording
    await conn.beginTransaction();

    const changeGiven = parseFloat((amountPaidNum - fineAmount).toFixed(2));

    // ── Insert payment record ─────────────────────────────────────────────────
    const [insertResult] = await conn.query(
      `INSERT INTO fine_payments
         (transaction_id, fine_amount, amount_paid, change_given,
          payment_type, payment_status, received_by_user_id, receipt_no, notes, paid_at)
       VALUES (?, ?, ?, ?, 'Cash', 'Paid', ?, '', ?, NOW())`,
      [transaction_id, fineAmount, amountPaidNum, changeGiven, receivedBy, notes || null]
    );

    const newId = insertResult.insertId;

    // ── Generate and store receipt number ─────────────────────────────────────
    const receiptNo = generateReceiptNo(newId);
    await conn.query(`UPDATE fine_payments SET receipt_no = ? WHERE id = ?`, [receiptNo, newId]);

    // ── Mark fine as paid on transaction ─────────────────────────────────────
    await conn.query(`UPDATE transactions SET fine_paid = 1 WHERE id = ?`, [transaction_id]);

    await conn.commit();

    // ── Return full payment record ────────────────────────────────────────────
    const [[payment]] = await conn.query(
      `SELECT fp.*, t.loan_date, t.due_date, t.return_date,
              b.title  AS book_title, b.barcode AS book_barcode,
              CONCAT(br.firstname,' ',br.lastname) AS borrower_name,
              br.id_no AS borrower_id_no
       FROM fine_payments fp
       INNER JOIN transactions t  ON fp.transaction_id = t.id
       INNER JOIN books        b  ON t.book_id         = b.id
       INNER JOIN borrowers    br ON t.borrower_id     = br.id
       WHERE fp.id = ?`,
      [newId]
    );

    res.status(201).json(payment);
  } catch (err) {
    await conn.rollback();
    res.status(500).json({ error: err.message });
  } finally {
    conn.release();
  }
});

module.exports = router;

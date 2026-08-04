const express = require('express');
const { getDb } = require('../database/init');
const { authMiddleware, requireRoles } = require('../middleware/auth');

const router = express.Router();
router.use(authMiddleware);

// ── Student / Borrower: view own borrow history ──────────────────────────────
// This route is registered BEFORE the circulation-staff role guard so that
// students and borrowers can access it with just a valid JWT.
router.get('/my-borrows', async (req, res) => {
  try {
    const pool = getDb();
    const userIdNo = req.user.user_id; // users.user_id == borrowers.id_no

    const [rows] = await pool.query(
      `SELECT
         t.id,
         t.loan_date,
         t.due_date,
         t.return_date,
         t.fine_amount,
         t.past_due_fines,
         t.total_fine,
         t.notes,
         t.status,
         b.title      AS book_title,
         b.author     AS book_author,
         b.barcode    AS book_barcode,
         b.type       AS book_type,
         b.call_no    AS book_call_no,
         b.category   AS book_category,
         GREATEST(DATEDIFF(CURDATE(), t.due_date), 0) AS days_overdue
       FROM transactions t
       INNER JOIN books     b  ON t.book_id     = b.id
       INNER JOIN borrowers br ON t.borrower_id = br.id
       WHERE br.id_no = ?
       ORDER BY
         FIELD(t.status, 'Overdue', 'Loaned', 'Returned'),
         t.due_date ASC`,
      [userIdNo]
    );

    const dailyFineRate = Number(process.env.DAILY_FINE_RATE || 5);
    const formatted = rows.map((row) => ({
      ...row,
      accruing_fine:
        row.status !== 'Returned'
          ? Number((row.days_overdue * dailyFineRate).toFixed(2))
          : 0,
    }));

    res.json(formatted);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ── Circulation-staff routes (Librarian / Circulation In-Charge only) ─────────
router.use(requireRoles(['ADMIN', 'LIBRARIAN', 'CIRCULATION_IN_CHARGE']));

function parseIsoDate(value) {
  if (!value) return null;
  const d = new Date(value);
  if (Number.isNaN(d.getTime())) return null;
  return d;
}

function dayDiff(a, b) {
  const ms = 24 * 60 * 60 * 1000;
  return Math.floor((a.getTime() - b.getTime()) / ms);
}

// Active loans search for circulation return flow (search borrower or title)
router.get('/active-loans', async (req, res) => {
  try {
    const { search = '' } = req.query;
    const pool = getDb();
    const like = `%${String(search || '').trim()}%`;

    const [rows] = await pool.query(
      `SELECT
         t.id,
         t.loan_date,
         t.due_date,
         t.status,
         b.id AS book_id,
         b.title AS book_title,
         b.author AS book_author,
         b.barcode AS book_barcode,
         br.id AS borrower_id,
         br.id_no AS borrower_id_no,
         CONCAT(br.firstname, ' ', br.lastname) AS borrower_name,
         GREATEST(DATEDIFF(CURDATE(), t.due_date), 0) AS days_overdue
       FROM transactions t
       INNER JOIN books b ON t.book_id = b.id
       INNER JOIN borrowers br ON t.borrower_id = br.id
       WHERE t.status IN ('Loaned', 'Overdue')
         AND (? = '%%' OR
              b.title LIKE ? OR
              b.author LIKE ? OR
              b.barcode LIKE ? OR
              br.firstname LIKE ? OR
              br.lastname LIKE ? OR
              br.id_no LIKE ?)
       ORDER BY t.due_date ASC, b.title ASC`,
      [like, like, like, like, like, like, like]
    );

    const dailyFineRate = Number(process.env.DAILY_FINE_RATE || 5);
    const formatted = rows.map((row) => ({
      ...row,
      current_status: row.days_overdue > 0 ? 'Overdue' : 'Loaned',
      suggested_fine: Number((row.days_overdue * dailyFineRate).toFixed(2)),
    }));

    res.json(formatted);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Overdue monitoring list
router.get('/overdue', async (req, res) => {
  try {
    const pool = getDb();
    const [rows] = await pool.query(
      `SELECT
         t.id,
         t.loan_date,
         t.due_date,
         b.title AS book_title,
         CONCAT(br.firstname, ' ', br.lastname) AS borrower_name,
         br.id_no AS borrower_id_no,
         GREATEST(DATEDIFF(CURDATE(), t.due_date), 1) AS days_overdue
       FROM transactions t
       INNER JOIN books b ON t.book_id = b.id
       INNER JOIN borrowers br ON t.borrower_id = br.id
       WHERE t.status IN ('Loaned', 'Overdue')
         AND t.due_date < CURDATE()
       ORDER BY t.due_date ASC`
    );

    const dailyFineRate = Number(process.env.DAILY_FINE_RATE || 5);
    res.json(
      rows.map((row) => ({
        ...row,
        estimated_fine: Number((row.days_overdue * dailyFineRate).toFixed(2)),
      }))
    );
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get all transactions with optional filters
router.get('/', async (req, res) => {
  try {
    const { status = null, borrower_id = null, search = null } = req.query;
    const pool = getDb();
    const [results] = await pool.query('CALL sp_get_all_transactions(?, ?, ?)', [
      status || null, borrower_id ? parseInt(borrower_id) : null, search || null,
    ]);
    res.json(results[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get active loans for a specific borrower
router.get('/borrower/:borrower_id', async (req, res) => {
  try {
    const pool = getDb();
    const [results] = await pool.query('CALL sp_get_borrower_loans(?)', [req.params.borrower_id]);
    res.json(results[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Check-out (create loan)
router.post('/checkout', async (req, res) => {
  try {
    const pool = getDb();
    const { book_id, borrower_id, loan_date, due_date, notes } = req.body;
    if (!book_id || !borrower_id || !due_date) {
      return res.status(400).json({ error: 'Book, borrower, and due date are required' });
    }
    const [results] = await pool.query('CALL sp_checkout_book(?,?,?,?,?)', [
      book_id, borrower_id, loan_date || null, due_date, notes || null,
    ]);
    res.status(201).json(results[0][0]);
  } catch (err) {
    if (err.sqlState === '45000') return res.status(400).json({ error: err.message });
    res.status(500).json({ error: err.message });
  }
});

// Check-in (return book)
router.post('/checkin/:id', async (req, res) => {
  try {
    const pool = getDb();
    const { return_date, fine_amount, past_due_fines, notes } = req.body;

    let computedFineAmount = fine_amount;
    let computedPastDueFines = past_due_fines;
    const returnDateValue = return_date || new Date().toISOString().split('T')[0];

    if (computedFineAmount === undefined || computedPastDueFines === undefined) {
      const [txRows] = await pool.query(
        `SELECT id, due_date, status
         FROM transactions
         WHERE id = ?`,
        [req.params.id]
      );

      const tx = txRows[0];
      if (!tx) {
        return res.status(404).json({ error: 'Transaction not found' });
      }

      const dueDate = parseIsoDate(tx.due_date);
      const returnDate = parseIsoDate(returnDateValue);
      const overdueDays = dueDate && returnDate ? Math.max(dayDiff(returnDate, dueDate), 0) : 0;
      const dailyFineRate = Number(process.env.DAILY_FINE_RATE || 5);

      if (computedFineAmount === undefined) {
        computedFineAmount = Number((overdueDays * dailyFineRate).toFixed(2));
      }

      if (computedPastDueFines === undefined) {
        computedPastDueFines = 0;
      }
    }

    const [results] = await pool.query('CALL sp_checkin_book(?,?,?,?,?)', [
      req.params.id,
      returnDateValue || null,
      computedFineAmount,
      computedPastDueFines,
      notes || null,
    ]);
    const payload = results[0][0];
    res.json({
      ...payload,
      computedFineAmount: Number(computedFineAmount || 0),
      computedPastDueFines: Number(computedPastDueFines || 0),
      totalFine: Number((Number(computedFineAmount || 0) + Number(computedPastDueFines || 0)).toFixed(2)),
    });
  } catch (err) {
    if (err.sqlState === '45000') return res.status(400).json({ error: err.message });
    res.status(500).json({ error: err.message });
  }
});

// Renew / Extend loan
router.post('/renew/:id', async (req, res) => {
  try {
    const pool = getDb();
    const { new_due_date } = req.body;
    if (!new_due_date) return res.status(400).json({ error: 'New due date is required' });
    const [results] = await pool.query('CALL sp_renew_loan(?,?)', [req.params.id, new_due_date]);
    res.json(results[0][0]);
  } catch (err) {
    if (err.sqlState === '45000') return res.status(400).json({ error: err.message });
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;

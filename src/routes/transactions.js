const express = require('express');
const { getDb } = require('../database/init');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();
router.use(authMiddleware);

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
    const [results] = await pool.query('CALL sp_checkin_book(?,?,?,?,?)', [
      req.params.id,
      return_date || null,
      fine_amount !== undefined ? fine_amount : null,
      past_due_fines !== undefined ? past_due_fines : null,
      notes || null,
    ]);
    res.json(results[0][0]);
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

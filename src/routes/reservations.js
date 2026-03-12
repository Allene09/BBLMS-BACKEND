const express = require('express');
const { getDb } = require('../database/init');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();
router.use(authMiddleware);

// Get all reservations
router.get('/', async (req, res) => {
  try {
    const { status = null, borrower_id = null } = req.query;
    const pool = getDb();
    const [results] = await pool.query('CALL sp_get_all_reservations(?, ?)', [
      status || null, borrower_id ? parseInt(borrower_id) : null,
    ]);
    res.json(results[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get reservation stats for a book — before /:id
router.get('/book/:book_id/stats', async (req, res) => {
  try {
    const pool = getDb();
    const [results] = await pool.query('CALL sp_get_book_reservation_count(?)', [req.params.book_id]);
    res.json(results[0][0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Create reservation
router.post('/', async (req, res) => {
  try {
    const pool = getDb();
    const { book_id, borrower_id, reserved_for_days, notes } = req.body;
    if (!book_id || !borrower_id) {
      return res.status(400).json({ error: 'Book and borrower are required' });
    }
    const [results] = await pool.query('CALL sp_create_reservation(?,?,?,?)', [
      book_id, borrower_id, reserved_for_days || null, notes || null,
    ]);
    res.status(201).json(results[0][0]);
  } catch (err) {
    if (err.sqlState === '45000') return res.status(400).json({ error: err.message });
    res.status(500).json({ error: err.message });
  }
});

// Update reservation status
router.put('/:id', async (req, res) => {
  try {
    const pool = getDb();
    const { status, notes } = req.body;
    const [results] = await pool.query('CALL sp_update_reservation(?,?,?)', [
      req.params.id, status || null, notes !== undefined ? notes : null,
    ]);
    res.json(results[0][0]);
  } catch (err) {
    if (err.sqlState === '45000') return res.status(404).json({ error: err.message });
    res.status(500).json({ error: err.message });
  }
});

// Cancel reservation
router.delete('/:id', async (req, res) => {
  try {
    const pool = getDb();
    await pool.query('CALL sp_cancel_reservation(?)', [req.params.id]);
    res.json({ message: 'Reservation cancelled' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;

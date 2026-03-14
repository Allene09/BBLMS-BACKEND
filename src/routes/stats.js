const express = require('express');
const { getDb } = require('../database/init');

const router = express.Router();

// Public endpoint — no auth required (used on login page)
router.get('/', async (req, res) => {
  try {
    const pool = getDb();
    const [[books], [borrowers], [loans]] = await Promise.all([
      pool.query('SELECT COUNT(*) as count FROM books'),
      pool.query('SELECT COUNT(*) as count FROM borrowers'),
      pool.query("SELECT COUNT(*) as count FROM transactions WHERE LOWER(status) IN ('loaned', 'overdue')"),
    ]);
    res.json({
      totalBooks:     books[0].count,
      totalBorrowers: borrowers[0].count,
      activeLoans:    loans[0].count,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;

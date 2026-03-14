const express = require('express');
const { getDb } = require('../database/init');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();
router.use(authMiddleware);

router.get('/', async (req, res) => {
  try {
    const pool = getDb();

    const [[statsResults], [recentResults], [bookTypeResults], [borrowerTypeResults]] = await Promise.all([
      pool.query('CALL sp_get_dashboard_stats()'),
      pool.query('CALL sp_get_recent_loans()'),
      pool.query('CALL sp_get_books_by_type()'),
      pool.query('CALL sp_get_borrowers_by_type()'),
    ]);

    const stats = statsResults[0][0];

    res.json({
      totalBooks:         stats.totalBooks,
      totalBorrowers:     stats.totalBorrowers,
      activeBorrowers:    stats.activeBorrowers,
      activeLoans:        stats.activeLoans,
      overdueLoans:       stats.overdueLoans,
      activeReservations: stats.activeReservations,
      totalSuppliers:     stats.totalSuppliers,
      totalReturned:      stats.totalReturned,
      totalFines:         stats.totalFines,
      recentLoans:        recentResults[0],
      booksByType:        bookTypeResults[0],
      borrowersByType:    borrowerTypeResults[0],
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;

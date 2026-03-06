const express = require('express');
const { getDb } = require('../database/init');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();
router.use(authMiddleware);

router.get('/', (req, res) => {
  try {
    const db = getDb();

    const totalBooks = db.prepare('SELECT COUNT(*) as count FROM books').get().count;
    const totalBorrowers = db.prepare('SELECT COUNT(*) as count FROM borrowers').get().count;
    const activeBorrowers = db.prepare("SELECT COUNT(*) as count FROM borrowers WHERE status = 'Active'").get().count;
    const activeLoans = db.prepare("SELECT COUNT(*) as count FROM transactions WHERE status = 'Loaned'").get().count;
    const overdueLoans = db.prepare("SELECT COUNT(*) as count FROM transactions WHERE status = 'Loaned' AND due_date < date('now')").get().count;
    const activeReservations = db.prepare("SELECT COUNT(*) as count FROM reservations WHERE status = 'Active'").get().count;
    const totalSuppliers = db.prepare('SELECT COUNT(*) as count FROM suppliers').get().count;
    const totalReturned = db.prepare("SELECT COUNT(*) as count FROM transactions WHERE status = 'Returned'").get().count;
    const totalFines = db.prepare("SELECT COALESCE(SUM(total_fine), 0) as total FROM transactions").get().total;

    const recentLoans = db.prepare(`
      SELECT t.*, b.title as book_title, br.firstname || ' ' || br.lastname as borrower_name
      FROM transactions t
      JOIN books b ON t.book_id = b.id
      JOIN borrowers br ON t.borrower_id = br.id
      ORDER BY t.created_at DESC LIMIT 10
    `).all();

    const booksByType = db.prepare('SELECT type, COUNT(*) as count FROM books GROUP BY type').all();

    const borrowersByType = db.prepare('SELECT type, COUNT(*) as count FROM borrowers GROUP BY type').all();

    res.json({
      totalBooks,
      totalBorrowers,
      activeBorrowers,
      activeLoans,
      overdueLoans,
      activeReservations,
      totalSuppliers,
      totalReturned,
      totalFines,
      recentLoans,
      booksByType,
      borrowersByType,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;

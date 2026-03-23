const express = require('express');
const { getDb } = require('../database/init');
const { authMiddleware, requireRoles } = require('../middleware/auth');

const router = express.Router();
router.use(authMiddleware);
router.use(requireRoles(['ADMIN', 'ADMINISTRATOR', 'LIBRARIAN']));

function toDateOnly(value) {
  if (!value) return null;
  const raw = String(value).trim();
  return raw ? raw : null;
}

router.get('/transactions', async (req, res) => {
  try {
    const from = toDateOnly(req.query.from);
    const to = toDateOnly(req.query.to);
    const status = req.query.status ? String(req.query.status).trim() : '';
    const search = req.query.search ? String(req.query.search).trim() : '';

    const pool = getDb();
    const [rows] = await pool.query(
      `SELECT
         t.id,
         t.loan_date,
         t.due_date,
         t.return_date,
         t.status,
         t.total_fine,
         b.title AS book_title,
         b.barcode AS book_barcode,
         CONCAT(br.firstname, ' ', br.lastname) AS borrower_name,
         br.id_no AS borrower_id_no
       FROM transactions t
       INNER JOIN books b ON t.book_id = b.id
       INNER JOIN borrowers br ON t.borrower_id = br.id
       WHERE (? IS NULL OR DATE(t.loan_date) >= ?)
         AND (? IS NULL OR DATE(t.loan_date) <= ?)
         AND (? = '' OR t.status = ?)
         AND (? = '' OR
              b.title LIKE CONCAT('%', ?, '%') OR
              b.barcode LIKE CONCAT('%', ?, '%') OR
              br.firstname LIKE CONCAT('%', ?, '%') OR
              br.lastname LIKE CONCAT('%', ?, '%') OR
              br.id_no LIKE CONCAT('%', ?, '%'))
       ORDER BY t.created_at DESC`,
      [
        from, from,
        to, to,
        status, status,
        search, search, search, search, search, search,
      ]
    );

    const summary = rows.reduce(
      (acc, row) => {
        acc.totalTransactions += 1;
        if (row.status === 'Loaned') acc.activeLoans += 1;
        if (row.status === 'Overdue') acc.overdueLoans += 1;
        if (row.status === 'Returned') acc.returnedLoans += 1;
        acc.totalFine += Number(row.total_fine || 0);
        return acc;
      },
      {
        totalTransactions: 0,
        activeLoans: 0,
        overdueLoans: 0,
        returnedLoans: 0,
        totalFine: 0,
      }
    );

    summary.totalFine = Number(summary.totalFine.toFixed(2));

    res.json({ summary, rows });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.get('/overview', async (_req, res) => {
  try {
    const pool = getDb();

    const [[statsRows], [recentRows]] = await Promise.all([
      pool.query(
        `SELECT
           (SELECT COUNT(*) FROM books) AS totalBooks,
           (SELECT COUNT(*) FROM borrowers) AS totalBorrowers,
           (SELECT COUNT(*) FROM transactions) AS totalTransactions,
           (SELECT COUNT(*) FROM transactions WHERE status = 'Loaned') AS activeLoans,
           (SELECT COUNT(*) FROM transactions WHERE status = 'Overdue' OR (status = 'Loaned' AND due_date < CURDATE())) AS overdueLoans,
           (SELECT COALESCE(SUM(total_fine), 0) FROM transactions) AS totalFine`
      ),
      pool.query(
        `SELECT
           DATE(t.created_at) AS date,
           COUNT(*) AS transactions
         FROM transactions t
         WHERE t.created_at >= DATE_SUB(CURDATE(), INTERVAL 14 DAY)
         GROUP BY DATE(t.created_at)
         ORDER BY DATE(t.created_at) ASC`
      ),
    ]);

    res.json({
      stats: statsRows[0],
      recentTrend: recentRows,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;

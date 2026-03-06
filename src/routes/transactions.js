const express = require('express');
const { getDb } = require('../database/init');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();
router.use(authMiddleware);

// Get all transactions with optional filters
router.get('/', (req, res) => {
  try {
    const db = getDb();
    const { status, borrower_id, search } = req.query;
    let query = `
      SELECT t.*, b.title as book_title, b.barcode as book_barcode, b.author as book_author,
             br.firstname || ' ' || br.lastname as borrower_name, br.id_no as borrower_id_no
      FROM transactions t
      JOIN books b ON t.book_id = b.id
      JOIN borrowers br ON t.borrower_id = br.id
      WHERE 1=1
    `;
    const params = [];

    if (status) { query += ' AND t.status = ?'; params.push(status); }
    if (borrower_id) { query += ' AND t.borrower_id = ?'; params.push(borrower_id); }
    if (search) {
      query += ' AND (b.title LIKE ? OR b.barcode LIKE ? OR br.firstname LIKE ? OR br.lastname LIKE ?)';
      const s = `%${search}%`;
      params.push(s, s, s, s);
    }

    query += ' ORDER BY t.created_at DESC';
    res.json(db.prepare(query).all(...params));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get loans for a specific borrower
router.get('/borrower/:borrower_id', (req, res) => {
  try {
    const db = getDb();
    const loans = db.prepare(`
      SELECT t.*, b.title as book_title, b.barcode as book_barcode
      FROM transactions t
      JOIN books b ON t.book_id = b.id
      WHERE t.borrower_id = ? AND t.status IN ('Loaned', 'Overdue')
      ORDER BY t.due_date ASC
    `).all(req.params.borrower_id);
    res.json(loans);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Check-out (create loan)
router.post('/checkout', (req, res) => {
  try {
    const db = getDb();
    const { book_id, borrower_id, loan_date, due_date, notes } = req.body;

    if (!book_id || !borrower_id || !due_date) {
      return res.status(400).json({ error: 'Book, borrower, and due date are required' });
    }

    // Check book availability
    const book = db.prepare('SELECT * FROM books WHERE id = ?').get(book_id);
    if (!book) return res.status(404).json({ error: 'Book not found' });
    if (book.copies_available <= 0) return res.status(400).json({ error: 'No copies available' });

    // Check if borrower exists
    const borrower = db.prepare('SELECT * FROM borrowers WHERE id = ?').get(borrower_id);
    if (!borrower) return res.status(404).json({ error: 'Borrower not found' });

    // Create transaction
    const result = db.prepare(`
      INSERT INTO transactions (book_id, borrower_id, loan_date, due_date, notes, status)
      VALUES (?, ?, ?, ?, ?, 'Loaned')
    `).run(book_id, borrower_id, loan_date || new Date().toISOString().split('T')[0], due_date, notes || '');

    // Decrease available copies
    db.prepare('UPDATE books SET copies_available = copies_available - 1 WHERE id = ?').run(book_id);

    const transaction = db.prepare(`
      SELECT t.*, b.title as book_title, b.barcode as book_barcode,
             br.firstname || ' ' || br.lastname as borrower_name
      FROM transactions t
      JOIN books b ON t.book_id = b.id
      JOIN borrowers br ON t.borrower_id = br.id
      WHERE t.id = ?
    `).get(result.lastInsertRowid);

    res.status(201).json(transaction);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Check-in (return book)
router.post('/checkin/:id', (req, res) => {
  try {
    const db = getDb();
    const { return_date, fine_amount, past_due_fines, notes } = req.body;

    const transaction = db.prepare('SELECT * FROM transactions WHERE id = ?').get(req.params.id);
    if (!transaction) return res.status(404).json({ error: 'Transaction not found' });
    if (transaction.status === 'Returned') return res.status(400).json({ error: 'Book already returned' });

    const returnDateStr = return_date || new Date().toISOString().split('T')[0];
    const fineAmt = fine_amount || 0;
    const pastDue = past_due_fines || 0;
    const totalFine = fineAmt + pastDue;

    db.prepare(`
      UPDATE transactions
      SET return_date = ?, fine_amount = ?, past_due_fines = ?, total_fine = ?,
          status = 'Returned', notes = COALESCE(?, notes), updated_at = datetime('now')
      WHERE id = ?
    `).run(returnDateStr, fineAmt, pastDue, totalFine, notes, req.params.id);

    // Increase available copies
    db.prepare('UPDATE books SET copies_available = copies_available + 1 WHERE id = ?').run(transaction.book_id);

    const updated = db.prepare(`
      SELECT t.*, b.title as book_title, b.barcode as book_barcode,
             br.firstname || ' ' || br.lastname as borrower_name
      FROM transactions t
      JOIN books b ON t.book_id = b.id
      JOIN borrowers br ON t.borrower_id = br.id
      WHERE t.id = ?
    `).get(req.params.id);

    res.json(updated);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Renew / Extend loan
router.post('/renew/:id', (req, res) => {
  try {
    const db = getDb();
    const { new_due_date } = req.body;
    if (!new_due_date) return res.status(400).json({ error: 'New due date is required' });

    const transaction = db.prepare('SELECT * FROM transactions WHERE id = ?').get(req.params.id);
    if (!transaction) return res.status(404).json({ error: 'Transaction not found' });
    if (transaction.status === 'Returned') return res.status(400).json({ error: 'Book already returned' });

    db.prepare("UPDATE transactions SET due_date = ?, updated_at = datetime('now') WHERE id = ?").run(new_due_date, req.params.id);

    res.json(db.prepare('SELECT * FROM transactions WHERE id = ?').get(req.params.id));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;

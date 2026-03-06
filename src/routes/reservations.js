const express = require('express');
const { getDb } = require('../database/init');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();
router.use(authMiddleware);

// Get all reservations
router.get('/', (req, res) => {
  try {
    const db = getDb();
    const { status, borrower_id } = req.query;
    let query = `
      SELECT r.*, b.title as book_title, b.barcode as book_barcode, b.copies_available,
             br.firstname || ' ' || br.lastname as borrower_name, br.id_no as borrower_id_no
      FROM reservations r
      JOIN books b ON r.book_id = b.id
      JOIN borrowers br ON r.borrower_id = br.id
      WHERE 1=1
    `;
    const params = [];

    if (status) { query += ' AND r.status = ?'; params.push(status); }
    if (borrower_id) { query += ' AND r.borrower_id = ?'; params.push(borrower_id); }

    query += ' ORDER BY r.reserved_on DESC';
    res.json(db.prepare(query).all(...params));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Create reservation
router.post('/', (req, res) => {
  try {
    const db = getDb();
    const { book_id, borrower_id, reserved_for_days, notes } = req.body;

    if (!book_id || !borrower_id) {
      return res.status(400).json({ error: 'Book and borrower are required' });
    }

    const book = db.prepare('SELECT * FROM books WHERE id = ?').get(book_id);
    if (!book) return res.status(404).json({ error: 'Book not found' });

    const borrower = db.prepare('SELECT * FROM borrowers WHERE id = ?').get(borrower_id);
    if (!borrower) return res.status(404).json({ error: 'Borrower not found' });

    // Check for existing active reservation
    const existing = db.prepare(
      'SELECT * FROM reservations WHERE book_id = ? AND borrower_id = ? AND status = ?'
    ).get(book_id, borrower_id, 'Active');
    if (existing) return res.status(400).json({ error: 'Borrower already has an active reservation for this book' });

    const result = db.prepare(`
      INSERT INTO reservations (book_id, borrower_id, reserved_for_days, notes)
      VALUES (?, ?, ?, ?)
    `).run(book_id, borrower_id, reserved_for_days || 5, notes || '');

    const reservation = db.prepare(`
      SELECT r.*, b.title as book_title, b.barcode as book_barcode,
             br.firstname || ' ' || br.lastname as borrower_name
      FROM reservations r
      JOIN books b ON r.book_id = b.id
      JOIN borrowers br ON r.borrower_id = br.id
      WHERE r.id = ?
    `).get(result.lastInsertRowid);

    res.status(201).json(reservation);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Update reservation status
router.put('/:id', (req, res) => {
  try {
    const db = getDb();
    const { status, notes } = req.body;
    const reservation = db.prepare('SELECT * FROM reservations WHERE id = ?').get(req.params.id);
    if (!reservation) return res.status(404).json({ error: 'Reservation not found' });

    const updates = [];
    const values = [];
    if (status) { updates.push('status = ?'); values.push(status); }
    if (notes !== undefined) { updates.push('notes = ?'); values.push(notes); }
    updates.push("updated_at = datetime('now')");
    values.push(req.params.id);

    db.prepare(`UPDATE reservations SET ${updates.join(', ')} WHERE id = ?`).run(...values);
    res.json(db.prepare('SELECT * FROM reservations WHERE id = ?').get(req.params.id));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Cancel reservation
router.delete('/:id', (req, res) => {
  try {
    const db = getDb();
    db.prepare("UPDATE reservations SET status = 'Cancelled', updated_at = datetime('now') WHERE id = ?").run(req.params.id);
    res.json({ message: 'Reservation cancelled' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get reservation stats for a book
router.get('/book/:book_id/stats', (req, res) => {
  try {
    const db = getDb();
    const count = db.prepare(
      "SELECT COUNT(*) as count FROM reservations WHERE book_id = ? AND status = 'Active'"
    ).get(req.params.book_id);
    res.json(count);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;

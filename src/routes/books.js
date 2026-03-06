const express = require('express');
const { getDb } = require('../database/init');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();
router.use(authMiddleware);

// Get all books with optional search
router.get('/', (req, res) => {
  try {
    const db = getDb();
    const { search, type, circulation_type } = req.query;
    let query = 'SELECT * FROM books WHERE 1=1';
    const params = [];

    if (search) {
      query += ' AND (title LIKE ? OR author LIKE ? OR barcode LIKE ? OR isbn LIKE ? OR call_no LIKE ?)';
      const s = `%${search}%`;
      params.push(s, s, s, s, s);
    }
    if (type) {
      query += ' AND type = ?';
      params.push(type);
    }
    if (circulation_type) {
      query += ' AND circulation_type = ?';
      params.push(circulation_type);
    }

    query += ' ORDER BY title ASC';
    const books = db.prepare(query).all(...params);
    res.json(books);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get single book
router.get('/:id', (req, res) => {
  try {
    const db = getDb();
    const book = db.prepare('SELECT * FROM books WHERE id = ?').get(req.params.id);
    if (!book) return res.status(404).json({ error: 'Book not found' });
    res.json(book);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get book by barcode
router.get('/barcode/:barcode', (req, res) => {
  try {
    const db = getDb();
    const book = db.prepare('SELECT * FROM books WHERE barcode = ?').get(req.params.barcode);
    if (!book) return res.status(404).json({ error: 'Book not found' });
    res.json(book);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Create book
router.post('/', (req, res) => {
  try {
    const db = getDb();
    const {
      title, author, co_author, type, publisher, place, date_published,
      volume, series, category, format, editor, illustrator, pages, isbn,
      physical_desc, accession_no, call_no, barcode, location,
      circulation_type, price, value, purchased_date, evaluated_date,
      acquisition_date, copies_available
    } = req.body;

    if (!title) return res.status(400).json({ error: 'Title is required' });

    const result = db.prepare(`
      INSERT INTO books (title, author, co_author, type, publisher, place, date_published,
        volume, series, category, format, editor, illustrator, pages, isbn,
        physical_desc, accession_no, call_no, barcode, location,
        circulation_type, price, value, purchased_date, evaluated_date,
        acquisition_date, copies_available)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `).run(
      title, author || '', co_author || '', type || 'Book', publisher || '', place || '',
      date_published || '', volume || '', series || '', category || '', format || '',
      editor || '', illustrator || '', pages || '', isbn || '', physical_desc || '',
      accession_no || '', call_no || '', barcode || null, location || '',
      circulation_type || 'Loanable', price || 0, value || 0,
      purchased_date || '', evaluated_date || '', acquisition_date || '',
      copies_available || 1
    );

    const book = db.prepare('SELECT * FROM books WHERE id = ?').get(result.lastInsertRowid);
    res.status(201).json(book);
  } catch (err) {
    if (err.message.includes('UNIQUE constraint')) {
      return res.status(400).json({ error: 'A book with this barcode already exists' });
    }
    res.status(500).json({ error: err.message });
  }
});

// Update book
router.put('/:id', (req, res) => {
  try {
    const db = getDb();
    const existing = db.prepare('SELECT * FROM books WHERE id = ?').get(req.params.id);
    if (!existing) return res.status(404).json({ error: 'Book not found' });

    const fields = [
      'title', 'author', 'co_author', 'type', 'publisher', 'place', 'date_published',
      'volume', 'series', 'category', 'format', 'editor', 'illustrator', 'pages', 'isbn',
      'physical_desc', 'accession_no', 'call_no', 'barcode', 'location',
      'circulation_type', 'price', 'value', 'purchased_date', 'evaluated_date',
      'acquisition_date', 'copies_available'
    ];

    const updates = [];
    const values = [];
    for (const field of fields) {
      if (req.body[field] !== undefined) {
        updates.push(`${field} = ?`);
        values.push(req.body[field]);
      }
    }

    if (updates.length === 0) return res.status(400).json({ error: 'No fields to update' });

    updates.push("updated_at = datetime('now')");
    values.push(req.params.id);

    db.prepare(`UPDATE books SET ${updates.join(', ')} WHERE id = ?`).run(...values);
    const book = db.prepare('SELECT * FROM books WHERE id = ?').get(req.params.id);
    res.json(book);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Delete book
router.delete('/:id', (req, res) => {
  try {
    const db = getDb();
    const existing = db.prepare('SELECT * FROM books WHERE id = ?').get(req.params.id);
    if (!existing) return res.status(404).json({ error: 'Book not found' });

    db.prepare('DELETE FROM books WHERE id = ?').run(req.params.id);
    res.json({ message: 'Book deleted successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;

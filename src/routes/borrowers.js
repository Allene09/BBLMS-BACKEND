const express = require('express');
const { getDb } = require('../database/init');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();
router.use(authMiddleware);

// Get all borrowers
router.get('/', (req, res) => {
  try {
    const db = getDb();
    const { search, type, status } = req.query;
    let query = 'SELECT * FROM borrowers WHERE 1=1';
    const params = [];

    if (search) {
      query += ' AND (firstname LIKE ? OR lastname LIKE ? OR id_no LIKE ? OR email LIKE ?)';
      const s = `%${search}%`;
      params.push(s, s, s, s);
    }
    if (type) { query += ' AND type = ?'; params.push(type); }
    if (status) { query += ' AND status = ?'; params.push(status); }

    query += ' ORDER BY lastname ASC, firstname ASC';
    res.json(db.prepare(query).all(...params));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get single borrower
router.get('/:id', (req, res) => {
  try {
    const db = getDb();
    const borrower = db.prepare('SELECT * FROM borrowers WHERE id = ?').get(req.params.id);
    if (!borrower) return res.status(404).json({ error: 'Borrower not found' });
    res.json(borrower);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get borrower by ID number
router.get('/idno/:id_no', (req, res) => {
  try {
    const db = getDb();
    const borrower = db.prepare('SELECT * FROM borrowers WHERE id_no = ?').get(req.params.id_no);
    if (!borrower) return res.status(404).json({ error: 'Borrower not found' });
    res.json(borrower);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Create borrower
router.post('/', (req, res) => {
  try {
    const db = getDb();
    const { id_no, firstname, lastname, mobile_phone, phone, email, address, notes, type, status } = req.body;
    if (!id_no || !firstname || !lastname) {
      return res.status(400).json({ error: 'ID No, Firstname, and Lastname are required' });
    }

    const result = db.prepare(`
      INSERT INTO borrowers (id_no, firstname, lastname, mobile_phone, phone, email, address, notes, type, status)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `).run(id_no, firstname, lastname, mobile_phone || '', phone || '', email || '', address || '', notes || '', type || 'Student', status || 'Active');

    res.status(201).json(db.prepare('SELECT * FROM borrowers WHERE id = ?').get(result.lastInsertRowid));
  } catch (err) {
    if (err.message.includes('UNIQUE constraint')) {
      return res.status(400).json({ error: 'A borrower with this ID number already exists' });
    }
    res.status(500).json({ error: err.message });
  }
});

// Update borrower
router.put('/:id', (req, res) => {
  try {
    const db = getDb();
    const existing = db.prepare('SELECT * FROM borrowers WHERE id = ?').get(req.params.id);
    if (!existing) return res.status(404).json({ error: 'Borrower not found' });

    const fields = ['id_no', 'firstname', 'lastname', 'mobile_phone', 'phone', 'email', 'address', 'notes', 'type', 'status'];
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
    db.prepare(`UPDATE borrowers SET ${updates.join(', ')} WHERE id = ?`).run(...values);
    res.json(db.prepare('SELECT * FROM borrowers WHERE id = ?').get(req.params.id));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Delete borrower
router.delete('/:id', (req, res) => {
  try {
    const db = getDb();
    const existing = db.prepare('SELECT * FROM borrowers WHERE id = ?').get(req.params.id);
    if (!existing) return res.status(404).json({ error: 'Borrower not found' });

    db.prepare('DELETE FROM borrowers WHERE id = ?').run(req.params.id);
    res.json({ message: 'Borrower deleted successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;

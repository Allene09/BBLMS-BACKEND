const express = require('express');
const { getDb } = require('../database/init');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();
router.use(authMiddleware);

// Get all suppliers
router.get('/', (req, res) => {
  try {
    const db = getDb();
    const { search } = req.query;
    let query = 'SELECT * FROM suppliers WHERE 1=1';
    const params = [];

    if (search) {
      query += ' AND (company_name LIKE ? OR sup_code LIKE ? OR contact_person LIKE ?)';
      const s = `%${search}%`;
      params.push(s, s, s);
    }
    query += ' ORDER BY company_name ASC';
    res.json(db.prepare(query).all(...params));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get single supplier
router.get('/:id', (req, res) => {
  try {
    const db = getDb();
    const supplier = db.prepare('SELECT * FROM suppliers WHERE id = ?').get(req.params.id);
    if (!supplier) return res.status(404).json({ error: 'Supplier not found' });
    res.json(supplier);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Create supplier
router.post('/', (req, res) => {
  try {
    const db = getDb();
    const { sup_code, company_name, address, phone, fax_no, mobile_phone, email, web_site, contact_person, position, gender } = req.body;
    if (!sup_code || !company_name) {
      return res.status(400).json({ error: 'Supplier code and company name are required' });
    }

    const result = db.prepare(`
      INSERT INTO suppliers (sup_code, company_name, address, phone, fax_no, mobile_phone, email, web_site, contact_person, position, gender)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `).run(sup_code, company_name, address || '', phone || '', fax_no || '', mobile_phone || '', email || '', web_site || '', contact_person || '', position || '', gender || 'Male');

    res.status(201).json(db.prepare('SELECT * FROM suppliers WHERE id = ?').get(result.lastInsertRowid));
  } catch (err) {
    if (err.message.includes('UNIQUE constraint')) {
      return res.status(400).json({ error: 'A supplier with this code already exists' });
    }
    res.status(500).json({ error: err.message });
  }
});

// Update supplier
router.put('/:id', (req, res) => {
  try {
    const db = getDb();
    const existing = db.prepare('SELECT * FROM suppliers WHERE id = ?').get(req.params.id);
    if (!existing) return res.status(404).json({ error: 'Supplier not found' });

    const fields = ['sup_code', 'company_name', 'address', 'phone', 'fax_no', 'mobile_phone', 'email', 'web_site', 'contact_person', 'position', 'gender'];
    const updates = [];
    const values = [];
    for (const field of fields) {
      if (req.body[field] !== undefined) { updates.push(`${field} = ?`); values.push(req.body[field]); }
    }
    if (updates.length === 0) return res.status(400).json({ error: 'No fields to update' });

    updates.push("updated_at = datetime('now')");
    values.push(req.params.id);
    db.prepare(`UPDATE suppliers SET ${updates.join(', ')} WHERE id = ?`).run(...values);
    res.json(db.prepare('SELECT * FROM suppliers WHERE id = ?').get(req.params.id));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Delete supplier
router.delete('/:id', (req, res) => {
  try {
    const db = getDb();
    db.prepare('DELETE FROM suppliers WHERE id = ?').run(req.params.id);
    res.json({ message: 'Supplier deleted successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;

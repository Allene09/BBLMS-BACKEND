const express = require('express');
const { getDb } = require('../database/init');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();
router.use(authMiddleware);

// Get all suppliers
router.get('/', async (req, res) => {
  try {
    const { search = null } = req.query;
    const pool = getDb();
    const [results] = await pool.query('CALL sp_get_all_suppliers(?)', [search || null]);
    res.json(results[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get single supplier
router.get('/:id', async (req, res) => {
  try {
    const pool = getDb();
    const [results] = await pool.query('CALL sp_get_supplier_by_id(?)', [req.params.id]);
    const supplier = results[0][0];
    if (!supplier) return res.status(404).json({ error: 'Supplier not found' });
    res.json(supplier);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Create supplier
router.post('/', async (req, res) => {
  try {
    const pool = getDb();
    const { sup_code, company_name, address, phone, fax_no, mobile_phone, email, web_site, contact_person, position, gender } = req.body;
    if (!sup_code || !company_name) {
      return res.status(400).json({ error: 'Supplier code and company name are required' });
    }
    const [results] = await pool.query('CALL sp_create_supplier(?,?,?,?,?,?,?,?,?,?,?)', [
      sup_code, company_name,
      address || null, phone || null, fax_no || null, mobile_phone || null,
      email || null, web_site || null, contact_person || null, position || null, gender || null,
    ]);
    res.status(201).json(results[0][0]);
  } catch (err) {
    if (err.code === 'ER_DUP_ENTRY') {
      return res.status(400).json({ error: 'A supplier with this code already exists' });
    }
    res.status(500).json({ error: err.message });
  }
});

// Update supplier
router.put('/:id', async (req, res) => {
  try {
    const pool = getDb();
    const { sup_code, company_name, address, phone, fax_no, mobile_phone, email, web_site, contact_person, position, gender } = req.body;
    const [results] = await pool.query('CALL sp_update_supplier(?,?,?,?,?,?,?,?,?,?,?,?)', [
      req.params.id,
      sup_code || null, company_name || null,
      address || null, phone || null, fax_no || null, mobile_phone || null,
      email || null, web_site || null, contact_person || null, position || null, gender || null,
    ]);
    const supplier = results[0][0];
    if (!supplier) return res.status(404).json({ error: 'Supplier not found' });
    res.json(supplier);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Delete supplier
router.delete('/:id', async (req, res) => {
  try {
    const pool = getDb();
    await pool.query('CALL sp_delete_supplier(?)', [req.params.id]);
    res.json({ message: 'Supplier deleted successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;

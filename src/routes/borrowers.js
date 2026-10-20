const express = require('express');
const { getDb } = require('../database/init');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();
router.use(authMiddleware);

// Get all borrowers
router.get('/', async (req, res) => {
  try {
    const { search = null, type = null, status = null } = req.query;
    const pool = getDb();
    const [results] = await pool.query('CALL sp_get_all_borrowers(?, ?, ?)', [
      search || null, type || null, status || null,
    ]);
    res.json(results[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get borrower by ID number — must be BEFORE /:id
router.get('/idno/:id_no', async (req, res) => {
  try {
    const pool = getDb();
    const [results] = await pool.query('CALL sp_get_borrower_by_idno(?)', [req.params.id_no]);
    const borrower = results[0][0];
    if (!borrower) return res.status(404).json({ error: 'Borrower not found' });
    res.json(borrower);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get single borrower
router.get('/:id', async (req, res) => {
  try {
    const pool = getDb();
    const [results] = await pool.query('CALL sp_get_borrower_by_id(?)', [req.params.id]);
    const borrower = results[0][0];
    if (!borrower) return res.status(404).json({ error: 'Borrower not found' });
    res.json(borrower);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Create borrower
router.post('/', async (req, res) => {
  try {
    const pool = getDb();
    const { id_no, firstname, lastname, mobile_phone, phone, email, address, notes, type, status } = req.body;
    if (!id_no || !firstname || !lastname) {
      return res.status(400).json({ error: 'ID No, Firstname, and Lastname are required' });
    }
    const [results] = await pool.query('CALL sp_create_borrower(?,?,?,?,?,?,?,?,?,?)', [
      id_no, firstname, lastname,
      mobile_phone || null, phone || null, email || null,
      address || null, notes || null, type || null, status || null,
    ]);
    res.status(201).json(results[0][0]);
  } catch (err) {
    if (err.code === 'ER_DUP_ENTRY') {
      return res.status(400).json({ error: 'A borrower with this ID number already exists' });
    }
    res.status(500).json({ error: err.message });
  }
});

// Update borrower
router.put('/:id', async (req, res) => {
  try {
    const pool = getDb();
    const { id_no, firstname, lastname, mobile_phone, phone, email, address, notes, type, status } = req.body;
    const [results] = await pool.query('CALL sp_update_borrower(?,?,?,?,?,?,?,?,?,?,?)', [
      req.params.id,
      id_no || null, firstname || null, lastname || null,
      mobile_phone || null, phone || null, email || null,
      address || null, notes || null, type || null, status || null,
    ]);
    const borrower = results[0][0];
    if (!borrower) return res.status(404).json({ error: 'Borrower not found' });
    res.json(borrower);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Delete borrower
router.delete('/:id', async (req, res) => {
  try {
    const pool = getDb();
    await pool.query('CALL sp_delete_borrower(?)', [req.params.id]);
    res.json({ message: 'Borrower deleted successfully' });
  } catch (err) {
    if (err.sqlState === '45000') return res.status(404).json({ error: err.message });
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;

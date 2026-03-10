const express = require('express');
const bcrypt = require('bcryptjs');
const { getDb } = require('../database/init');
const { authMiddleware, adminMiddleware } = require('../middleware/auth');

const router = express.Router();
router.use(authMiddleware);
router.use(adminMiddleware);

// Get all users
router.get('/', async (req, res) => {
  try {
    const pool = getDb();
    const [results] = await pool.query('CALL sp_get_all_users()');
    res.json(results[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Create user
router.post('/', async (req, res) => {
  try {
    const pool = getDb();
    const { user_id, username, password, designation, access_right, is_admin } = req.body;
    if (!user_id || !username || !password) {
      return res.status(400).json({ error: 'User ID, username, and password are required' });
    }
    const hashedPassword = bcrypt.hashSync(password, 10);
    const [results] = await pool.query('CALL sp_create_user(?,?,?,?,?,?)', [
      user_id, username, hashedPassword,
      designation || null, access_right || null, is_admin ? 1 : 0,
    ]);
    res.status(201).json(results[0][0]);
  } catch (err) {
    if (err.code === 'ER_DUP_ENTRY') {
      return res.status(400).json({ error: 'User ID already exists' });
    }
    res.status(500).json({ error: err.message });
  }
});

// Update user
router.put('/:id', async (req, res) => {
  try {
    const pool = getDb();
    const { username, password, designation, access_right, is_admin } = req.body;
    const hashedPassword = password ? bcrypt.hashSync(password, 10) : null;
    const [results] = await pool.query('CALL sp_update_user(?,?,?,?,?,?)', [
      req.params.id,
      username || null,
      hashedPassword,
      designation !== undefined ? designation : null,
      access_right || null,
      is_admin !== undefined ? (is_admin ? 1 : 0) : null,
    ]);
    const user = results[0][0];
    if (!user) return res.status(404).json({ error: 'User not found' });
    res.json(user);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Delete user
router.delete('/:id', async (req, res) => {
  try {
    const pool = getDb();
    await pool.query('CALL sp_delete_user(?)', [req.params.id]);
    res.json({ message: 'User deleted successfully' });
  } catch (err) {
    if (err.sqlState === '45000') return res.status(400).json({ error: err.message });
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;

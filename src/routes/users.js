const express = require('express');
const bcrypt = require('bcryptjs');
const { getDb } = require('../database/init');
const { authMiddleware, adminMiddleware } = require('../middleware/auth');

const router = express.Router();
router.use(authMiddleware);
router.use(adminMiddleware);

// Get all users
router.get('/', (req, res) => {
  try {
    const db = getDb();
    const users = db.prepare('SELECT id, user_id, username, designation, access_right, is_admin, created_at FROM users ORDER BY user_id').all();
    res.json(users);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Create user
router.post('/', (req, res) => {
  try {
    const db = getDb();
    const { user_id, username, password, designation, access_right, is_admin } = req.body;
    if (!user_id || !username || !password) {
      return res.status(400).json({ error: 'User ID, username, and password are required' });
    }

    const hashedPassword = bcrypt.hashSync(password, 10);
    const result = db.prepare(`
      INSERT INTO users (user_id, username, password, designation, access_right, is_admin)
      VALUES (?, ?, ?, ?, ?, ?)
    `).run(user_id, username, hashedPassword, designation || '', access_right || 'USER', is_admin ? 1 : 0);

    const user = db.prepare('SELECT id, user_id, username, designation, access_right, is_admin FROM users WHERE id = ?').get(result.lastInsertRowid);
    res.status(201).json(user);
  } catch (err) {
    if (err.message.includes('UNIQUE constraint')) {
      return res.status(400).json({ error: 'User ID already exists' });
    }
    res.status(500).json({ error: err.message });
  }
});

// Update user
router.put('/:id', (req, res) => {
  try {
    const db = getDb();
    const existing = db.prepare('SELECT * FROM users WHERE id = ?').get(req.params.id);
    if (!existing) return res.status(404).json({ error: 'User not found' });

    const { username, password, designation, access_right, is_admin } = req.body;
    const updates = [];
    const values = [];

    if (username) { updates.push('username = ?'); values.push(username); }
    if (password) { updates.push('password = ?'); values.push(bcrypt.hashSync(password, 10)); }
    if (designation !== undefined) { updates.push('designation = ?'); values.push(designation); }
    if (access_right) { updates.push('access_right = ?'); values.push(access_right); }
    if (is_admin !== undefined) { updates.push('is_admin = ?'); values.push(is_admin ? 1 : 0); }

    if (updates.length === 0) return res.status(400).json({ error: 'No fields to update' });

    updates.push("updated_at = datetime('now')");
    values.push(req.params.id);
    db.prepare(`UPDATE users SET ${updates.join(', ')} WHERE id = ?`).run(...values);

    const user = db.prepare('SELECT id, user_id, username, designation, access_right, is_admin FROM users WHERE id = ?').get(req.params.id);
    res.json(user);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Delete user
router.delete('/:id', (req, res) => {
  try {
    const db = getDb();
    const user = db.prepare('SELECT * FROM users WHERE id = ?').get(req.params.id);
    if (!user) return res.status(404).json({ error: 'User not found' });
    if (user.user_id === 'ADMIN') return res.status(400).json({ error: 'Cannot delete the default admin account' });

    db.prepare('DELETE FROM users WHERE id = ?').run(req.params.id);
    res.json({ message: 'User deleted successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;

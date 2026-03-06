const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { getDb } = require('../database/init');

const router = express.Router();

// Login
router.post('/login', (req, res) => {
  try {
    const { user_id, password } = req.body;
    if (!user_id || !password) {
      return res.status(400).json({ error: 'User ID and password are required.' });
    }

    const db = getDb();
    const user = db.prepare('SELECT * FROM users WHERE user_id = ?').get(user_id);

    if (!user) {
      return res.status(401).json({ error: 'Invalid credentials.' });
    }

    const validPassword = bcrypt.compareSync(password, user.password);
    if (!validPassword) {
      return res.status(401).json({ error: 'Invalid credentials.' });
    }

    const token = jwt.sign(
      { id: user.id, user_id: user.user_id, username: user.username, access_right: user.access_right, is_admin: user.is_admin },
      process.env.JWT_SECRET,
      { expiresIn: '8h' }
    );

    res.json({
      token,
      user: {
        id: user.id,
        user_id: user.user_id,
        username: user.username,
        designation: user.designation,
        access_right: user.access_right,
        is_admin: user.is_admin,
      },
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get current user
router.get('/me', (req, res) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader) return res.status(401).json({ error: 'No token' });

    const token = authHeader.split(' ')[1];
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const db = getDb();
    const user = db.prepare('SELECT id, user_id, username, designation, access_right, is_admin FROM users WHERE id = ?').get(decoded.id);

    if (!user) return res.status(404).json({ error: 'User not found' });
    res.json(user);
  } catch (err) {
    res.status(401).json({ error: 'Invalid token' });
  }
});

module.exports = router;

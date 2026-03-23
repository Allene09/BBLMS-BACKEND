const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { getDb } = require('../database/init');

const router = express.Router();

// Login
router.post('/login', async (req, res) => {
  try {
    const { user_id, password } = req.body;
    if (!user_id || !password) {
      return res.status(400).json({ error: 'User ID and password are required.' });
    }

    const pool = getDb();
    const [results] = await pool.query('CALL sp_user_login(?)', [user_id]);
    const user = results[0][0];

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
        is_admin: user.is_admin ? 1 : 0,
      },
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Sign Up - Register new user and borrower
router.post('/signup', async (req, res) => {
  return res.status(403).json({ error: 'Self-signup is disabled. Please contact the administrator.' });

  try {
    const pool = getDb();
    const {
      id_no, firstname, lastname, password,
      mobile_phone, phone, email, address, notes, type
    } = req.body;

    // Validation
    if (!id_no || !firstname || !lastname || !password) {
      return res.status(400).json({ error: 'ID No, Firstname, Lastname, and Password are required.' });
    }

    if (password.length < 6) {
      return res.status(400).json({ error: 'Password must be at least 6 characters.' });
    }

    // Check if user/borrower already exists
    const [existingUser] = await pool.query('SELECT id FROM users WHERE user_id = ?', [id_no]);
    if (existingUser[0]) {
      return res.status(400).json({ error: 'A user with this ID already exists.' });
    }

    const [existingBorrower] = await pool.query('SELECT id FROM borrowers WHERE id_no = ?', [id_no]);
    if (existingBorrower[0]) {
      return res.status(400).json({ error: 'A borrower with this ID already exists.' });
    }

    // Create user account
    const hashedPassword = bcrypt.hashSync(password, 10);
    const username = `${firstname} ${lastname}`.trim();
    
    const [userResult] = await pool.query('CALL sp_create_user(?,?,?,?,?,?)', [
      id_no, username, hashedPassword, null, 'USER', 0
    ]);
    
    // Create borrower record
    const [borrowerResult] = await pool.query('CALL sp_create_borrower(?,?,?,?,?,?,?,?,?,?)', [
      id_no, firstname, lastname,
      mobile_phone || null, phone || null, email || null,
      address || null, notes || null, type || 'STUDENT', 'ACTIVE'
    ]);

    res.status(201).json({ 
      message: 'Account created successfully! You can now sign in.',
      user_id: id_no
    });
  } catch (err) {
    if (err.code === 'ER_DUP_ENTRY') {
      return res.status(400).json({ error: 'An account with this ID already exists.' });
    }
    res.status(500).json({ error: err.message });
  }
});

// Get current user
router.get('/me', async (req, res) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader) return res.status(401).json({ error: 'No token' });

    const token = authHeader.split(' ')[1];
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const pool = getDb();
    const [results] = await pool.query('CALL sp_get_current_user(?)', [decoded.id]);
    const user = results[0][0];

    if (!user) return res.status(404).json({ error: 'User not found' });
    res.json(user);
  } catch (err) {
    res.status(401).json({ error: 'Invalid token' });
  }
});

module.exports = router;

const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { getDb } = require('../database/init');

const router = express.Router();

function normalizeBorrowerType(type) {
  const value = String(type || 'Student').trim().toLowerCase();
  if (value === 'faculty') return 'Faculty';
  if (value === 'others' || value === 'other') return 'Others';
  return 'Student';
}

function normalizeAccountStatus(status) {
  return String(status || 'APPROVED').trim().toUpperCase();
}

function splitFullName(fullName = '') {
  const parts = String(fullName || '').trim().split(/\s+/).filter(Boolean);
  if (parts.length <= 1) {
    return { firstname: parts[0] || '', lastname: '' };
  }

  return {
    firstname: parts[0],
    lastname: parts.slice(1).join(' '),
  };
}

// Login
router.post('/login', async (req, res) => {
  try {
    const { user_id, password } = req.body;
    if (!user_id || !password) {
      return res.status(400).json({ error: 'User ID and password are required.' });
    }

    const pool = getDb();
    const [results] = await pool.query(
      `SELECT
         id,
         user_id,
         username,
         password,
         designation,
         access_right,
         is_admin,
         status
       FROM users
       WHERE user_id = ?
       LIMIT 1`,
      [user_id]
    );
    const user = results[0];

    if (!user) {
      return res.status(401).json({ error: 'Invalid credentials.' });
    }

    const accountStatus = normalizeAccountStatus(user.status);
    if (accountStatus === 'PENDING') {
      return res.status(403).json({ error: 'Your account is pending admin approval.' });
    }
    if (accountStatus === 'DENIED') {
      return res.status(403).json({ error: 'Your account was denied by the administrator.' });
    }

    const validPassword = bcrypt.compareSync(password, user.password);
    if (!validPassword) {
      return res.status(401).json({ error: 'Invalid credentials.' });
    }

    const token = jwt.sign(
      {
        id: user.id,
        user_id: user.user_id,
        username: user.username,
        access_right: user.access_right,
        is_admin: user.is_admin,
        status: accountStatus,
      },
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
        status: accountStatus,
      },
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Sign Up - Register new user and borrower
router.post('/signup', async (req, res) => {
  try {
    const pool = getDb();
    const {
      id_no, firstname, middle_name, lastname, gender, college,
      mobile_phone, phone, email, address, notes, type
    } = req.body;

    // Validation
    if (!id_no || !firstname || !lastname) {
      return res.status(400).json({ error: 'ID No, Firstname, and Lastname are required.' });
    }

    const hashedPassword = bcrypt.hashSync('bisu123', 10);
    const username = `${firstname} ${lastname}`.trim();
    const borrowerType = normalizeBorrowerType(type);
    const conn = await pool.getConnection();

    try {
      await conn.beginTransaction();

      const [existingUserRows] = await conn.query(
        'SELECT id, status FROM users WHERE user_id = ? LIMIT 1',
        [id_no]
      );
      const existingUser = existingUserRows[0] || null;
      const existingStatus = normalizeAccountStatus(existingUser?.status);

      if (existingUser && existingStatus === 'APPROVED') {
        await conn.rollback();
        conn.release();
        return res.status(400).json({ error: 'An account with this ID already exists.' });
      }

      if (existingUser && existingStatus === 'PENDING') {
        await conn.rollback();
        conn.release();
        return res.status(400).json({ error: 'This account is already pending admin approval.' });
      }

      if (existingUser) {
        await conn.query(
          `UPDATE users
           SET username = ?,
               password = ?,
               designation = ?,
               access_right = ?,
               is_admin = 0,
               status = 'PENDING',
               updated_at = NOW()
           WHERE user_id = ?`,
          [username, hashedPassword, 'Borrower', 'BORROWER', id_no]
        );
      } else {
        await conn.query(
          `INSERT INTO users (user_id, username, password, designation, access_right, is_admin, status)
           VALUES (?, ?, ?, ?, ?, 0, 'PENDING')`,
          [id_no, username, hashedPassword, 'Borrower', 'BORROWER']
        );
      }

      const [existingBorrowerRows] = await conn.query(
        'SELECT id FROM borrowers WHERE id_no = ? LIMIT 1',
        [id_no]
      );

      const borrowerNotes = notes && notes.trim()
        ? `${notes.trim()} | Pending admin approval`
        : 'Pending admin approval';

      if (existingBorrowerRows[0]) {
        await conn.query(
          `UPDATE borrowers
           SET firstname = ?,
               middle_name = ?,
               lastname = ?,
               gender = ?,
               college = ?,
               mobile_phone = ?,
               phone = ?,
               email = ?,
               address = ?,
               notes = ?,
               date_registered = CURDATE(),
               type = ?,
               status = 'Inactive',
               updated_at = NOW()
           WHERE id_no = ?`,
          [
            firstname,
            middle_name || '',
            lastname,
            gender || 'Male',
            college || 'CTECH',
            mobile_phone || '',
            phone || '',
            email || '',
            address || '',
            borrowerNotes,
            borrowerType,
            id_no,
          ]
        );
      } else {
        await conn.query(
          `INSERT INTO borrowers
            (id_no, firstname, middle_name, lastname, gender, college, mobile_phone, phone, email, address, notes, date_registered, type, status)
           VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURDATE(), ?, 'Inactive')`,
          [
            id_no,
            firstname,
            middle_name || '',
            lastname,
            gender || 'Male',
            college || 'CTECH',
            mobile_phone || '',
            phone || '',
            email || '',
            address || '',
            borrowerNotes,
            borrowerType,
          ]
        );
      }

      await conn.commit();
      conn.release();

      return res.status(201).json({
        message: 'Account created successfully! It is now pending admin approval.',
        user_id: id_no,
      });
    } catch (txErr) {
      await conn.rollback();
      conn.release();
      throw txErr;
    }
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
    const [results] = await pool.query(
      `SELECT id, user_id, username, designation, access_right, is_admin, status
       FROM users
       WHERE id = ?
       LIMIT 1`,
      [decoded.id]
    );
    const user = results[0];

    if (!user) return res.status(404).json({ error: 'User not found' });
    if (normalizeAccountStatus(user.status) !== 'APPROVED') {
      return res.status(403).json({ error: 'Account is not active.' });
    }

    let borrower = null;
    const [borrowerRows] = await pool.query(
      `SELECT
         id,
         id_no,
         firstname,
         middle_name,
         lastname,
         gender,
         college,
         mobile_phone,
         phone,
         email,
         address,
         notes,
         date_registered,
         type,
         status
       FROM borrowers
       WHERE id_no = ?
       LIMIT 1`,
      [user.user_id]
    );
    borrower = borrowerRows[0] || null;

    res.json({ ...user, borrower });
  } catch (err) {
    if (err.name === 'JsonWebTokenError' || err.name === 'TokenExpiredError') {
      return res.status(401).json({ error: 'Invalid token' });
    }
    res.status(500).json({ error: err.message });
  }
});

// Update current user profile
router.patch('/me', async (req, res) => {
  const authHeader = req.headers.authorization;
  if (!authHeader) return res.status(401).json({ error: 'No token' });

  const token = authHeader.split(' ')[1];

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const pool = getDb();
    const conn = await pool.getConnection();

    try {
      await conn.beginTransaction();

      const [userRows] = await conn.query(
        `SELECT id, user_id, username, designation, access_right, is_admin, status
         FROM users
         WHERE id = ?
         LIMIT 1`,
        [decoded.id]
      );
      const currentUser = userRows[0];

      if (!currentUser) {
        await conn.rollback();
        conn.release();
        return res.status(404).json({ error: 'User not found' });
      }

      if (normalizeAccountStatus(currentUser.status) !== 'APPROVED') {
        await conn.rollback();
        conn.release();
        return res.status(403).json({ error: 'Account is not active.' });
      }

      const nextUsername = req.body.username ? String(req.body.username).trim() : currentUser.username;
      const nextDesignation = req.body.designation !== undefined
        ? String(req.body.designation || '').trim()
        : currentUser.designation;
      const nextPassword = req.body.password ? String(req.body.password) : null;
      const nextPasswordHash = nextPassword ? bcrypt.hashSync(nextPassword, 10) : null;

      await conn.query(
        `UPDATE users
         SET username = ?,
             password = COALESCE(?, password),
             designation = ?,
             updated_at = NOW()
         WHERE id = ?`,
        [nextUsername, nextPasswordHash, nextDesignation, currentUser.id]
      );

      let borrower = null;
      const borrowerInput = req.body.borrower || {};
      const nameParts = splitFullName(nextUsername);
      const firstname = String(borrowerInput.firstname ?? nameParts.firstname).trim();
      const middle_name = String(borrowerInput.middle_name ?? '').trim();
      const lastname = String(borrowerInput.lastname ?? nameParts.lastname).trim();
      const gender = String(borrowerInput.gender ?? 'Male').trim();
      const college = String(borrowerInput.college ?? 'CTECH').trim();
      const mobilePhone = String(borrowerInput.mobile_phone ?? '').trim();
      const phone = String(borrowerInput.phone ?? '').trim();
      const email = String(borrowerInput.email ?? '').trim();
      const address = String(borrowerInput.address ?? '').trim();
      const notes = borrowerInput.notes !== undefined ? String(borrowerInput.notes || '').trim() : null;
      const type = normalizeBorrowerType(borrowerInput.type ?? 'Student');

      const [existingBorrower] = await conn.query('SELECT id FROM borrowers WHERE id_no = ?', [currentUser.user_id]);
      if (existingBorrower.length > 0) {
        await conn.query(
          `UPDATE borrowers
           SET firstname = ?,
               middle_name = ?,
               lastname = ?,
               gender = ?,
               college = ?,
               mobile_phone = ?,
               phone = ?,
               email = ?,
               address = ?,
               notes = ?,
               type = ?,
               updated_at = NOW()
           WHERE id_no = ?`,
          [
            firstname,
            middle_name,
            lastname,
            gender,
            college,
            mobilePhone,
            phone,
            email,
            address,
            notes,
            type,
            currentUser.user_id,
          ]
        );
      }

      const [borrowerRows] = await conn.query(
        `SELECT
           id,
           id_no,
           firstname,
           middle_name,
           lastname,
           gender,
           college,
           mobile_phone,
           phone,
           email,
           address,
           notes,
           date_registered,
           type,
           status
         FROM borrowers
         WHERE id_no = ?
         LIMIT 1`,
        [currentUser.user_id]
      );
      borrower = borrowerRows[0] || null;

      const [updatedRows] = await conn.query(
        `SELECT id, user_id, username, designation, access_right, is_admin, status
         FROM users
         WHERE id = ?
         LIMIT 1`,
        [currentUser.id]
      );

      await conn.commit();
      conn.release();

      return res.json({
        ...updatedRows[0],
        is_admin: updatedRows[0].is_admin ? 1 : 0,
        borrower,
      });
    } catch (txErr) {
      await conn.rollback();
      conn.release();
      throw txErr;
    }
  } catch (err) {
    if (err.name === 'JsonWebTokenError' || err.name === 'TokenExpiredError') {
      return res.status(401).json({ error: 'Invalid token' });
    }
    return res.status(500).json({ error: err.message });
  }
});

module.exports = router;

const express = require('express');
const bcrypt = require('bcryptjs');
const { getDb } = require('../database/init');
const { authMiddleware, adminMiddleware } = require('../middleware/auth');

const router = express.Router();
router.use(authMiddleware);

// Get user's loans (before adminMiddleware)
router.get('/:id/loans', async (req, res) => {
  try {
    const pool = getDb();
    // Get borrower linked to this user and their loans
    const [userResult] = await pool.query('SELECT user_id FROM users WHERE id = ?', [req.params.id]);
    if (!userResult[0]) return res.status(404).json({ error: 'User not found' });
    
    const userId = userResult[0].user_id;
    // Find borrower with matching id_no
    const [borrowerResult] = await pool.query('SELECT id FROM borrowers WHERE id_no = ?', [userId]);
    if (!borrowerResult[0]) return res.json([]); // No borrower record yet
    
    const [results] = await pool.query('CALL sp_get_borrower_loans(?)', [borrowerResult[0].id]);
    res.json(results[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Pending borrower signups for admin review
router.get('/pending-signups', adminMiddleware, async (req, res) => {
  try {
    const pool = getDb();
    const [rows] = await pool.query(
      `SELECT
         u.id,
         u.user_id,
         u.username,
         u.designation,
         u.access_right,
         u.is_admin,
         u.status,
         u.created_at,
         b.firstname,
         b.lastname,
         b.mobile_phone,
         b.phone,
         b.email,
         b.address,
         b.notes,
         b.college,
         b.date_registered,
         b.type AS borrower_type,
         b.status AS borrower_status
       FROM users u
       LEFT JOIN borrowers b ON b.id_no = u.user_id
       WHERE u.access_right = 'BORROWER' AND u.status = 'PENDING'
       ORDER BY u.created_at ASC`
    );
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.patch('/:id/approve', adminMiddleware, async (req, res) => {
  const pool = getDb();
  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();

    const [userRows] = await conn.query(
      'SELECT id, user_id FROM users WHERE id = ? LIMIT 1',
      [req.params.id]
    );
    const user = userRows[0];
    if (!user) {
      await conn.rollback();
      conn.release();
      return res.status(404).json({ error: 'User not found' });
    }

    await conn.query(
      `UPDATE users
       SET status = 'APPROVED',
           updated_at = NOW()
       WHERE id = ?`,
      [req.params.id]
    );

    await conn.query(
      `UPDATE borrowers
       SET status = 'Active',
           updated_at = NOW()
       WHERE id_no = ?`,
      [user.user_id]
    );

    await conn.commit();
    conn.release();
    res.json({ message: 'Signup approved successfully' });
  } catch (err) {
    await conn.rollback();
    conn.release();
    res.status(500).json({ error: err.message });
  }
});

router.patch('/:id/deny', adminMiddleware, async (req, res) => {
  const pool = getDb();
  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();

    const [userRows] = await conn.query(
      'SELECT id, user_id FROM users WHERE id = ? LIMIT 1',
      [req.params.id]
    );
    const user = userRows[0];
    if (!user) {
      await conn.rollback();
      conn.release();
      return res.status(404).json({ error: 'User not found' });
    }

    await conn.query(
      `UPDATE users
       SET status = 'DENIED',
           updated_at = NOW()
       WHERE id = ?`,
      [req.params.id]
    );

    await conn.query(
      `UPDATE borrowers
       SET status = 'Inactive',
           updated_at = NOW()
       WHERE id_no = ?`,
      [user.user_id]
    );

    await conn.commit();
    conn.release();
    res.json({ message: 'Signup denied successfully' });
  } catch (err) {
    await conn.rollback();
    conn.release();
    res.status(500).json({ error: err.message });
  }
});

// Borrow book for user (creates borrower if needed)
router.post('/borrow', async (req, res) => {
  try {
    const pool = getDb();
    const { user_id, book_id, due_date } = req.body;
    
    if (!user_id || !book_id || !due_date) {
      return res.status(400).json({ error: 'User ID, book ID, and due date are required' });
    }

    // Get user details
    const [userResult] = await pool.query('SELECT * FROM users WHERE id = ?', [user_id]);
    if (!userResult[0]) return res.status(404).json({ error: 'User not found' });
    
    const user = userResult[0];
    
    // Check if borrower exists with user's user_id as id_no
    let [borrowerResult] = await pool.query('SELECT id FROM borrowers WHERE id_no = ?', [user.user_id]);
    let borrowerId;
    
    if (!borrowerResult[0]) {
      // Create borrower record for this user
      const [createResult] = await pool.query(
        'CALL sp_create_borrower(?,?,?,?,?,?,?,?,?,?)',
        [user.user_id, user.username, '', null, null, null, null, null, 'STAFF', 'ACTIVE']
      );
      borrowerId = createResult[0][0].id;
    } else {
      borrowerId = borrowerResult[0].id;
    }

    // Process checkout
    const [results] = await pool.query('CALL sp_checkout_book(?,?,?,?,?)', [
      book_id, borrowerId, null, due_date, `Checked out via User Management`
    ]);
    
    res.status(201).json(results[0][0]);
  } catch (err) {
    if (err.sqlState === '45000') return res.status(400).json({ error: err.message });
    res.status(500).json({ error: err.message });
  }
});

// Apply admin middleware for remaining routes
router.use(adminMiddleware);

// Get all users
router.get('/', async (req, res) => {
  try {
    const pool = getDb();
    const [results] = await pool.query(
      `SELECT
         u.id,
         u.user_id,
         u.username,
         u.designation,
         u.access_right,
         u.is_admin,
         u.status,
         u.created_at,
         u.updated_at,
         b.firstname,
         b.lastname,
         b.mobile_phone,
         b.phone,
         b.email,
         b.address,
         b.notes,
         b.college,
         b.type AS borrower_type
       FROM users u
       LEFT JOIN borrowers b ON b.id_no = u.user_id
       ORDER BY u.created_at DESC`
    );
    res.json(results);
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
    const [result] = await pool.query(
      `INSERT INTO users (user_id, username, password, designation, access_right, is_admin, status)
       VALUES (?, ?, ?, ?, ?, ?, 'APPROVED')`,
      [
        user_id,
        username,
        hashedPassword,
        designation || '',
        access_right || 'USER',
        is_admin ? 1 : 0,
      ]
    );
    res.status(201).json({
      id: result.insertId,
      user_id,
      username,
      designation: designation || '',
      access_right: access_right || 'USER',
      is_admin: is_admin ? 1 : 0,
      status: 'APPROVED',
    });
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
    const [existingRows] = await pool.query('SELECT * FROM users WHERE id = ? LIMIT 1', [req.params.id]);
    const existingUser = existingRows[0];
    if (!existingUser) return res.status(404).json({ error: 'User not found' });

    await pool.query(
      `UPDATE users
       SET username = ?,
           password = COALESCE(?, password),
           designation = ?,
           access_right = ?,
           is_admin = ?,
           updated_at = NOW()
       WHERE id = ?`,
      [
        username || existingUser.username,
        hashedPassword,
        designation !== undefined ? designation : existingUser.designation,
        access_right || existingUser.access_right,
        is_admin !== undefined ? (is_admin ? 1 : 0) : existingUser.is_admin,
        req.params.id,
      ]
    );

    const [updatedRows] = await pool.query('SELECT * FROM users WHERE id = ? LIMIT 1', [req.params.id]);
    const user = updatedRows[0];
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
    await pool.query('DELETE FROM users WHERE id = ?', [req.params.id]);
    res.json({ message: 'User deleted successfully' });
  } catch (err) {
    if (err.sqlState === '45000') return res.status(400).json({ error: err.message });
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;

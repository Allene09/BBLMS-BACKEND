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

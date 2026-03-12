const express = require('express');
const { getDb } = require('../database/init');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();
router.use(authMiddleware);

// Get all books with optional search
router.get('/', async (req, res) => {
  try {
    const { search = null, type = null, circulation_type = null } = req.query;
    const pool = getDb();
    const [results] = await pool.query('CALL sp_get_all_books(?, ?, ?)', [
      search || null, type || null, circulation_type || null,
    ]);
    res.json(results[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get current user's loans
router.get('/my-loans', async (req, res) => {
  try {
    const pool = getDb();
    const userId = req.user.user_id;
    
    // Find borrower with matching id_no
    const [borrowerResult] = await pool.query('SELECT id FROM borrowers WHERE id_no = ?', [userId]);
    if (!borrowerResult[0]) return res.json([]); // No borrower record yet
    
    const [results] = await pool.query('CALL sp_get_borrower_loans(?)', [borrowerResult[0].id]);
    res.json(results[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Self-borrow a book (logged-in user borrows for themselves)
router.post('/borrow', async (req, res) => {
  try {
    const pool = getDb();
    const { book_id, due_date } = req.body;
    const user = req.user;
    
    if (!book_id || !due_date) {
      return res.status(400).json({ error: 'Book ID and due date are required' });
    }

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
      book_id, borrowerId, null, due_date, `Self-checkout by ${user.username}`
    ]);
    
    res.status(201).json(results[0][0]);
  } catch (err) {
    if (err.sqlState === '45000') return res.status(400).json({ error: err.message });
    res.status(500).json({ error: err.message });
  }
});

// Get book by barcode — must be BEFORE /:id
router.get('/barcode/:barcode', async (req, res) => {
  try {
    const pool = getDb();
    const [results] = await pool.query('CALL sp_get_book_by_barcode(?)', [req.params.barcode]);
    const book = results[0][0];
    if (!book) return res.status(404).json({ error: 'Book not found' });
    res.json(book);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get single book
router.get('/:id', async (req, res) => {
  try {
    const pool = getDb();
    const [results] = await pool.query('CALL sp_get_book_by_id(?)', [req.params.id]);
    const book = results[0][0];
    if (!book) return res.status(404).json({ error: 'Book not found' });
    res.json(book);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Create book
router.post('/', async (req, res) => {
  try {
    const pool = getDb();
    const {
      title, author, co_author, type, publisher, place, date_published,
      volume, series, category, format, editor, illustrator, pages, isbn,
      physical_desc, accession_no, call_no, barcode, location,
      circulation_type, price, value, purchased_date, evaluated_date,
      acquisition_date, copies_available
    } = req.body;

    if (!title) return res.status(400).json({ error: 'Title is required' });

    const [results] = await pool.query('CALL sp_create_book(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)', [
      title, author || null, co_author || null, type || null, publisher || null,
      place || null, date_published || null, volume || null, series || null,
      category || null, format || null, editor || null, illustrator || null,
      pages || null, isbn || null, physical_desc || null, accession_no || null,
      call_no || null, barcode || null, location || null, circulation_type || null,
      price || null, value || null, purchased_date || null, evaluated_date || null,
      acquisition_date || null, copies_available || null,
    ]);
    res.status(201).json(results[0][0]);
  } catch (err) {
    if (err.code === 'ER_DUP_ENTRY') {
      return res.status(400).json({ error: 'A book with this barcode already exists' });
    }
    res.status(500).json({ error: err.message });
  }
});

// Update book
router.put('/:id', async (req, res) => {
  try {
    const pool = getDb();
    const {
      title, author, co_author, type, publisher, place, date_published,
      volume, series, category, format, editor, illustrator, pages, isbn,
      physical_desc, accession_no, call_no, barcode, location,
      circulation_type, price, value, purchased_date, evaluated_date,
      acquisition_date, copies_available
    } = req.body;

    const [results] = await pool.query('CALL sp_update_book(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)', [
      req.params.id,
      title || null, author || null, co_author || null, type || null,
      publisher || null, place || null, date_published || null, volume || null,
      series || null, category || null, format || null, editor || null,
      illustrator || null, pages || null, isbn || null, physical_desc || null,
      accession_no || null, call_no || null, barcode || null, location || null,
      circulation_type || null, price || null, value || null,
      purchased_date || null, evaluated_date || null, acquisition_date || null,
      copies_available || null,
    ]);
    const book = results[0][0];
    if (!book) return res.status(404).json({ error: 'Book not found' });
    res.json(book);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Delete book
router.delete('/:id', async (req, res) => {
  try {
    const pool = getDb();
    await pool.query('CALL sp_delete_book(?)', [req.params.id]);
    res.json({ message: 'Book deleted successfully' });
  } catch (err) {
    if (err.sqlState === '45000') return res.status(404).json({ error: err.message });
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;

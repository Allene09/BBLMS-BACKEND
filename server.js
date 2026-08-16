require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { getDb, initializeDatabase } = require('./src/database/init');

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json());

// Public stats endpoint (no auth required — used by landing page & login)
app.get('/api/stats', async (req, res) => {
  try {
    const pool = getDb();
    const [rows] = await pool.query(
      `SELECT
        (SELECT COUNT(*) FROM books)                             AS totalBooks,
        (SELECT COUNT(*) FROM borrowers)                         AS totalBorrowers,
        (SELECT COUNT(*) FROM transactions WHERE status='Loaned') AS activeLoans`
    );
    res.json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Routes
app.use('/api/auth', require('./src/routes/auth'));
app.use('/api/books', require('./src/routes/books'));
app.use('/api/borrowers', require('./src/routes/borrowers'));
app.use('/api/suppliers', require('./src/routes/suppliers'));
app.use('/api/transactions', require('./src/routes/transactions'));
app.use('/api/reservations', require('./src/routes/reservations'));
app.use('/api/users', require('./src/routes/users'));
app.use('/api/dashboard', require('./src/routes/dashboard'));
app.use('/api/reports', require('./src/routes/reports'));
app.use('/api/fines',   require('./src/routes/fines'));

// Health check
app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', message: 'BISU-Bilar Library Management System API' });
});

// Initialize MySQL pool then start server
initializeDatabase().then(() => {
  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
    console.log(`API: http://localhost:${PORT}/api`);
  });
});

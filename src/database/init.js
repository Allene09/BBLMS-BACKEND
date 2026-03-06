const Database = require('better-sqlite3');
const path = require('path');
const bcrypt = require('bcryptjs');

const DB_PATH = process.env.DB_PATH || './database.sqlite';

let db;

function getDb() {
  if (!db) {
    db = new Database(path.resolve(DB_PATH));
    db.pragma('journal_mode = WAL');
    db.pragma('foreign_keys = ON');
  }
  return db;
}

function initializeDatabase() {
  const db = getDb();

  db.exec(`
    -- System Users
    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id TEXT UNIQUE NOT NULL,
      username TEXT NOT NULL,
      password TEXT NOT NULL,
      designation TEXT DEFAULT '',
      access_right TEXT DEFAULT 'USER',
      is_admin INTEGER DEFAULT 0,
      created_at TEXT DEFAULT (datetime('now')),
      updated_at TEXT DEFAULT (datetime('now'))
    );

    -- Borrowers / Patrons
    CREATE TABLE IF NOT EXISTS borrowers (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      id_no TEXT UNIQUE NOT NULL,
      firstname TEXT NOT NULL,
      lastname TEXT NOT NULL,
      mobile_phone TEXT DEFAULT '',
      phone TEXT DEFAULT '',
      email TEXT DEFAULT '',
      address TEXT DEFAULT '',
      notes TEXT DEFAULT '',
      date_registered TEXT DEFAULT (date('now')),
      type TEXT CHECK(type IN ('Student', 'Faculty', 'Others')) DEFAULT 'Student',
      status TEXT CHECK(status IN ('Active', 'Inactive')) DEFAULT 'Active',
      created_at TEXT DEFAULT (datetime('now')),
      updated_at TEXT DEFAULT (datetime('now'))
    );

    -- Suppliers
    CREATE TABLE IF NOT EXISTS suppliers (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      sup_code TEXT UNIQUE NOT NULL,
      company_name TEXT NOT NULL,
      address TEXT DEFAULT '',
      phone TEXT DEFAULT '',
      fax_no TEXT DEFAULT '',
      mobile_phone TEXT DEFAULT '',
      email TEXT DEFAULT '',
      web_site TEXT DEFAULT '',
      contact_person TEXT DEFAULT '',
      position TEXT DEFAULT '',
      gender TEXT CHECK(gender IN ('Male', 'Female', 'Other')) DEFAULT 'Male',
      created_at TEXT DEFAULT (datetime('now')),
      updated_at TEXT DEFAULT (datetime('now'))
    );

    -- Library Items / Books
    CREATE TABLE IF NOT EXISTS books (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      author TEXT DEFAULT '',
      co_author TEXT DEFAULT '',
      type TEXT DEFAULT 'Book',
      publisher TEXT DEFAULT '',
      place TEXT DEFAULT '',
      date_published TEXT DEFAULT '',
      volume TEXT DEFAULT '',
      series TEXT DEFAULT '',
      category TEXT DEFAULT '',
      format TEXT DEFAULT '',
      editor TEXT DEFAULT '',
      illustrator TEXT DEFAULT '',
      pages TEXT DEFAULT '',
      isbn TEXT DEFAULT '',
      physical_desc TEXT DEFAULT '',
      accession_no TEXT DEFAULT '',
      call_no TEXT DEFAULT '',
      barcode TEXT UNIQUE,
      location TEXT DEFAULT '',
      circulation_type TEXT DEFAULT 'Loanable',
      price REAL DEFAULT 0,
      value REAL DEFAULT 0,
      purchased_date TEXT DEFAULT '',
      evaluated_date TEXT DEFAULT '',
      acquisition_date TEXT DEFAULT '',
      copies_available INTEGER DEFAULT 1,
      created_at TEXT DEFAULT (datetime('now')),
      updated_at TEXT DEFAULT (datetime('now'))
    );

    -- Transactions (Check-out / Check-in)
    CREATE TABLE IF NOT EXISTS transactions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      book_id INTEGER NOT NULL,
      borrower_id INTEGER NOT NULL,
      loan_date TEXT DEFAULT (date('now')),
      due_date TEXT NOT NULL,
      return_date TEXT DEFAULT NULL,
      fine_amount REAL DEFAULT 0,
      past_due_fines REAL DEFAULT 0,
      total_fine REAL DEFAULT 0,
      notes TEXT DEFAULT '',
      status TEXT CHECK(status IN ('Loaned', 'Returned', 'Overdue')) DEFAULT 'Loaned',
      created_at TEXT DEFAULT (datetime('now')),
      updated_at TEXT DEFAULT (datetime('now')),
      FOREIGN KEY (book_id) REFERENCES books(id),
      FOREIGN KEY (borrower_id) REFERENCES borrowers(id)
    );

    -- Reservations
    CREATE TABLE IF NOT EXISTS reservations (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      book_id INTEGER NOT NULL,
      borrower_id INTEGER NOT NULL,
      reserved_on TEXT DEFAULT (date('now')),
      reserved_for_days INTEGER DEFAULT 5,
      notes TEXT DEFAULT '',
      status TEXT CHECK(status IN ('Active', 'Fulfilled', 'Cancelled', 'Expired')) DEFAULT 'Active',
      created_at TEXT DEFAULT (datetime('now')),
      updated_at TEXT DEFAULT (datetime('now')),
      FOREIGN KEY (book_id) REFERENCES books(id),
      FOREIGN KEY (borrower_id) REFERENCES borrowers(id)
    );
  `);

  // Seed default admin user if not exists
  const adminExists = db.prepare('SELECT id FROM users WHERE user_id = ?').get('ADMIN');
  if (!adminExists) {
    const hashedPassword = bcrypt.hashSync('admin123', 10);
    db.prepare(`
      INSERT INTO users (user_id, username, password, designation, access_right, is_admin)
      VALUES (?, ?, ?, ?, ?, ?)
    `).run('ADMIN', 'ADMIN USER', hashedPassword, 'Librarian', 'ADMINISTRATOR', 1);
  }

  console.log('Database initialized successfully');
}

module.exports = { getDb, initializeDatabase };

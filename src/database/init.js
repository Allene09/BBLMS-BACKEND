const mysql = require('mysql2/promise');

let pool;

function getDb() {
  if (!pool) {
    pool = mysql.createPool({
      host:              process.env.DB_HOST     || '127.0.0.1',
      port:              process.env.DB_PORT     || 3306,
      user:              process.env.DB_USER,
      password:          process.env.DB_PASSWORD,
      database:          process.env.DB_NAME,
      waitForConnections: true,
      connectionLimit:   10,
      queueLimit:        0,
    });
  }
  return pool;
}

async function initializeDatabase() {
  const pool = getDb();
  try {
    const conn = await pool.getConnection();
    console.log(`MySQL connected → ${process.env.DB_HOST}:${process.env.DB_PORT || 3306} / ${process.env.DB_NAME}`);
    conn.release();

    const [statusColumns] = await pool.query(
      `SELECT COUNT(*) AS column_count
       FROM information_schema.COLUMNS
       WHERE TABLE_SCHEMA = ?
         AND TABLE_NAME = 'users'
         AND COLUMN_NAME = 'status'`,
      [process.env.DB_NAME]
    );

    if ((statusColumns[0]?.column_count || 0) === 0) {
      await pool.query(
        `ALTER TABLE users
         ADD COLUMN status ENUM('APPROVED','PENDING','DENIED') DEFAULT 'APPROVED' AFTER is_admin`
      );
      await pool.query("UPDATE users SET status = 'APPROVED' WHERE status IS NULL OR status = ''");
      console.log('Migrated users.status column for account approval workflow');
    }

    // ── Migration: fine_paid flag on transactions ──────────────────────────────
    const [finePaidCol] = await pool.query(
      `SELECT COUNT(*) AS column_count
       FROM information_schema.COLUMNS
       WHERE TABLE_SCHEMA = ?
         AND TABLE_NAME   = 'transactions'
         AND COLUMN_NAME  = 'fine_paid'`,
      [process.env.DB_NAME]
    );
    if ((finePaidCol[0]?.column_count || 0) === 0) {
      await pool.query(
        `ALTER TABLE transactions
         ADD COLUMN fine_paid TINYINT(1) NOT NULL DEFAULT 0 AFTER total_fine`
      );
      console.log('Migrated transactions.fine_paid column');
    }

    // ── Migration: new personal info fields on borrowers ────────────────────────
    const [borrowerCol] = await pool.query(
      `SELECT COUNT(*) AS column_count
       FROM information_schema.COLUMNS
       WHERE TABLE_SCHEMA = ?
         AND TABLE_NAME   = 'borrowers'
         AND COLUMN_NAME  = 'middle_name'`,
      [process.env.DB_NAME]
    );
    if ((borrowerCol[0]?.column_count || 0) === 0) {
      await pool.query(
        `ALTER TABLE borrowers
         ADD COLUMN middle_name VARCHAR(100) DEFAULT '' AFTER firstname,
         ADD COLUMN gender ENUM('Male','Female','Other') DEFAULT 'Male' AFTER lastname,
         ADD COLUMN college ENUM('CTECH','CFES','CBM','COAS') DEFAULT 'CTECH' AFTER gender`
      );
      console.log('Migrated borrowers table (middle_name, gender, college)');
    }

    // ── Migration: fine_payments table ─────────────────────────────────────────
    const [fpTable] = await pool.query(
      `SELECT COUNT(*) AS table_count
       FROM information_schema.TABLES
       WHERE TABLE_SCHEMA = ?
         AND TABLE_NAME   = 'fine_payments'`,
      [process.env.DB_NAME]
    );
    if ((fpTable[0]?.table_count || 0) === 0) {
      await pool.query(
        `CREATE TABLE fine_payments (
           id                  INT(11)        NOT NULL AUTO_INCREMENT,
           transaction_id      INT(11)        NOT NULL,
           fine_amount         DECIMAL(10,2)  NOT NULL DEFAULT '0.00',
           amount_paid         DECIMAL(10,2)  NOT NULL DEFAULT '0.00',
           change_given        DECIMAL(10,2)  NOT NULL DEFAULT '0.00',
           payment_type        ENUM('Cash')   NOT NULL DEFAULT 'Cash',
           payment_status      ENUM('Paid','Void') NOT NULL DEFAULT 'Paid',
           received_by_user_id VARCHAR(50)    NOT NULL DEFAULT '',
           receipt_no          VARCHAR(30)    NOT NULL DEFAULT '',
           notes               TEXT,
           paid_at             DATETIME       DEFAULT CURRENT_TIMESTAMP,
           created_at          DATETIME       DEFAULT CURRENT_TIMESTAMP,
           PRIMARY KEY (id),
           UNIQUE KEY uk_fine_payments_receipt (receipt_no),
           KEY idx_fine_payments_transaction (transaction_id),
           KEY idx_fine_payments_status (payment_status),
           CONSTRAINT fk_fine_payments_transaction
             FOREIGN KEY (transaction_id) REFERENCES transactions (id) ON UPDATE CASCADE
         ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci`
      );
      console.log('Created fine_payments table');
    }
  } catch (err) {
    console.error('MySQL connection failed:', err.message);
    process.exit(1);
  }

}

module.exports = { getDb, initializeDatabase };

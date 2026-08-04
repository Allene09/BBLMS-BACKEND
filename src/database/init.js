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
  } catch (err) {
    console.error('MySQL connection failed:', err.message);
    process.exit(1);
  }

}

module.exports = { getDb, initializeDatabase };

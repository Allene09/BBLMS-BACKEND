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
  } catch (err) {
    console.error('MySQL connection failed:', err.message);
    process.exit(1);
  }

}

module.exports = { getDb, initializeDatabase };

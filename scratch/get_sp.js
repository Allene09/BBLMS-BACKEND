require('dotenv').config();
const { getDb } = require('../src/database/init');
async function run() {
  const pool = getDb();
  const [rows] = await pool.query("SHOW CREATE PROCEDURE sp_get_all_transactions");
  console.log(rows[0]['Create Procedure']);
  process.exit(0);
}
run().catch(console.error);

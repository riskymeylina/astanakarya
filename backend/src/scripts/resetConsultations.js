require('dotenv').config();
const pool = require('../config/db');

async function resetConsultations() {
  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();
    await connection.query('DELETE FROM consultation_messages');
    await connection.query('DELETE FROM property_consultation_requests');
    await connection.commit();
    console.info('Consultation requests and chat messages have been reset.');
  } catch (error) {
    await connection.rollback();
    console.error('Failed to reset consultations:', error.message);
    process.exitCode = 1;
  } finally {
    connection.release();
    await pool.end();
  }
}

resetConsultations();

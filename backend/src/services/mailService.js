const nodemailer = require('nodemailer');

function createTransporter() {
  const host = (process.env.SMTP_HOST || '').trim();
  const user = (process.env.SMTP_USER || '').trim();
  const pass = process.env.SMTP_PASS || '';
  const port = Number(process.env.SMTP_PORT || 587);

  if (!host || !user || !pass) {
    return null;
  }

  return nodemailer.createTransport({
    host,
    port,
    secure: port === 465,
    auth: {
      user,
      pass,
    },
  });
}

async function sendPasswordResetCode({ toEmail, code, expiresInMinutes }) {
  const transporter = createTransporter();

  if (!transporter) {
    console.log(
      `[dev-mail] Kode reset password untuk ${toEmail}: ${code} (berlaku ${expiresInMinutes} menit)`,
    );
    return;
  }

  await transporter.sendMail({
    from: process.env.SMTP_FROM || process.env.SMTP_USER,
    to: toEmail,
    subject: 'Kode Reset Kata Sandi',
    text: `Kode reset kata sandi Anda adalah ${code}. Kode ini berlaku selama ${expiresInMinutes} menit.`,
    html: `<p>Kode reset kata sandi Anda adalah <strong>${code}</strong>.</p><p>Kode ini berlaku selama ${expiresInMinutes} menit.</p>`,
  });
}

module.exports = {
  sendPasswordResetCode,
};

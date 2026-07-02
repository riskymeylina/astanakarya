// =====================================================
// Telegram Bot Service
// Mengirim pesen OTP ke Telegram via Bot API
// =====================================================
const https = require("https");

/**
 * Kirim pesan teks ke chat Telegram yang udah di-set di .env
 * @param {string} message - Teks yang mau dikirim
 * @returns {Promise<boolean>} true kalo berhasil, false kalo gagal
 */
function sendTelegramMessage(message) {
  const botToken = (process.env.TELEGRAM_BOT_TOKEN || "").trim();
  const chatId = (process.env.TELEGRAM_CHAT_ID || "").trim();

  if (!botToken || !chatId) {
    console.log("[dev-telegram] TELEGRAM_BOT_TOKEN atau TELEGRAM_CHAT_ID tidak dikonfigurasi");
    return Promise.resolve(false);
  }

  return new Promise((resolve, reject) => {
    const payload = JSON.stringify({
      chat_id: chatId,
      text: message,
      parse_mode: "HTML",
    });

    const url = new URL(`https://api.telegram.org/bot${botToken}/sendMessage`);
    const options = {
      hostname: url.hostname,
      path: url.pathname,
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Content-Length": Buffer.byteLength(payload),
      },
    };

    const req = https.request(options, (res) => {
      let body = "";
      res.on("data", (chunk) => (body += chunk));
      res.on("end", () => {
        try {
          const parsed = JSON.parse(body);
          if (parsed.ok) {
            console.log("[telegram] Pesan berhasil dikirim");
            resolve(true);
          } else {
            console.error("[telegram] Gagal:", parsed.description);
            resolve(false);
          }
        } catch {
          console.error("[telegram] Gagal parse response");
          resolve(false);
        }
      });
    });

    req.on("error", (err) => {
      console.error("[telegram] Error:", err.message);
      resolve(false);
    });

    req.write(payload);
    req.end();
  });
}

/**
 * Kirim kode OTP reset password ke Telegram
 * @param {object} params
 * @param {string} params.code - Kode OTP 6 digit
 * @param {number} params.expiresInMinutes - Masa berlaku dalam menit
 */
async function sendOtpToTelegram({ code, expiresInMinutes }) {
  const message = [
    "<b>🔐 Kode Reset Kata Sandi</b>",
    "",
    `Kode OTP kamu: <b>${code}</b>`,
    "",
    `Kode ini berlaku selama <b>${expiresInMinutes} menit</b>.`,
    "Jangan bagikan kode ini ke siapa pun!",
  ].join("\n");

  const sent = await sendTelegramMessage(message);
  if (sent) {
    console.log(`[telegram] Kode OTP terkirim: ${code}`);
  }
  return sent;
}

module.exports = {
  sendTelegramMessage,
  sendOtpToTelegram,
};

const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.sendOtpEmail = functions.https.onCall(async (data, context) => {
  const email = (data && data.email) || '';
  const code = (data && data.code) || '';

  if (!email || !code) {
    throw new functions.https.HttpsError('invalid-argument', 'email and code are required');
  }

  // Write to the 'mail' collection - the extension will send the email automatically
  try {
    await admin.firestore().collection('mail').add({
      to: email,
      message: {
        subject: 'Your UniBridge LK verification code',
        text: `Your verification code is ${code}. It expires in 10 minutes.`,
        html: `
          <div style="font-family: Arial, sans-serif; padding: 20px; max-width: 600px; margin: 0 auto;">
            <h2 style="color: #333;">UniBridge LK Verification</h2>
            <p>Your verification code is:</p>
            <div style="background: #f4f4f4; padding: 15px; border-radius: 5px; text-align: center; font-size: 32px; font-weight: bold; letter-spacing: 5px; margin: 20px 0;">
              ${code}
            </div>
            <p style="color: #666;">This code expires in 10 minutes.</p>
            <p style="color: #999; font-size: 12px; margin-top: 30px;">If you didn't request this code, please ignore this email.</p>
          </div>
        `
      }
    });
    return { ok: true };
  } catch (err) {
    console.error('Failed to queue email', err);
    throw new functions.https.HttpsError('internal', 'Failed to send email');
  }
});

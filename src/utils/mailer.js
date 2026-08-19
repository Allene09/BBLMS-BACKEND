const nodemailer = require('nodemailer');

const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});

/**
 * Sends an email notification to the approved borrower.
 * @param {string} toEmail 
 * @param {string} firstname 
 * @param {string} idNo 
 * @param {string} defaultPassword 
 */
const sendApprovalEmail = async (toEmail, firstname, idNo, defaultPassword) => {
  if (!process.env.EMAIL_USER || !process.env.EMAIL_PASS) {
    console.warn('Email credentials not set. Skipping approval email to', toEmail);
    return;
  }

  const htmlContent = `
    <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; color: #333; line-height: 1.6;">
      <h2 style="color: #4f46e5;">Welcome to BISU-Bilar Library System!</h2>
      <p>Hi <strong>${firstname}</strong>,</p>
      <p>We are pleased to inform you that your borrower account has been <strong>approved</strong> by the administrator.</p>
      
      <div style="background-color: #f3f4f6; padding: 20px; border-radius: 8px; margin: 20px 0;">
        <h3 style="margin-top: 0; color: #1f2937;">Your Login Credentials</h3>
        <p style="margin-bottom: 5px;"><strong>User ID:</strong> ${idNo}</p>
        <p style="margin-top: 0;"><strong>Password:</strong> ${defaultPassword}</p>
      </div>

      <p><em>Please make sure to log in and change your password from your profile settings as soon as possible for security purposes.</em></p>
      
      <br>
      <p>Best regards,</p>
      <p><strong>BISU-Bilar Library Administration</strong></p>
    </div>
  `;

  const mailOptions = {
    from: `"BISU-Bilar Library" <${process.env.EMAIL_USER}>`,
    to: toEmail,
    subject: 'Your Borrower Account has been Approved!',
    html: htmlContent,
  };

  try {
    const info = await transporter.sendMail(mailOptions);
    console.log('Approval email sent successfully to:', toEmail, 'Message ID:', info.messageId);
    return true;
  } catch (error) {
    console.error('Error sending approval email to', toEmail, error);
    return false;
  }
};

/**
 * Sends an email notification to an appointed user.
 * @param {string} toEmail 
 * @param {string} username 
 * @param {string} idNo 
 * @param {string} defaultPassword 
 */
const sendAppointEmail = async (toEmail, username, idNo, defaultPassword) => {
  if (!process.env.EMAIL_USER || !process.env.EMAIL_PASS) {
    console.warn('Email credentials not set. Skipping appoint email to', toEmail);
    return;
  }

  const htmlContent = `
    <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; color: #333; line-height: 1.6;">
      <h2 style="color: #4f46e5;">Welcome to BISU-Bilar Library System!</h2>
      <p>Hi <strong>${username}</strong>,</p>
      <p>An administrator has appointed you as a system user.</p>
      
      <div style="background-color: #f3f4f6; padding: 20px; border-radius: 8px; margin: 20px 0;">
        <h3 style="margin-top: 0; color: #1f2937;">Your Login Credentials</h3>
        <p style="margin-bottom: 5px;"><strong>User ID:</strong> ${idNo}</p>
        <p style="margin-top: 0;"><strong>Password:</strong> ${defaultPassword}</p>
      </div>

      <p><em>Please log in using these credentials. You can change your password from your profile settings.</em></p>
      
      <br>
      <p>Best regards,</p>
      <p><strong>BISU-Bilar Library Administration</strong></p>
    </div>
  `;

  const mailOptions = {
    from: `"BISU-Bilar Library" <${process.env.EMAIL_USER}>`,
    to: toEmail,
    subject: 'You have been appointed as a Library System User',
    html: htmlContent,
  };

  try {
    const info = await transporter.sendMail(mailOptions);
    console.log('Appoint email sent successfully to:', toEmail, 'Message ID:', info.messageId);
    return true;
  } catch (error) {
    console.error('Error sending appoint email to', toEmail, error);
    return false;
  }
};

module.exports = {
  transporter,
  sendApprovalEmail,
  sendAppointEmail
};

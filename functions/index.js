const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const admin = require('firebase-admin');

admin.initializeApp();

exports.myFunction = onDocumentCreated("/chat/{messageId}", async (event) => {
  // Retrieve data from the Firestore document
  const data = event.data.data();

  // Send a push notification using Firebase Cloud Messaging
  await admin.messaging().send({
    notification: {
      title: data['username'],
      body: data['message'],
    },
    data: {
      click_action: 'FLUTTER_NOTIFICATION_CLICK',
    },
    topic: 'chat',
  });

  // Ensure function completes successfully
  return null;
});

const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.myFunction = functions.firestore
  .document('ownerBookedGames/{userId}/bookItems/{documentId}')
  .onCreate((snapshot, context) => {
    return admin.messaging().sendToTopic('notifying', {
      notification: {
        title: "booking",
        body: snapshot.data().playerName + " booked " + snapshot.data().gameName,
        clickAction: 'FLUTTER_NOTIFICATION_CLICK',
      },
    });
  });
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendVaccinationNotifications = functions.firestore
  .document('users/{userId}/notifications/{notificationId}')
  .onCreate(async (snap, context) => {
    const notification = snap.data();
    const { userId } = context.params;

    const scheduledTime = notification.scheduledTime.toDate();
    const now = new Date();
    const differenceInMinutes = (scheduledTime - now) / (1000 * 60);

    // If the notification is due within 5 minutes, send it immediately
    if (differenceInMinutes <= 5 && differenceInMinutes >= 0) {
      const userDoc = await admin.firestore()
        .collection('users')
        .doc(userId)
        .get();

      const fcmToken = userDoc.data().fcmToken;
      if (!fcmToken) {
        console.log(`No FCM token found for user ${userId}`);
        return;
      }

      const message = {
        token: fcmToken,
        notification: {
          title: 'Vaccination Reminder',
          body: `Time for ${notification.vaccineName}!`,
        },
        data: {
          childId: notification.childId,
          vaccineId: notification.vaccineId,
        },
      };

      try {
        await admin.messaging().send(message);
        console.log(`Successfully sent FCM notification to user ${userId} for ${notification.vaccineName}`);
        await snap.ref.update({ status: 'sent', delivered: false });
      } catch (error) {
        console.error(`Error sending FCM notification: ${error}`);
        await snap.ref.update({ status: 'failed', error: error.message });
      }
    } else if (differenceInMinutes > 5) {
      console.log(`Notification for ${notification.vaccineName} scheduled for ${scheduledTime}`);
    }
  });
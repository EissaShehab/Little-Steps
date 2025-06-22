const { onSchedule } = require("firebase-functions/v2/scheduler");
const { initializeApp, applicationDefault } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");
const logger = require("firebase-functions/logger");

initializeApp({
  credential: applicationDefault(),
});

exports.sendScheduledNotifications = onSchedule("every 5 minutes", async () => {
  const db = getFirestore();
  const now = new Date();
  const fiveMinutesAgo = new Date(now.getTime() - 5 * 60 * 1000);
  const fiveMinutesAhead = new Date(now.getTime() + 5 * 60 * 1000);
  const fourHoursAgo = new Date(now.getTime() - 4 * 60 * 60 * 1000);

  try {
    const usersSnapshot = await db.collection("users").get();

    for (const userDoc of usersSnapshot.docs) {
      const userId = userDoc.id;
      const fcmToken = userDoc.data().fcmToken;
      const language = userDoc.data().language || "en";

      if (!fcmToken) {
        logger.warn(`⚠️ No FCM token for user ${userId}`);
        continue;
      }

      // 🔔 إشعارات المطاعيم المجدولة
      const vaccineNotifsSnapshot = await db
        .collection("users")
        .doc(userId)
        .collection("notifications")
        .where("delivered", "==", false)
        .where("type", "==", "vaccination")
        .where("scheduledTime", ">=", fiveMinutesAgo)
        .where("scheduledTime", "<=", fiveMinutesAhead)
        .get();

      // 🌤️ إشعارات الطقس المضافة حديثًا
      const weatherNotifsSnapshot = await db
        .collection("users")
        .doc(userId)
        .collection("notifications")
        .where("delivered", "==", false)
        .where("type", "==", "weather")
        .where("timestamp", ">=", fourHoursAgo)
        .get();

      const allNotifications = [
        ...vaccineNotifsSnapshot.docs,
        ...weatherNotifsSnapshot.docs,
      ];

      if (allNotifications.length === 0) {
        logger.info(`ℹ️ No pending notifications for user ${userId}`);
        continue;
      }

      for (const doc of allNotifications) {
        const {
          title,
          title_ar,
          message,
          message_ar,
          type = "unknown",
        } = doc.data();

        const localizedTitle = language === "ar" ? title_ar || title : title;
        const localizedMessage = language === "ar" ? message_ar || message : message;

        try {
          await getMessaging().send({
            token: fcmToken,
            notification: {
              title: localizedTitle,
              body: localizedMessage,
            },
            data: {
              type: type,
              childId: doc.data().childId || "",
            },
          });

          // ✅ تحسين التخزين مع deliveredAt و timestamp
          await doc.ref.update({
            delivered: true,
            deliveredAt: new Date().toISOString(),
            timestamp: new Date()
          });

          logger.info(`✅ ${type.toUpperCase()} notification sent to ${userId}: ${localizedTitle}`);
        } catch (sendError) {
          logger.error(`❌ Error sending FCM to ${userId}: ${sendError.message}`);
        }
      }
    }

    logger.info("✅ All notifications processed successfully.");
  } catch (error) {
    logger.error("❌ Top-level error sending scheduled notifications:", error);
  }
});

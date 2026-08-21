const {setGlobalOptions} = require("firebase-functions");
const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

// Initialize Firebase Admin so we can talk to Firestore and FCM
admin.initializeApp();

setGlobalOptions({maxInstances: 10});

exports.notifyOnUserMatch = onDocumentCreated(
    "users/{userId}",
    async (event) => {
      const newUser = event.data.data(); // Get the data of the new user
      const db = admin.firestore();

      // 1. Query for potential matches
      const matchingUsersSnapshot = await db.collection("users")
          .where("district", "==", newUser.choice1)
          .where("choice1", "==", newUser.district)
          .where("subject", "==", newUser.subject)
          .get();

      if (matchingUsersSnapshot.empty) return;

      const promises = [];

      matchingUsersSnapshot.forEach((doc) => {
        const matchedUser = doc.data();
        const matchedUserId = doc.id;

        // 2. Prepare Push Notification
        if (matchedUser.fcmToken) {
          const message = {
            token: matchedUser.fcmToken,
            notification: {
              title: "New Match Found!",
              body: `${newUser.name} matches ${newUser.subject}.`,
            },
            data: {
              type: "MATCH_NOTIFICATION",
              uid: newUser.uid,
            },
          };
          promises.push(admin.messaging().send(message));
        }

        // 3. Save to a 'notifications' collection
        promises.push(db.collection("notifications").add({
          userId: matchedUserId,
          title: "New Match Found!",
          message: `${newUser.name} matches ${newUser.subject}.`,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          isRead: false,
          relatedUserId: newUser.uid,
        }));
      });

      return Promise.all(promises);
    });

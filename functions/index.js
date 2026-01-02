/**
 * Cloud Functions for FuelMate App
 *
 * These functions trigger FCM notifications when:
 * 1. A new message is created
 * 2. A new quote is created
 * 3. A new request is created
 */

const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {onDocumentUpdated} = require("firebase-functions/v2/firestore");
const {setGlobalOptions} = require("firebase-functions/v2");
const admin = require("firebase-admin");
const logger = require("firebase-functions/logger");

// Initialize Firebase Admin
admin.initializeApp();

// Set global options for all functions
setGlobalOptions({
  maxInstances: 10,
  region: "us-central1", // Change to your preferred region
});

/**
 * Send FCM notification to a specific user
 * @param {string} userId - The user ID to send notification to
 * @param {object} notification - The notification object with title and body
 * @param {object} data - Additional data payload
 * @return {Promise<void>}
 */
async function sendNotificationToUser(userId, notification, data) {
  try {
    // Query for the user's FCM token
    const userDoc = await admin.firestore()
        .collection("users")
        .doc(userId)
        .get();

    if (!userDoc.exists) {
      logger.warn(`User ${userId} not found`);
      return;
    }

    const fcmToken = userDoc.data().fcmToken;

    if (!fcmToken) {
      logger.warn(`No FCM token for user ${userId}`);
      return;
    }

    // Send the notification
    const message = {
      notification: notification,
      data: data,
      token: fcmToken,
      android: {
        priority: "high",
        notification: {
          channelId: "fuelmate_channel_id",
          sound: "default",
          priority: "high",
        },
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
            badge: 1,
          },
        },
      },
    };

    const response = await admin.messaging().send(message);
    logger.info(`Successfully sent notification to ${userId}:`, response);
  } catch (error) {
    logger.error(`Error sending notification to ${userId}:`, error);
  }
}

/**
 * Send FCM notification to a topic
 * @param {string} topic - The topic name to send notification to
 * @param {object} notification - The notification object with title and body
 * @param {object} data - Additional data payload
 * @return {Promise<void>}
 */
async function sendNotificationToTopic(topic, notification, data) {
  try {
    const message = {
      notification: notification,
      data: data,
      topic: topic,
      android: {
        priority: "high",
        notification: {
          channelId: "fuelmate_channel_id",
          sound: "default",
          priority: "high",
        },
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
            badge: 1,
          },
        },
      },
    };

    const response = await admin.messaging().send(message);
    logger.info(`Successfully sent notification to topic ${topic}:`, response);
  } catch (error) {
    logger.error(`Error sending notification to topic ${topic}:`, error);
  }
}

/**
 * Trigger: When a new message is created
 * Sends notification to the recipient
 */
exports.onNewMessage = onDocumentCreated(
    "petrolRequests/{requestId}/messages/{messageId}",
    async (event) => {
      const messageData = event.data.data();
      const requestId = event.params.requestId;

      logger.info("New message created:", {requestId, messageData});

      // Get the request to find the participants
      const requestDoc = await admin.firestore()
          .collection("petrolRequests")
          .doc(requestId)
          .get();

      if (!requestDoc.exists) {
        logger.warn(`Request ${requestId} not found`);
        return;
      }

      const requestData = requestDoc.data();
      const senderId = messageData.senderId;
      const senderName = messageData.senderName || "Someone";
      const messageText = messageData.message || "New message";

      // Determine the recipient (the other person in the chat)
      let recipientId;
      if (senderId === requestData.userId) {
        // Sender is the needy, recipient is the provider
        recipientId = requestData.acceptedProviderId;
      } else {
        // Sender is the provider, recipient is the needy
        recipientId = requestData.userId;
      }

      if (!recipientId) {
        logger.warn("No recipient found for message");
        return;
      }

      // Send notification to the recipient
      await sendNotificationToUser(
          recipientId,
          {
            title: `💬 New Message from ${senderName}`,
            body: messageText,
          },
          {
            type: "message",
            requestId: requestId,
            payload: `chat_${requestId}`,
          },
      );
    },
);

/**
 * Trigger: When a new quote is created
 * Sends notification to the needy user
 */
exports.onNewQuote = onDocumentCreated(
    "quotes/{quoteId}",
    async (event) => {
      const quoteData = event.data.data();
      const quoteId = event.params.quoteId;

      logger.info("New quote created:", {quoteId, quoteData});

      const requestId = quoteData.requestId;
      const providerId = quoteData.providerId;
      const providerName = quoteData.providerName || "A provider";
      const price = quoteData.price || 0;
      const currency = quoteData.currency || "PKR";

      // Get the request to find the needy user
      const requestDoc = await admin.firestore()
          .collection("petrolRequests")
          .doc(requestId)
          .get();

      if (!requestDoc.exists) {
        logger.warn(`Request ${requestId} not found`);
        return;
      }

      const requestData = requestDoc.data();
      const needyUserId = requestData.userId;

      // Send notification to the needy user
      await sendNotificationToUser(
          needyUserId,
          {
            title: "💰 New Quote Received!",
            body: `${providerName} offered ${currency} ${price.toFixed(2)}`,
          },
          {
            type: "quote",
            requestId: requestId,
            quoteId: quoteId,
            providerId: providerId,
            payload: `quote_${quoteId}`,
          },
      );
    },
);

/**
 * Trigger: When a new petrol request is created
 * Sends notification to all providers (via topic)
 */
exports.onNewRequest = onDocumentCreated(
    "petrolRequests/{requestId}",
    async (event) => {
      const requestData = event.data.data();
      const requestId = event.params.requestId;

      logger.info("New request created:", {requestId, requestData});

      const needyName = requestData.userName || "Someone";
      const message = requestData.message || "needs petrol";
      const location = requestData.location || {};
      const distance = location.distance || null;

      // Send notification to all providers (subscribed to 'providers' topic)
      await sendNotificationToTopic(
          "providers",
          {
            title: "🚨 New Petrol Request!",
            body: `${needyName} needs petrol! "${message}" ` +
              `${distance ? `(${distance}km away)` : ""}`,
          },
          {
            type: "request",
            requestId: requestId,
            needyName: needyName,
            payload: `request_${requestId}`,
          },
      );

      // Also send to 'all_users' topic as a fallback
      await sendNotificationToTopic(
          "all_users",
          {
            title: "🚨 New Petrol Request!",
            body: `${needyName} needs petrol! "${message}"`,
          },
          {
            type: "request",
            requestId: requestId,
            needyName: needyName,
            payload: `request_${requestId}`,
          },
      );
    },
);

/**
 * Trigger: When a quote is accepted (request status changes to 'accepted')
 * Sends notification to the provider whose quote was accepted
 */
exports.onQuoteAccepted = onDocumentUpdated(
    "petrolRequests/{requestId}",
    async (event) => {
      const beforeData = event.data.before.data();
      const afterData = event.data.after.data();
      const requestId = event.params.requestId;

      // Check if status changed to 'accepted'
      if (beforeData.status !== "accepted" && afterData.status === "accepted") {
        logger.info("Quote accepted for request:", {requestId, afterData});

        const providerId = afterData.acceptedProviderId;
        const needyName = afterData.userName || "Someone";

        if (!providerId) {
          logger.warn("No provider ID found for accepted quote");
          return;
        }

        // Send notification to the provider
        await sendNotificationToUser(
            providerId,
            {
              title: "✅ Quote Accepted!",
              body: `${needyName} accepted your quote for ` +
                `request ${requestId}`,
            },
            {
              type: "quote_accepted",
              requestId: requestId,
              needyName: needyName,
              payload: `request_${requestId}`,
            },
        );
      }
    },
);

/**
 * Trigger: When a request is completed
 * Sends notification to the needy user
 */
exports.onRequestCompleted = onDocumentUpdated(
    "petrolRequests/{requestId}",
    async (event) => {
      const beforeData = event.data.before.data();
      const afterData = event.data.after.data();
      const requestId = event.params.requestId;

      // Check if status changed to 'completed'
      if (beforeData.status !== "completed" &&
          afterData.status === "completed") {
        logger.info("Request completed:", {requestId, afterData});

        const needyUserId = afterData.userId;
        const providerName = afterData.acceptedProviderName || "Provider";

        // Send notification to the needy user
        await sendNotificationToUser(
            needyUserId,
            {
              title: "🎉 Request Completed!",
              body: `Your request was completed by ${providerName}`,
            },
            {
              type: "request_completed",
              requestId: requestId,
              providerName: providerName,
              payload: `request_${requestId}`,
            },
        );
      }
    },
);

// Export a test function for debugging
exports.testNotification = require("firebase-functions/v2/https").onRequest(
    async (req, res) => {
      try {
        const userId = req.query.userId || "test_user";
        await sendNotificationToUser(
            userId,
            {
              title: "🧪 Test Notification",
              body: "This is a test notification from Cloud Functions!",
            },
            {
              type: "test",
              payload: "test",
            },
        );
        res.json({success: true, message: `Notification sent to ${userId}`});
      } catch (error) {
        logger.error("Test notification error:", error);
        res.status(500).json({success: false, error: error.message});
      }
    },
);

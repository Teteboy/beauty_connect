const { User, DeviceToken } = require('../models');
const admin = require('firebase-admin');
const path = require('path');

// Initialize Firebase Admin SDK
try {
  const serviceAccount = require(path.join(__dirname, '../../config/firebase-service-account.json'));
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
  console.log('Firebase Admin SDK initialized successfully');
} catch (error) {
  console.error('Error initializing Firebase Admin SDK:', error);
  // Create a mock implementation for development if Firebase isn't configured
  if (!admin.apps.length) {
    console.log('Using mock Firebase implementation for development');
    admin.initializeApp({
      credential: { getAccessToken: () => Promise.resolve({ access_token: 'mock-token', expires_in: 3600 }) }
    });
  }
}

/**
 * Send push notification to a user
 * @param {string} userId - The ID of the user to notify
 * @param {string} title - Notification title
 * @param {string} message - Notification message
 * @param {string} type - Type of notification (booking, message, reminder, marketing)
 * @param {string} relatedId - Optional ID related to the notification (e.g., bookingId, messageId)
 * @returns {Promise<void>}
 */
exports.sendPushNotification = async (userId, title, message, type, relatedId = null) => {
  try {
    // Get user's device tokens
    const deviceTokens = await DeviceToken.findAll({
      where: { userId, isActive: true }
    });
    
    if (!deviceTokens || deviceTokens.length === 0) {
      console.log(`No device tokens found for user ${userId}`);
      return Promise.resolve();
    }
    
    // Extract token values
    const tokens = deviceTokens.map(device => device.token);
    
    console.log('Sending push notification:');
    console.log({
      userId,
      title,
      message,
      type,
      relatedId,
      tokens
    });
    
    // Create notification payload
    const payload = {
      notification: {
        title,
        body: message,
      },
      data: {
        type,
        relatedId: relatedId ? relatedId.toString() : '',
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
      },
    };
    
    try {
      // Send to all user devices
      const response = await admin.messaging().sendMulticast({
        tokens,
        ...payload,
      });
      
      console.log(`Successfully sent message: ${response.successCount} successful, ${response.failureCount} failed`);
      
      // Handle failed tokens
      if (response.failureCount > 0) {
        const failedTokens = [];
        response.responses.forEach((resp, idx) => {
          if (!resp.success) {
            failedTokens.push(tokens[idx]);
            console.log(`Error sending to token ${tokens[idx]}: ${resp.error}`);
          }
        });
        
        // Mark failed tokens as inactive
        if (failedTokens.length > 0) {
          await DeviceToken.update(
            { isActive: false },
            { where: { token: failedTokens } }
          );
        }
      }
      
      return Promise.resolve();
    } catch (fcmError) {
      console.error('Error sending FCM notification:', fcmError);
      return Promise.resolve();
    }
  } catch (error) {
    console.error('Error sending push notification:', error);
    throw error;
  }
};

/**
 * Register a device for push notifications
 * @param {string} userId - The ID of the user
 * @param {string} deviceToken - The device token for push notifications
 * @param {string} platform - The device platform (ios, android, web)
 * @returns {Promise<void>}
 */
exports.registerDevice = async (userId, deviceToken, platform) => {
  try {
    // Check if token already exists
    const existingToken = await DeviceToken.findOne({
      where: { token: deviceToken }
    });
    
    if (existingToken) {
      // Update the userId if it's different
      if (existingToken.userId !== userId) {
        existingToken.userId = userId;
        await existingToken.save();
      }
      
      // Make sure it's active
      if (!existingToken.isActive) {
        existingToken.isActive = true;
        existingToken.lastUsed = new Date();
        await existingToken.save();
      }
    } else {
      // Create new device token
      await DeviceToken.create({
        userId,
        token: deviceToken,
        platform,
        isActive: true,
        lastUsed: new Date()
      });
    }
    
    console.log(`Device registered for user ${userId}`);
    return Promise.resolve();
  } catch (error) {
    console.error('Error registering device:', error);
    throw error;
  }
};

/**
 * Unregister a device from push notifications
 * @param {string} deviceToken - The device token to unregister
 * @returns {Promise<void>}
 */
exports.unregisterDevice = async (deviceToken) => {
  try {
    // Find the device token
    const token = await DeviceToken.findOne({
      where: { token: deviceToken }
    });
    
    if (token) {
      // Instead of deleting, mark as inactive
      token.isActive = false;
      await token.save();
      console.log(`Device token ${deviceToken} marked as inactive`);
    } else {
      console.log(`Device token ${deviceToken} not found`);
    }
    
    return Promise.resolve();
  } catch (error) {
    console.error('Error unregistering device:', error);
    throw error;
  }
};

/**
 * Get all device tokens for a user
 * @param {string} userId - The ID of the user
 * @returns {Promise<Array>} Array of device tokens
 */
exports.getUserDeviceTokens = async (userId) => {
  try {
    const deviceTokens = await DeviceToken.findAll({
      where: { userId, isActive: true }
    });
    
    return deviceTokens.map(device => device.token);
  } catch (error) {
    console.error('Error getting user device tokens:', error);
    throw error;
  }
};



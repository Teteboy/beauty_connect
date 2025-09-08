const { Notification, NotificationSetting } = require('../models');
const { sendPushNotification } = require('./push-notification');

/**
 * Create a notification for a user
 * @param {string} userId - The ID of the user to notify
 * @param {string} title - Notification title
 * @param {string} message - Notification message
 * @param {string} type - Type of notification (booking, message, reminder, marketing)
 * @param {string} relatedId - Optional ID related to the notification (e.g., bookingId, messageId)
 * @returns {Promise<Notification>} The created notification
 */
exports.createNotification = async (userId, title, message, type, relatedId = null) => {
  try {
    // Check user notification settings
    const settings = await NotificationSetting.findOne({
      where: { userId }
    });
    
    // If settings exist, check if this type of notification is enabled
    if (settings) {
      let shouldSend = true;
      
      switch (type) {
        case 'booking':
          shouldSend = settings.bookingNotifications;
          break;
        case 'message':
          shouldSend = settings.messageNotifications;
          break;
        case 'reminder':
          shouldSend = settings.reminderNotifications;
          break;
        case 'marketing':
          shouldSend = settings.marketingNotifications;
          break;
      }
      
      if (!shouldSend) {
        console.log(`Notification type ${type} is disabled for user ${userId}`);
        return null;
      }
    }
    
    // Create notification in database
    const notification = await Notification.create({
      userId,
      title,
      message,
      type,
      relatedId,
      isRead: false
    });
    
    // Send push notification if available
    try {
      await sendPushNotification(userId, title, message, type, relatedId);
    } catch (pushError) {
      console.error('Error sending push notification:', pushError);
      // Continue even if push notification fails
    }
    
    return notification;
  } catch (error) {
    console.error('Error creating notification:', error);
    throw error;
  }
};

/**
 * Create message notification
 * @param {string} senderId - The ID of the message sender
 * @param {string} receiverId - The ID of the message receiver
 * @param {string} senderName - The name of the sender
 * @param {string} messageContent - The content of the message
 * @param {string} messageId - The ID of the message
 */
exports.createMessageNotification = async (senderId, receiverId, senderName, messageContent, messageId) => {
  try {
    const title = `New message from ${senderName}`;
    let message = messageContent;
    
    // Truncate message if too long
    if (message.length > 100) {
      message = message.substring(0, 97) + '...';
    }
    
    await this.createNotification(
      receiverId,
      title,
      message,
      'message',
      messageId
    );
  } catch (error) {
    console.error('Error creating message notification:', error);
    throw error;
  }
};

/**
 * Create booking notifications
 * @param {Object} booking - The booking object
 * @param {string} action - The action (created, updated, canceled)
 */
exports.createBookingNotification = async (booking, action) => {
  try {
    const { customerId, technicianId, serviceId, date, time } = booking;
    
    let customerTitle, customerMessage;
    let technicianTitle, technicianMessage;
    
    const formattedDateTime = `${new Date(date).toLocaleDateString()} at ${time}`;
    
    switch (action) {
      case 'created':
        customerTitle = 'Booking Confirmed';
        customerMessage = `Your booking for ${formattedDateTime} has been confirmed.`;
        
        technicianTitle = 'New Booking';
        technicianMessage = `You have a new booking for ${formattedDateTime}.`;
        break;
        
      case 'updated':
        customerTitle = 'Booking Updated';
        customerMessage = `Your booking has been updated to ${formattedDateTime}.`;
        
        technicianTitle = 'Booking Updated';
        technicianMessage = `A booking has been updated to ${formattedDateTime}.`;
        break;
        
      case 'canceled':
        customerTitle = 'Booking Canceled';
        customerMessage = `Your booking for ${formattedDateTime} has been canceled.`;
        
        technicianTitle = 'Booking Canceled';
        technicianMessage = `A booking for ${formattedDateTime} has been canceled.`;
        break;
    }
    
    // Create notifications for both customer and technician
    await Promise.all([
      this.createNotification(
        customerId,
        customerTitle,
        customerMessage,
        'booking',
        booking.id
      ),
      this.createNotification(
        technicianId,
        technicianTitle,
        technicianMessage,
        'booking',
        booking.id
      )
    ]);
  } catch (error) {
    console.error('Error creating booking notification:', error);
    throw error;
  }
};

/**
 * Create reminder notification
 * @param {string} userId - The ID of the user to remind
 * @param {Object} booking - The booking object
 * @param {number} hoursBeforeAppointment - Hours before the appointment to send reminder
 */
exports.createReminderNotification = async (userId, booking, hoursBeforeAppointment = 24) => {
  try {
    const { date, time, id } = booking;
    
    const title = 'Appointment Reminder';
    const message = `You have an appointment ${hoursBeforeAppointment === 24 ? 'tomorrow' : `in ${hoursBeforeAppointment} hours`} at ${time}.`;
    
    await this.createNotification(
      userId,
      title,
      message,
      'reminder',
      id
    );
  } catch (error) {
    console.error('Error creating reminder notification:', error);
    throw error;
  }
};

/**
 * Create marketing notification
 * @param {Array} userIds - Array of user IDs to notify
 * @param {string} title - Marketing notification title
 * @param {string} message - Marketing notification message
 */
exports.createMarketingNotification = async (userIds, title, message) => {
  try {
    const promises = userIds.map(userId => 
      this.createNotification(
        userId,
        title,
        message,
        'marketing',
        null
      )
    );
    
    await Promise.all(promises);
  } catch (error) {
    console.error('Error creating marketing notification:', error);
    throw error;
  }
};


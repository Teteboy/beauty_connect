const { Notification, User, NotificationSetting, DeviceToken } = require('../models');
const { sendPushNotification, registerDevice, unregisterDevice } = require('../utils/push-notification');

// Get all notifications for current user
exports.getNotifications = async (req, res) => {
  try {
    const userId = req.user.id;
    
    const notifications = await Notification.findAll({
      where: { userId },
      order: [['createdAt', 'DESC']]
    });
    
    res.json(notifications);
  } catch (error) {
    console.error('Error fetching notifications:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Mark notification as read
exports.markAsRead = async (req, res) => {
  try {
    const userId = req.user.id;
    const notificationId = req.params.id;
    
    const notification = await Notification.findOne({
      where: { id: notificationId, userId }
    });
    
    if (!notification) {
      return res.status(404).json({ message: 'Notification not found' });
    }
    
    notification.isRead = true;
    await notification.save();
    
    res.json(notification);
  } catch (error) {
    console.error('Error marking notification as read:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Mark all notifications as read
exports.markAllAsRead = async (req, res) => {
  try {
    const userId = req.user.id;
    
    await Notification.update(
      { isRead: true },
      { where: { userId, isRead: false } }
    );
    
    res.json({ message: 'All notifications marked as read' });
  } catch (error) {
    console.error('Error marking all notifications as read:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Delete a notification
exports.deleteNotification = async (req, res) => {
  try {
    const userId = req.user.id;
    const notificationId = req.params.id;
    
    const notification = await Notification.findOne({
      where: { id: notificationId, userId }
    });
    
    if (!notification) {
      return res.status(404).json({ message: 'Notification not found' });
    }
    
    await notification.destroy();
    
    res.json({ message: 'Notification deleted successfully' });
  } catch (error) {
    console.error('Error deleting notification:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Get notification settings
exports.getSettings = async (req, res) => {
  try {
    const userId = req.user.id;
    
    let settings = await NotificationSetting.findOne({
      where: { userId }
    });
    
    if (!settings) {
      // Create default settings if none exist
      settings = await NotificationSetting.create({
        userId,
        bookingNotifications: true,
        messageNotifications: true,
        reminderNotifications: true,
        marketingNotifications: false
      });
    }
    
    res.json(settings);
  } catch (error) {
    console.error('Error fetching notification settings:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Update notification settings
exports.updateSettings = async (req, res) => {
  try {
    const userId = req.user.id;
    const { 
      bookingNotifications, 
      messageNotifications, 
      reminderNotifications, 
      marketingNotifications 
    } = req.body;
    
    let settings = await NotificationSetting.findOne({
      where: { userId }
    });
    
    if (!settings) {
      // Create settings if none exist
      settings = await NotificationSetting.create({
        userId,
        bookingNotifications: bookingNotifications ?? true,
        messageNotifications: messageNotifications ?? true,
        reminderNotifications: reminderNotifications ?? true,
        marketingNotifications: marketingNotifications ?? false
      });
    } else {
      // Update existing settings
      if (bookingNotifications !== undefined) settings.bookingNotifications = bookingNotifications;
      if (messageNotifications !== undefined) settings.messageNotifications = messageNotifications;
      if (reminderNotifications !== undefined) settings.reminderNotifications = reminderNotifications;
      if (marketingNotifications !== undefined) settings.marketingNotifications = marketingNotifications;
      
      await settings.save();
    }
    
    res.json(settings);
  } catch (error) {
    console.error('Error updating notification settings:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Register device for push notifications
exports.registerDevice = async (req, res) => {
  try {
    const userId = req.user.id;
    const { deviceToken, platform } = req.body;
    
    if (!deviceToken || !platform) {
      return res.status(400).json({ message: 'Device token and platform are required' });
    }
    
    // Check if token already exists
    let deviceTokenRecord = await DeviceToken.findOne({
      where: { token: deviceToken }
    });
    
    if (deviceTokenRecord) {
      // Update the userId if it's different
      if (deviceTokenRecord.userId !== userId) {
        deviceTokenRecord.userId = userId;
        await deviceTokenRecord.save();
      }
      
      // Make sure it's active
      if (!deviceTokenRecord.isActive) {
        deviceTokenRecord.isActive = true;
        deviceTokenRecord.lastUsed = new Date();
        await deviceTokenRecord.save();
      }
    } else {
      // Create new device token
      deviceTokenRecord = await DeviceToken.create({
        userId,
        token: deviceToken,
        platform,
        isActive: true,
        lastUsed: new Date()
      });
    }
    
    res.json({ message: 'Device registered successfully' });
  } catch (error) {
    console.error('Error registering device:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Unregister device from push notifications
exports.unregisterDevice = async (req, res) => {
  try {
    const { deviceToken } = req.body;
    
    if (!deviceToken) {
      return res.status(400).json({ message: 'Device token is required' });
    }
    
    // Find the device token
    const deviceTokenRecord = await DeviceToken.findOne({
      where: { token: deviceToken }
    });
    
    if (deviceTokenRecord) {
      // Instead of deleting, mark as inactive
      deviceTokenRecord.isActive = false;
      await deviceTokenRecord.save();
    }
    
    res.json({ message: 'Device unregistered successfully' });
  } catch (error) {
    console.error('Error unregistering device:', error);
    res.status(500).json({ message: 'Server error' });
  }
};







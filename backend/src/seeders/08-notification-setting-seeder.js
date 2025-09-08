'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    // Create notification settings for users
    return queryInterface.bulkInsert('NotificationSettings', [
      {
        userId: 2, // Sarah (technician)
        bookingNotifications: true,
        messageNotifications: true,
        reminderNotifications: true,
        marketingNotifications: false,
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        userId: 3, // Michael (technician)
        bookingNotifications: true,
        messageNotifications: true,
        reminderNotifications: true,
        marketingNotifications: true,
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        userId: 4, // Emily (technician)
        bookingNotifications: true,
        messageNotifications: true,
        reminderNotifications: true,
        marketingNotifications: false,
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        userId: 5, // John (customer)
        bookingNotifications: true,
        messageNotifications: true,
        reminderNotifications: true,
        marketingNotifications: false,
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        userId: 6, // Jessica (customer)
        bookingNotifications: true,
        messageNotifications: true,
        reminderNotifications: true,
        marketingNotifications: true,
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        userId: 7, // David (customer)
        bookingNotifications: true,
        messageNotifications: false,
        reminderNotifications: true,
        marketingNotifications: false,
        createdAt: new Date(),
        updatedAt: new Date()
      }
    ]);
  },

  down: async (queryInterface, Sequelize) => {
    return queryInterface.bulkDelete('NotificationSettings', null, {});
  }
};
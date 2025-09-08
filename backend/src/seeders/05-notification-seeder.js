'use strict';
const { v4: uuidv4 } = require('uuid');

module.exports = {
  up: async (queryInterface, Sequelize) => {
    // Create timestamps
    const now = new Date();
    const oneHourAgo = new Date(now.getTime() - 3600000);
    const sixHoursAgo = new Date(now.getTime() - 21600000);
    const oneDayAgo = new Date(now.getTime() - 86400000);
    const twoDaysAgo = new Date(now.getTime() - 172800000);
    
    return queryInterface.bulkInsert('Notifications', [
      // Booking notifications
      {
        id: uuidv4(),
        userId: 2, // Sarah (technician)
        title: 'New Booking Request',
        message: 'John Smith has requested a Haircut & Styling appointment',
        type: 'booking',
        isRead: true,
        relatedId: '1', // Booking ID
        createdAt: twoDaysAgo,
        updatedAt: twoDaysAgo
      },
      {
        id: uuidv4(),
        userId: 3, // Michael (technician)
        title: 'New Booking Request',
        message: 'Jessica Wilson has requested a Manicure appointment',
        type: 'booking',
        isRead: true,
        relatedId: '2', // Booking ID
        createdAt: twoDaysAgo,
        updatedAt: twoDaysAgo
      },
      {
        id: uuidv4(),
        userId: 4, // Emily (technician)
        title: 'New Booking Request',
        message: 'David Miller has requested a Special Event Makeup appointment',
        type: 'booking',
        isRead: true,
        relatedId: '3', // Booking ID
        createdAt: oneDayAgo,
        updatedAt: oneDayAgo
      },
      {
        id: uuidv4(),
        userId: 2, // Sarah (technician)
        title: 'New Booking Request',
        message: 'Jessica Wilson has requested a Hair Coloring appointment',
        type: 'booking',
        isRead: false,
        relatedId: '5', // Booking ID
        createdAt: oneHourAgo,
        updatedAt: oneHourAgo
      },
      
      // Message notifications
      {
        id: uuidv4(),
        userId: 2, // Sarah (technician)
        title: 'New Message',
        message: 'You have a new message from John Smith',
        type: 'message',
        isRead: true,
        relatedId: '1', // Message ID
        createdAt: twoDaysAgo,
        updatedAt: twoDaysAgo
      },
      {
        id: uuidv4(),
        userId: 5, // John (customer)
        title: 'New Message',
        message: 'You have a new message from Sarah Johnson',
        type: 'message',
        isRead: true,
        relatedId: '2', // Message ID
        createdAt: twoDaysAgo,
        updatedAt: twoDaysAgo
      },
      {
        id: uuidv4(),
        userId: 3, // Michael (technician)
        title: 'New Message',
        message: 'You have a new message from Jessica Wilson',
        type: 'message',
        isRead: true,
        relatedId: '5', // Message ID
        createdAt: oneDayAgo,
        updatedAt: oneDayAgo
      },
      {
        id: uuidv4(),
        userId: 7, // David (customer)
        title: 'New Message',
        message: 'You have a new message from Emily Davis',
        type: 'message',
        isRead: false,
        relatedId: '9', // Message ID
        createdAt: oneHourAgo,
        updatedAt: oneHourAgo
      },
      
      // System notifications
      {
        id: uuidv4(),
        userId: 5, // John (customer)
        title: 'Booking Confirmed',
        message: 'Your appointment with Sarah Johnson has been confirmed',
        type: 'system',
        isRead: true,
        relatedId: '1', // Booking ID
        createdAt: twoDaysAgo,
        updatedAt: twoDaysAgo
      },
      {
        id: uuidv4(),
        userId: 6, // Jessica (customer)
        title: 'Booking Completed',
        message: 'Your appointment with Michael Brown has been completed. Please leave a review!',
        type: 'system',
        isRead: false,
        relatedId: '2', // Booking ID
        createdAt: sixHoursAgo,
        updatedAt: sixHoursAgo
      }
    ]);
  },

  down: async (queryInterface, Sequelize) => {
    return queryInterface.bulkDelete('Notifications', null, {});
  }
};

'use strict';
const { v4: uuidv4 } = require('uuid');

module.exports = {
  up: async (queryInterface, Sequelize) => {
    // Create dates for bookings
    const today = new Date();
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);
    
    const nextWeek = new Date(today);
    nextWeek.setDate(nextWeek.getDate() + 7);
    
    const lastWeek = new Date(today);
    lastWeek.setDate(lastWeek.getDate() - 7);
    
    return queryInterface.bulkInsert('Bookings', [
      // Completed bookings
      {
        id: uuidv4(),
        customerId: 5, // John
        technicianId: 2, // Sarah
        serviceId: 1, // Haircut & Styling
        dateTime: lastWeek,
        status: 'completed',
        notes: 'First time customer',
        price: 50.00,
        createdAt: new Date(lastWeek.getTime() - 86400000), // 1 day before booking
        updatedAt: new Date(lastWeek.getTime() + 3600000) // 1 hour after booking
      },
      {
        id: uuidv4(),
        customerId: 6, // Jessica
        technicianId: 3, // Michael
        serviceId: 4, // Manicure
        dateTime: lastWeek,
        status: 'completed',
        notes: 'Preferred light pink color',
        price: 35.00,
        createdAt: new Date(lastWeek.getTime() - 172800000), // 2 days before booking
        updatedAt: new Date(lastWeek.getTime() + 3600000) // 1 hour after booking
      },
      
      // Confirmed bookings (upcoming)
      {
        id: uuidv4(),
        customerId: 7, // David
        technicianId: 4, // Emily
        serviceId: 8, // Special Event Makeup
        dateTime: tomorrow,
        status: 'confirmed',
        notes: 'For anniversary dinner',
        price: 85.00,
        createdAt: new Date(today.getTime() - 259200000), // 3 days ago
        updatedAt: new Date(today.getTime() - 172800000) // 2 days ago (when confirmed)
      },
      {
        id: uuidv4(),
        customerId: 5, // John
        technicianId: 3, // Michael
        serviceId: 5, // Pedicure
        dateTime: nextWeek,
        status: 'confirmed',
        notes: '',
        price: 45.00,
        createdAt: new Date(today.getTime() - 86400000), // 1 day ago
        updatedAt: new Date(today.getTime() - 43200000) // 12 hours ago (when confirmed)
      },
      
      // Pending bookings
      {
        id: uuidv4(),
        customerId: 6, // Jessica
        technicianId: 2, // Sarah
        serviceId: 2, // Hair Coloring
        dateTime: nextWeek,
        status: 'pending',
        notes: 'Interested in balayage technique',
        price: 85.00,
        createdAt: new Date(today.getTime() - 3600000), // 1 hour ago
        updatedAt: new Date(today.getTime() - 3600000) // 1 hour ago
      },
      
      // Cancelled booking
      {
        id: uuidv4(),
        customerId: 7, // David
        technicianId: 4, // Emily
        serviceId: 7, // Natural Makeup
        dateTime: tomorrow,
        status: 'cancelled',
        notes: 'Had to reschedule',
        price: 60.00,
        createdAt: new Date(today.getTime() - 432000000), // 5 days ago
        updatedAt: new Date(today.getTime() - 259200000) // 3 days ago (when cancelled)
      }
    ]);
  },

  down: async (queryInterface, Sequelize) => {
    return queryInterface.bulkDelete('Bookings', null, {});
  }
};
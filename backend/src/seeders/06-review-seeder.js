'use strict';
const { v4: uuidv4 } = require('uuid');

module.exports = {
  up: async (queryInterface, Sequelize) => {
    // First, get the actual booking IDs from the database
    const bookings = await queryInterface.sequelize.query(
      'SELECT id FROM "Bookings" LIMIT 2;',
      { type: queryInterface.sequelize.QueryTypes.SELECT }
    );
    
    if (bookings.length < 2) {
      console.log('Warning: Not enough bookings found for review seeding');
      return Promise.resolve();
    }

    return queryInterface.bulkInsert('Reviews', [
      {
        id: 1,
        bookingId: bookings[0].id, // Use actual UUID from database
        customerId: 5, // John
        technicianId: 2, // Sarah
        rating: 5,
        comment: 'Sarah did an amazing job with my haircut! Very professional and friendly. Will definitely book again.',
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        id: 2,
        bookingId: bookings[1].id, // Use actual UUID from database
        customerId: 6, // Jessica
        technicianId: 3, // Michael
        rating: 4,
        comment: 'Great service and attention to detail. The manicure looks beautiful and has lasted well.',
        createdAt: new Date(),
        updatedAt: new Date()
      }
    ]);
  },

  down: async (queryInterface, Sequelize) => {
    return queryInterface.bulkDelete('Reviews', null, {});
  }
};




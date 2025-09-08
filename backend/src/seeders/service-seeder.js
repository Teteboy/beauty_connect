'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    return queryInterface.bulkInsert('Services', [
      {
        name: 'Haircut',
        description: 'Professional haircut service',
        price: 50.00,
        durationMinutes: 30,  // Updated field name
        category: 'Hair',
        imageUrl: 'https://example.com/haircut.jpg',  // Updated field name
        isAvailable: true,  // Added field
        technicianId: 1,
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        name: 'Manicure',
        description: 'Professional nail care for hands',
        price: 35.00,
        durationMinutes: 45,  // Updated field name
        category: 'Nails',
        imageUrl: 'https://example.com/manicure.jpg',  // Updated field name
        isAvailable: true,  // Added field
        technicianId: 2,
        createdAt: new Date(),
        updatedAt: new Date()
      },
      // Add more services as needed
    ]);
  },

  down: async (queryInterface, Sequelize) => {
    return queryInterface.bulkDelete('Services', null, {});
  }
};
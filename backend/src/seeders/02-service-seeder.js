'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    return queryInterface.bulkInsert('Services', [
      // Hair services (Sarah - ID 2)
      {
        name: 'Haircut & Styling',
        description: 'Professional haircut and styling service tailored to your preferences.',
        price: 50.00,
        durationMinutes: 60,
        category: 'Hair',
        imageUrl: 'https://images.unsplash.com/photo-1560066984-138dadb4c035',
        isAvailable: true,
        technicianId: 2,
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        name: 'Hair Coloring',
        description: 'Full hair coloring service using premium products for vibrant, long-lasting color.',
        price: 85.00,
        durationMinutes: 120,
        category: 'Hair',
        imageUrl: 'https://images.unsplash.com/photo-1519165678289-8dec49bc74f0',
        isAvailable: true,
        technicianId: 2,
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        name: 'Blowout',
        description: 'Professional blow dry and styling for any occasion.',
        price: 40.00,
        durationMinutes: 45,
        category: 'Hair',
        imageUrl: 'https://images.unsplash.com/photo-1522336572468-97b06e8ef143',
        isAvailable: true,
        technicianId: 2,
        createdAt: new Date(),
        updatedAt: new Date()
      },
      
      // Nail services (Michael - ID 3)
      {
        name: 'Manicure',
        description: 'Classic manicure including nail shaping, cuticle care, and polish application.',
        price: 35.00,
        durationMinutes: 45,
        category: 'Nails',
        imageUrl: 'https://images.unsplash.com/photo-1604654894610-df63bc536371',
        isAvailable: true,
        technicianId: 3,
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        name: 'Pedicure',
        description: 'Relaxing pedicure treatment including foot soak, exfoliation, and polish.',
        price: 45.00,
        durationMinutes: 60,
        category: 'Nails',
        imageUrl: 'https://images.unsplash.com/photo-1632345031435-8727f6897d53',
        isAvailable: true,
        technicianId: 3,
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        name: 'Gel Nails',
        description: 'Long-lasting gel nail application with a wide selection of colors.',
        price: 55.00,
        durationMinutes: 75,
        category: 'Nails',
        imageUrl: 'https://images.unsplash.com/photo-1607779097040-26e80aa78e66',
        isAvailable: true,
        technicianId: 3,
        createdAt: new Date(),
        updatedAt: new Date()
      },
      
      // Makeup services (Emily - ID 4)
      {
        name: 'Natural Makeup',
        description: 'Everyday makeup application that enhances your natural beauty.',
        price: 60.00,
        durationMinutes: 45,
        category: 'Makeup',
        imageUrl: 'https://images.unsplash.com/photo-1503236823255-94609f598e71',
        isAvailable: true,
        technicianId: 4,
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        name: 'Special Event Makeup',
        description: 'Glamorous makeup application perfect for special occasions and events.',
        price: 85.00,
        durationMinutes: 60,
        category: 'Makeup',
        imageUrl: 'https://images.unsplash.com/photo-1526045478516-99145907023c',
        isAvailable: true,
        technicianId: 4,
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        name: 'Bridal Makeup',
        description: 'Complete bridal makeup service including consultation and trial.',
        price: 150.00,
        durationMinutes: 90,
        category: 'Makeup',
        imageUrl: 'https://images.unsplash.com/photo-1519699047748-de8e457a634e',
        isAvailable: true,
        technicianId: 4,
        createdAt: new Date(),
        updatedAt: new Date()
      }
    ]);
  },

  down: async (queryInterface, Sequelize) => {
    return queryInterface.bulkDelete('Services', null, {});
  }
};
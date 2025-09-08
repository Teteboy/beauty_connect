'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    // Create sample device tokens for testing
    return queryInterface.bulkInsert('DeviceTokens', [
      {
        userId: 2, // Sarah (technician)
        token: 'sample_ios_token_sarah_1',
        platform: 'ios',
        isActive: true,
        lastUsed: new Date(),
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        userId: 3, // Michael (technician)
        token: 'sample_android_token_michael_1',
        platform: 'android',
        isActive: true,
        lastUsed: new Date(),
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        userId: 5, // John (customer)
        token: 'sample_ios_token_john_1',
        platform: 'ios',
        isActive: true,
        lastUsed: new Date(),
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        userId: 6, // Jessica (customer)
        token: 'sample_android_token_jessica_1',
        platform: 'android',
        isActive: true,
        lastUsed: new Date(),
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        userId: 5, // John's second device
        token: 'sample_web_token_john_2',
        platform: 'web',
        isActive: true,
        lastUsed: new Date(),
        createdAt: new Date(),
        updatedAt: new Date()
      }
    ]);
  },

  down: async (queryInterface, Sequelize) => {
    return queryInterface.bulkDelete('DeviceTokens', null, {});
  }
};
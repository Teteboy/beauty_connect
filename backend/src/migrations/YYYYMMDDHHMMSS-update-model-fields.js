'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    // Service model updates
    await queryInterface.renameColumn('Services', 'duration', 'durationMinutes');
    await queryInterface.renameColumn('Services', 'image', 'imageUrl');
    await queryInterface.addColumn('Services', 'isAvailable', {
      type: Sequelize.BOOLEAN,
      defaultValue: true
    });

    // Message model updates
    await queryInterface.renameColumn('Messages', 'recipientId', 'receiverId');
    await queryInterface.addColumn('Messages', 'timestamp', {
      type: Sequelize.DATE,
      defaultValue: Sequelize.NOW
    });

    // Booking model updates
    await queryInterface.renameColumn('Bookings', 'bookingDate', 'dateTime');
    await queryInterface.addColumn('Bookings', 'price', {
      type: Sequelize.DECIMAL(10, 2),
      allowNull: true
    });

    // User model updates
    await queryInterface.addColumn('Users', 'specialty', {
      type: Sequelize.STRING,
      allowNull: true
    });
  },

  down: async (queryInterface, Sequelize) => {
    // Revert Service model updates
    await queryInterface.renameColumn('Services', 'durationMinutes', 'duration');
    await queryInterface.renameColumn('Services', 'imageUrl', 'image');
    await queryInterface.removeColumn('Services', 'isAvailable');

    // Revert Message model updates
    await queryInterface.renameColumn('Messages', 'receiverId', 'recipientId');
    await queryInterface.removeColumn('Messages', 'timestamp');

    // Revert Booking model updates
    await queryInterface.renameColumn('Bookings', 'dateTime', 'bookingDate');
    await queryInterface.removeColumn('Bookings', 'price');

    // Revert User model updates
    await queryInterface.removeColumn('Users', 'specialty');
  }
};
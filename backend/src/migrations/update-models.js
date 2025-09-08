'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    // Update Service table
    await queryInterface.renameColumn('Services', 'duration', 'durationMinutes');
    await queryInterface.renameColumn('Services', 'image', 'imageUrl');
    await queryInterface.addColumn('Services', 'isAvailable', {
      type: Sequelize.BOOLEAN,
      defaultValue: true
    });

    // Update Message table
    await queryInterface.renameColumn('Messages', 'recipientId', 'receiverId');
    await queryInterface.addColumn('Messages', 'timestamp', {
      type: Sequelize.DATE,
      defaultValue: Sequelize.NOW
    });

    // Update Booking table
    await queryInterface.renameColumn('Bookings', 'bookingDate', 'dateTime');
    await queryInterface.addColumn('Bookings', 'price', {
      type: Sequelize.DECIMAL(10, 2),
      allowNull: true
    });

    // Update User table
    await queryInterface.addColumn('Users', 'specialty', {
      type: Sequelize.STRING,
      allowNull: true
    });
  },

  down: async (queryInterface, Sequelize) => {
    // Revert Service table changes
    await queryInterface.renameColumn('Services', 'durationMinutes', 'duration');
    await queryInterface.renameColumn('Services', 'imageUrl', 'image');
    await queryInterface.removeColumn('Services', 'isAvailable');

    // Revert Message table changes
    await queryInterface.renameColumn('Messages', 'receiverId', 'recipientId');
    await queryInterface.removeColumn('Messages', 'timestamp');

    // Revert Booking table changes
    await queryInterface.renameColumn('Bookings', 'dateTime', 'bookingDate');
    await queryInterface.removeColumn('Bookings', 'price');

    // Revert User table changes
    await queryInterface.removeColumn('Users', 'specialty');
  }
};
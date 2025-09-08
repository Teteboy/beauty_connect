'use strict';
const bcrypt = require('bcryptjs');

module.exports = {
  up: async (queryInterface, Sequelize) => {
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash('password123', salt);
    
    return queryInterface.bulkInsert('Users', [
      // Admin user
      {
        firstName: 'Admin',
        lastName: 'User',
        email: 'admin@example.com',
        password: hashedPassword,
        phone: '1234567890',
        role: 'admin',
        location: 'New York, NY',
        bio: 'System administrator',
        isVerified: true,
        createdAt: new Date(),
        updatedAt: new Date()
      },
      // Technicians
      {
        firstName: 'Sarah',
        lastName: 'Johnson',
        email: 'sarah@example.com',
        password: hashedPassword,
        phone: '2345678901',
        role: 'technician',
        location: 'Los Angeles, CA',
        bio: 'Professional hairstylist with 5 years of experience',
        profileImage: 'https://randomuser.me/api/portraits/women/1.jpg',
        specialty: 'Hair Styling',
        isVerified: true,
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        firstName: 'Michael',
        lastName: 'Brown',
        email: 'michael@example.com',
        password: hashedPassword,
        phone: '3456789012',
        role: 'technician',
        location: 'Chicago, IL',
        bio: 'Certified nail technician specializing in nail art',
        profileImage: 'https://randomuser.me/api/portraits/men/1.jpg',
        specialty: 'Nail Care',
        isVerified: true,
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        firstName: 'Emily',
        lastName: 'Davis',
        email: 'emily@example.com',
        password: hashedPassword,
        phone: '4567890123',
        role: 'technician',
        location: 'Miami, FL',
        bio: 'Makeup artist with experience in bridal and special events',
        profileImage: 'https://randomuser.me/api/portraits/women/2.jpg',
        specialty: 'Makeup',
        isVerified: true,
        createdAt: new Date(),
        updatedAt: new Date()
      },
      // Customers
      {
        firstName: 'John',
        lastName: 'Smith',
        email: 'john@example.com',
        password: hashedPassword,
        phone: '5678901234',
        role: 'customer',
        location: 'Boston, MA',
        isVerified: true,
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        firstName: 'Jessica',
        lastName: 'Wilson',
        email: 'jessica@example.com',
        password: hashedPassword,
        phone: '6789012345',
        role: 'customer',
        location: 'Seattle, WA',
        profileImage: 'https://randomuser.me/api/portraits/women/3.jpg',
        isVerified: true,
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        firstName: 'David',
        lastName: 'Miller',
        email: 'david@example.com',
        password: hashedPassword,
        phone: '7890123456',
        role: 'customer',
        location: 'Denver, CO',
        profileImage: 'https://randomuser.me/api/portraits/men/2.jpg',
        isVerified: true,
        createdAt: new Date(),
        updatedAt: new Date()
      }
    ]);
  },

  down: async (queryInterface, Sequelize) => {
    return queryInterface.bulkDelete('Users', null, {});
  }
};
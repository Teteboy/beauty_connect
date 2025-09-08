'use strict';

const { sequelize } = require('../models');
const userSeeder = require('./01-user-seeder');
const serviceSeeder = require('./02-service-seeder');
const bookingSeeder = require('./03-booking-seeder');
const messageSeeder = require('./04-message-seeder');
const notificationSeeder = require('./05-notification-seeder');
const reviewSeeder = require('./06-review-seeder');
const deviceTokenSeeder = require('./07-device-token-seeder');
const notificationSettingSeeder = require('./08-notification-setting-seeder');
const serviceImageSeeder = require('./09-service-image-seeder');

async function seedDatabase() {
  try {
    console.log('Starting database seeding...');
    
    // First, sync the database to create tables
    console.log('Creating database tables...');
    await sequelize.sync({ force: true });
    console.log('✓ Database tables created');
    
    // Run seeders in order
    console.log('Seeding users...');
    await userSeeder.up(sequelize.getQueryInterface(), sequelize);
    console.log('✓ Users seeded');
    
    console.log('Seeding services...');
    await serviceSeeder.up(sequelize.getQueryInterface(), sequelize);
    console.log('✓ Services seeded');
    
    console.log('Seeding service images...');
    await serviceImageSeeder.up(sequelize.getQueryInterface(), sequelize);
    console.log('✓ Service images seeded');
    
    console.log('Seeding bookings...');
    await bookingSeeder.up(sequelize.getQueryInterface(), sequelize);
    console.log('✓ Bookings seeded');
    
    console.log('Seeding messages...');
    await messageSeeder.up(sequelize.getQueryInterface(), sequelize);
    console.log('✓ Messages seeded');
    
    console.log('Seeding notifications...');
    await notificationSeeder.up(sequelize.getQueryInterface(), sequelize);
    console.log('✓ Notifications seeded');
    
    console.log('Seeding reviews...');
    await reviewSeeder.up(sequelize.getQueryInterface(), sequelize);
    console.log('✓ Reviews seeded');
    
    console.log('Seeding device tokens...');
    await deviceTokenSeeder.up(sequelize.getQueryInterface(), sequelize);
    console.log('✓ Device tokens seeded');
    
    console.log('Seeding notification settings...');
    await notificationSettingSeeder.up(sequelize.getQueryInterface(), sequelize);
    console.log('✓ Notification settings seeded');
    
    console.log('Database seeding completed successfully!');
  } catch (error) {
    console.error('Error seeding database:', error);
    throw error;
  } finally {
    await sequelize.close();
    process.exit();
  }
}

// Only run if this file is executed directly
if (require.main === module) {
  seedDatabase();
}

module.exports = { seedDatabase };



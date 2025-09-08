'use strict';

const { sequelize } = require('../models');
const { seedDatabase } = require('../seeders/index');

async function resetDatabase() {
  try {
    console.log('Starting database reset...');
    
    // Drop all tables
    console.log('Dropping all tables...');
    await sequelize.drop();
    console.log('✓ All tables dropped');
    
    // The seedDatabase function now handles table creation and seeding
    await seedDatabase();
    
    console.log('Database reset completed successfully!');
  } catch (error) {
    console.error('Error resetting database:', error);
  } finally {
    // Don't exit here since seedDatabase already calls process.exit()
  }
}

// Run the reset if this file is executed directly
if (require.main === module) {
  resetDatabase();
}

module.exports = {
  resetDatabase
};

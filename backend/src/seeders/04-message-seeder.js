'use strict';
const { v4: uuidv4 } = require('uuid');

module.exports = {
  up: async (queryInterface, Sequelize) => {
    // Create timestamps for messages
    const now = new Date();
    
    // Create timestamps for a conversation (3 days ago)
    const threeDaysAgo = new Date(now.getTime() - 259200000);
    const timestamp1 = new Date(threeDaysAgo.getTime());
    const timestamp2 = new Date(threeDaysAgo.getTime() + 300000); // 5 minutes later
    const timestamp3 = new Date(threeDaysAgo.getTime() + 600000); // 10 minutes later
    const timestamp4 = new Date(threeDaysAgo.getTime() + 900000); // 15 minutes later
    
    // Create timestamps for another conversation (yesterday)
    const yesterday = new Date(now.getTime() - 86400000);
    const timestamp5 = new Date(yesterday.getTime());
    const timestamp6 = new Date(yesterday.getTime() + 300000); // 5 minutes later
    const timestamp7 = new Date(yesterday.getTime() + 3600000); // 1 hour later
    
    // Create timestamps for a recent conversation (today)
    const timestamp8 = new Date(now.getTime() - 7200000); // 2 hours ago
    const timestamp9 = new Date(now.getTime() - 3600000); // 1 hour ago
    
    return queryInterface.bulkInsert('Messages', [
      // Conversation between John (5) and Sarah (2)
      {
        id: uuidv4(),
        senderId: 5, // John
        receiverId: 2, // Sarah
        content: 'Hi Sarah, I\'m interested in booking a haircut. Do you have any availability this week?',
        timestamp: timestamp1,
        isRead: true,
        createdAt: timestamp1,
        updatedAt: timestamp1
      },
      {
        id: uuidv4(),
        senderId: 2, // Sarah
        receiverId: 5, // John
        content: 'Hello John! Yes, I have openings on Thursday afternoon and Friday morning. What works best for you?',
        timestamp: timestamp2,
        isRead: true,
        createdAt: timestamp2,
        updatedAt: timestamp2
      },
      {
        id: uuidv4(),
        senderId: 5, // John
        receiverId: 2, // Sarah
        content: 'Thursday afternoon would be perfect. Around 2pm?',
        timestamp: timestamp3,
        isRead: true,
        createdAt: timestamp3,
        updatedAt: timestamp3
      },
      {
        id: uuidv4(),
        senderId: 2, // Sarah
        receiverId: 5, // John
        content: 'Great! I\'ve reserved 2pm on Thursday for you. Looking forward to seeing you then!',
        timestamp: timestamp4,
        isRead: true,
        createdAt: timestamp4,
        updatedAt: timestamp4
      },
      
      // Conversation between Jessica (6) and Michael (3)
      {
        id: uuidv4(),
        senderId: 6, // Jessica
        receiverId: 3, // Michael
        content: 'Hi Michael, I\'m wondering if you offer nail art services?',
        timestamp: timestamp5,
        isRead: true,
        createdAt: timestamp5,
        updatedAt: timestamp5
      },
      {
        id: uuidv4(),
        senderId: 3, // Michael
        receiverId: 6, // Jessica
        content: 'Hello Jessica! Yes, I specialize in nail art. Did you have a specific design in mind?',
        timestamp: timestamp6,
        isRead: true,
        createdAt: timestamp6,
        updatedAt: timestamp6
      },
      {
        id: uuidv4(),
        senderId: 6, // Jessica
        receiverId: 3, // Michael
        content: 'I was thinking something floral for an upcoming event. How much would that cost?',
        timestamp: timestamp7,
        isRead: true,
        createdAt: timestamp7,
        updatedAt: timestamp7
      },
      
      // Conversation between David (7) and Emily (4)
      {
        id: uuidv4(),
        senderId: 7, // David
        receiverId: 4, // Emily
        content: 'Hi Emily, I need to reschedule my appointment for tomorrow. Is that possible?',
        timestamp: timestamp8,
        isRead: true,
        createdAt: timestamp8,
        updatedAt: timestamp8
      },
      {
        id: uuidv4(),
        senderId: 4, // Emily
        receiverId: 7, // David
        content: 'Hi David, no problem! I have availability next week on Tuesday or Wednesday. Would either of those work?',
        timestamp: timestamp9,
        isRead: false, // Unread message
        createdAt: timestamp9,
        updatedAt: timestamp9
      }
    ]);
  },

  down: async (queryInterface, Sequelize) => {
    return queryInterface.bulkDelete('Messages', null, {});
  }
};
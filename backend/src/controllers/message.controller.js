const { Message, User, Notification } = require('../models');
const { Op } = require('sequelize');
const sequelize = require('sequelize');
const notificationHelper = require('../utils/notification-helper');

// Get all conversations for the current user
exports.getConversations = async (req, res) => {
  try {
    const userId = req.user.id;

    // Find all unique users the current user has exchanged messages with
    const conversations = await Message.findAll({
      where: {
        [Op.or]: [
          { senderId: userId },
          { receiverId: userId }
        ]
      },
      attributes: [
        [sequelize.fn('DISTINCT', 
          sequelize.literal(
            `CASE WHEN "senderId" = ${userId} THEN "receiverId" ELSE "senderId" END`
          )
        ), 'userId']
      ],
      raw: true
    });
    
    // Get user details and last message for each conversation
    const conversationDetails = await Promise.all(
      conversations.map(async (conv) => {
        const otherUserId = conv.userId;
        
        // Get user details
        const user = await User.findByPk(otherUserId, {
          attributes: ['id', 'firstName', 'lastName', 'profileImage']
        });
        
        // Get last message
        const lastMessage = await Message.findOne({
          where: {
            [Op.or]: [
              { senderId: userId, receiverId: otherUserId },
              { senderId: otherUserId, receiverId: userId }
            ]
          },
          order: [['createdAt', 'DESC']]
        });
        
        // Count unread messages
        const unreadCount = await Message.count({
          where: {
            senderId: otherUserId,
            receiverId: userId,
            isRead: false
          }
        });
        
        return {
          user: user ? user.get({ plain: true }) : null,
          lastMessage: lastMessage ? lastMessage.get({ plain: true }) : null,
          unreadCount
        };
      })
    );
    
    // Filter out null users (in case a user was deleted)
    const validConversations = conversationDetails.filter(conv => conv.user !== null);
    
    // Convert all IDs to strings to match Flutter models
    const formattedConversations = validConversations.map(conv => {
      if (conv.user) {
        conv.user.id = conv.user.id.toString();
      }
      if (conv.lastMessage) {
        conv.lastMessage.id = conv.lastMessage.id.toString();
        conv.lastMessage.senderId = conv.lastMessage.senderId.toString();
        conv.lastMessage.receiverId = conv.lastMessage.receiverId.toString();
        // Ensure timestamp is in ISO format
        if (conv.lastMessage.createdAt) {
          conv.lastMessage.timestamp = conv.lastMessage.createdAt;
        }
      }
      return conv;
    });
    
    res.status(200).json(formattedConversations);
  } catch (error) {
    console.error('Get conversations error:', error);
    res.status(500).json({ message: 'Server error while fetching conversations' });
  }
};

// Get messages between current user and another user
exports.getMessagesByUser = async (req, res) => {
  try {
    const currentUserId = req.user.id;
    const otherUserId = req.params.userId;
    
    // Get messages between the two users
    const messages = await Message.findAll({
      where: {
        [Op.or]: [
          { senderId: currentUserId, receiverId: otherUserId },
          { senderId: otherUserId, receiverId: currentUserId }
        ]
      },
      order: [['createdAt', 'ASC']],
      include: [
        {
          model: User,
          as: 'sender',
          attributes: ['id', 'firstName', 'lastName', 'profileImage']
        }
      ]
    });
    
    // Convert to plain objects and format IDs as strings
    const formattedMessages = messages.map(message => {
      const plainMessage = message.get({ plain: true });
      plainMessage.id = plainMessage.id.toString();
      plainMessage.senderId = plainMessage.senderId.toString();
      plainMessage.receiverId = plainMessage.receiverId.toString();
      if (plainMessage.sender) {
        plainMessage.sender.id = plainMessage.sender.id.toString();
      }
      // Ensure timestamp is in ISO format
      plainMessage.timestamp = plainMessage.createdAt;
      return plainMessage;
    });
    
    res.status(200).json(formattedMessages);
  } catch (error) {
    console.error('Get messages error:', error);
    res.status(500).json({ message: 'Server error while fetching messages' });
  }
};

// Send a new message
exports.sendMessage = async (req, res) => {
  try {
    const senderId = req.user.id;
    const { receiverId, content } = req.body;
    
    // Convert receiverId to integer if needed
    const receiverIdInt = parseInt(receiverId, 10);
    
    if (!receiverIdInt || !content) {
      return res.status(400).json({ message: 'Receiver ID and content are required' });
    }
    
    // Create message without specifying ID (let Sequelize handle it)
    const messageData = {
      senderId,
      receiverId: receiverIdInt,
      content,
      isRead: false,
      timestamp: new Date()
    };
    
    console.log('Creating message with data:', messageData);
    
    const message = await Message.create(messageData);
    
    console.log('Message created:', message.toJSON());
    
    // Create notification for recipient
    await notificationHelper.createMessageNotification(
      senderId,
      receiverIdInt,
      `${req.user.firstName} ${req.user.lastName}`,
      content,
      message.id.toString()
    );
    
    res.status(201).json(message);
  } catch (error) {
    console.error('Error sending message:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Mark messages as read
exports.markAsRead = async (req, res) => {
  try {
    const currentUserId = req.user.id;
    const otherUserId = req.params.userId;
    
    await Message.update(
      { isRead: true },
      {
        where: {
          senderId: otherUserId,
          receiverId: currentUserId,
          isRead: false
        }
      }
    );
    
    res.json({ message: 'Messages marked as read' });
  } catch (error) {
    console.error('Error marking messages as read:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Example of get conversation function
exports.getConversation = async (req, res) => {
  try {
    const userId = req.user.id;
    const otherUserId = req.params.userId;
    
    const messages = await Message.findAll({
      where: {
        [Op.or]: [
          { senderId: userId, receiverId: otherUserId },  // Changed from recipientId
          { senderId: otherUserId, receiverId: userId }   // Changed from recipientId
        ]
      },
      order: [['timestamp', 'ASC']],  // Changed from createdAt to timestamp
      include: [
        {
          model: User,
          as: 'sender',
          attributes: ['id', 'firstName', 'lastName', 'profileImage']
        },
        {
          model: User,
          as: 'recipient',  // Make sure this matches the association alias
          attributes: ['id', 'firstName', 'lastName', 'profileImage']
        }
      ]
    });
    
    res.status(200).json(messages);
  } catch (error) {
    console.error('Get conversation error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};





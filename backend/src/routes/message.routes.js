const express = require('express');
const router = express.Router();
const { check } = require('express-validator');
const messageController = require('../controllers/message.controller');
const authMiddleware = require('../middleware/auth.middleware');
const validationMiddleware = require('../middleware/validation.middleware');

// Test route to check if message routes are working (no auth required)
router.get('/test', (req, res) => {
  res.status(200).json({ message: 'Message routes are working' });
});

// Get all conversations for current user
router.get('/conversations', authMiddleware, messageController.getConversations);

// Get messages between current user and another user
router.get('/conversations/:userId', authMiddleware, messageController.getMessagesByUser);

// Send a message
router.post(
  '/',
  [
    authMiddleware,
    check('receiverId', 'Receiver ID is required').not().isEmpty(),
    check('content', 'Message content is required').not().isEmpty(),
    validationMiddleware
  ],
  messageController.sendMessage
);

// Mark messages as read
router.put('/:userId/read', authMiddleware, messageController.markAsRead);

module.exports = router;


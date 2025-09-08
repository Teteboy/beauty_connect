const express = require('express');
const router = express.Router();
const analyticsController = require('../controllers/analytics.controller');
const authMiddleware = require('../middleware/auth.middleware');

// Get analytics data for authenticated user
router.get('/', authMiddleware, analyticsController.getAnalytics);

module.exports = router;
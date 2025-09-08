const express = require('express');
const router = express.Router();
const { check } = require('express-validator');
const authController = require('../controllers/auth.controller');
const authMiddleware = require('../middleware/auth.middleware');
const validationMiddleware = require('../middleware/validation.middleware');

// Register user
router.post(
  '/register',
  [
    check('firstName', 'First name is required').not().isEmpty(),
    check('lastName', 'Last name is required').not().isEmpty(),
    check('email', 'Please include a valid email').isEmail(),
    check('password', 'Password must be at least 6 characters').isLength({ min: 6 }),
    check('role', 'Role must be either customer or technician').isIn(['customer', 'technician']),
    validationMiddleware
  ],
  authController.register
);

// Login user
router.post(
  '/login',
  [
    check('email', 'Please include a valid email').isEmail(),
    check('password', 'Password is required').exists(),
    validationMiddleware
  ],
  authController.login
);

// Get current user
router.get('/me', authMiddleware, authController.getProfile);

// Update user profile
router.put('/profile', authMiddleware, authController.updateProfile);

// Forgot password
router.post(
  '/forgot-password',
  [
    check('email', 'Please include a valid email').isEmail(),
    validationMiddleware
  ],
  authController.forgotPassword
);

// Reset password
router.post(
  '/reset-password',
  [
    check('token', 'Token is required').not().isEmpty(),
    check('password', 'Password must be at least 6 characters').isLength({ min: 6 }),
    validationMiddleware
  ],
  authController.resetPassword
);

// Get all technicians
router.get('/technicians', authController.getTechnicians);

// Get user by ID
router.get('/users/:id', authController.getUserById);

// Get users by role (for chat functionality)
router.get('/users', authMiddleware, authController.getUsersByRole);

module.exports = router;







const express = require('express');
const router = express.Router();
const { check } = require('express-validator');
const validationMiddleware = require('../middleware/validation.middleware');

const reviewController = require('../controllers/review.controller');
const authMiddleware = require('../middleware/auth.middleware');

// Get all reviews
router.get('/', reviewController.getAllReviews);

// Get reviews by technician ID
router.get('/technician/:technicianId', reviewController.getTechnicianReviews);

// Get review by ID
router.get('/:id', reviewController.getReviewById);

// Create a new review
router.post(
  '/',
  [
    authMiddleware,
    check('bookingId', 'Booking ID is required').not().isEmpty(),
    check('rating', 'Rating is required and must be between 1 and 5').isInt({ min: 1, max: 5 }),
    validationMiddleware
  ],
  reviewController.createReview
);

// Update a review
router.put(
  '/:id',
  [
    authMiddleware,
    check('rating', 'Rating must be between 1 and 5').optional().isInt({ min: 1, max: 5 }),
    validationMiddleware
  ],
  reviewController.updateReview
);

// Delete a review
router.delete('/:id', authMiddleware, reviewController.deleteReview);

module.exports = router;


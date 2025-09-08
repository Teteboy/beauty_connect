const express = require('express');
const router = express.Router();
const { check } = require('express-validator');
const bookingController = require('../controllers/booking.controller');
const authMiddleware = require('../middleware/auth.middleware');
const validationMiddleware = require('../middleware/validation.middleware');

// Get customer bookings - must come before /:id route to avoid conflict
router.get('/customer/:customerId', authMiddleware, bookingController.getCustomerBookings);

// Get technician bookings - must come before /:id route to avoid conflict
router.get('/technician/:technicianId', authMiddleware, bookingController.getTechnicianBookings);

// Get all bookings (filtered by user role)
router.get('/', authMiddleware, bookingController.getBookings);

// Get booking by ID
router.get('/:id', authMiddleware, bookingController.getBookingById);

// Create a new booking (customers only)
router.post(
  '/',
  [
    authMiddleware,
    check('serviceId', 'Service ID is required').not().isEmpty(),
    check('dateTime', 'Date and time are required').isISO8601(),
    validationMiddleware
  ],
  bookingController.createBooking
);

// Update booking status
router.put(
  '/:id/status',
  [
    authMiddleware,
    check('status', 'Status must be valid').isIn(['pending', 'confirmed', 'completed', 'cancelled']),
    validationMiddleware
  ],
  bookingController.updateBookingStatus
);

// Update booking details
router.put(
  '/:id',
  [
    authMiddleware,
    check('dateTime', 'Date and time must be valid').optional().isISO8601(),
    validationMiddleware
  ],
  bookingController.updateBooking
);

// Delete booking
router.delete('/:id', authMiddleware, bookingController.deleteBooking);

module.exports = router;



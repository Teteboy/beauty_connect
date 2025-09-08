const { validationResult } = require('express-validator');
const { Review, Booking, User, Service } = require('../models');

exports.getAllReviews = async (req, res) => {
  try {
    const { technicianId } = req.query;
    
    // Build query conditions
    const whereConditions = {};
    
    if (technicianId) {
      whereConditions.technicianId = technicianId;
    }
    
    // Get reviews with related data
    const reviews = await Review.findAll({
      where: whereConditions,
      include: [
        {
          model: Booking,
          as: 'booking',
          include: [
            {
              model: Service,
              as: 'service'
            }
          ]
        },
        {
          model: User,
          as: 'customer',
          attributes: ['id', 'firstName', 'lastName', 'profileImage']
        },
        {
          model: User,
          as: 'technician',
          attributes: ['id', 'firstName', 'lastName', 'profileImage']
        }
      ],
      order: [['createdAt', 'DESC']]
    });
    
    res.status(200).json(reviews);
  } catch (error) {
    console.error('Get reviews error:', error);
    res.status(500).json({ message: 'Server error while fetching reviews' });
  }
};

exports.getReviewById = async (req, res) => {
  try {
    const { id } = req.params;
    
    // Get review with related data
    const review = await Review.findByPk(id, {
      include: [
        {
          model: Booking,
          as: 'booking',
          include: [
            {
              model: Service,
              as: 'service'
            }
          ]
        },
        {
          model: User,
          as: 'customer',
          attributes: ['id', 'firstName', 'lastName', 'profileImage']
        },
        {
          model: User,
          as: 'technician',
          attributes: ['id', 'firstName', 'lastName', 'profileImage']
        }
      ]
    });
    
    if (!review) {
      return res.status(404).json({ message: 'Review not found' });
    }
    
    res.status(200).json(review);
  } catch (error) {
    console.error('Get review error:', error);
    res.status(500).json({ message: 'Server error while fetching review' });
  }
};

exports.createReview = async (req, res) => {
  try {
    // Check for validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    
    const { bookingId, rating, comment } = req.body;
    const customerId = req.user.id;
    
    // Check if booking exists
    const booking = await Booking.findByPk(bookingId);
    if (!booking) {
      return res.status(404).json({ message: 'Booking not found' });
    }
    
    // Check if user is the customer of this booking
    if (booking.customerId !== customerId) {
      return res.status(403).json({ message: 'Not authorized to review this booking' });
    }
    
    // Check if booking is completed
    if (booking.status !== 'completed') {
      return res.status(400).json({ message: 'Can only review completed bookings' });
    }
    
    // Check if review already exists for this booking
    const existingReview = await Review.findOne({ where: { bookingId } });
    if (existingReview) {
      return res.status(400).json({ message: 'Review already exists for this booking' });
    }
    
    // Create review
    const review = await Review.create({
      bookingId,
      customerId,
      technicianId: booking.technicianId,
      rating,
      comment
    });
    
    // Get review with related data
    const newReview = await Review.findByPk(review.id, {
      include: [
        {
          model: Booking,
          as: 'booking',
          include: [
            {
              model: Service,
              as: 'service'
            }
          ]
        },
        {
          model: User,
          as: 'customer',
          attributes: ['id', 'firstName', 'lastName', 'profileImage']
        },
        {
          model: User,
          as: 'technician',
          attributes: ['id', 'firstName', 'lastName', 'profileImage']
        }
      ]
    });
    
    res.status(201).json({
      message: 'Review created successfully',
      review: newReview
    });
  } catch (error) {
    console.error('Create review error:', error);
    res.status(500).json({ message: 'Server error while creating review' });
  }
};

exports.updateReview = async (req, res) => {
  try {
    // Check for validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    
    const { id } = req.params;
    const { rating, comment } = req.body;
    const userId = req.user.id;
    
    // Find review
    const review = await Review.findByPk(id);
    
    if (!review) {
      return res.status(404).json({ message: 'Review not found' });
    }
    
    // Check if user is authorized to update this review
    if (review.customerId !== userId && req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Not authorized to update this review' });
    }
    
    // Update review fields
    if (rating) review.rating = rating;
    if (comment !== undefined) review.comment = comment;
    
    await review.save();
    
    // Get updated review with related data
    const updatedReview = await Review.findByPk(id, {
      include: [
        {
          model: Booking,
          as: 'booking',
          include: [
            {
              model: Service,
              as: 'service'
            }
          ]
        },
        {
          model: User,
          as: 'customer',
          attributes: ['id', 'firstName', 'lastName', 'profileImage']
        },
        {
          model: User,
          as: 'technician',
          attributes: ['id', 'firstName', 'lastName', 'profileImage']
        }
      ]
    });
    
    res.status(200).json({
      message: 'Review updated successfully',
      review: updatedReview
    });
  } catch (error) {
    console.error('Update review error:', error);
    res.status(500).json({ message: 'Server error while updating review' });
  }
};

exports.deleteReview = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;
    
    // Find review
    const review = await Review.findByPk(id);
    
    if (!review) {
      return res.status(404).json({ message: 'Review not found' });
    }
    
    // Check if user is authorized to delete this review
    if (review.customerId !== userId && req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Not authorized to delete this review' });
    }
    
    // Delete review
    await review.destroy();
    
    res.status(200).json({
      message: 'Review deleted successfully'
    });
  } catch (error) {
    console.error('Delete review error:', error);
    res.status(500).json({ message: 'Server error while deleting review' });
  }
};

exports.getTechnicianReviews = async (req, res) => {
  try {
    const { technicianId } = req.params;
    
    // Get reviews
    const reviews = await Review.findAll({
      where: { technicianId },
      include: [
        {
          model: Booking,
          as: 'booking',
          include: [
            {
              model: Service,
              as: 'service'
            }
          ]
        },
        {
          model: User,
          as: 'customer',
          attributes: ['id', 'firstName', 'lastName', 'profileImage']
        }
      ],
      order: [['createdAt', 'DESC']]
    });
    
    // Calculate average rating
    let totalRating = 0;
    reviews.forEach(review => {
      totalRating += review.rating;
    });
    const averageRating = reviews.length > 0 ? totalRating / reviews.length : 0;
    
    res.status(200).json({
      reviews,
      averageRating,
      totalReviews: reviews.length
    });
  } catch (error) {
    console.error('Get technician reviews error:', error);
    res.status(500).json({ message: 'Server error while fetching technician reviews' });
  }
};
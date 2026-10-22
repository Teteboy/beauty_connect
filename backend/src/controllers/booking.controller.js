const { validationResult } = require('express-validator');
const { Booking, User, Service, Notification } = require('../models');
const { Op } = require('sequelize');

exports.getBookings = async (req, res) => {
  try {
    const { status, date } = req.query;
    const userId = req.user.id;
    const userRole = req.user.role;
    
    // Build query conditions
    let whereConditions = {};
    
    // Filter by status if provided
    if (status) {
      whereConditions.status = status;
    }
    
    // Filter by date if provided
    if (date) {
      const startDate = new Date(date);
      startDate.setHours(0, 0, 0, 0);
      
      const endDate = new Date(date);
      endDate.setHours(23, 59, 59, 999);
      
      whereConditions.dateTime = {
        [Op.between]: [startDate, endDate]
      };
    }
    
    // Filter by user role
    if (userRole === 'customer') {
      whereConditions.customerId = userId;
    } else if (userRole === 'technician') {
      whereConditions.technicianId = userId;
    }
    // Admin can see all bookings
    
    // Get bookings with related data
    const bookings = await Booking.findAll({
      where: whereConditions,
      include: [
        {
          model: Service,
          as: 'service',
          include: [
            {
              model: User,
              as: 'technician', // Changed from 'provider' to 'technician' to match model
              attributes: ['id', 'firstName', 'lastName', 'email', 'phone', 'profileImage']
            }
          ]
        },
        {
          model: User,
          as: 'customer',
          attributes: ['id', 'firstName', 'lastName', 'email', 'phone', 'profileImage']
        },
        {
          model: User,
          as: 'technician',
          attributes: ['id', 'firstName', 'lastName', 'email', 'phone', 'profileImage']
        }
      ],
      order: [['dateTime', 'DESC']]
    });
    
    // Convert to plain objects to avoid circular references
    const plainBookings = bookings.map(booking => booking.get({ plain: true }));
    
    res.status(200).json(plainBookings);
  } catch (error) {
    console.error('Get bookings error:', error);
    res.status(500).json({ message: 'Server error while fetching bookings' });
  }
};

exports.getBookingById = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;
    const userRole = req.user.role;
    
    // Get booking with related data
    const booking = await Booking.findByPk(id, {
      include: [
        {
          model: Service,
          as: 'service',
          include: [
            {
              model: User,
              as: 'technician', // Changed from 'provider' to 'technician' to match model
              attributes: ['id', 'firstName', 'lastName', 'email', 'phone', 'profileImage']
            }
          ]
        },
        {
          model: User,
          as: 'customer',
          attributes: ['id', 'firstName', 'lastName', 'email', 'phone', 'profileImage']
        },
        {
          model: User,
          as: 'technician',
          attributes: ['id', 'firstName', 'lastName', 'email', 'phone', 'profileImage']
        }
      ]
    });
    
    if (!booking) {
      return res.status(404).json({ message: 'Booking not found' });
    }
    
    // Check if user is authorized to view this booking
    if (userRole !== 'admin' && 
        booking.customerId !== userId && 
        booking.technicianId !== userId) {
      return res.status(403).json({ message: 'Not authorized to view this booking' });
    }
    
    // Convert to plain object to avoid circular references
    const plainBooking = booking.get({ plain: true });
    
    res.status(200).json(plainBooking);
  } catch (error) {
    console.error('Get booking error:', error);
    res.status(500).json({ message: 'Server error while fetching booking' });
  }
};

exports.createBooking = async (req, res) => {
  try {
    // Check for validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    
    const { serviceId, dateTime, notes } = req.body;
    const customerId = req.user.id;
    
    console.log('Creating booking with data:', { serviceId, dateTime, notes, customerId });
    
    // Check if service exists
    const service = await Service.findByPk(serviceId);
    if (!service) {
      return res.status(404).json({ message: 'Service not found' });
    }
    
    // Get technician ID from service
    const technicianId = service.technicianId;
    
    const autoApprove = process.env.AUTO_APPROVE_BOOKINGS !== 'false';

    // Create booking
    const booking = await Booking.create({
      customerId,
      technicianId,
      serviceId,
      dateTime,
      notes,
      price: service.price,
      status: autoApprove ? 'confirmed' : 'pending'
    });

    // Create notification for technician
    await Notification.create({
      userId: technicianId,
      title: autoApprove ? 'New Booking Confirmed' : 'New Booking',
      message: autoApprove
        ? `A booking for ${service.name} was automatically confirmed`
        : `You have a new booking request for ${service.name}`,
      type: 'booking',
      relatedId: booking.id
    });
    
    // Get booking with related data
    const newBooking = await Booking.findByPk(booking.id, {
      include: [
        {
          model: Service,
          as: 'service'
        },
        {
          model: User,
          as: 'customer',
          attributes: ['id', 'firstName', 'lastName', 'email', 'phone']
        },
        {
          model: User,
          as: 'technician',
          attributes: ['id', 'firstName', 'lastName', 'email', 'phone']
        }
      ]
    });
    
    // Convert to plain object to avoid circular references
    const plainBooking = newBooking.get({ plain: true });
    
    res.status(201).json({
      message: 'Booking created successfully',
      booking: plainBooking
    });
  } catch (error) {
    console.error('Create booking error:', error);
    res.status(500).json({ message: 'Server error while creating booking' });
  }
};

exports.updateBookingStatus = async (req, res) => {
  try {
    // Check for validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    
    const { id } = req.params;
    const { status } = req.body;
    const userId = req.user.id;
    const userRole = req.user.role;
    
    // Find booking
    const booking = await Booking.findByPk(id);
    
    if (!booking) {
      return res.status(404).json({ message: 'Booking not found' });
    }
    
    // Check if user is authorized to update this booking
    if (userRole === 'customer') {
      // Customers can only cancel their own bookings
      if (booking.customerId !== userId) {
        return res.status(403).json({ message: 'Not authorized to update this booking' });
      }
      
      if (status !== 'cancelled') {
        return res.status(403).json({ message: 'Customers can only cancel bookings' });
      }
    } else if (userRole === 'technician') {
      // Technicians can update status of their own bookings
      if (booking.technicianId !== userId) {
        return res.status(403).json({ message: 'Not authorized to update this booking' });
      }
      
      // Technicians cannot cancel confirmed bookings
      if (booking.status === 'confirmed' && status === 'cancelled') {
        return res.status(403).json({ message: 'Cannot cancel confirmed bookings' });
      }
    }
    // Admins can update any booking
    
    // Update booking status
    booking.status = status;
    await booking.save();
    
    res.status(200).json({
      message: 'Booking status updated successfully',
      booking
    });
  } catch (error) {
    console.error('Update booking status error:', error);
    res.status(500).json({ message: 'Server error while updating booking status' });
  }
};

exports.updateBooking = async (req, res) => {
  try {
    // Check for validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    
    const { id } = req.params;
    const { dateTime, notes } = req.body;
    const userId = req.user.id;
    const userRole = req.user.role;
    
    // Find booking
    const booking = await Booking.findByPk(id);
    
    if (!booking) {
      return res.status(404).json({ message: 'Booking not found' });
    }
    
    // Check if user is authorized to update this booking
    if (userRole !== 'admin' && 
        booking.customerId !== userId && 
        booking.technicianId !== userId) {
      return res.status(403).json({ message: 'Not authorized to update this booking' });
    }
    
    // Check if booking can be updated
    if (booking.status === 'completed' || booking.status === 'cancelled') {
      return res.status(400).json({ message: 'Cannot update completed or cancelled bookings' });
    }
    
    // Update booking fields
    if (dateTime) booking.dateTime = dateTime;
    if (notes !== undefined) booking.notes = notes;
    
    await booking.save();
    
    res.status(200).json({
      message: 'Booking updated successfully',
      booking
    });
  } catch (error) {
    console.error('Update booking error:', error);
    res.status(500).json({ message: 'Server error while updating booking' });
  }
};

exports.deleteBooking = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;
    const userRole = req.user.role;
    
    // Find booking
    const booking = await Booking.findByPk(id);
    
    if (!booking) {
      return res.status(404).json({ message: 'Booking not found' });
    }
    
    // Check if user is authorized to delete this booking
    if (userRole !== 'admin' && 
        booking.customerId !== userId && 
        booking.technicianId !== userId) {
      return res.status(403).json({ message: 'Not authorized to delete this booking' });
    }
    
    // Check if booking can be deleted
    if (booking.status !== 'pending') {
      return res.status(400).json({ message: 'Only pending bookings can be deleted' });
    }
    
    // Delete booking
    await booking.destroy();
    
    res.status(200).json({
      message: 'Booking deleted successfully'
    });
  } catch (error) {
    console.error('Delete booking error:', error);
    res.status(500).json({ message: 'Server error while deleting booking' });
  }
};

exports.getCustomerBookings = async (req, res) => {
  try {
    const { customerId } = req.params;
    const userId = req.user.id;
    const userRole = req.user.role;
    
    // Check if user is authorized to view these bookings
    if (userRole !== 'admin' && parseInt(customerId) !== userId) {
      return res.status(403).json({ message: 'Not authorized to view these bookings' });
    }
    
    // Get bookings
    const bookings = await Booking.findAll({
      where: { customerId },
      include: [
        {
          model: Service,
          as: 'service'
        },
        {
          model: User,
          as: 'technician',
          attributes: ['id', 'firstName', 'lastName', 'email', 'phone', 'profileImage']
        }
      ],
      order: [['dateTime', 'DESC']]
    });
    
    res.status(200).json(bookings);
  } catch (error) {
    console.error('Get customer bookings error:', error);
    res.status(500).json({ message: 'Server error while fetching customer bookings' });
  }
};

exports.getTechnicianBookings = async (req, res) => {
  try {
    const { technicianId } = req.params;
    const userId = req.user.id;
    const userRole = req.user.role;
    
    // Check if user is authorized to view these bookings
    if (userRole !== 'admin' && parseInt(technicianId) !== userId) {
      return res.status(403).json({ message: 'Not authorized to view these bookings' });
    }
    
    // Get bookings
    const bookings = await Booking.findAll({
      where: { technicianId },
      include: [
        {
          model: Service,
          as: 'service'
        },
        {
          model: User,
          as: 'customer',
          attributes: ['id', 'firstName', 'lastName', 'email', 'phone', 'profileImage']
        }
      ],
      order: [['dateTime', 'DESC']]
    });
    
    res.status(200).json(bookings);
  } catch (error) {
    console.error('Get technician bookings error:', error);
    res.status(500).json({ message: 'Server error while fetching technician bookings' });
  }
};










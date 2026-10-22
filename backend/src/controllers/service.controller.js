const { Service, User, ServiceImage, Review, sequelize } = require('../models');
const { Op } = require('sequelize');

// Attache la note moyenne et le nombre d'avis à chaque technicien
// des services retournés.
async function attachTechnicianRatings(services) {
  const techIds = [...new Set(services.map(s => s.technicianId))];
  if (techIds.length === 0) return services;

  const aggregates = await Review.findAll({
    where: { technicianId: { [Op.in]: techIds } },
    attributes: [
      'technicianId',
      [sequelize.fn('AVG', sequelize.col('rating')), 'ratingAvg'],
      [sequelize.fn('COUNT', sequelize.col('id')), 'reviewsCount'],
    ],
    group: ['technicianId'],
    raw: true,
  });

  const ratings = {};
  for (const agg of aggregates) {
    ratings[agg.technicianId] = {
      ratingAvg: parseFloat(agg.ratingAvg),
      reviewsCount: parseInt(agg.reviewsCount, 10),
    };
  }

  return services.map(s => {
    const service = s.get({ plain: true });
    if (service.technician) {
      const r = ratings[service.technicianId];
      service.technician.ratingAvg = r ? r.ratingAvg : null;
      service.technician.reviewsCount = r ? r.reviewsCount : 0;
    }
    return service;
  });
}

exports.getAllServices = async (req, res) => {
  try {
    const { category, technicianId, search } = req.query;
    
    // Build query conditions
    const whereConditions = {};
    
    if (category) {
      whereConditions.category = category;
    }
    
    if (technicianId) {
      whereConditions.technicianId = technicianId;
    }
    
    if (search) {
      whereConditions[Op.or] = [
        { name: { [Op.iLike]: `%${search}%` } },
        { description: { [Op.iLike]: `%${search}%` } }
      ];
    }
    
    // Get services with technician info
    const services = await Service.findAll({
      where: whereConditions,
      include: [
        {
          model: User,
          as: 'technician',
          attributes: ['id', 'firstName', 'lastName', 'email', 'phone', 'location', 'profileImage']
        }
      ],
      order: [['createdAt', 'DESC']]
    });
    
    const enriched = await attachTechnicianRatings(services);

    // Return array of services
    res.status(200).json(enriched);
  } catch (error) {
    console.error('Get services error:', error);
    res.status(500).json({ message: 'Server error while fetching services' });
  }
};

exports.getServiceById = async (req, res) => {
  try {
    const { id } = req.params;
    
    const service = await Service.findByPk(id, {
      include: [
        {
          model: User,
          as: 'technician',
          attributes: ['id', 'firstName', 'lastName', 'email', 'phone', 'location', 'profileImage']
        }
      ]
    });
    
    if (!service) {
      return res.status(404).json({ message: 'Service not found' });
    }
    
    res.status(200).json(service);
  } catch (error) {
    console.error('Get service error:', error);
    res.status(500).json({ message: 'Server error while fetching service' });
  }
};

exports.getServicesByTechnician = async (req, res) => {
  try {
    const { technicianId } = req.params;
    
    const services = await Service.findAll({
      where: { technicianId },
      include: [
        {
          model: User,
          as: 'technician',
          attributes: ['id', 'firstName', 'lastName', 'email', 'phone', 'location', 'bio', 'specialty', 'profileImage', 'isVerified']
        }
      ],
      order: [['createdAt', 'DESC']]
    });

    const enriched = await attachTechnicianRatings(services);
    res.status(200).json(enriched);
  } catch (error) {
    console.error('Get services by technician error:', error);
    res.status(500).json({ message: 'Server error while fetching services' });
  }
};

exports.createService = async (req, res) => {
  try {
    // Check if user is a technician or admin
    if (req.user.role !== 'technician' && req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Only technicians can create services' });
    }
    
    const { name, description, price, durationMinutes, category, imageUrl, isAvailable } = req.body;
    
    // Log the request body for debugging
    console.log('Create service request body:', req.body);
    
    // Additional validation
    if (!name || !description || price === undefined || durationMinutes === undefined || !category) {
      return res.status(400).json({ 
        message: 'Missing required fields',
        requiredFields: ['name', 'description', 'price', 'durationMinutes', 'category'],
        received: req.body
      });
    }
    
    // Create service
    const service = await Service.create({
      name,
      description,
      price: parseFloat(price),
      durationMinutes: parseInt(durationMinutes),
      category,
      imageUrl,
      isAvailable: isAvailable !== undefined ? isAvailable : true,
      technicianId: req.user.id
    });
    
    res.status(201).json(service);
  } catch (error) {
    console.error('Create service error:', error);
    res.status(500).json({ 
      message: 'Server error while creating service',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

exports.updateService = async (req, res) => {
  try {
    const { id } = req.params;
    const { name, description, price, durationMinutes, category, imageUrl, isAvailable } = req.body;
    
    // Find service
    const service = await Service.findByPk(id);
    if (!service) {
      return res.status(404).json({ message: 'Service not found' });
    }
    
    // Check if user is the owner or admin
    if (service.technicianId !== req.user.id && req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Not authorized to update this service' });
    }
    
    // Update service fields
    if (name) service.name = name;
    if (description !== undefined) service.description = description;
    if (price !== undefined) service.price = price;
    if (durationMinutes !== undefined) service.durationMinutes = durationMinutes;
    if (category !== undefined) service.category = category;
    if (imageUrl !== undefined) service.imageUrl = imageUrl;
    if (isAvailable !== undefined) service.isAvailable = isAvailable;
    
    await service.save();
    
    res.status(200).json(service);
  } catch (error) {
    console.error('Update service error:', error);
    res.status(500).json({ message: 'Server error while updating service' });
  }
};

exports.deleteService = async (req, res) => {
  try {
    const { id } = req.params;
    
    // Find service
    const service = await Service.findByPk(id);
    if (!service) {
      return res.status(404).json({ message: 'Service not found' });
    }
    
    // Check if user is the owner or admin
    if (service.technicianId !== req.user.id && req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Not authorized to delete this service' });
    }
    
    // Delete service
    await service.destroy();
    
    res.status(200).json({ message: 'Service deleted successfully' });
  } catch (error) {
    console.error('Delete service error:', error);
    res.status(500).json({ message: 'Server error while deleting service' });
  }
};

// Get technician's own services
exports.getMyServices = async (req, res) => {
  try {
    const technicianId = req.user.id;
    
    const services = await Service.findAll({
      where: {
        technicianId: technicianId
      },
      order: [['createdAt', 'DESC']]
    });
    
    res.status(200).json(services);
  } catch (error) {
    console.error('Get my services error:', error);
    res.status(500).json({ message: 'Server error while fetching services' });
  }
};

// Get service images
exports.getServiceImages = async (req, res) => {
  try {
    const { id } = req.params;
    
    const images = await ServiceImage.findAll({
      where: { serviceId: id },
      order: [['createdAt', 'DESC']]
    });
    
    res.status(200).json(images);
  } catch (error) {
    console.error('Get service images error:', error);
    res.status(500).json({ message: 'Server error while fetching service images' });
  }
};

// Add service image
exports.addServiceImage = async (req, res) => {
  try {
    const { id } = req.params;
    const { imageUrl, caption } = req.body;
    
    // Check if service exists
    const service = await Service.findByPk(id);
    if (!service) {
      return res.status(404).json({ message: 'Service not found' });
    }
    
    // Check if user is the owner or admin
    if (service.technicianId !== req.user.id && req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Not authorized to add images to this service' });
    }
    
    // Create image
    const image = await ServiceImage.create({
      serviceId: parseInt(id),
      imageUrl,
      caption
    });
    
    res.status(201).json(image);
  } catch (error) {
    console.error('Add service image error:', error);
    res.status(500).json({ message: 'Server error while adding service image' });
  }
};

// Delete service image
exports.deleteServiceImage = async (req, res) => {
  try {
    const { id, imageId } = req.params;
    
    // Check if image exists
    const image = await ServiceImage.findByPk(imageId);
    if (!image) {
      return res.status(404).json({ message: 'Image not found' });
    }
    
    // Check if image belongs to the service
    if (image.serviceId !== parseInt(id)) {
      return res.status(400).json({ message: 'Image does not belong to this service' });
    }
    
    // Check if user is the owner or admin
    const service = await Service.findByPk(id);
    if (service.technicianId !== req.user.id && req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Not authorized to delete this image' });
    }
    
    // Delete image
    await image.destroy();
    
    res.status(200).json({ message: 'Image deleted successfully' });
  } catch (error) {
    console.error('Delete service image error:', error);
    res.status(500).json({ message: 'Server error while deleting service image' });
  }
};





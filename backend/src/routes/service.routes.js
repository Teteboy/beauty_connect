const express = require('express');
const router = express.Router();
const serviceController = require('../controllers/service.controller');
const auth = require('../middleware/auth.middleware');

// Create service (technician only)
router.post('/', auth, serviceController.createService);

// Get technician's own services
router.get('/my-services', auth, serviceController.getMyServices);

// Get services by technician ID
router.get('/technician/:technicianId', serviceController.getServicesByTechnician);

// Get all services (public)
router.get('/', serviceController.getAllServices);

// Get service by ID
router.get('/:id', serviceController.getServiceById);

// Update service (technician only)
router.put('/:id', auth, serviceController.updateService);

// Delete service (technician only)
router.delete('/:id', auth, serviceController.deleteService);

// Service image routes
router.get('/:id/images', serviceController.getServiceImages);
router.post('/:id/images', auth, serviceController.addServiceImage);
router.delete('/:id/images/:imageId', auth, serviceController.deleteServiceImage);

module.exports = router;






const express = require('express');
const router = express.Router();
const uploadController = require('../controllers/upload.controller');
const auth = require('../middleware/auth.middleware');

// Upload an image (authenticated)
router.post('/image', auth, uploadController.uploadImage);

module.exports = router;

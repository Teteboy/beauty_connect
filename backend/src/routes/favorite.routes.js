const express = require('express');
const router = express.Router();
const { Favorite, User } = require('../models');
const auth = require('../middleware/auth.middleware');

// Liste des prestataires favoris de l'utilisateur
router.get('/', auth, async (req, res) => {
  try {
    const favorites = await Favorite.findAll({
      where: { userId: req.user.id },
      include: [{
        model: User, as: 'technician',
        attributes: ['id', 'firstName', 'lastName', 'location', 'profileImage', 'specialty', 'isVerified']
      }],
      order: [['createdAt', 'DESC']]
    });
    res.json({ favorites });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: 'Server error' });
  }
});

// IDs uniquement (léger, pour le provider)
router.get('/ids', auth, async (req, res) => {
  const rows = await Favorite.findAll({ where: { userId: req.user.id }, attributes: ['technicianId'], raw: true });
  res.json({ ids: rows.map(r => r.technicianId) });
});

// Basculer un favori
router.post('/:technicianId', auth, async (req, res) => {
  try {
    const technicianId = parseInt(req.params.technicianId, 10);
    const existing = await Favorite.findOne({ where: { userId: req.user.id, technicianId } });
    if (existing) {
      await existing.destroy();
      return res.json({ favorited: false });
    }
    await Favorite.create({ userId: req.user.id, technicianId });
    res.json({ favorited: true });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;

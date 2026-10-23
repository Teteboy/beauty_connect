const express = require('express');
const router = express.Router();
const { Availability } = require('../models');
const auth = require('../middleware/auth.middleware');

// Mes disponibilités (prestataire)
router.get('/me', auth, async (req, res) => {
  const days = await Availability.findAll({ where: { userId: req.user.id }, order: [['dayOfWeek', 'ASC']] });
  res.json({ availability: days });
});

// Remplacer mes disponibilités : { days: [{dayOfWeek, isEnabled, slots[]}] }
router.put('/me', auth, async (req, res) => {
  try {
    const days = Array.isArray(req.body.days) ? req.body.days : [];
    for (const d of days) {
      const dayOfWeek = parseInt(d.dayOfWeek, 10);
      if (Number.isNaN(dayOfWeek) || dayOfWeek < 0 || dayOfWeek > 6) continue;
      await Availability.upsert({
        userId: req.user.id,
        dayOfWeek,
        isEnabled: !!d.isEnabled,
        slots: Array.isArray(d.slots) ? d.slots.map(String) : [],
      });
    }
    const updated = await Availability.findAll({ where: { userId: req.user.id }, order: [['dayOfWeek', 'ASC']] });
    res.json({ availability: updated });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: 'Server error' });
  }
});

// Disponibilités publiques d'un prestataire (créneaux affichés à la réservation)
router.get('/:technicianId', async (req, res) => {
  const days = await Availability.findAll({
    where: { userId: req.params.technicianId, isEnabled: true },
    order: [['dayOfWeek', 'ASC']]
  });
  res.json({ availability: days });
});

module.exports = router;

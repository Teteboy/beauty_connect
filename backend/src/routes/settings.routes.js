const express = require('express');
const router = express.Router();
const { NotificationSetting, Preference } = require('../models');
const auth = require('../middleware/auth.middleware');

// Paramètres de notification
router.get('/notifications', auth, async (req, res) => {
  const [s] = await NotificationSetting.findOrCreate({
    where: { userId: req.user.id }, defaults: {}
  });
  res.json({ settings: s });
});

router.put('/notifications', auth, async (req, res) => {
  const allowed = ['bookingNotifications', 'messageNotifications',
    'reminderNotifications', 'marketingNotifications'];
  const updates = {};
  for (const k of allowed) if (k in req.body) updates[k] = !!req.body[k];
  const [s] = await NotificationSetting.findOrCreate({
    where: { userId: req.user.id }, defaults: {}
  });
  await s.update(updates);
  res.json({ settings: s });
});

// Préférences WhatsApp / consentements
router.get('/preferences', auth, async (req, res) => {
  const [p] = await Preference.findOrCreate({ where: { userId: req.user.id }, defaults: {} });
  res.json({ preferences: p });
});

router.put('/preferences', auth, async (req, res) => {
  const allowed = ['whatsappNumber', 'whatsappConsent', 'whatsappUpdates',
    'whatsappReminders', 'marketingConsent'];
  const updates = {};
  for (const k of allowed) {
    if (!(k in req.body)) continue;
    updates[k] = typeof req.body[k] === 'boolean' ? req.body[k] : req.body[k];
  }
  const [p] = await Preference.findOrCreate({ where: { userId: req.user.id }, defaults: {} });
  await p.update(updates);
  res.json({ preferences: p });
});

module.exports = router;

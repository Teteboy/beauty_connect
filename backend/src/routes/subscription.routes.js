const express = require('express');
const router = express.Router();
const { Subscription } = require('../models');
const auth = require('../middleware/auth.middleware');

const PLANS = { basic: 0, pro: 5000, premium: 12000 }; // XAF / mois

router.get('/mine', auth, async (req, res) => {
  const sub = await Subscription.findOne({
    where: { userId: req.user.id, status: 'active' },
    order: [['startedAt', 'DESC']]
  });
  res.json({ subscription: sub, plans: PLANS });
});

router.post('/', auth, async (req, res) => {
  try {
    const plan = String(req.body.plan || 'basic').toLowerCase();
    if (!(plan in PLANS)) return res.status(400).json({ message: 'Plan inconnu' });
    await Subscription.update({ status: 'cancelled' },
      { where: { userId: req.user.id, status: 'active' } });
    const expiresAt = new Date();
    expiresAt.setMonth(expiresAt.getMonth() + 1);
    const sub = await Subscription.create({
      userId: req.user.id, plan, price: PLANS[plan], status: 'active', expiresAt
    });
    res.status(201).json({ subscription: sub });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: 'Server error' });
  }
});

router.post('/cancel', auth, async (req, res) => {
  await Subscription.update({ status: 'cancelled' },
    { where: { userId: req.user.id, status: 'active' } });
  res.json({ message: 'Abonnement résilié' });
});

module.exports = router;

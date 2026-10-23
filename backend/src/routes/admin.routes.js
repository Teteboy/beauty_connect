const express = require('express');
const router = express.Router();
const { User, Booking, Service, Review, Verification, sequelize } = require('../models');
const { Op } = require('sequelize');
const auth = require('../middleware/auth.middleware');
const admin = require('../middleware/admin.middleware');

router.use(auth, admin);

// Vue d'ensemble du tableau de bord
router.get('/overview', async (req, res) => {
  const [users, technicians, services, bookings, pendingVerifications] =
    await Promise.all([
      User.count(), User.count({ where: { role: 'technician' } }),
      Service.count(), Booking.count(),
      Verification.count({ where: { status: 'pending' } }),
    ]);
  const revenue = await Booking.sum('price', { where: { status: { [Op.in]: ['confirmed', 'completed'] } } });
  res.json({ users, technicians, services, bookings, pendingVerifications, revenue: revenue || 0 });
});

router.get('/users', async (req, res) => {
  const { role, search } = req.query;
  const where = {};
  if (role) where.role = role;
  if (search) {
    where[Op.or] = [
      { firstName: { [Op.iLike]: `%${search}%` } },
      { lastName: { [Op.iLike]: `%${search}%` } },
      { email: { [Op.iLike]: `%${search}%` } },
    ];
  }
  const users = await User.findAll({
    where,
    attributes: { exclude: ['password', 'resetToken', 'resetTokenExpiry'] },
    order: [['createdAt', 'DESC']], limit: 200
  });
  res.json({ users });
});

router.put('/users/:id/verify', async (req, res) => {
  const user = await User.findByPk(req.params.id);
  if (!user) return res.status(404).json({ message: 'Not found' });
  await user.update({ isVerified: req.body.isVerified !== false });
  res.json({ user });
});

router.get('/verifications', async (req, res) => {
  const rows = await Verification.findAll({
    include: [{ model: User, as: 'user',
      attributes: ['id', 'firstName', 'lastName', 'email', 'phone', 'location'] }],
    order: [['createdAt', 'DESC']]
  });
  res.json({ verifications: rows });
});

router.put('/verifications/:id', async (req, res) => {
  const v = await Verification.findByPk(req.params.id);
  if (!v) return res.status(404).json({ message: 'Not found' });
  const status = req.body.status; // approved | rejected
  await v.update({ status, reviewedById: req.user.id, reviewedAt: new Date(), notes: req.body.notes || v.notes });
  if (status === 'approved') {
    await User.update({ isVerified: true }, { where: { id: v.userId } });
  }
  res.json({ verification: v });
});

router.get('/bookings', async (req, res) => {
  const { status } = req.query;
  const where = status ? { status } : {};
  const bookings = await Booking.findAll({
    where,
    include: [
      { model: User, as: 'customer', attributes: ['id', 'firstName', 'lastName'] },
      { model: User, as: 'technician', attributes: ['id', 'firstName', 'lastName'] },
      { model: Service, as: 'service', attributes: ['id', 'name', 'price'] },
    ],
    order: [['dateTime', 'DESC']], limit: 200
  });
  res.json({ bookings });
});

router.get('/finance', async (req, res) => {
  const totals = await Booking.findAll({
    attributes: ['status', [sequelize.fn('COUNT', sequelize.col('id')), 'count'],
      [sequelize.fn('SUM', sequelize.col('price')), 'total']],
    group: ['status'], raw: true
  });
  res.json({ totals, bookingFeeXaf: 500 });
});

module.exports = router;

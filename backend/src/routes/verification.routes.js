const express = require('express');
const router = express.Router();
const { Verification } = require('../models');
const auth = require('../middleware/auth.middleware');

// Statut du dossier de vérification
router.get('/status', auth, async (req, res) => {
  const v = await Verification.findOne({ where: { userId: req.user.id } });
  res.json({ verification: v || { status: 'none', documents: [] } });
});

// Soumettre des justificatifs
router.post('/', auth, async (req, res) => {
  try {
    const documents = Array.isArray(req.body.documents) ? req.body.documents : [];
    const [v] = await Verification.upsert({
      userId: req.user.id,
      documents,
      status: 'pending',
      reviewedAt: null,
      reviewedById: null,
    });
    res.json({ verification: v });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;

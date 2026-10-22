/**
 * Seed de démonstration BeautyConnect — idempotent (findOrCreate).
 * Usage : node seed.js
 */
require('dotenv').config();
const db = require('./src/models');
const { User, Service, Booking, Review, Notification, Message } = db;

const P = 'password123';

const technicians = [
  { firstName: 'Amina', lastName: 'Njoya', email: 'amina@beautyconnect.cm', specialty: 'Coiffure', location: 'Douala, Bonapriso', bio: 'Coiffeuse spécialisée en tresses, vanilles et soins capillaires.', isVerified: true },
  { firstName: 'Joël', lastName: 'Mbarga', email: 'joel@beautyconnect.cm', specialty: 'Barbier', location: 'Douala, Akwa', bio: 'Barbier professionnel · coupe, barbe et soins du visage.', isVerified: true },
  { firstName: 'Sarah', lastName: 'Essomba', email: 'sarah@beautyconnect.cm', specialty: 'Massage & bien-être', location: 'Yaoundé, Bastos', bio: 'Massothérapeute certifiée · détente et récupération.', isVerified: true },
  { firstName: 'Nadia', lastName: 'Tchoumi', email: 'nadia@beautyconnect.cm', specialty: 'Ongles', location: 'Douala, Deïdo', bio: 'Prothésiste ongulaire · gel, nail art et soins des mains.', isVerified: false },
  { firstName: 'Éric', lastName: 'Fouda', email: 'eric@beautyconnect.cm', specialty: 'Fitness', location: 'Yaoundé, Nlongkak', bio: 'Coach sportif personnel · remise en forme et suivi.', isVerified: true },
  { firstName: 'Studio', lastName: 'Ink', email: 'studio.ink@beautyconnect.cm', specialty: 'Tatouage', location: 'Douala, Bali', bio: 'Studio de tatouage hygiénique · flash et projets personnalisés.', isVerified: false },
];

const customers = [
  { firstName: 'Léa', lastName: 'Mballa', email: 'lea@beautyconnect.cm', location: 'Douala, Bonapriso' },
  { firstName: 'Marc', lastName: 'Atangana', email: 'marc@beautyconnect.cm', location: 'Yaoundé, Centre-ville' },
  { firstName: 'Élodie', lastName: 'Mbeki', email: 'elodie@beautyconnect.cm', location: 'Douala, Bali' },
];

// [techEmail, name, description, price, durationMin, category]
const services = [
  ['amina@beautyconnect.cm', 'Tresses collées', 'Pose de tresses collées soignées, adaptées à votre style. Produit fourni sur demande.', 8000, 120, 'Hair'],
  ['amina@beautyconnect.cm', 'Soin capillaire complet', 'Diagnostic, soin profond et coiffage. Cheveux naturels ou défrisés.', 5000, 60, 'Hair'],
  ['joel@beautyconnect.cm', 'Coupe & barbe', 'Coupe tendance, contour net et entretien de la barbe avec serviette chaude.', 5000, 45, 'Hair'],
  ['joel@beautyconnect.cm', 'Taille de barbe express', 'Taille et finition de la barbe en 20 minutes.', 2500, 20, 'Hair'],
  ['sarah@beautyconnect.cm', 'Massage relaxant', 'Massage californien 60 minutes pour relâcher les tensions.', 12000, 60, 'Massage'],
  ['sarah@beautyconnect.cm', 'Massage sportif', 'Massage profond ciblé récupération musculaire.', 15000, 75, 'Massage'],
  ['nadia@beautyconnect.cm', 'Pose gel & nail art', 'Pose complète en gel avec décorations personnalisées.', 9000, 90, 'Nails'],
  ['nadia@beautyconnect.cm', 'Manucure soignée', 'Manucure complète : cuticules, limage et vernis.', 5000, 45, 'Nails'],
  ['eric@beautyconnect.cm', 'Coaching personnel', 'Séance individuelle avec programme adapté à vos objectifs.', 10000, 60, 'Other'],
  ['studio.ink@beautyconnect.cm', 'Tatouage flash', 'Motif flash au choix du catalogue du studio, petit format.', 25000, 90, 'Other'],
  ['studio.ink@beautyconnect.cm', 'Projet tatouage personnalisé', 'Consultation et réalisation de votre projet sur mesure.', 50000, 180, 'Other'],
];

async function main() {
  await db.sequelize.authenticate();
  console.log('Connexion DB OK');

  const techIds = {};
  for (const t of technicians) {
    const [u, created] = await User.findOrCreate({
      where: { email: t.email },
      defaults: { ...t, password: P, phone: '+237600000000', role: 'technician' },
    });
    if (!created) await u.update({ specialty: t.specialty, location: t.location, bio: t.bio, isVerified: t.isVerified });
    techIds[t.email] = u.id;
    console.log(`tech ${t.email} #${u.id}${created ? ' (créé)' : ''}`);
  }

  const custIds = {};
  for (const c of customers) {
    const [u, created] = await User.findOrCreate({
      where: { email: c.email },
      defaults: { ...c, password: P, phone: '+237699000000', role: 'customer' },
    });
    custIds[c.email] = u.id;
    console.log(`client ${c.email} #${u.id}${created ? ' (créé)' : ''}`);
  }

  const serviceIds = {};
  for (const [email, name, description, price, durationMinutes, category] of services) {
    const [s, created] = await Service.findOrCreate({
      where: { name, technicianId: techIds[email] },
      defaults: { description, price, durationMinutes, category, isAvailable: true },
    });
    serviceIds[name] = { id: s.id, techId: techIds[email], price };
    if (created) console.log(`service ${name}`);
  }

  const bookings = [
    // [customer, serviceName, offsetDays, hour, status, notes]
    ['lea@beautyconnect.cm', 'Tresses collées', 2, 10, 'confirmed', 'Mèches X-pression fournies par moi.'],
    ['elodie@beautyconnect.cm', 'Tresses collées', 5, 14, 'pending', null],
    ['marc@beautyconnect.cm', 'Coupe & barbe', 1, 9, 'confirmed', null],
    ['lea@beautyconnect.cm', 'Pose gel & nail art', 3, 15, 'confirmed', 'French manucure de préférence.'],
    ['marc@beautyconnect.cm', 'Massage relaxant', -7, 11, 'completed', null],
    ['elodie@beautyconnect.cm', 'Soin capillaire complet', -14, 10, 'completed', null],
    ['lea@beautyconnect.cm', 'Massage relaxant', -21, 16, 'completed', null],
    ['marc@beautyconnect.cm', 'Tatouage flash', 4, 11, 'pending', 'Motif floral petit format.'],
    ['elodie@beautyconnect.cm', 'Coaching personnel', -3, 8, 'cancelled', 'Empêchement de dernière minute.'],
    ['lea@beautyconnect.cm', 'Manucure soignée', 6, 13, 'pending', null],
  ];

  const bookingRows = {};
  for (const [email, svc, dayOffset, hour, status, notes] of bookings) {
    const s = serviceIds[svc];
    const date = new Date();
    date.setDate(date.getDate() + dayOffset);
    date.setHours(hour, 0, 0, 0);
    const [b, created] = await Booking.findOrCreate({
      where: { customerId: custIds[email], serviceId: s.id, dateTime: date },
      defaults: { technicianId: s.techId, status, notes, price: s.price },
    });
    bookingRows[`${email}|${svc}|${dayOffset}`] = b.id;
    if (created) console.log(`booking ${svc} → ${status}`);
  }

  const reviews = [
    ['marc@beautyconnect.cm', 'Massage relaxant', -7, 5, 'Moment très relaxant, accueil impeccable. Je recommande.'],
    ['elodie@beautyconnect.cm', 'Soin capillaire complet', -14, 5, 'Ma coiffeuse a pris le temps d’expliquer chaque étape.'],
    ['lea@beautyconnect.cm', 'Massage relaxant', -21, 4, 'Très bon massage, ambiance apaisante.'],
  ];
  for (const [email, svc, dayOffset, rating, comment] of reviews) {
    const bookingId = bookingRows[`${email}|${svc}|${dayOffset}`];
    const s = serviceIds[svc];
    const [r, created] = await Review.findOrCreate({
      where: { bookingId },
      defaults: { customerId: custIds[email], technicianId: s.techId, rating, comment },
    });
    if (created) console.log(`review ${svc} ★${rating}`);
  }

  const notifications = [
    [custIds['lea@beautyconnect.cm'], 'Réservation confirmée', 'Votre rendez-vous « Tresses collées » est confirmé.', 'booking'],
    [custIds['lea@beautyconnect.cm'], 'Nouvel avis reçu', 'Votre prestataire a consulté votre avis.', 'review'],
    [techIds['amina@beautyconnect.cm'], 'Nouvelle demande', 'Élodie M. souhaite réserver « Tresses collées ».', 'booking'],
    [techIds['amina@beautyconnect.cm'], 'Dossier vérifié', 'Votre dossier de vérification a été validé.', 'account'],
    [custIds['marc@beautyconnect.cm'], 'Rappel de rendez-vous', 'Coupe & barbe demain à 09:00.', 'booking'],
  ];
  for (const [userId, title, message, type] of notifications) {
    const [, created] = await Notification.findOrCreate({
      where: { userId, title },
      defaults: { message, type, isRead: false },
    });
    if (created) console.log(`notif ${title} → user ${userId}`);
  }

  const messages = [
    [custIds['lea@beautyconnect.cm'], techIds['amina@beautyconnect.cm'], 'Bonjour Amina, je confirme mon rendez-vous de samedi à 10h.'],
    [techIds['amina@beautyconnect.cm'], custIds['lea@beautyconnect.cm'], 'Bonjour Léa ! C\'est noté, à samedi 10h. N\'oubliez pas vos mèches.'],
    [custIds['marc@beautyconnect.cm'], techIds['joel@beautyconnect.cm'], 'Salut Joël, possible d\'avancer ma coupe à 9h30 ?'],
    [techIds['joel@beautyconnect.cm'], custIds['marc@beautyconnect.cm'], 'Oui Marc, 9h30 ça marche. À demain !'],
    [custIds['elodie@beautyconnect.cm'], techIds['nadia@beautyconnect.cm'], 'Bonjour, avez-vous encore des disponibilités cette semaine ?'],
  ];
  for (const [senderId, receiverId, content] of messages) {
    const exists = await Message.findOne({ where: { senderId, receiverId, content } });
    if (!exists) {
      await Message.create({ senderId, receiverId, content });
      console.log(`msg ${senderId}→${receiverId}`);
    }
  }

  const counts = await Promise.all([
    User.count(), Service.count(), Booking.count(), Review.count(), Notification.count(),
  ]);
  console.log(`\nTerminé : ${counts[0]} users · ${counts[1]} services · ${counts[2]} bookings · ${counts[3]} reviews · ${counts[4]} notifications`);
  process.exit(0);
}

main().catch((e) => { console.error(e); process.exit(1); });

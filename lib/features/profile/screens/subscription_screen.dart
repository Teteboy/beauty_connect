import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/utils/navigation.dart';

/// Écran « Abonnement et visibilité » (prestataire).
///
/// UI uniquement : il n'existe pas d'endpoint `/subscription` côté backend.
/// La sélection de plan affiche un aperçu local ; le bouton « Changer de
/// plan » reste informatif tant que la facturation n'est pas branchée.
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _Plan {
  final String name;
  final int priceCfa;
  final String priceHint;
  final List<String> features;
  final String badge;

  const _Plan({
    required this.name,
    required this.priceCfa,
    required this.priceHint,
    required this.features,
    required this.badge,
  });
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  static const List<_Plan> _plans = [
    _Plan(
      name: 'Gratuit',
      priceCfa: 0,
      priceHint: 'CFA / XAF · Offre de base',
      features: [
        'Profil public',
        'Catalogue de services',
        'Réservations',
        'Agenda',
      ],
      badge: 'Socle proposé',
    ),
    _Plan(
      name: 'Pro',
      priceCfa: 5000,
      priceHint: 'CFA / XAF · Par mois',
      features: [
        'Tout Gratuit, plus :',
        'Statistiques avancées',
        'Outils de gestion',
        'Options de profil',
      ],
      badge: 'Optionnel',
    ),
    _Plan(
      name: 'Premium',
      priceCfa: 12000,
      priceHint: 'CFA / XAF · Par mois',
      features: [
        'Tout Pro, plus :',
        'Mise en avant du profil',
        'Badge vérifié prioritaire',
        'Support dédié',
      ],
      badge: 'Optionnel',
    ),
  ];

  String _currentPlan = 'Gratuit';
  String _selectedPlan = 'Gratuit';

  void _goBack() {
    if (context.canPop()) {
      safePop(context, fallback: '/profile');
    } else {
      context.go('/profile');
    }
  }

  static String _price(num value) =>
      '${NumberFormat('#,##0', 'fr').format(value).replaceAll('\u202f', ' ').replaceAll('\u00a0', ' ')} CFA';

  void _changePlan() {
    if (_selectedPlan == _currentPlan) return;
    // NOTE : pas d'endpoint d'abonnement — changement simulé en local.
    // Quand il existera : `ApiService.post('/subscription', {'plan': ...})`.
    setState(() => _currentPlan = _selectedPlan);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Plan « $_currentPlan » sélectionné (démo)'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Espace prestataire / Offres'),
        leading: IconButton(
          onPressed: _goBack,
          icon: const Icon(LucideIcons.arrowLeft),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              children: [
                Text(
                  'Développer mon activité',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.orangePale,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(LucideIcons.info,
                          color: AppColors.accent, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Modèle en brouillon',
                              style: TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'En attente de validation métier. Tarifs proposés : aucun abonnement ni prélèvement actif.',
                              style: TextStyle(
                                color: AppColors.textMedium,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                for (final plan in _plans) _planCard(plan),
                const SizedBox(height: 4),
                _visibilityCard(),
                const SizedBox(height: 16),
                Text(
                  'La commission sur les réservations terminées et payées est également proposée. Son taux reste à définir et ne s\'applique pas encore.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMedium,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Conditions, renouvellement et résiliation à approuver avant toute commercialisation. Intégrations de paiement non activées.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textLight,
                      ),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: CustomButton(
              text: _selectedPlan == _currentPlan
                  ? 'Plan actuel : $_currentPlan'
                  : 'Changer de plan',
              onPressed: _selectedPlan == _currentPlan ? null : _changePlan,
            ),
          ),
        ],
      ),
    );
  }

  Widget _planCard(_Plan plan) {
    final isSelected = _selectedPlan == plan.name;
    final isCurrent = _currentPlan == plan.name;

    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = plan.name),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.cardShadow,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    plan.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                if (isCurrent)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Plan actuel',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              plan.priceCfa == 0 ? 'Gratuit' : _price(plan.priceCfa),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              plan.priceHint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textLight,
                  ),
            ),
            const SizedBox(height: 12),
            for (final feature in plan.features)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(LucideIcons.check,
                        size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feature,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textMedium,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.navyBackground,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                plan.badge,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _visibilityCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Visibilité à la carte',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.orangePale,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Sponsorisé',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Placements payants dans des espaces identifiés « Sponsorisé ». Budget et durée à définir séparément de l\'abonnement.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textMedium,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Aucune garantie de classement ou de réservation.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

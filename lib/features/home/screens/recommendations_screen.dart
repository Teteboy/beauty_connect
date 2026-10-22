import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/concept_banner.dart';

/// Future-concept screen: personalized provider recommendations.
/// Demo only — no recommendation endpoint exists yet.
class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  // ── Demo data ─────────────────────────────────────────────────────────
  static const _filters = ['Coiffure', 'Bien-être', 'Douala'];
  int _selectedFilter = 0;

  static const _providers = [
    _Reco(
      name: 'Sarah Essomba',
      category: 'Bien-être · Massage',
      rating: 4.9,
      reviews: 64,
      distanceKm: 3.4,
      priceFrom: 12000,
      reason: 'Populaire près de vous',
      why: 'Vous aimez les soins et les pauses bien-être.',
    ),
    _Reco(
      name: 'Amina Njoya',
      category: 'Coiffure · Tresses & soins',
      rating: 4.9,
      reviews: 128,
      distanceKm: 1.2,
      priceFrom: 8000,
      reason: 'Mieux noté',
      why: 'Vos dernières réservations étaient en coiffure.',
    ),
    _Reco(
      name: 'Nadia Bekono',
      category: 'Onglerie · Nail art',
      rating: 4.7,
      reviews: 42,
      distanceKm: 2.8,
      priceFrom: 6000,
      reason: 'Nouveau',
      why: 'Nouvelle prestataire vérifiée à Douala.',
    ),
  ];

  final Set<int> _favorites = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            const ConceptHeader(title: 'Pensé pour vous'),
            const SizedBox(height: 16),
            const ConceptBanner(),
            const SizedBox(height: 20),
            Text('Votre prochain moment\npour vous.',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    height: 1.15)),
            const SizedBox(height: 10),
            Text(
              'Une sélection inspirée de vos envies, que vous gardez sous '
              'contrôle.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textMedium, height: 1.4),
            ),
            const SizedBox(height: 16),

            // ── Filter chips ──────────────────────────────────────────
            Wrap(
              spacing: 8,
              children: [
                for (var i = 0; i < _filters.length; i++)
                  ChoiceChip(
                    label: Text(_filters[i]),
                    selected: i == _selectedFilter,
                    onSelected: (_) => setState(() => _selectedFilter = i),
                    selectedColor: AppColors.accent,
                    backgroundColor: AppColors.navyBackground,
                    labelStyle: TextStyle(
                      color: i == _selectedFilter
                          ? Colors.white
                          : AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide.none,
                    ),
                    showCheckmark: false,
                  ),
              ],
            ),
            const SizedBox(height: 24),

            Text('À découvrir près de chez vous',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            for (var i = 0; i < _providers.length; i++)
              _ProviderCard(
                reco: _providers[i],
                isFavorite: _favorites.contains(i),
                onFavorite: () => setState(() {
                  _favorites.contains(i)
                      ? _favorites.remove(i)
                      : _favorites.add(i);
                }),
                onViewProfile: () => context.go('/services'),
              ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text('Gérer mes préférences',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark)),
                    ),
                    const Icon(Icons.tune, color: AppColors.textDark, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Reco {
  final String name;
  final String category;
  final double rating;
  final int reviews;
  final double distanceKm;
  final int priceFrom;
  final String reason;
  final String why;

  const _Reco({
    required this.name,
    required this.category,
    required this.rating,
    required this.reviews,
    required this.distanceKm,
    required this.priceFrom,
    required this.reason,
    required this.why,
  });
}

class _ProviderCard extends StatelessWidget {
  final _Reco reco;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onViewProfile;

  const _ProviderCard({
    required this.reco,
    required this.isFavorite,
    required this.onFavorite,
    required this.onViewProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.orangePale,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.person_outline,
                    color: AppColors.accent, size: 36),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(reco.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textDark)),
                        ),
                        GestureDetector(
                          onTap: onFavorite,
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: AppColors.accent,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    Text(reco.category,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.textMedium)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star,
                            color: AppColors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${reco.rating.toStringAsFixed(1).replaceAll('.', ',')} '
                          '(${reco.reviews} avis) · '
                          '${reco.distanceKm.toStringAsFixed(1).replaceAll('.', ',')} km',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.textMedium),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('À partir de ${_price(reco.priceFrom)} CFA',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.navyBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(reco.reason,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onViewProfile,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
              ),
              child: const Text('Voir profil',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 8),
          Text('Pourquoi ce choix ? ${reco.why}',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textLight)),
        ],
      ),
    );
  }

  String _price(int v) {
    final s = v.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      final remaining = s.length - i;
      buffer.write(s[i]);
      if (remaining > 1 && remaining % 3 == 1) buffer.write(' ');
    }
    return buffer.toString();
  }
}

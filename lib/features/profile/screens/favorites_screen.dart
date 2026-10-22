import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/models/service.dart';
import '../../../core/providers/favorites_provider.dart';
import '../../../core/providers/service_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../services/widgets/service_card.dart';

/// Écran « Mes favoris » (client) — liste des prestataires enregistrés.
///
/// Les favoris sont stockés par ID de prestataire dans [FavoritesProvider]
/// (SharedPreferences). Il n'existe pas d'endpoint `/favorites` côté
/// backend : les fiches sont reconstruites à partir des services déjà
/// disponibles via `GET /services`.
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoritesProvider>().load();
      context.read<ServiceProvider>().fetchServices();
    });
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Consumer2<FavoritesProvider, ServiceProvider>(
          builder: (context, favorites, serviceProvider, _) {
            final favoriteProviders =
                _buildFavoriteProviders(favorites, serviceProvider.services);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MON ESPACE · CLIENT',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          IconButton(
                            onPressed: _goBack,
                            icon: const Icon(Icons.arrow_back_rounded,
                                color: AppColors.primary),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Mes favoris',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Vos talents préférés, toujours à portée de main.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textMedium,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${favoriteProviders.length} prestataire${favoriteProviders.length > 1 ? 's' : ''} enregistré${favoriteProviders.length > 1 ? 's' : ''}',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.textDark,
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: favoriteProviders.isEmpty
                      ? _emptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                          itemCount: favoriteProviders.length,
                          itemBuilder: (context, index) => _FavoriteCard(
                            entry: favoriteProviders[index],
                            onRemove: () => favorites
                                .toggle(favoriteProviders[index].technicianId),
                            onViewProfile: () => context.push(
                              '/service-catalogue/${favoriteProviders[index].technicianId}',
                            ),
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    children: [
                      if (favoriteProviders.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            'Touchez le cœur pour retirer un favori.',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.textLight),
                          ),
                        ),
                      CustomButton(
                        text: "Trouver d'autres talents",
                        isOutlined: true,
                        onPressed: () => context.push('/services'),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Regroupe les services par prestataire et ne conserve que les favoris.
  List<_FavoriteProvider> _buildFavoriteProviders(
    FavoritesProvider favorites,
    List<Service> services,
  ) {
    final Map<int, List<Service>> byTechnician = {};
    for (final service in services) {
      byTechnician.putIfAbsent(service.technicianId, () => []).add(service);
    }

    final entries = <_FavoriteProvider>[];
    byTechnician.forEach((technicianId, techServices) {
      if (!favorites.isFavorite(technicianId)) return;
      techServices.sort((a, b) => a.price.compareTo(b.price));
      final first = techServices.first;
      entries.add(
        _FavoriteProvider(
          technicianId: technicianId,
          name: first.technician?.fullName ?? 'Prestataire',
          specialty: ServiceCard.category(first.category),
          imageUrl: first.technician?.profileImage ?? first.imageUrl,
          minPrice: first.price,
          location: first.technician?.location,
        ),
      );
    });
    return entries;
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite_border_rounded,
                size: 64, color: AppColors.accent),
            const SizedBox(height: 16),
            Text(
              'Aucun favori pour le moment',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Touchez le cœur sur le profil d\'un prestataire pour le retrouver ici.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMedium,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteProvider {
  final int technicianId;
  final String name;
  final String specialty;
  final String? imageUrl;
  final double minPrice;
  final String? location;

  const _FavoriteProvider({
    required this.technicianId,
    required this.name,
    required this.specialty,
    required this.minPrice,
    this.imageUrl,
    this.location,
  });
}

class _FavoriteCard extends StatelessWidget {
  final _FavoriteProvider entry;
  final VoidCallback onRemove;
  final VoidCallback onViewProfile;

  const _FavoriteCard({
    required this.entry,
    required this.onRemove,
    required this.onViewProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: entry.imageUrl != null && entry.imageUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: entry.imageUrl!,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => _placeholder(),
                          placeholder: (_, __) => _placeholder(),
                        )
                      : _placeholder(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.specialty,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (entry.location != null &&
                        entry.location!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        entry.location!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    const SizedBox(height: 5),
                    Text(
                      'À partir de ${ServiceCard.price(entry.minPrice)}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.favorite, color: AppColors.accent),
                tooltip: 'Retirer des favoris',
              ),
            ],
          ),
          const SizedBox(height: 8),
          CustomButton(
            text: 'Voir profil',
            isOutlined: true,
            height: 44,
            onPressed: onViewProfile,
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => const ColoredBox(
        color: AppColors.navyBackground,
        child: Icon(Icons.person_outline, color: AppColors.primary),
      );
}

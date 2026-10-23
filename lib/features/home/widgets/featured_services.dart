import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/service_provider.dart';
import '../../../core/providers/favorites_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../services/widgets/service_card.dart';

class FeaturedServices extends StatelessWidget {
  const FeaturedServices({super.key});
  @override
  Widget build(BuildContext context) =>
      Consumer<ServiceProvider>(builder: (context, provider, _) {
        if (provider.isLoading)
          return const SizedBox(
              height: 240, child: Center(child: CircularProgressIndicator()));
        if (provider.services.isEmpty)
          return const SizedBox(
              height: 160,
              child: Center(
                  child: Text('Aucun talent à découvrir pour le moment.')));
        final seen = <int>{};
        final services = provider.services
            .where((s) => seen.add(s.technicianId))
            .take(8)
            .toList();
        return SizedBox(
            height: 280,
            child: ListView.separated(
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              scrollDirection: Axis.horizontal,
              itemCount: services.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final service = services[index];
                final tech = service.technician;
                final image =
                    service.imageUrl ?? service.technician?.profileImage;
                return GestureDetector(
                    onTap: () => context
                        .go('/service-catalogue/${service.technicianId}'),
                    child: Container(
                      width: 280,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: AppColors.cardShadow,
                          border: Border.all(color: AppColors.divider)),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(children: [
                              SizedBox(
                                  height: 142,
                                  width: double.infinity,
                                  child: image != null && image.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: image,
                                          fit: BoxFit.cover,
                                          errorWidget: (_, __, ___) =>
                                              _placeholder())
                                      : _placeholder()),
                              Positioned(
                                  top: 10,
                                  right: 10,
                                  child: Consumer<FavoritesProvider>(
                                      builder: (context, favorites, _) {
                                    return GestureDetector(
                                        onTap: () => favorites.toggle(
                                            '${service.technicianId}'),
                                        child: Container(
                                            width: 32,
                                            height: 32,
                                            decoration: const BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle),
                                            child: Icon(LucideIcons.heart,
                                                size: 16,
                                                color: AppColors.accent)));
                                  })),
                            ]),
                            Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    12, 10, 12, 0),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          tech?.fullName ?? service.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                  color: AppColors.primary,
                                                  fontWeight: FontWeight.w700)),
                                      const SizedBox(height: 3),
                                      Text(
                                          '${ServiceCard.category(service.category)}${tech?.location == null ? '' : ' · ${tech!.location}'}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall),
                                      const SizedBox(height: 5),
                                      Row(children: [
                                        const Icon(LucideIcons.star,
                                            size: 13, color: AppColors.amber),
                                        const SizedBox(width: 3),
                                        Expanded(
                                            child: Text(
                                          tech?.ratingAvg != null
                                              ? '${tech!.ratingAvg!.toStringAsFixed(1).replaceAll('.', ',')} (${tech.reviewsCount} avis)'
                                              : 'Nouveau',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                  color: AppColors.textMedium),
                                        )),
                                      ]),
                                      const SizedBox(height: 7),
                                      Text(
                                          'À partir de ${ServiceCard.price(service.price)}',
                                          style: const TextStyle(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 13)),
                                    ])),
                          ]),
                    ));
              },
            ));
      });
  Widget _placeholder() => const ColoredBox(
      color: AppColors.navyBackground,
      child: Icon(LucideIcons.flower, color: AppColors.primary, size: 40));
}

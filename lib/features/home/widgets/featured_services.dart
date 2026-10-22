import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/service_provider.dart';
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
            .take(5)
            .toList();
        return SizedBox(
            height: 258,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              scrollDirection: Axis.horizontal,
              itemCount: services.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final service = services[index];
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
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppColors.cardShadow,
                          border: Border.all(color: AppColors.divider)),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                                height: 142,
                                width: double.infinity,
                                child: image != null && image.isNotEmpty
                                    ? Image.network(image,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            _placeholder())
                                    : _placeholder()),
                            Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          service.technician?.fullName ??
                                              service.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                  color: AppColors.primary,
                                                  fontWeight: FontWeight.w700)),
                                      const SizedBox(height: 5),
                                      Text(
                                          '${ServiceCard.category(service.category)}${service.technician?.location == null ? '' : ' · ${service.technician!.location}'}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall),
                                      const SizedBox(height: 8),
                                      Text(
                                          'À partir de ${ServiceCard.price(service.price)}',
                                          style: const TextStyle(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w700)),
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

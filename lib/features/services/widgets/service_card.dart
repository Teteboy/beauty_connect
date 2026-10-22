import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/models/service.dart';
import '../../../core/providers/favorites_provider.dart';
import '../../../core/theme/app_colors.dart';

class ServiceCard extends StatelessWidget {
  final Service service;
  final bool showEditOptions;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final String? actionLabel;
  final VoidCallback? onAction;
  const ServiceCard(
      {super.key,
      required this.service,
      this.showEditOptions = false,
      this.onEdit,
      this.onDelete,
      this.actionLabel,
      this.onAction});

  static String price(num value) =>
      '${NumberFormat('#,##0', 'fr').format(value).replaceAll('\u202f', ' ').replaceAll('\u00a0', ' ')} CFA';
  static String category(String value) =>
      const {
        'Hair': 'Coiffure',
        'Nails': 'Ongles',
        'Makeup': 'Maquillage',
        'Skin': 'Soins',
        'Skincare': 'Soins',
        'Eyebrows': 'Sourcils',
        'Eyelashes': 'Cils',
        'Other': 'Autres',
        'Barber': 'Barbier',
        'Tattoo': 'Tatouage',
        'Wellness': 'Bien-être'
      }[value] ??
      value;

  @override
  Widget build(BuildContext context) {
    final image = service.technician?.profileImage ?? service.imageUrl;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.cardShadow,
          border: Border.all(color: AppColors.divider)),
      child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => context.go('/service/${service.id}'),
            child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                              width: 72,
                              height: 80,
                              child: image != null && image.isNotEmpty
                                  ? Image.network(image,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          _placeholder())
                                  : _placeholder())),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Row(children: [
                              Expanded(
                                  child: Text(
                                      service.technician?.fullName ??
                                          service.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w700))),
                              Consumer<FavoritesProvider>(
                                  builder: (context, favorites, _) {
                                return GestureDetector(
                                    onTap: () =>
                                        favorites.toggle(service.technicianId),
                                    child: Icon(LucideIcons.heart,
                                        size: 18,
                                        color: AppColors.accent));
                              }),
                            ]),
                            const SizedBox(height: 4),
                            Text(
                                '${category(service.category)} · ${service.name}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall),
                            const SizedBox(height: 3),
                            Row(children: [
                              const Icon(LucideIcons.star,
                                  size: 12, color: AppColors.amber),
                              const SizedBox(width: 3),
                              Expanded(
                                  child: Text(
                                      service.technician?.ratingAvg != null
                                          ? '${service.technician!.ratingAvg!.toStringAsFixed(1).replaceAll('.', ',')} (${service.technician!.reviewsCount} avis)${service.technician?.location == null ? '' : ' · ${service.technician!.location}'}'
                                          : (service.technician?.location ??
                                              'Nouveau'),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall)),
                            ]),
                            const SizedBox(height: 5),
                            Row(children: [
                              Expanded(
                                  child: Text(
                                      'À partir de ${price(service.price)}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13))),
                              if (actionLabel != null) ...[
                                const SizedBox(width: 8),
                                GestureDetector(
                                    onTap: onAction,
                                    child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 6),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                                color: AppColors.primary)),
                                        child: Text(actionLabel!,
                                            style: const TextStyle(
                                                color: AppColors.primary,
                                                fontSize: 11,
                                                fontWeight:
                                                    FontWeight.w700))))
                              ],
                            ]),
                            if (!service.isAvailable)
                              const Text('Indisponible',
                                  style: TextStyle(color: AppColors.textLight)),
                          ])),
                      if (showEditOptions)
                        PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') onEdit?.call();
                              if (value == 'delete') onDelete?.call();
                            },
                            itemBuilder: (_) => const [
                                  PopupMenuItem(
                                      value: 'edit', child: Text('Modifier')),
                                  PopupMenuItem(
                                      value: 'delete', child: Text('Supprimer'))
                                ]),
                    ])),
          )),
    );
  }

  Widget _placeholder() => const ColoredBox(
      color: AppColors.navyBackground,
      child: Icon(LucideIcons.user, color: AppColors.primary));
}

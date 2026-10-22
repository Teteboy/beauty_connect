import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/models/service.dart';
import '../../../core/theme/app_colors.dart';

class ServiceCard extends StatelessWidget {
  final Service service;
  final bool showEditOptions;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  const ServiceCard(
      {super.key,
      required this.service,
      this.showEditOptions = false,
      this.onEdit,
      this.onDelete});

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
                            Text(service.technician?.fullName ?? service.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text(
                                '${category(service.category)} · ${service.name}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall),
                            if (service.technician?.location != null)
                              Text(service.technician!.location!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall),
                            const SizedBox(height: 5),
                            Text('À partir de ${price(service.price)}',
                                style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13)),
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

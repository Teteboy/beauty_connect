import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class CategoriesGrid extends StatelessWidget {
  const CategoriesGrid({super.key});

  static const categories = [
    ('Coiffure', 'Hair', LucideIcons.scissors),
    ('Ongles', 'Nails', LucideIcons.hand),
    ('Maquillage', 'Makeup', LucideIcons.brush),
    ('Soins', 'Skincare', LucideIcons.droplet),
    ('Tatouage', 'Tattoo', LucideIcons.penTool),
    ('Barbier', 'Barber', LucideIcons.scissors),
    ('Bien-être', 'Wellness', LucideIcons.flower),
    ('Fitness', 'Fitness', LucideIcons.dumbbell),
    ('Cils', 'Eyelashes', LucideIcons.eye),
    ('Massage', 'Massage', LucideIcons.flower),
  ];

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 38,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final category = categories[index];
            return ActionChip(
              avatar: Icon(category.$3,
                  size: 16,
                  color: index == 0 ? Colors.white : AppColors.primary),
              label: Text(category.$1),
              backgroundColor:
                  index == 0 ? AppColors.accent : AppColors.navyBackground,
              side: BorderSide.none,
              labelStyle: TextStyle(
                  color: index == 0 ? Colors.white : AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12),
              onPressed: () => context.go('/services?category=${category.$2}'),
            );
          },
        ),
      );
}

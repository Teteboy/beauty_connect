import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class CategoriesGrid extends StatelessWidget {
  const CategoriesGrid({super.key});

  static const categories = [
    ('Coiffure', 'Hair', Icons.content_cut),
    ('Ongles', 'Nails', Icons.back_hand_outlined),
    ('Maquillage', 'Makeup', Icons.brush_outlined),
    ('Soins', 'Skincare', Icons.water_drop_outlined),
    ('Tatouage', 'Tattoo', Icons.draw_outlined),
    ('Barbier', 'Barber', Icons.face_outlined),
    ('Bien-être', 'Wellness', Icons.spa_outlined),
    ('Fitness', 'Fitness', Icons.fitness_center),
    ('Cils', 'Eyelashes', Icons.visibility_outlined),
    ('Massage', 'Massage', Icons.self_improvement),
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

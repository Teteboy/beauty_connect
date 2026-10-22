import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

/// Orange eyebrow label shown at the top of every "future concept" screen.
class ConceptEyebrow extends StatelessWidget {
  const ConceptEyebrow({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'CONCEPTS FUTURS · CONCEPT · À VENIR',
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.accent,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
    );
  }
}

/// Pale-orange info banner explaining that the feature is a demo concept.
class ConceptBanner extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;

  const ConceptBanner({
    super.key,
    this.title = 'Concept • À venir',
    this.message =
        'Aperçu d\'une fonctionnalité future. Aucune opération réelle n\'est effectuée.',
    this.icon = LucideIcons.info,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.orangePale,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.accent, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMedium,
                        height: 1.35,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Consistent header for future-concept screens: back button, eyebrow and
/// title, optional trailing icon — matching the Figma frames.
class ConceptHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final VoidCallback? onBack;

  const ConceptHeader({
    super.key,
    required this.title,
    this.trailing,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ConceptEyebrow(),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton(
              onPressed: onBack ??
                  () => context.canPop() ? context.pop() : context.go('/home'),
              icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textDark),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
            trailing ??
                const Icon(LucideIcons.info,
                    color: AppColors.textLight, size: 22),
          ],
        ),
      ],
    );
  }
}

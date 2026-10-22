import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// BeautyConnect brand logo.
///
/// Renders the real brand emblem from `assets/images/logo_emblem.png`.
/// Set [circular] to wrap it in the branded gradient circle, or use
/// [variant] `full` to show the emblem + wordmark lockup
/// (`assets/images/logo_full.png`).
class AppLogo extends StatelessWidget {
  final double size;
  final Color? backgroundColor;
  final bool circular;
  final bool full;

  const AppLogo({
    super.key,
    this.size = 80,
    this.backgroundColor,
    this.circular = true,
    this.full = false,
  });

  @override
  Widget build(BuildContext context) {
    if (full) {
      return Image.asset(
        'assets/images/logo_full.png',
        height: size,
        fit: BoxFit.contain,
      );
    }

    if (circular) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withOpacity(0.25),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipOval(
          child: Padding(
            padding: EdgeInsets.all(size * 0.08),
            child: Image.asset(
              'assets/images/logo_emblem.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      );
    }

    return Image.asset(
      'assets/images/logo_emblem.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}

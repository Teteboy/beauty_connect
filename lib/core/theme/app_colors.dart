import 'package:flutter/material.dart';

class AppColors {
  // Brand — navy + orange
  static const Color primary = Color(0xFF1B2E7A);
  static const Color primaryDark = Color(0xFF0F1D52);
  static const Color midNavy = Color(0xFF253DA0);
  static const Color accent = Color(0xFFE8620A);
  static const Color accentLight = Color(0xFFF47C2E);
  static const Color amber = Color(0xFFF5A623);
  static const Color primaryLight = midNavy;
  static const Color accentPink = accent;

  // Backgrounds
  static const Color scaffoldBackground = Colors.white;
  static const Color cardBackground = Colors.white;
  static const Color surface = Colors.white;
  static const Color navyBackground = Color(0xFFF0F3FB);
  static const Color orangePale = Color(0xFFFDF0E6);

  // Text
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textMedium = Color(0xFF374151);
  static const Color textLight = Color(0xFF6B7280);

  // States
  static const Color success = Color(0xFF16A34A);
  static const Color warning = amber;
  static const Color error = Color(0xFFC52E36);
  static const Color info = Color(0xFF1976D2);

  // Misc
  static const Color divider = Color(0xFFE2E8F0);
  static const Color shadow = Color(0x141B2E7A);
  static const Color inputFill = Colors.white;
  static const Color inputBorder = Color(0xFFE2E8F0);
  static const Color chipBackground = navyBackground;
  static const Color online = Color(0xFF16A34A);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryDark, primary],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [primaryDark, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Elevation (Figma effect styles)
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: primary.withValues(alpha: 0.08),
          blurRadius: 12,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get buttonShadow => [
        BoxShadow(
          color: accent.withValues(alpha: 0.28),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get sheetShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.12),
          blurRadius: 24,
          offset: const Offset(0, -4),
        ),
      ];
}

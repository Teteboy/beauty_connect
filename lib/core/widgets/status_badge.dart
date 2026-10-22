import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  Color get _backgroundColor {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.amber;
      case 'confirmed':
        return AppColors.primary;
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.textLight;
      case 'in_progress':
        return AppColors.midNavy;
      default:
        return AppColors.chipBackground;
    }
  }

  Color get _textColor {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFF7A4A00);
      case 'confirmed':
      case 'completed':
      case 'in_progress':
        return Colors.white;
      case 'cancelled':
        return const Color(0xFF374151);
      default:
        return AppColors.textMedium;
    }
  }

  String get _label {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'En attente';
      case 'confirmed':
        return 'Confirmée';
      case 'completed':
        return 'Terminée';
      case 'cancelled':
        return 'Annulée';
      case 'in_progress':
        return 'En cours';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _label,
        style: TextStyle(
          color: _textColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

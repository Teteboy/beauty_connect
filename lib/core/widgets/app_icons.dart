import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Icônes fines (style Lucide) alignées sur le design Figma.
class AppIcons {
  AppIcons._();

  /// Catégories de services — set Figma « Catégories · défaut et sélection ».
  static IconData forCategory(String category) {
    switch (category.toLowerCase()) {
      case 'coiffure':
        return LucideIcons.scissors;
      case 'ongles':
        return LucideIcons.hand;
      case 'maquillage':
        return LucideIcons.brush;
      case 'soins':
        return LucideIcons.droplets;
      case 'tatouage':
        return LucideIcons.penTool;
      case 'barbier':
        return LucideIcons.scissors;
      case 'bien-être':
      case 'bien-etre':
        return LucideIcons.sparkles;
      case 'fitness':
        return LucideIcons.dumbbell;
      case 'cils':
        return LucideIcons.eye;
      case 'massage':
      case 'massage & bien-être':
        return LucideIcons.flower;
      case 'esthétique':
      case 'esthetique':
        return LucideIcons.sparkles;
      case 'autre':
        return LucideIcons.plus;
      default:
        return LucideIcons.sparkles;
    }
  }
}

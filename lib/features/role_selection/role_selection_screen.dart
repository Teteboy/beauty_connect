import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_logo.dart';
import '../../core/widgets/custom_button.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});
  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const SizedBox(height: 20),
          const Text('BIENVENUE',
              style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 10,
                  fontWeight: FontWeight.w700)),
          const Text('Bienvenue chez vous',
              style: TextStyle(
                  color: AppColors.primaryDark,
                  fontSize: 22,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 40),
          const AppLogo(size: 210, full: true),
          const SizedBox(height: 24),
          const Text('Vous êtes ?',
              style: TextStyle(
                  color: AppColors.primaryDark,
                  fontSize: 32,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 20),
          const Text(
              'Une expérience adaptée à vos envies. Choisissez comment rejoindre BeautyConnect.'),
          const SizedBox(height: 40),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
                child: _roleCard('customer', 'Je cherche des services',
                    'Découvrir et réserver', Icons.person_outline)),
            const SizedBox(width: 12),
            Expanded(
                child: _roleCard('technician', 'Je suis un prestataire',
                    'Partager mon savoir-faire', Icons.content_cut)),
          ]),
          const SizedBox(height: 18),
          const Text('Deux rôles, une même connexion.',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
          const SizedBox(height: 24),
          CustomButton(
              text: 'Continuer',
              onPressed: _selectedRole == null
                  ? null
                  : () => context.go('/register', extra: _selectedRole)),
          TextButton(
              onPressed: () => context.go('/login'),
              child: const Text('Déjà un compte ? Se connecter')),
        ]),
      )),
    );
  }

  Widget _roleCard(
      String role, String title, String description, IconData icon) {
    final selected = _selectedRole == role;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? AppColors.orangePale : Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
                color: selected ? AppColors.accent : AppColors.primary,
                width: selected ? 2 : 1)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
            onTap: () => setState(() => _selectedRole = role),
            child: Container(
              constraints: const BoxConstraints(minHeight: 190),
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon,
                        color: selected ? AppColors.accent : AppColors.primary,
                        size: 30),
                    const SizedBox(height: 20),
                    Text(title,
                        style: const TextStyle(
                            color: AppColors.primaryDark,
                            fontSize: 17,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 14),
                    Text(description,
                        style: const TextStyle(fontSize: 12, height: 1.4)),
                  ]),
            )),
      ),
    );
  }
}

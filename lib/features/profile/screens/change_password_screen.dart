import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/profile');
    }
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.changePassword(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? 'Mot de passe modifié avec succès !'
            : authProvider.error ?? 'Échec du changement de mot de passe'),
        backgroundColor: success ? AppColors.success : AppColors.error,
      ),
    );
    if (success) _goBack();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Changer le mot de passe'),
        leading: IconButton(
          onPressed: _goBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sécurité du compte',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text(
                        'Saisissez votre mot de passe actuel puis choisissez-en un nouveau',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textMedium,
                            ),
                      ),
                      const SizedBox(height: 24),
                      CustomTextField(
                        controller: _currentPasswordController,
                        label: 'Mot de passe actuel',
                        obscureText: _obscureCurrentPassword,
                        prefixIcon: const Icon(Icons.lock_outline,
                            color: AppColors.textMedium),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureCurrentPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                          onPressed: () => setState(() =>
                              _obscureCurrentPassword =
                                  !_obscureCurrentPassword),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Le mot de passe actuel est requis'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _newPasswordController,
                        label: 'Nouveau mot de passe',
                        obscureText: _obscureNewPassword,
                        prefixIcon: const Icon(Icons.lock_outline,
                            color: AppColors.textMedium),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureNewPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                          onPressed: () => setState(
                              () => _obscureNewPassword = !_obscureNewPassword),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Le nouveau mot de passe est requis';
                          }
                          if (value.length < 6) {
                            return 'Le mot de passe doit contenir au moins 6 caractères';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _confirmPasswordController,
                        label: 'Confirmer le nouveau mot de passe',
                        obscureText: _obscureConfirmPassword,
                        prefixIcon: const Icon(Icons.lock_outline,
                            color: AppColors.textMedium),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                          onPressed: () => setState(() =>
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez confirmer votre nouveau mot de passe';
                          }
                          if (value != _newPasswordController.text) {
                            return 'Les mots de passe ne correspondent pas';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Exigences du mot de passe',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 14),
                      _requirement('Au moins 6 caractères'),
                      _requirement('Contient lettres et chiffres'),
                      _requirement('Différent du mot de passe actuel'),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                CustomButton(
                  text: 'Changer le mot de passe',
                  isLoading: authProvider.isLoading,
                  onPressed: authProvider.isLoading ? null : _changePassword,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _requirement(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            const Icon(Icons.check_circle_outline,
                size: 18, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(text,
                  style: const TextStyle(color: AppColors.textMedium)),
            ),
          ],
        ),
      );
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
                color: AppColors.shadow, blurRadius: 18, offset: Offset(0, 6)),
          ],
        ),
        child: child,
      );
}

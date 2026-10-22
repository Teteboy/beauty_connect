import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendEmail() async {
    if (!_emailSent && !(_formKey.currentState?.validate() ?? false)) return;
    final authProvider = context.read<AuthProvider>();
    final success =
        await authProvider.forgotPassword(_emailController.text.trim());
    if (!mounted) return;
    if (success) {
      setState(() => _emailSent = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(authProvider.error ??
              'Impossible d’envoyer le lien. Veuillez réessayer.'),
          backgroundColor: AppColors.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    return Scaffold(
        body: SafeArea(
            child: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
          key: _formKey,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              IconButton(
                  tooltip: 'Retour',
                  onPressed: () => context.go('/login'),
                  icon: const Icon(LucideIcons.arrowLeft, color: AppColors.primary)),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    const Text('BIENVENUE',
                        style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 10,
                            fontWeight: FontWeight.w700)),
                    Text(
                        _emailSent
                            ? 'Consultez vos e-mails'
                            : 'Mot de passe oublié ?',
                        style: const TextStyle(
                            color: AppColors.primaryDark,
                            fontSize: 22,
                            fontWeight: FontWeight.w700)),
                  ])),
            ]),
            const SizedBox(height: 64),
            Center(
                child: Container(
                    width: 128,
                    height: 128,
                    decoration: const BoxDecoration(
                        color: AppColors.navyBackground,
                        shape: BoxShape.circle),
                    child: Icon(
                        _emailSent
                            ? LucideIcons.mailCheck
                            : LucideIcons.key,
                        color: AppColors.accent,
                        size: 52))),
            const SizedBox(height: 56),
            Text(_emailSent ? 'Un lien vous attend.' : 'Pas d’inquiétude.',
                style: const TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: 28,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            Text(_emailSent
                ? 'Si un compte est associé à ${_emailController.text.trim()}, vous recevrez un lien pour réinitialiser votre mot de passe.'
                : 'Indiquez votre adresse e-mail. Nous vous enverrons un lien de réinitialisation.'),
            const SizedBox(height: 24),
            if (!_emailSent) ...[
              CustomTextField(
                  controller: _emailController,
                  label: 'Adresse e-mail',
                  hintText: 'lea.mballa@gmail.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value?.isEmpty ?? true)
                      return 'Veuillez saisir votre adresse e-mail.';
                    if (!RegExp(r'^\S+@\S+\.\S+').hasMatch(value!))
                      return 'Veuillez saisir une adresse e-mail valide.';
                    return null;
                  }),
              const SizedBox(height: 16),
            ],
            CustomButton(
                text: _emailSent
                    ? 'Renvoyer le lien'
                    : 'Envoyer le lien de réinitialisation',
                isLoading: authProvider.isLoading,
                onPressed: _sendEmail),
            if (_emailSent) ...[
              const SizedBox(height: 16),
              Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: AppColors.navyBackground,
                      borderRadius: BorderRadius.circular(12)),
                  child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(LucideIcons.circleCheck,
                            color: AppColors.primary, size: 20),
                        SizedBox(width: 12),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text('E-mail envoyé',
                                  style: TextStyle(
                                      color: AppColors.primaryDark,
                                      fontWeight: FontWeight.w700)),
                              SizedBox(height: 4),
                              Text(
                                  'Vous n’avez rien reçu ? Vérifiez vos courriers indésirables ou réessayez avec une autre adresse.',
                                  style: TextStyle(fontSize: 12)),
                            ])),
                      ])),
              TextButton(
                  onPressed: () => setState(() => _emailSent = false),
                  child: const Text('Utiliser une autre adresse')),
            ],
            const SizedBox(height: 24),
            TextButton(
                onPressed: () => context.go('/login'),
                child: const Text('Retour à la connexion')),
          ])),
    )));
  }
}

/// Opened from the reset link with its token, never from the email confirmation.
class ResetPasswordScreen extends StatefulWidget {
  final String token;
  const ResetPasswordScreen({super.key, required this.token});
  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _reset() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.resetPassword(
        token: widget.token, newPassword: _passwordController.text);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Votre mot de passe a été réinitialisé.')));
      context.go('/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(authProvider.error ??
              'La réinitialisation a échoué. Veuillez demander un nouveau lien.'),
          backgroundColor: AppColors.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AuthProvider>().isLoading;
    final validToken = widget.token.trim().isNotEmpty;
    return Scaffold(
        body: SafeArea(
            child: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
          key: _formKey,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              IconButton(
                  tooltip: 'Retour',
                  onPressed: () => context.go('/login'),
                  icon: const Icon(LucideIcons.arrowLeft, color: AppColors.primary)),
              const Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('BIENVENUE',
                        style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 10,
                            fontWeight: FontWeight.w700)),
                    Text('Nouveau mot de passe',
                        style: TextStyle(
                            color: AppColors.primaryDark,
                            fontSize: 22,
                            fontWeight: FontWeight.w700)),
                  ])),
            ]),
            const SizedBox(height: 64),
            Center(
                child: Container(
                    width: 128,
                    height: 128,
                    decoration: const BoxDecoration(
                        color: AppColors.navyBackground,
                        shape: BoxShape.circle),
                    child: const Icon(LucideIcons.shieldCheck,
                        color: AppColors.accent, size: 52))),
            const SizedBox(height: 56),
            const Text('Un nouveau départ.',
                style: TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: 28,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            const Text(
                'Choisissez un mot de passe unique pour protéger votre compte.'),
            const SizedBox(height: 24),
            if (!validToken) ...[
              const Text(
                  'Ce lien est incomplet. Demandez un nouveau lien de réinitialisation.',
                  style: TextStyle(color: AppColors.error)),
              TextButton(
                  onPressed: () => context.go('/forgot-password'),
                  child: const Text('Demander un nouveau lien')),
            ],
            CustomTextField(
                controller: _passwordController,
                label: 'Nouveau mot de passe',
                enabled: validToken,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                    tooltip: _obscurePassword
                        ? 'Afficher le mot de passe'
                        : 'Masquer le mot de passe',
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    icon: Icon(
                        _obscurePassword
                            ? LucideIcons.eyeOff
                            : LucideIcons.eye,
                        size: 20)),
                validator: (value) => value == null ||
                        value.length < 8 ||
                        !RegExp(r'[a-zA-Z]').hasMatch(value) ||
                        !RegExp(r'[0-9]').hasMatch(value)
                    ? 'Au moins 8 caractères, avec lettres et chiffres.'
                    : null),
            const SizedBox(height: 20),
            CustomTextField(
                controller: _confirmController,
                label: 'Confirmer le mot de passe',
                enabled: validToken,
                obscureText: _obscureConfirm,
                suffixIcon: IconButton(
                    tooltip: _obscureConfirm
                        ? 'Afficher la confirmation'
                        : 'Masquer la confirmation',
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                    icon: Icon(
                        _obscureConfirm
                            ? LucideIcons.eyeOff
                            : LucideIcons.eye,
                        size: 20)),
                validator: (value) => value != _passwordController.text ||
                        (value?.isEmpty ?? true)
                    ? 'Les mots de passe ne correspondent pas.'
                    : null),
            const SizedBox(height: 12),
            const Text('Au moins 8 caractères, avec lettres et chiffres.',
                style: TextStyle(color: AppColors.textLight, fontSize: 11)),
            const SizedBox(height: 16),
            CustomButton(
                text: 'Réinitialiser',
                isLoading: loading,
                onPressed: validToken ? _reset : null),
            const SizedBox(height: 24),
            TextButton(
                onPressed: () => context.go('/login'),
                child: const Text('Retour à la connexion')),
          ])),
    )));
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (!mounted) return;
    if (success) {
      context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(authProvider.error ?? 'La connexion a échoué.'),
        backgroundColor: AppColors.error,
      ));
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
                  onPressed: () => context.go('/role-selection'),
                  icon: const Icon(Icons.arrow_back, color: AppColors.primary)),
              const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('BIENVENUE',
                        style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 10,
                            fontWeight: FontWeight.w700)),
                    Text('Connexion',
                        style: TextStyle(
                            color: AppColors.primaryDark,
                            fontSize: 22,
                            fontWeight: FontWeight.w700)),
                  ]),
            ]),
            const SizedBox(height: 36),
            const Align(
                alignment: Alignment.centerLeft,
                child: AppLogo(size: 64, full: true)),
            const SizedBox(height: 20),
            const Text('Bon retour !',
                style: TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: 32,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            const Text('Vos experts préférés n’attendent que vous.'),
            const SizedBox(height: 32),
            CustomTextField(
                controller: _emailController,
                label: 'Adresse e-mail',
                hintText: 'lea.mballa@gmail.com',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value?.isEmpty ?? true)
                    return 'Veuillez saisir votre adresse e-mail.';
                  if (!RegExp(r'^\S+@\S+\.\S+').hasMatch(value!))
                    return 'Veuillez saisir une adresse e-mail valide.';
                  return null;
                }),
            const SizedBox(height: 20),
            CustomTextField(
                controller: _passwordController,
                label: 'Mot de passe',
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  tooltip: _obscurePassword
                      ? 'Afficher le mot de passe'
                      : 'Masquer le mot de passe',
                  icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                      color: AppColors.textLight),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true)
                    return 'Veuillez saisir votre mot de passe.';
                  if (value!.length < 6)
                    return 'Le mot de passe doit contenir au moins 6 caractères.';
                  return null;
                }),
            Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                    onPressed: () => context.go('/forgot-password'),
                    child: const Text('Mot de passe oublié ?'))),
            CustomButton(
                text: 'Se connecter',
                backgroundColor: AppColors.primary,
                isLoading: authProvider.isLoading,
                onPressed: _login),
            const SizedBox(height: 32),
            const Row(children: [
              Expanded(child: Divider()),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('ou continuer avec',
                      style:
                          TextStyle(fontSize: 12, color: AppColors.textLight))),
              Expanded(child: Divider())
            ]),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(
                  child: CustomButton(
                      text: 'Google',
                      icon: Icons.g_mobiledata,
                      isOutlined: true,
                      height: 50,
                      onPressed: () {})),
              const SizedBox(width: 12),
              Expanded(
                  child: CustomButton(
                      text: 'Apple',
                      icon: Icons.apple,
                      isOutlined: true,
                      height: 50,
                      onPressed: () {})),
            ]),
            const SizedBox(height: 32),
            const Text('Pas encore de compte ?', textAlign: TextAlign.center),
            TextButton(
                onPressed: () => context.go('/role-selection'),
                child: const Text('S’inscrire')),
          ])),
    )));
  }
}

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/custom_dropdown.dart';

class RegisterScreen extends StatefulWidget {
  final String? initialRole;
  const RegisterScreen({super.key, this.initialRole});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _locationController = TextEditingController();
  final _bioController = TextEditingController();
  final _customSpecialtyController = TextEditingController();
  String? _specialty;
  late String _selectedRole;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreedToTerms = false;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole ?? 'customer';
  }

  @override
  void dispose() {
    for (final controller in [
      _firstNameController,
      _lastNameController,
      _emailController,
      _phoneController,
      _passwordController,
      _confirmController,
      _locationController,
      _bioController,
      _customSpecialtyController
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Veuillez accepter les conditions d’utilisation et la politique de confidentialité.'),
          backgroundColor: AppColors.error));
      return;
    }
    if (_selectedRole == 'technician') {
      if (_specialty == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Veuillez choisir votre spécialité.'),
            backgroundColor: AppColors.error));
        return;
      }
      if (_locationController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Veuillez indiquer votre zone d’activité.'),
            backgroundColor: AppColors.error));
        return;
      }
    }
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      phone: _phoneController.text.trim(),
      role: _selectedRole,
      location: _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
      bio: _bioController.text.trim().isEmpty
          ? null
          : _bioController.text.trim(),
      specialty: _selectedRole == 'technician'
          ? (_specialty == 'Autre'
              ? _customSpecialtyController.text.trim()
              : _specialty)
          : null,
    );
    if (!mounted) return;
    if (success) {
      if (authProvider.user?.role == 'technician') {
        context.go('/technician-home');
      } else {
        context.go('/home');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(authProvider.error ?? 'L’inscription a échoué.'),
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
                  onPressed: () => context.go('/role-selection'),
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
                    Text('Créer un compte',
                        style: TextStyle(
                            color: AppColors.primaryDark,
                            fontSize: 22,
                            fontWeight: FontWeight.w700)),
                  ])),
            ]),
            const SizedBox(height: 24),
            const Text('La beauté commence par une rencontre.'),
            const SizedBox(height: 16),
            Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                    color: AppColors.navyBackground,
                    borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  Expanded(child: _roleTab('customer', 'Client')),
                  Expanded(child: _roleTab('technician', 'Prestataire')),
                ])),
            const SizedBox(height: 20),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                  child: CustomTextField(
                      controller: _firstNameController,
                      label: 'Prénom',
                      hintText: 'Léa',
                      textInputAction: TextInputAction.next,
                      validator: (value) => (value?.trim().isEmpty ?? true)
                          ? 'Veuillez saisir votre prénom.'
                          : null)),
              const SizedBox(width: 12),
              Expanded(
                  child: CustomTextField(
                      controller: _lastNameController,
                      label: 'Nom',
                      hintText: 'Mballa',
                      textInputAction: TextInputAction.next,
                      validator: (value) => (value?.trim().isEmpty ?? true)
                          ? 'Veuillez saisir votre nom.'
                          : null)),
            ]),
            const SizedBox(height: 16),
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
            const SizedBox(height: 16),
            CustomTextField(
                controller: _phoneController,
                label: 'Téléphone',
                hintText: '+237 6 77 12 34 56',
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                validator: (value) => (value?.isEmpty ?? true)
                    ? 'Veuillez saisir votre numéro de téléphone.'
                    : null),
            if (_selectedRole == 'technician') ...[
              const SizedBox(height: 24),
              const Text('VOTRE ACTIVITÉ',
                  style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 10,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              CustomDropdown<String>(
                  label: 'Spécialité',
                  hintText: 'Choisissez votre domaine',
                  value: _specialty,
                  items: const [
                    DropdownMenuItem(value: 'Coiffure', child: Text('Coiffure')),
                    DropdownMenuItem(value: 'Barbier', child: Text('Barbier')),
                    DropdownMenuItem(value: 'Ongles', child: Text('Ongles')),
                    DropdownMenuItem(
                        value: 'Maquillage', child: Text('Maquillage')),
                    DropdownMenuItem(
                        value: 'Esthétique', child: Text('Esthétique')),
                    DropdownMenuItem(
                        value: 'Massage & bien-être',
                        child: Text('Massage & bien-être')),
                    DropdownMenuItem(value: 'Fitness', child: Text('Fitness')),
                    DropdownMenuItem(
                        value: 'Tatouage', child: Text('Tatouage')),
                    DropdownMenuItem(value: 'Autre', child: Text('Autre')),
                  ],
                  onChanged: (value) => setState(() => _specialty = value),
                  validator: (value) =>
                      value == null ? 'Veuillez choisir votre spécialité.' : null),
              if (_specialty == 'Autre') ...[
                const SizedBox(height: 16),
                CustomTextField(
                    controller: _customSpecialtyController,
                    label: 'Précisez votre spécialité',
                    hintText: 'Ex. : Tresses, Dreadlocks, Soins capillaires…',
                    textInputAction: TextInputAction.next,
                    validator: (value) => (value?.trim().isEmpty ?? true)
                        ? 'Veuillez préciser votre spécialité.'
                        : null),
              ],
              const SizedBox(height: 16),
              CustomTextField(
                  controller: _locationController,
                  label: 'Zone d’activité',
                  hintText: 'Douala, Bonapriso',
                  textInputAction: TextInputAction.next,
                  validator: (value) => (value?.trim().isEmpty ?? true)
                      ? 'Veuillez indiquer votre zone d’activité.'
                      : null),
              const SizedBox(height: 16),
              CustomTextField(
                  controller: _bioController,
                  label: 'Présentation (facultatif)',
                  hintText: 'Parlez de votre expérience et de vos services…',
                  maxLines: 3),
            ],
            const SizedBox(height: 16),
            CustomTextField(
                controller: _passwordController,
                label: 'Mot de passe',
                hintText: '6 caractères minimum',
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.next,
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
                        size: 20,
                        color: AppColors.textLight)),
                validator: (value) {
                  if (value?.isEmpty ?? true)
                    return 'Veuillez saisir votre mot de passe.';
                  if (value!.length < 6)
                    return 'Le mot de passe doit contenir au moins 6 caractères.';
                  return null;
                }),
            const SizedBox(height: 16),
            CustomTextField(
                controller: _confirmController,
                label: 'Confirmer le mot de passe',
                hintText: 'Saisir à nouveau',
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
                        size: 20,
                        color: AppColors.textLight)),
                validator: (value) => value != _passwordController.text ||
                        (value?.isEmpty ?? true)
                    ? 'Les mots de passe ne correspondent pas.'
                    : null),
            const SizedBox(height: 12),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Checkbox(
                  value: _agreedToTerms,
                  activeColor: AppColors.accent,
                  onChanged: (value) =>
                      setState(() => _agreedToTerms = value ?? false)),
              const Expanded(
                  child: Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text(
                          'J’accepte les conditions d’utilisation et la politique de confidentialité.',
                          style: TextStyle(fontSize: 12)))),
            ]),
            TextButton(
                onPressed: () => context.go('/login'),
                child: const Text('Déjà un compte ? Se connecter')),
            const SizedBox(height: 24),
            CustomButton(
                text: 'S’inscrire',
                isLoading: authProvider.isLoading,
                onPressed: _handleRegister),
          ])),
    )));
  }

  Widget _roleTab(String role, String label) {
    final selected = _selectedRole == role;
    return Semantics(
        selected: selected,
        child: TextButton(
          onPressed: () => setState(() => _selectedRole = role),
          style: TextButton.styleFrom(
              backgroundColor:
                  selected ? AppColors.primary : Colors.transparent,
              foregroundColor: selected ? Colors.white : AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10))),
          child: Text(label),
        ));
  }
}

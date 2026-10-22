import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/profile_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _locationController;
  late final TextEditingController _bioController;
  late final TextEditingController _specialtyController;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user!;
    _firstNameController = TextEditingController(text: user.firstName);
    _lastNameController = TextEditingController(text: user.lastName);
    _phoneController = TextEditingController(text: user.phone ?? '');
    _emailController = TextEditingController(text: user.email);
    _locationController = TextEditingController(text: user.location ?? '');
    _bioController = TextEditingController(text: user.bio ?? '');
    _specialtyController = TextEditingController(text: user.specialty ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    _specialtyController.dispose();
    super.dispose();
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/profile');
    }
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text('Photo de profil',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _ImagePickerOption(
                icon: LucideIcons.image,
                label: 'Galerie',
                onTap: () {
                  Navigator.pop(sheetContext);
                  context.read<ProfileProvider>().pickImage();
                },
              ),
              _ImagePickerOption(
                icon: LucideIcons.camera,
                label: 'Appareil photo',
                onTap: () {
                  Navigator.pop(sheetContext);
                  context.read<ProfileProvider>().takePhoto();
                },
              ),
              _ImagePickerOption(
                icon: LucideIcons.trash,
                label: 'Supprimer',
                onTap: () {
                  Navigator.pop(sheetContext);
                  context.read<ProfileProvider>().clearSelectedImage();
                },
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final profileProvider = context.read<ProfileProvider>();
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user!;
    final success = await profileProvider.updateProfile(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      location: _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
      bio: _bioController.text.trim().isEmpty
          ? null
          : _bioController.text.trim(),
      specialty: user.role == 'technician' &&
              _specialtyController.text.trim().isNotEmpty
          ? _specialtyController.text.trim()
          : null,
      profileImage: profileProvider.selectedImage,
      authProvider: authProvider,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(success ? LucideIcons.circleCheck : LucideIcons.circleAlert,
            color: AppColors.surface),
        const SizedBox(width: 8),
        Expanded(
          child: Text(success
              ? 'Profil mis à jour avec succès !'
              : profileProvider.error ?? 'Échec de la mise à jour du profil'),
        ),
      ]),
      backgroundColor: success ? AppColors.success : AppColors.error,
      behavior: SnackBarBehavior.floating,
    ));
    if (success) context.go('/profile');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            final user = authProvider.user!;
            return Consumer<ProfileProvider>(
              builder: (context, profileProvider, _) => Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: _goBack,
                          icon: const Icon(LucideIcons.arrowLeft,
                              color: AppColors.textDark),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'MON ESPACE · ${user.role == 'technician' ? 'PRESTATAIRE' : 'CLIENT'}',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.2,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Modifier le profil',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                      child: Form(
                        key: _formKey,
                        child: Column(children: [
                          _ProfilePhoto(
                            user: user,
                            profileProvider: profileProvider,
                            onTap: _showImagePicker,
                          ),
                          const SizedBox(height: 24),
                          Row(children: [
                            Expanded(
                              child: CustomTextField(
                                controller: _firstNameController,
                                label: 'Prénom',
                                validator: (value) =>
                                    value == null || value.trim().isEmpty
                                        ? 'Le prénom est requis'
                                        : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CustomTextField(
                                controller: _lastNameController,
                                label: 'Nom',
                                validator: (value) =>
                                    value == null || value.trim().isEmpty
                                        ? 'Le nom est requis'
                                        : null,
                              ),
                            ),
                          ]),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _emailController,
                            label: 'Adresse e-mail',
                            enabled: false,
                            prefixIcon: const Icon(LucideIcons.mail,
                                color: AppColors.textMedium),
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _phoneController,
                            label: 'Téléphone',
                            hintText: '+237 6 77 12 34 56',
                            keyboardType: TextInputType.phone,
                            prefixIcon: const Icon(LucideIcons.phone,
                                color: AppColors.textMedium),
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _locationController,
                            label: 'Localisation',
                            hintText: 'Ex. Douala, Bonapriso',
                            prefixIcon: const Icon(LucideIcons.mapPin,
                                color: AppColors.textMedium),
                          ),
                          if (user.role == 'technician') ...[
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: _specialtyController,
                              label: 'Spécialités',
                              hintText: 'Ex. Coiffeuse, Prothésiste ongulaire',
                              prefixIcon: const Icon(LucideIcons.flower,
                                  color: AppColors.textMedium),
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: _bioController,
                              label: 'Bio',
                              hintText: 'Parlez-nous de vous...',
                              maxLines: 4,
                              prefixIcon: const Icon(LucideIcons.pencil,
                                  color: AppColors.textMedium),
                              validator: (value) => value != null &&
                                      value.length > 500
                                  ? 'La bio doit faire 500 caractères ou moins'
                                  : null,
                            ),
                          ],
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.navyBackground,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(LucideIcons.shieldCheck,
                                    color: AppColors.primary, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Vos données, votre choix',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Votre e-mail et votre numéro de téléphone ne sont jamais affichés sur votre profil public.',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: AppColors.textMedium,
                                              height: 1.4,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ]),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: CustomButton(
                      text: 'Enregistrer les modifications',
                      isLoading: profileProvider.isLoading,
                      onPressed:
                          profileProvider.isLoading ? null : _saveProfile,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProfilePhoto extends StatelessWidget {
  const _ProfilePhoto({
    required this.user,
    required this.profileProvider,
    required this.onTap,
  });
  final dynamic user;
  final ProfileProvider profileProvider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasNetworkImage =
        user.profileImage != null && user.profileImage!.isNotEmpty;
    final firstInitial = user.firstName.isNotEmpty ? user.firstName[0] : '';
    final lastInitial = user.lastName.isNotEmpty ? user.lastName[0] : '';
    return Row(children: [
      Stack(children: [
        CircleAvatar(
          radius: 34,
          backgroundColor: AppColors.navyBackground,
          backgroundImage: profileProvider.selectedImage != null
              ? FileImage(profileProvider.selectedImage!)
              : hasNetworkImage
                  ? CachedNetworkImageProvider(user.profileImage!)
                  : null,
          child: profileProvider.selectedImage == null && !hasNetworkImage
              ? Text('$firstInitial$lastInitial',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ))
              : null,
        ),
      ]),
      const SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Modifier la photo',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w700,
                    )),
            const SizedBox(height: 2),
            Text('Appareil photo ou galerie',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textMedium,
                    )),
          ],
        ),
      ),
      IconButton(
        onPressed: onTap,
        icon: const Icon(LucideIcons.camera,
            color: AppColors.accent, size: 26),
      ),
    ]);
  }
}

class _ImagePickerOption extends StatelessWidget {
  const _ImagePickerOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.orangePale,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.accent),
            ),
            const SizedBox(height: 8),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ]),
        ),
      );
}

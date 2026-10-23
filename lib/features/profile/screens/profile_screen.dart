import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/favorites_provider.dart';
import '../../../core/providers/service_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            final user = authProvider.user;

            if (user == null) {
              return Center(
                child: Text(
                  'Veuillez vous connecter pour voir votre profil',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              );
            }

            final imageUrl = user.profileImage;
            final initials =
                '${user.firstName.isNotEmpty ? user.firstName[0] : ''}'
                '${user.lastName.isNotEmpty ? user.lastName[0] : ''}';
            final roleLabel =
                user.role == 'technician' ? 'Prestataire' : 'Client';
            final location =
                (user.location != null && user.location!.isNotEmpty)
                    ? ' · ${user.location}'
                    : '';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MON ESPACE · ${user.role == 'technician' ? 'PRESTATAIRE' : 'CLIENT'}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Mon espace',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                    child: Column(
                      children: [
                        // Navy profile card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: AppColors.cardShadow,
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  _ProfileAvatar(
                                    imageUrl: imageUrl,
                                    initials: initials.isEmpty ? 'U' : initials,
                                    onEdit: () => context.go('/edit-profile'),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${user.firstName} ${user.lastName}'
                                              .trim(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w800,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '$roleLabel$location',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: Colors.white
                                                    .withValues(alpha: 0.85),
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              const Row(
                                children: [
                                  Expanded(
                                    child: _Stat(
                                        number: '4',
                                        label: 'réservations effectuées'),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: _Stat(
                                        number: '8',
                                        label: 'prestataires favoris'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (user.isTechnician)
                          _TechnicianExtras(user: user),
                        const SizedBox(height: 24),

                        // Menu list
                        _MenuItem(
                          title: 'Modifier le profil',
                          onTap: () => context.go('/edit-profile'),
                        ),
                        if (user.isCustomer)
                          _MenuItem(
                            title: 'Mes favoris',
                            subtitle: 'Vos talents à retrouver',
                            onTap: () => context.push('/favorites'),
                          ),
                        if (user.isTechnician) ...[
                          _MenuItem(
                            title: 'Mes disponibilités',
                            subtitle: 'Horaires chaque semaine',
                            onTap: () => context.push('/availability'),
                          ),
                          _MenuItem(
                            title: 'Vérification du profil',
                            subtitle: 'Dossier de vérification',
                            onTap: () => context.push('/verification'),
                          ),
                          _MenuItem(
                            title: 'Abonnement et visibilité',
                            subtitle: 'Développer mon activité',
                            onTap: () => context.push('/subscription'),
                          ),
                        ],
                        _MenuItem(
                          title: 'Méthodes de paiement',
                          subtitle: 'Concept · À venir',
                          onTap: () => context.push('/payment-methods'),
                        ),
                        if (user.role == 'technician')
                          _MenuItem(
                            title: 'Gains et reversements',
                            subtitle: 'Concept · À venir',
                            onTap: () => context.push('/earnings'),
                          )
                        else
                          _MenuItem(
                            title: 'Pensé pour vous',
                            subtitle: 'Recommandations · Concept',
                            onTap: () => context.push('/recommendations'),
                          ),
                        _MenuItem(
                          title: 'Notifications',
                          onTap: () => context.go('/notification-settings'),
                        ),
                        _MenuItem(
                          title: 'Préférences WhatsApp',
                          subtitle: 'Numéro et consentements',
                          onTap: () => context.push('/whatsapp-preferences'),
                        ),
                        _MenuItem(
                          title: 'Confidentialité et sécurité',
                          onTap: () => context.go('/privacy'),
                        ),
                        _MenuItem(
                          title: 'Aide & Support',
                          onTap: () => context.go('/help'),
                        ),
                        _MenuItem(
                          title: 'Se déconnecter',
                          isDestructive: true,
                          trailing: const Icon(LucideIcons.logOut,
                              color: AppColors.error, size: 20),
                          onTap: () async {
                            await authProvider.logout();
                            context.read<FavoritesProvider>().reset();
                            if (context.mounted) context.go('/login');
                          },
                        ),

                        const SizedBox(height: 24),
                        Text(
                          'BeautyConnect · Votre beauté, notre connexion',
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textLight,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TechnicianExtras extends StatefulWidget {
  final dynamic user;
  const _TechnicianExtras({required this.user});

  @override
  State<_TechnicianExtras> createState() => _TechnicianExtrasState();
}

class _TechnicianExtrasState extends State<_TechnicianExtras> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<ServiceProvider>().loadMyServices());
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final services = context.watch<ServiceProvider>().myServices;
    final images = services
        .expand((s) => [
              if (s.imageUrl?.isNotEmpty == true) s.imageUrl!,
              ...s.images.map((i) => i.imageUrl).where((u) => u.isNotEmpty),
            ])
        .toSet()
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _pill(user.specialty ?? 'Beauté'),
            if (user.location != null && user.location!.isNotEmpty)
              _pill(user.location!),
          ],
        ),
        if (user.bio != null && user.bio!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(user.bio!,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textMedium, height: 1.5)),
        ],
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
              child: CustomButton(
                  text: 'Modifier mon profil',
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  onPressed: () => context.go('/edit-profile'))),
          const SizedBox(width: 12),
          Expanded(
              child: CustomButton(
                  text: 'Aperçu public',
                  isOutlined: true,
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  onPressed: () =>
                      context.go('/service-catalogue/${user.id}'))),
        ]),
        const SizedBox(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Mon portfolio',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: AppColors.primary)),
          GestureDetector(
              onTap: () => context.go('/my-services'),
              child: const Text('Gérer',
                  style: TextStyle(
                      color: AppColors.accent, fontWeight: FontWeight.w700))),
        ]),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: images.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              if (index == images.length) {
                return GestureDetector(
                  onTap: () => context.go('/my-services'),
                  child: Container(
                    width: 110,
                    decoration: BoxDecoration(
                        color: AppColors.navyBackground,
                        borderRadius: BorderRadius.circular(16)),
                    child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.plus, color: AppColors.primary),
                          SizedBox(height: 4),
                          Text('Ajouter',
                              style: TextStyle(
                                  color: AppColors.primary, fontSize: 11)),
                        ]),
                  ),
                );
              }
              return ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: images[index],
                  width: 110,
                  height: 110,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                      width: 110, color: AppColors.navyBackground),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _pill(String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
            color: AppColors.navyBackground,
            borderRadius: BorderRadius.circular(20)),
        child: Text(label,
            style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w700)),
      );
}

class _ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final String initials;
  final VoidCallback onEdit;

  const _ProfileAvatar({
    required this.imageUrl,
    required this.initials,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return SizedBox(
      width: 84,
      height: 84,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            backgroundImage:
                hasImage ? CachedNetworkImageProvider(imageUrl!) : null,
            child: hasImage
                ? null
                : Text(
                    initials.toUpperCase(),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Material(
              color: AppColors.accent,
              shape: const CircleBorder(),
              elevation: 3,
              child: InkWell(
                onTap: onEdit,
                customBorder: const CircleBorder(),
                child: const SizedBox(
                  width: 28,
                  height: 28,
                  child:
                      Icon(LucideIcons.pencil, color: Colors.white, size: 15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String number;
  final String label;

  const _Stat({required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          number,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.85),
              ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool isDestructive;
  final Widget? trailing;
  final VoidCallback onTap;

  const _MenuItem({
    required this.title,
    this.subtitle,
    this.isDestructive = false,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : AppColors.textDark;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: color,
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textMedium,
                                  ),
                        ),
                      ],
                    ],
                  ),
                ),
                trailing ??
                    const Icon(
                      LucideIcons.chevronRight,
                      color: AppColors.textDark,
                      size: 22,
                    ),
              ],
            ),
          ),
        ),
        const Divider(height: 1, color: AppColors.divider),
      ],
    );
  }
}

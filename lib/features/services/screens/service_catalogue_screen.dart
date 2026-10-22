import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/models/service.dart';
import '../../../core/models/user.dart';
import '../../../core/providers/favorites_provider.dart';
import '../../../core/providers/service_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/section_header.dart';

class ServiceCatalogueScreen extends StatefulWidget {
  final String serviceId;

  const ServiceCatalogueScreen({
    super.key,
    required this.serviceId,
  });

  @override
  State<ServiceCatalogueScreen> createState() => _ServiceCatalogueScreenState();
}

class _ServiceCatalogueScreenState extends State<ServiceCatalogueScreen> {
  List<Service> _services = [];
  User? _technician;
  bool _isLoading = true;
  String? _error;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      context.read<FavoritesProvider>().load();
      final id = int.tryParse(widget.serviceId);
      if (id == null) throw const FormatException('Invalid technician id');

      final serviceProvider = context.read<ServiceProvider>();
      await serviceProvider.fetchTechnicianServices(id);

      if (!mounted) return;
      final services = serviceProvider.technicianServices;
      setState(() {
        _error = serviceProvider.error == null
            ? null
            : 'Impossible de charger le profil du prestataire';
        _services = services;
        _technician = services.isNotEmpty ? services.first.technician : null;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Impossible de charger le profil du prestataire';
        _isLoading = false;
      });
    }
  }

  List<String> _portfolioImages() {
    final urls = <String>[];
    for (final s in _services) {
      if (s.imageUrl != null && s.imageUrl!.isNotEmpty) urls.add(s.imageUrl!);
      for (final img in s.images) {
        if (img.imageUrl.isNotEmpty) urls.add(img.imageUrl);
      }
    }
    return urls.toSet().toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_error != null || _technician == null) {
      return Scaffold(
        appBar: AppBar(leading: _backButton()),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline,
                    size: 56, color: AppColors.error),
                const SizedBox(height: 16),
                Text(
                  _error ?? 'Prestataire introuvable',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                CustomButton(
                  text: 'Retour',
                  width: 200,
                  onPressed: () => context.go('/services'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final tech = _technician!;
    final portfolio = _portfolioImages();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Stack(
        children: [
          // Background header image
          SizedBox(
            height: 280,
            width: double.infinity,
            child: tech.profileImage != null && tech.profileImage!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: tech.profileImage!,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => _headerFallback(),
                  )
                : _headerFallback(),
          ),
          // Gradient overlay
          Container(
            height: 280,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppColors.scaffoldBackground.withOpacity(0.9),
                  AppColors.scaffoldBackground,
                ],
              ),
            ),
          ),
          // Content
          CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: _backButton(),
                title: Text(
                  'BeautyConnect',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                centerTitle: true,
                actions: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.share, color: Colors.white),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 100),
                      // Profile card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppColors.cardShadow,
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundColor: AppColors.chipBackground,
                              backgroundImage: tech.profileImage != null &&
                                      tech.profileImage!.isNotEmpty
                                  ? CachedNetworkImageProvider(
                                      tech.profileImage!)
                                  : null,
                              child: tech.profileImage == null ||
                                      tech.profileImage!.isEmpty
                                  ? const Icon(Icons.person,
                                      color: AppColors.textLight, size: 32)
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          tech.fullName,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall
                                              ?.copyWith(
                                                color: AppColors.textDark,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                      if (tech.isVerified)
                                        const Icon(Icons.verified,
                                            color: AppColors.primaryLight,
                                            size: 18),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: [
                                      _Badge(
                                          text: tech.specialty ??
                                              'Professionnel de la beauté'),
                                      const _Badge(text: 'Spécialiste'),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.star,
                                          color: AppColors.warning, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Prestataire beauté',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: AppColors.textMedium,
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Consumer<FavoritesProvider>(
                              builder: (context, favorites, _) {
                                _isFavorite =
                                    favorites.isFavorite(widget.serviceId);
                                return IconButton(
                                  onPressed: () =>
                                      favorites.toggle(widget.serviceId),
                                  icon: Icon(
                                    _isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: _isFavorite
                                        ? AppColors.accent
                                        : AppColors.primaryLight,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'À propos',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(color: AppColors.textDark),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        tech.bio ??
                            'Ce prestataire n’a pas encore ajouté de présentation.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textMedium,
                              height: 1.6,
                            ),
                      ),
                      const SizedBox(height: 28),
                      SectionHeader(
                        title: 'Portfolio',
                        actionLabel: 'Tout voir',
                        onActionTap: () {},
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 140,
                        child: portfolio.isEmpty
                            ? const Center(
                                child: Text('Aucune photo pour le moment'))
                            : ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: portfolio.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 12),
                                itemBuilder: (context, index) {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: CachedNetworkImage(
                                      imageUrl: portfolio[index],
                                      width: 140,
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) => Container(
                                        width: 140,
                                        color: AppColors.chipBackground,
                                      ),
                                      errorWidget: (_, __, ___) => Container(
                                        width: 140,
                                        color: AppColors.chipBackground,
                                        child: const Icon(Icons.broken_image),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                      const SizedBox(height: 28),
                      SectionHeader(
                        title: 'Services',
                        actionLabel: 'Tout voir',
                        onActionTap: () {},
                      ),
                      const SizedBox(height: 16),
                      if (_services.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child:
                              Center(child: Text('Aucun service disponible')),
                        )
                      else
                        Column(
                          children: _services
                              .map((s) => _ServiceCard(service: s))
                              .toList(),
                        ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Bottom sticky bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 20,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.chipBackground,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: IconButton(
                        onPressed: () => context.go('/chat/${tech.id}'),
                        icon: const Icon(Icons.chat_bubble_outline,
                            color: AppColors.textDark),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomButton(
                        text: 'Réserver maintenant',
                        onPressed: () {
                          if (_services.isNotEmpty) {
                            context.go('/service/${_services.first.id}');
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerFallback() {
    return Container(
      color: AppColors.primaryDark,
      child: const Icon(
        Icons.spa,
        color: Colors.white54,
        size: 64,
      ),
    );
  }

  Widget _backButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        style: IconButton.styleFrom(
          backgroundColor: Colors.black.withOpacity(0.3),
          shape: const CircleBorder(),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;

  const _Badge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.chipBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textMedium,
              fontSize: 10,
            ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final Service service;

  const _ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  service.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMedium,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time,
                        color: AppColors.textLight, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      service.formattedDuration,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.payments,
                        color: AppColors.textLight, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${NumberFormat('#,##0', 'fr_FR').format(service.price).replaceAll('\u202f', ' ').replaceAll('\u00a0', ' ')} CFA',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () => context.go('/service/${service.id}'),
              icon: const Icon(Icons.add, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}

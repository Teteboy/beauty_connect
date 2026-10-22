import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/models/service.dart';
import '../../../core/models/user.dart';
import '../../../core/providers/favorites_provider.dart';
import '../../../core/providers/service_provider.dart';
import '../../../core/services/api_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/section_header.dart';
import '../widgets/service_card.dart';
import '../../../core/utils/navigation.dart';

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
  double? _averageRating;
  int _totalReviews = 0;
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

      double? avg;
      var count = 0;
      try {
        final reviewsResponse =
            await ApiService.get('/reviews/technician/$id');
        if (reviewsResponse is Map<String, dynamic>) {
          final rating = reviewsResponse['averageRating'];
          if (rating is num && rating > 0) avg = rating.toDouble();
          count = (reviewsResponse['totalReviews'] as num?)?.toInt() ?? 0;
        }
      } catch (_) {}

      if (!mounted) return;
      final services = serviceProvider.technicianServices;
      setState(() {
        _error = serviceProvider.error == null
            ? null
            : 'Impossible de charger le profil du prestataire';
        _services = services;
        _technician = services.isNotEmpty ? services.first.technician : null;
        _averageRating = avg;
        _totalReviews = count;
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
        appBar: AppBar(
            leading: IconButton(
                onPressed: () => safePop(context, fallback: '/services'),
                icon: const Icon(LucideIcons.arrowLeft))),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.circleAlert,
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
    final heroImage = portfolio.isNotEmpty
        ? portfolio.first
        : (tech.profileImage != null && tech.profileImage!.isNotEmpty
            ? tech.profileImage!
            : null);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => safePop(context, fallback: '/services'),
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textDark),
        ),
        title: Text(
          'Votre prochain expert',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
        ),
        actions: [
          IconButton(
            tooltip: 'Contacter',
            onPressed: () => context.go('/chat/${tech.id}'),
            icon: const Icon(LucideIcons.messageCircle,
                color: AppColors.textDark),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Hero + avatar superposé
          SizedBox(
            height: 250,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: 0,
                  left: 20,
                  right: 20,
                  height: 200,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: heroImage != null
                        ? CachedNetworkImage(
                            imageUrl: heroImage,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                                color: AppColors.chipBackground),
                            errorWidget: (_, __, ___) => _heroFallback(),
                          )
                        : _heroFallback(),
                  ),
                ),
                Positioned(
                  left: 40,
                  bottom: 6,
                  child: CircleAvatar(
                    radius: 34,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.chipBackground,
                      backgroundImage: tech.profileImage != null &&
                              tech.profileImage!.isNotEmpty
                          ? CachedNetworkImageProvider(tech.profileImage!)
                          : null,
                      child: tech.profileImage == null ||
                              tech.profileImage!.isEmpty
                          ? const Icon(LucideIcons.user,
                              color: AppColors.textLight, size: 30)
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  tech.fullName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                              ),
                              if (tech.isVerified) ...[
                                const SizedBox(width: 6),
                                const Icon(LucideIcons.badgeCheck,
                                    color: AppColors.primaryLight, size: 18),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tech.location ?? 'Cameroun',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.textMedium),
                          ),
                        ],
                      ),
                    ),
                    Consumer<FavoritesProvider>(
                      builder: (context, favorites, _) {
                        _isFavorite = favorites.isFavorite(widget.serviceId);
                        return IconButton(
                          onPressed: () =>
                              favorites.toggle(widget.serviceId),
                          icon: Icon(
                            _isFavorite
                                ? LucideIcons.heart
                                : LucideIcons.heart,
                            color: AppColors.accent,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.navyBackground,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        tech.specialty ??
                            ServiceCard.category(
                                _services.isNotEmpty
                                    ? _services.first.category
                                    : ''),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (_averageRating != null || _totalReviews > 0) ...[
                      const SizedBox(width: 12),
                      const Icon(LucideIcons.star,
                          color: AppColors.amber, size: 16),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          '${(_averageRating ?? 0).toStringAsFixed(1).replaceAll('.', ',')} · $_totalReviews avis',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  tech.bio ??
                      'Ce prestataire n’a pas encore ajouté de présentation.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMedium,
                        height: 1.6,
                      ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Services proposés',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: AppColors.primary),
                ),
                const SizedBox(height: 8),
                if (_services.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text('Aucun service disponible')),
                  )
                else
                  Column(
                    children: _services
                        .map((s) => _ServiceRow(service: s))
                        .toList(),
                  ),
                const SizedBox(height: 20),
                SectionHeader(
                  title: 'Mon portfolio',
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
                                  child:
                                      const Icon(LucideIcons.imageOff),
                                ),
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.textDark.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
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
                  color: AppColors.navyBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: IconButton(
                  onPressed: () => context.go('/chat/${tech.id}'),
                  icon: const Icon(LucideIcons.messageCircle,
                      color: AppColors.primary),
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
    );
  }

  Widget _heroFallback() {
    return Container(
      color: AppColors.navyBackground,
      child: const Icon(
        LucideIcons.flower,
        color: AppColors.primaryLight,
        size: 56,
      ),
    );
  }

}


class _ServiceRow extends StatelessWidget {
  final Service service;

  const _ServiceRow({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.divider),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${service.formattedDuration} · ${ServiceCard.price(service.price)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMedium,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => context.go('/service/${service.id}'),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Réserver',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

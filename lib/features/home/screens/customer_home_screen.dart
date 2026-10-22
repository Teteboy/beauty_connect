import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/booking_provider.dart';
import '../../../core/providers/service_provider.dart';
import '../../../core/providers/notification_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/search_field.dart';
import '../../../core/widgets/section_header.dart';
import '../../services/widgets/service_card.dart';
import '../widgets/categories_grid.dart';
import '../widgets/featured_services.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});
  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceProvider>().fetchServices();
      context.read<BookingProvider>().fetchBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await context.read<ServiceProvider>().fetchServices();
            if (!context.mounted) return;
            await context.read<BookingProvider>().fetchBookings();
          },
          child: ListView(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 44),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(28)),
                ),
                child: Row(children: [
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text('Bonjour, ${user?.firstName ?? 'bienvenue'}',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800)),
                        const SizedBox(height: 6),
                        Row(children: [
                          const Icon(LucideIcons.mapPin,
                              size: 14, color: Colors.white70),
                          const SizedBox(width: 4),
                          Expanded(
                              child: Text(user?.location ?? 'Douala, Bonapriso',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 12)))
                        ]),
                      ])),
                  Stack(children: [
                    IconButton(
                        tooltip: 'Notifications',
                        onPressed: () => context.go('/notifications'),
                        icon: const Icon(LucideIcons.bell,
                            color: Colors.white)),
                    if (context.watch<NotificationProvider>().unreadCount > 0)
                      const Positioned(
                          top: 10,
                          right: 12,
                          child: CircleAvatar(
                              radius: 4, backgroundColor: AppColors.accent)),
                  ]),
                  const SizedBox(width: 4),
                  GestureDetector(
                      onTap: () => context.go('/profile'),
                      child: Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white, width: 2)),
                          child: CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.navyBackground,
                              backgroundImage: user?.profileImage != null
                                  ? NetworkImage(user!.profileImage!)
                                  : null,
                              child: user?.profileImage == null
                                  ? const Icon(LucideIcons.user,
                                      color: AppColors.primary, size: 18)
                                  : null))),
                ]),
              ),
              Transform.translate(
                  offset: const Offset(0, -24),
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: AppColors.cardShadow),
                          child: SearchField(
                              hintText:
                                  'Rechercher un service ou prestataire',
                              onSubmitted: (query) => context.go(
                                  '/services?search=${Uri.encodeComponent(query)}'),
                              onFilterTap: () => context.go('/services'))))),
              Transform.translate(
                  offset: const Offset(0, -12),
                  child: const CategoriesGrid()),
              Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                  child: SectionHeader(
                      title: 'Les talents à découvrir',
                      actionLabel: 'Tout voir',
                      onActionTap: () => context.go('/recommendations'))),
              const FeaturedServices(),
              Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                  child: SectionHeader(
                      title: 'Près de vous',
                      actionLabel: 'Voir la liste',
                      onActionTap: () => context.go('/services'))),
              Consumer<ServiceProvider>(builder: (context, provider, _) {
                if (provider.isLoading)
                  return const Center(child: CircularProgressIndicator());
                if (provider.error != null)
                  return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(children: [
                        const Text('Impossible de charger les services.'),
                        TextButton(
                            onPressed: provider.fetchServices,
                            child: const Text('Réessayer'))
                      ]));
                if (provider.services.isEmpty)
                  return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('Aucun prestataire pour le moment.'));
                return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                        children: provider.services
                            .take(5)
                            .map((service) => ServiceCard(service: service))
                            .toList()));
              }),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/models/service.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/booking_provider.dart';
import '../../../core/providers/service_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/section_header.dart';

class MyServicesScreen extends StatefulWidget {
  const MyServicesScreen({super.key});
  @override
  State<MyServicesScreen> createState() => _MyServicesScreenState();
}

class _MyServicesScreenState extends State<MyServicesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMyServices());
  }

  Future<void> _loadMyServices() async {
    final user = context.read<AuthProvider>().user;
    if (user != null && user.role == 'technician') {
      await Future.wait([
        context.read<ServiceProvider>().loadMyServices(),
        context.read<BookingProvider>().fetchTechnicianBookings(user.id),
      ]);
    }
  }

  Future<void> _toggleServiceAvailability(Service service) async {
    final provider = context.read<ServiceProvider>();
    final success = await provider.updateService(
        serviceId: service.id.toString(), isAvailable: !service.isAvailable);
    if (mounted && !success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Impossible de modifier le service. Réessayez.'),
          backgroundColor: AppColors.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ServiceProvider>();
    final now = DateTime.now();
    final monthly = context
        .watch<BookingProvider>()
        .technicianBookings
        .where(
            (b) => b.dateTime.year == now.year && b.dateTime.month == now.month)
        .length;
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.go('/add-service'),
          icon: const Icon(LucideIcons.plus),
          label: const Text('Ajouter un service')),
      body: SafeArea(
          child: Column(children: [
        const AppHeader(
            title: 'Mes services', subtitle: 'CATALOGUE · PRESTATAIRE'),
        Expanded(
            child: provider.isLoading && provider.myServices.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : provider.error != null
                    ? Center(
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(LucideIcons.circleAlert,
                            color: AppColors.error, size: 48),
                        const SizedBox(height: 16),
                        const Text('Impossible de charger vos services.'),
                        TextButton(
                            onPressed: _loadMyServices,
                            child: const Text('Réessayer')),
                      ]))
                    : RefreshIndicator(
                        onRefresh: _loadMyServices,
                        child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                            children: [
                              Row(children: [
                                Expanded(
                                    child: _stat(
                                        '${provider.myServices.where((s) => s.isAvailable).length}',
                                        'services actifs')),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: _stat(
                                        '$monthly', 'réservations ce mois')),
                              ]),
                              const SizedBox(height: 20),
                              SectionHeader(
                                  title: 'Votre savoir-faire',
                                  actionLabel:
                                      '${provider.myServices.length} services'),
                              const SizedBox(height: 16),
                              if (provider.myServices.isEmpty)
                                const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 48),
                                    child: Text(
                                        'Aucun service pour le moment.\nAjoutez votre premier service.',
                                        textAlign: TextAlign.center)),
                              ...provider.myServices.map((service) =>
                                  _serviceCard(service, provider.isLoading)),
                              const Text(
                                  'Les services inactifs ne sont pas visibles dans le catalogue.',
                                  style: TextStyle(
                                      color: AppColors.textLight,
                                      fontSize: 12)),
                            ]))),
      ])),
    );
  }

  Widget _stat(String value, String label) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.navyBackground,
          borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value,
            style: const TextStyle(
                color: AppColors.primary,
                fontSize: 28,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text(label,
            style: const TextStyle(fontSize: 12, color: AppColors.textMedium)),
      ]));

  Widget _serviceCard(Service service, bool busy) => Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
          boxShadow: AppColors.cardShadow),
      child: InkWell(
          onTap: () => context.go('/edit-service/${service.id}'),
          child: Row(children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                    width: 72,
                    height: 72,
                    child:
                        service.imageUrl != null && service.imageUrl!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: service.imageUrl!,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) => const Icon(
                                    LucideIcons.flower,
                                    color: AppColors.primary))
                            : const ColoredBox(
                                color: AppColors.navyBackground,
                                child: Icon(LucideIcons.flower,
                                    color: AppColors.primary)))),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(service.name,
                      style: const TextStyle(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(
                      '${_category(service.category)} · ${service.durationMinutes} min',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textMedium)),
                  const SizedBox(height: 4),
                  Text(
                      '${NumberFormat('#,##0', 'fr_FR').format(service.price).replaceAll('\u202f', ' ').replaceAll('\u00a0', ' ')} CFA',
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700)),
                ])),
            Column(children: [
              const Icon(LucideIcons.pencil,
                  size: 18, color: AppColors.primary),
              Row(mainAxisSize: MainAxisSize.min, children: [
                Text(service.isAvailable ? 'Actif' : 'Inactif',
                    style: const TextStyle(fontSize: 10)),
                Switch(
                    value: service.isAvailable,
                    activeTrackColor: AppColors.primary,
                    onChanged: busy
                        ? null
                        : (_) => _toggleServiceAvailability(service)),
              ]),
            ]),
          ])));

  String _category(String value) =>
      const {
        'Hair': 'Coiffure',
        'Nails': 'Ongles',
        'Skincare': 'Soins',
        'Makeup': 'Maquillage',
        'Eyebrows': 'Sourcils',
        'Eyelashes': 'Cils',
        'Other': 'Autre'
      }[value] ??
      value;
}

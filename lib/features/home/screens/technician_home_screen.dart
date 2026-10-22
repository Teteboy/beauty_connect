import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/booking_provider.dart';
import '../../../core/providers/service_provider.dart';
import '../../../core/providers/review_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/status_badge.dart';

class TechnicianHomeScreen extends StatefulWidget {
  const TechnicianHomeScreen({super.key});
  @override
  State<TechnicianHomeScreen> createState() => _TechnicianHomeScreenState();
}

class _TechnicianHomeScreenState extends State<TechnicianHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final user = context.read<AuthProvider>().user;
    if (user != null)
      await Future.wait([
        context.read<ServiceProvider>().loadMyServices(),
        context.read<BookingProvider>().fetchTechnicianBookings(user.id),
        context.read<ReviewProvider>().fetchReviews(technicianId: user.id),
      ]);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final provider = context.watch<BookingProvider>();
    final reviews = context.watch<ReviewProvider>().reviews;
    final bookings = provider.technicianBookings;
    final now = DateTime.now();
    final monthly = bookings
        .where(
            (b) => b.dateTime.year == now.year && b.dateTime.month == now.month)
        .length;
    final average = reviews.isEmpty
        ? '—'
        : (reviews.fold(0.0, (sum, review) => sum + review.rating) /
                reviews.length)
            .toStringAsFixed(1)
            .replaceAll('.', ',');
    final upcoming = bookings
        .where((b) =>
            b.dateTime.isAfter(now) &&
            b.status != 'completed' &&
            b.status != 'cancelled')
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return Scaffold(
        body: SafeArea(
            child: RefreshIndicator(
                onRefresh: _loadData,
                child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 28),
                    children: [
                      AppHeader(
                          title: 'Bonjour, ${user?.firstName ?? ''}',
                          subtitle: 'MON ESPACE · PRESTATAIRE'),
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: Row(children: [
                                      CircleAvatar(
                                          radius: 38,
                                          backgroundColor: AppColors.midNavy,
                                          backgroundImage: user?.profileImage !=
                                                      null &&
                                                  user!.profileImage!.isNotEmpty
                                              ? CachedNetworkImageProvider(
                                                  user.profileImage!)
                                              : null,
                                          child: user?.profileImage == null ||
                                                  user!.profileImage!.isEmpty
                                              ? Text(user?.initials ?? '',
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 24))
                                              : null),
                                      const SizedBox(width: 16),
                                      Expanded(
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                            Text(user?.fullName ?? 'Mon profil',
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 22,
                                                    fontWeight:
                                                        FontWeight.w800)),
                                            const SizedBox(height: 4),
                                            Text(
                                                'Prestataire · ${user?.specialty ?? 'Beauté'}',
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12)),
                                            const SizedBox(height: 8),
                                            Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4),
                                                decoration: BoxDecoration(
                                                    color: AppColors.accent,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20)),
                                                child: Text(
                                                    '★ $average · ${reviews.length} avis',
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w600))),
                                          ])),
                                    ])),
                                const SizedBox(height: 16),
                                Row(children: [
                                  Expanded(
                                      child: _stat('${bookings.length}',
                                          'Total réservations')),
                                  const SizedBox(width: 12),
                                  Expanded(
                                      child: _stat('$monthly', 'Ce mois-ci'))
                                ]),
                                const SizedBox(height: 12),
                                Row(children: [
                                  Expanded(
                                      child: _stat(
                                          '$average / 5', 'Note moyenne')),
                                  const SizedBox(width: 12),
                                  Expanded(child: _stat('—', 'Taux de réponse'))
                                ]),
                                const SizedBox(height: 20),
                                _link(LucideIcons.scissors, 'Mes Services',
                                    '/my-services'),
                                _link(LucideIcons.calendarDays,
                                    'Mes Réservations', '/technician-bookings'),
                                _link(LucideIcons.messageCircle, 'Mes Messages',
                                    '/messages'),
                                _link(LucideIcons.wallet,
                                    'Gains', '/analytics'),
                                const SizedBox(height: 16),
                                SectionHeader(
                                    title: 'Prochain rendez-vous',
                                    actionLabel: 'Tout voir',
                                    onActionTap: () =>
                                        context.go('/technician-bookings')),
                                const SizedBox(height: 12),
                                if (provider.isLoading)
                                  const Center(
                                      child: CircularProgressIndicator())
                                else if (provider.error != null)
                                  Column(children: [
                                    const Text(
                                        'Impossible de charger vos réservations.'),
                                    TextButton(
                                        onPressed: _loadData,
                                        child: const Text('Réessayer'))
                                  ])
                                else if (upcoming.isEmpty)
                                  Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(20),
                                      decoration: _cardDecoration,
                                      child: const Text(
                                          'Aucun rendez-vous à venir'))
                                else
                                  Container(
                                      decoration: _cardDecoration,
                                      child: ListTile(
                                          onTap: () => context.go(
                                              '/booking-detail/${upcoming.first.id}'),
                                          leading: const Icon(
                                              LucideIcons.calendarCheck,
                                              color: AppColors.primary),
                                          title: Text(
                                              '${upcoming.first.customerName} · ${upcoming.first.serviceName}',
                                              style: const TextStyle(
                                                  color: AppColors.primaryDark,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 13)),
                                          subtitle: Text(
                                              '${upcoming.first.dateTime.day}/${upcoming.first.dateTime.month}/${upcoming.first.dateTime.year} · ${upcoming.first.formattedTime}'),
                                          trailing: StatusBadge(
                                              status: upcoming.first.status))),
                              ])),
                    ]))));
  }

  BoxDecoration get _cardDecoration => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: AppColors.cardShadow);
  Widget _stat(String value, String label) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.navyBackground,
          borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value,
            style: const TextStyle(
                color: AppColors.primary,
                fontSize: 27,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text(label,
            style: const TextStyle(color: AppColors.textMedium, fontSize: 12)),
      ]));
  Widget _link(IconData icon, String title, String route) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
          decoration: _cardDecoration,
          child: ListTile(
              onTap: () => context.go(route),
              leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: AppColors.orangePale,
                      borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: AppColors.accent)),
              title: Text(title,
                  style: const TextStyle(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w600)),
              trailing:
                  const Icon(LucideIcons.chevronRight, color: AppColors.primary))));
}

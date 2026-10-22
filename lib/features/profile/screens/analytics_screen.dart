import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/analytics_provider.dart';
import '../../../core/providers/booking_provider.dart';
import '../../../core/providers/review_provider.dart';
import '../../../core/widgets/status_badge.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});
  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedPeriod = 'This Month';
  // Period identifiers are sent unchanged to the API.
  static const _periods = {
    'This Week': 'Cette semaine',
    'This Month': 'Ce mois-ci',
    'Last 3 Months': 'Les 3 derniers mois',
    'This Year': 'Cette année'
  };
  BoxDecoration get _cardDecoration => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: AppColors.cardShadow);
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAnalytics());
  }

  void _loadAnalytics() {
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      context.read<AnalyticsProvider>().fetchAnalytics(_selectedPeriod);
      if (user.role == 'technician') {
        context.read<BookingProvider>().fetchTechnicianBookings(user.id);
        context.read<ReviewProvider>().fetchReviews(technicianId: user.id);
      }
    }
  }

  String _money(num value) =>
      '${NumberFormat('#,##0', 'fr_FR').format(value).replaceAll('\u202f', ' ').replaceAll('\u00a0', ' ')} CFA';

  @override
  Widget build(BuildContext context) {
    final analyticsProvider = context.watch<AnalyticsProvider>();
    final bookings = context.watch<BookingProvider>().bookings;
    final reviews = context.watch<ReviewProvider>().reviews;
    final completed = bookings.where((b) => b.status == 'completed').toList();
    final revenue = completed.fold(0.0, (sum, b) => sum + b.price);
    final average = reviews.isEmpty
        ? '—'
        : (reviews.fold(0.0, (sum, r) => sum + r.rating) / reviews.length)
            .toStringAsFixed(1)
            .replaceAll('.', ',');
    final data = analyticsProvider.analyticsData;
    return Scaffold(
      backgroundColor: AppColors.navyBackground,
      appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          title: const Text('Gains et statistiques'),
          leading: IconButton(
              onPressed: () =>
                  context.canPop() ? context.pop() : context.go('/profile'),
              icon: const Icon(LucideIcons.arrowLeft)),
          actions: [
            PopupMenuButton<String>(
                initialValue: _selectedPeriod,
                icon: const Icon(LucideIcons.slidersHorizontal),
                onSelected: (value) {
                  setState(() => _selectedPeriod = value);
                  _loadAnalytics();
                },
                itemBuilder: (_) => _periods.entries
                    .map((e) =>
                        PopupMenuItem(value: e.key, child: Text(e.value)))
                    .toList())
          ]),
      body: RefreshIndicator(
          onRefresh: () async => _loadAnalytics(),
          child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                Text(_periods[_selectedPeriod]!,
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 20),
                if (analyticsProvider.error != null)
                  Container(
                      padding: const EdgeInsets.all(16),
                      decoration: _cardDecoration,
                      child: Column(children: [
                        const Text('Impossible de charger les statistiques.',
                            style: TextStyle(color: AppColors.error)),
                        TextButton(
                            onPressed: _loadAnalytics,
                            child: const Text('Réessayer')),
                      ])),
                if (analyticsProvider.isLoading)
                  const Center(child: CircularProgressIndicator())
                else ...[
                  Row(children: [
                    Expanded(
                        child: _metric(
                            'Total réservations',
                            '${bookings.length}',
                            LucideIcons.calendar,
                            AppColors.primary)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _metric('Terminées', '${completed.length}',
                            LucideIcons.circleCheck, AppColors.success))
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                        child: _metric('Revenus totaux', _money(revenue),
                            LucideIcons.banknote, AppColors.accent)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _metric('Note moyenne', '$average / 5',
                            LucideIcons.star, AppColors.amber))
                  ]),
                  const SizedBox(height: 28),
                  const Text('Activité récente',
                      style: TextStyle(
                          fontSize: 18,
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  if (bookings.isEmpty)
                    const Text('Aucune réservation pour le moment.'),
                  ...bookings.take(5).map((booking) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: _cardDecoration,
                      child: ListTile(
                          title: Text('Réservation n° ${booking.id}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(
                              '${booking.serviceName}\n${_money(booking.price)}'),
                          isThreeLine: true,
                          trailing: StatusBadge(status: booking.status)))),
                  const SizedBox(height: 20),
                  Container(
                      padding: const EdgeInsets.all(20),
                      decoration: _cardDecoration,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Vos performances',
                                style: TextStyle(
                                    color: AppColors.primaryDark,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(height: 16),
                            _insight(
                                LucideIcons.trendingUp,
                                'Évolution des réservations',
                                data?['growth']?.toString() ??
                                    'Données indisponibles'),
                            _insight(
                                LucideIcons.clock,
                                'Heures de pointe',
                                data?['peakHours']?.toString() ??
                                    'Données indisponibles'),
                            _insight(
                                LucideIcons.heart,
                                'Service le plus populaire',
                                data?['popularService']?.toString() ??
                                    'Données indisponibles'),
                          ])),
                ],
              ])),
    );
  }

  Widget _metric(String title, String value, IconData icon, Color color) =>
      Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, color: color),
            const SizedBox(height: 12),
            Text(value,
                style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(title,
                style:
                    const TextStyle(color: AppColors.textLight, fontSize: 12))
          ]));
  Widget _insight(IconData icon, String title, String value) => ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.accent),
      title: Text(title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      subtitle: Text(value));
}

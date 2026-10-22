import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/models/booking.dart';
import '../../../core/providers/booking_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../widgets/booking_card.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});
  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  int _selectedTab = 0;
  static const _tabs = ['À venir', 'Terminées', 'Annulées'];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<BookingProvider>().fetchBookings());
  }

  List<Booking> _bookingsForTab(List<Booking> bookings) {
    const upcomingStatuses = {'pending', 'confirmed', 'in_progress'};
    final filtered = bookings.where((booking) {
      final status = booking.status.toLowerCase();
      if (_selectedTab == 0) return upcomingStatuses.contains(status);
      if (_selectedTab == 1) return status == 'completed';
      return status == 'cancelled';
    }).toList();
    filtered.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return filtered;
  }

  Future<void> _cancel(Booking booking) async {
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
                title: const Text('Annuler la réservation ?'),
                content: const Text('Cette action est définitive.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Conserver')),
                  TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Annuler'))
                ]));
    if (confirmed != true || !mounted) return;
    final success = await context
        .read<BookingProvider>()
        .updateBookingStatus(booking.id, 'cancelled');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success
            ? 'Réservation annulée.'
            : 'Impossible d’annuler la réservation. Réessayez.')));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Mes Réservations')),
        body: Column(children: [
          Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                  color: AppColors.navyBackground,
                  borderRadius: BorderRadius.circular(28)),
              child: Row(
                  children: List.generate(
                      _tabs.length,
                      (index) => Expanded(
                          child: GestureDetector(
                              onTap: () => setState(() => _selectedTab = index),
                              child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                      color: index == _selectedTab
                                          ? AppColors.primary
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(24)),
                                  child: Text(_tabs[index],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: index == _selectedTab
                                              ? Colors.white
                                              : AppColors.primary,
                                          fontWeight: FontWeight.w600)))))))),
          Expanded(
              child: Consumer<BookingProvider>(builder: (context, provider, _) {
            if (provider.isLoading && provider.customerBookings.isEmpty)
              return const Center(child: CircularProgressIndicator());
            if (provider.error != null && provider.customerBookings.isEmpty)
              return Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('Impossible de charger les réservations.'),
                TextButton(
                    onPressed: provider.fetchBookings,
                    child: const Text('Réessayer'))
              ]));
            final bookings = _bookingsForTab(provider.customerBookings);
            return RefreshIndicator(
                onRefresh: provider.fetchBookings,
                child: ListView(
                    padding: const EdgeInsets.all(16),
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      if (bookings.isEmpty)
                        Padding(
                            padding: const EdgeInsets.symmetric(vertical: 64),
                            child: Column(children: [
                              const Icon(LucideIcons.calendar,
                                  size: 56, color: AppColors.primary),
                              const SizedBox(height: 20),
                              Text(
                                  [
                                    'Aucune réservation à venir',
                                    'Aucune réservation terminée',
                                    'Aucune réservation annulée'
                                  ][_selectedTab],
                                  style: Theme.of(context).textTheme.titleLarge,
                                  textAlign: TextAlign.center),
                              const SizedBox(height: 12),
                              const Text(
                                  'Votre prochain moment beauté vous attend.',
                                  textAlign: TextAlign.center),
                              const SizedBox(height: 24),
                              CustomButton(
                                  text: 'Découvrir les services',
                                  isOutlined: true,
                                  onPressed: () => context.go('/services'))
                            ])),
                      ...bookings.map((booking) => Column(children: [
                            BookingCard(
                                booking: booking,
                                onTap: () => context
                                    .go('/booking-detail/${booking.id}')),
                            if (booking.status == 'pending')
                              Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: CustomButton(
                                      text: 'Annuler la demande',
                                      isOutlined: true,
                                      height: 42,
                                      onPressed: () => _cancel(booking)))
                            else if (_selectedTab == 0)
                              Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: CustomButton(
                                      text: 'Reprogrammer',
                                      isOutlined: true,
                                      height: 42,
                                      onPressed: () => ScaffoldMessenger.of(
                                              context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  'La reprogrammation sera bientôt disponible.')))))
                          ])),
                    ]));
          })),
        ]),
      );
}

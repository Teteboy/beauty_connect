import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import '../../../core/models/booking.dart';
import '../../../core/providers/booking_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../widgets/booking_card.dart';
import '../widgets/reschedule_sheet.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});
  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  int _selectedTab = 0;
  static const _tabs = ['À venir', 'Terminées', 'Annulées'];
  static const _subtitles = [
    'Vos prochaines pauses beauté',
    'Vos moments pour vous, en un endroit',
    'Les demandes qui n\'ont pas abouti',
  ];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR');
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<BookingProvider>().fetchBookings());
  }

  List<Booking> _bookingsForTab(List<Booking> bookings, int tab) {
    const upcomingStatuses = {'pending', 'confirmed', 'in_progress'};
    final filtered = bookings.where((booking) {
      final status = booking.status.toLowerCase();
      if (tab == 0) return upcomingStatuses.contains(status);
      if (tab == 1) return status == 'completed';
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

  Widget _tabSelector(List<Booking> all) {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
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
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 4),
                            decoration: BoxDecoration(
                                color: index == _selectedTab
                                    ? AppColors.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(24)),
                            child: Text(
                                '${_tabs[index]} (${_bookingsForTab(all, index).length})',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: index == _selectedTab
                                        ? Colors.white
                                        : AppColors.primary,
                                    fontWeight: FontWeight.w600))))))));
  }

  Widget _cardActions(Booking booking) {
    final status = booking.status.toLowerCase();
    if (status == 'pending') {
      return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: CustomButton(
              text: 'Annuler la demande',
              isOutlined: true,
              height: 42,
              onPressed: () => _cancel(booking)));
    }
    if (status == 'confirmed' || status == 'in_progress') {
      return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(children: [
            Expanded(
                child: CustomButton(
                    text: 'Reprogrammer',
                    isOutlined: true,
                    height: 42,
                    onPressed: () =>
                        RescheduleSheet.show(context, booking))),
            const SizedBox(width: 10),
            Expanded(
                child: CustomButton(
                    text: 'Voir le détail',
                    height: 42,
                    onPressed: () =>
                        context.go('/booking-detail/${booking.id}'))),
          ]));
    }
    if (status == 'completed') {
      return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(children: [
            Expanded(
                child: CustomButton(
                    text: 'Laisser un avis',
                    isOutlined: true,
                    height: 42,
                    onPressed: () => context.go('/review/${booking.id}'))),
            const SizedBox(width: 10),
            Expanded(
                child: CustomButton(
                    text: 'Réserver à nouveau',
                    height: 42,
                    onPressed: () =>
                        context.go('/service-catalogue/${booking.technicianId}'))),
          ]));
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Mes Réservations')),
        body: Consumer<BookingProvider>(builder: (context, provider, _) {
          if (provider.isLoading && provider.customerBookings.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null && provider.customerBookings.isEmpty) {
            return Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('Impossible de charger les réservations.'),
              TextButton(
                  onPressed: provider.fetchBookings,
                  child: const Text('Réessayer'))
            ]));
          }
          final all = provider.customerBookings;
          final bookings = _bookingsForTab(all, _selectedTab);
          final pendingCount = _bookingsForTab(all, 0)
              .where((b) => b.status.toLowerCase() == 'pending')
              .length;
          return Column(children: [
            _tabSelector(all),
            const SizedBox(height: 8),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(_subtitles[_selectedTab],
                        style: Theme.of(context).textTheme.bodySmall))),
            const SizedBox(height: 12),
            Expanded(
                child: RefreshIndicator(
                    onRefresh: provider.fetchBookings,
                    child: ListView(
                        padding: const EdgeInsets.all(16),
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          if (bookings.isEmpty)
                            Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 64),
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
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                      textAlign: TextAlign.center),
                                  const SizedBox(height: 12),
                                  const Text(
                                      'Votre prochain moment beauté vous attend.',
                                      textAlign: TextAlign.center),
                                  const SizedBox(height: 24),
                                  CustomButton(
                                      text: 'Découvrir les services',
                                      isOutlined: true,
                                      onPressed: () =>
                                          context.go('/services'))
                                ])),
                          ...bookings.map((booking) => Column(children: [
                                BookingCard(
                                    booking: booking,
                                    onTap: () => context
                                        .go('/booking-detail/${booking.id}')),
                                _cardActions(booking),
                              ])),
                          if (_selectedTab == 0 && pendingCount > 0)
                            Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                    color: AppColors.orangePale,
                                    borderRadius: BorderRadius.circular(14)),
                                child: Row(children: [
                                  const Icon(LucideIcons.info,
                                      color: AppColors.accent, size: 18),
                                  const SizedBox(width: 10),
                                  Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                        const Text('En attente d’une réponse',
                                            style: TextStyle(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 13)),
                                        Text(
                                            'Votre demande sera confirmée après acceptation par le prestataire.',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                    color:
                                                        AppColors.textMedium)),
                                      ])),
                                ])),
                        ]))),
          ]);
        }),
      );
}

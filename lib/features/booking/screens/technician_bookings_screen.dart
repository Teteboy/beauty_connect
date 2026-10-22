import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/models/booking.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/booking_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/status_badge.dart';

class TechnicianBookingsScreen extends StatefulWidget {
  const TechnicianBookingsScreen({super.key});

  @override
  State<TechnicianBookingsScreen> createState() =>
      _TechnicianBookingsScreenState();
}

class _TechnicianBookingsScreenState extends State<TechnicianBookingsScreen> {
  int _selectedTab = 0;
  DateTime? _selectedDay;

  static const _tabs = ['Nouvelles demandes', 'Planifiées', 'Historique'];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        context.read<BookingProvider>().fetchTechnicianBookings(user.id);
      }
    });
  }

  List<Booking> _bookingsForTab(List<Booking> bookings) {
    final filtered = bookings.where((booking) {
      switch (_selectedTab) {
        case 0:
          return booking.status == 'pending';
        case 1:
          return (booking.status == 'confirmed' ||
                  booking.status == 'in_progress') &&
              (_selectedDay == null ||
                  DateUtils.isSameDay(booking.dateTime, _selectedDay));
        case 2:
          return booking.status == 'completed' || booking.status == 'cancelled';
        default:
          return true;
      }
    }).toList();

    filtered.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return filtered;
  }

  Widget _buildAgenda() {
    final day = _selectedDay ?? DateTime.now();
    final start = day.subtract(Duration(days: day.weekday - 1));
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(children: [
          Row(children: [
            Expanded(
                child: Text(DateFormat('MMMM yyyy', 'fr_FR').format(day),
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700))),
            TextButton(
                onPressed: () => setState(() => _selectedDay = null),
                child: const Text('Tout voir')),
            IconButton(
                tooltip: 'Choisir une date',
                icon: const Icon(LucideIcons.calendarDays,
                    color: AppColors.primary),
                onPressed: () async {
                  final date = await showDatePicker(
                      context: context,
                      initialDate: day,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                      helpText: 'Choisir une date',
                      cancelText: 'Annuler',
                      confirmText: 'Confirmer',
                      fieldLabelText: 'Date',
                      fieldHintText: 'JJ/MM/AAAA');
                  if (date != null && mounted)
                    setState(() => _selectedDay = date);
                }),
          ]),
          SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                  children: List.generate(7, (index) {
                final date = start.add(Duration(days: index));
                final selected = _selectedDay != null &&
                    DateUtils.isSameDay(date, _selectedDay);
                return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                        label: Text(DateFormat('EEE d', 'fr_FR').format(date)),
                        selected: selected,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                            color: selected ? Colors.white : AppColors.primary,
                            fontSize: 11),
                        onSelected: (_) =>
                            setState(() => _selectedDay = date)));
              }))),
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(
              title: 'Réservations',
              subtitle: 'RÉSERVATIONS · PRESTATAIRE',
              showNotification: true,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: _TabSelector(
                selectedIndex: _selectedTab,
                onSelected: (index) => setState(() => _selectedTab = index),
              ),
            ),
            if (_selectedTab == 1) _buildAgenda(),
            Expanded(
              child: Consumer<BookingProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading &&
                      provider.technicianBookings.isEmpty) {
                    return const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary),
                    );
                  }
                  if (provider.error != null &&
                      provider.technicianBookings.isEmpty) {
                    return _ErrorState(
                      message: provider.error!,
                      onRetry: () {
                        final user = context.read<AuthProvider>().user;
                        if (user != null) {
                          provider.fetchTechnicianBookings(user.id);
                        }
                      },
                    );
                  }
                  return _BookingsList(
                    bookings: _bookingsForTab(provider.technicianBookings),
                    tabName: _tabs[_selectedTab],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabSelector extends StatelessWidget {
  const _TabSelector({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.navyBackground,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: List.generate(
          _TechnicianBookingsScreenState._tabs.length,
          (index) {
            final selected = selectedIndex == index;
            return Expanded(
              child: GestureDetector(
                onTap: () => onSelected(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: selected
                        ? const [
                            BoxShadow(
                              color: Color(0x16000000),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    _TechnicianBookingsScreenState._tabs[index],
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: selected ? Colors.white : AppColors.primary,
                          fontSize: 11,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w500,
                        ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BookingsList extends StatelessWidget {
  const _BookingsList({required this.bookings, required this.tabName});

  final List<Booking> bookings;
  final String tabName;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        if (bookings.isEmpty)
          _EmptyState(message: 'Aucune réservation dans cette rubrique')
        else
          ...bookings.map(
            (booking) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _TechnicianBookingCard(booking: booking),
            ),
          ),
      ],
    );
  }
}

class _TechnicianBookingCard extends StatelessWidget {
  final Booking booking;

  const _TechnicianBookingCard({required this.booking});

  Future<void> _updateStatus(BuildContext context, String status) async {
    final success = await context
        .read<BookingProvider>()
        .updateBookingStatus(booking.id, status);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Réservation mise à jour'
              : 'Impossible de modifier la réservation',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = booking.customer?.profileImage;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => _imagePlaceholder(),
                          errorWidget: (_, __, ___) => _imagePlaceholder(),
                        )
                      : _imagePlaceholder(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            booking.customerName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: AppColors.textDark,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 17,
                                ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusBadge(status: booking.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking.serviceName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textMedium,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.calendar,
                          color: AppColors.accentPink,
                          size: 15,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${DateFormat('EEE d MMM', 'fr_FR').format(booking.dateTime)} · ${booking.formattedTime}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.accentPink,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${NumberFormat('#,##0', 'fr_FR').format(booking.price).replaceAll('\u202f', ' ').replaceAll('\u00a0', ' ')} CFA',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          _buildActions(context),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    if (booking.status == 'pending') {
      return Row(
        children: [
          Expanded(
            child: _ActionButton(
              label: 'Refuser',
              outlined: true,
              onPressed: () => _updateStatus(context, 'cancelled'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ActionButton(
              label: 'Accepter',
              backgroundColor: AppColors.success,
              onPressed: () => _updateStatus(context, 'confirmed'),
            ),
          ),
        ],
      );
    } else if (booking.status == 'confirmed') {
      return _ActionButton(
        label: 'Marquer comme terminée',
        backgroundColor: AppColors.textDark,
        onPressed: () => _updateStatus(context, 'completed'),
      );
    } else {
      return _ActionButton(
        label: 'Voir les détails',
        outlined: true,
        onPressed: () => context.go('/booking-detail/${booking.id}'),
      );
    }
  }

  Widget _imagePlaceholder() => Container(
        color: AppColors.chipBackground,
        child: const Icon(LucideIcons.flower, color: AppColors.primaryLight),
      );
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.outlined = false,
  });

  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: outlined ? AppColors.error : Colors.white,
        );
    return SizedBox(
      height: 42,
      child: outlined
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                side: const BorderSide(color: AppColors.error),
              ),
              child: Text(label, style: style),
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                backgroundColor: backgroundColor ?? AppColors.primary,
              ),
              child: Text(label, style: style),
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 56),
      child: Column(
        children: [
          const Icon(
            LucideIcons.calendar,
            size: 48,
            color: AppColors.textLight,
          ),
          const SizedBox(height: 14),
          Text(message, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.circleAlert, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Réessayer')),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/models/booking.dart';
import '../../../core/providers/booking_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';

/// Bottom sheet permettant de reprogrammer une réservation
/// (nouvelle date + nouvel horaire).
class RescheduleSheet extends StatefulWidget {
  final Booking booking;
  const RescheduleSheet({super.key, required this.booking});

  static Future<void> show(BuildContext context, Booking booking) {
    initializeDateFormatting('fr');
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RescheduleSheet(booking: booking),
    );
  }

  @override
  State<RescheduleSheet> createState() => _RescheduleSheetState();
}

class _RescheduleSheetState extends State<RescheduleSheet> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isSaving = false;

  Future<void> _confirm() async {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Veuillez choisir une date et un horaire.'),
          backgroundColor: AppColors.error));
      return;
    }
    final dateTime = DateTime(_selectedDate!.year, _selectedDate!.month,
        _selectedDate!.day, _selectedTime!.hour, _selectedTime!.minute);
    if (!dateTime.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Veuillez choisir un horaire à venir.')));
      return;
    }
    setState(() => _isSaving = true);
    final success = await context
        .read<BookingProvider>()
        .rescheduleBooking(widget.booking.id, dateTime);
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success
            ? 'Réservation reprogrammée.'
            : 'Impossible de reprogrammer. Réessayez.'),
        backgroundColor: success ? AppColors.success : AppColors.error));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(
                child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text('Reprogrammer',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: AppColors.primary)),
            const SizedBox(height: 4),
            Text(widget.booking.serviceName,
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
            Container(
                decoration: BoxDecoration(
                    color: AppColors.navyBackground,
                    borderRadius: BorderRadius.circular(16)),
                child: TableCalendar<void>(
                    locale: 'fr',
                    firstDay: DateTime.now(),
                    lastDay: DateTime.now().add(const Duration(days: 90)),
                    focusedDay: _selectedDate ?? DateTime.now(),
                    selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    headerStyle: const HeaderStyle(
                        formatButtonVisible: false, titleCentered: true),
                    calendarStyle: const CalendarStyle(
                        outsideDaysVisible: false,
                        selectedDecoration: BoxDecoration(
                            color: AppColors.primary, shape: BoxShape.circle),
                        todayDecoration: BoxDecoration(
                            color: AppColors.orangePale, shape: BoxShape.circle),
                        todayTextStyle: TextStyle(color: AppColors.accent)),
                    onDaySelected: (day, _) =>
                        setState(() => _selectedDate = day))),
            const SizedBox(height: 20),
            Text('Choisir un horaire',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: AppColors.primary)),
            const SizedBox(height: 12),
            SizedBox(
                height: 44,
                child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 10,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final time = TimeOfDay(hour: 9 + index, minute: 0);
                      final selected = _selectedTime == time;
                      return ChoiceChip(
                          label: Text(
                              '${time.hour.toString().padLeft(2, '0')}:00'),
                          selected: selected,
                          showCheckmark: false,
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.navyBackground,
                          labelStyle: TextStyle(
                              color:
                                  selected ? Colors.white : AppColors.primary),
                          side: BorderSide.none,
                          onSelected: (_) =>
                              setState(() => _selectedTime = time));
                    })),
            const SizedBox(height: 24),
            CustomButton(
                text: 'Confirmer le nouveau créneau',
                isLoading: _isSaving,
                onPressed: _confirm),
          ]),
        ),
      ),
    );
  }
}

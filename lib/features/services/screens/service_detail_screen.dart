import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../../core/models/service.dart';
import '../../../core/providers/booking_provider.dart';
import '../../../core/providers/service_provider.dart';
import '../../../core/constants/business_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../widgets/service_card.dart';

class ServiceDetailScreen extends StatefulWidget {
  final String serviceId;
  const ServiceDetailScreen({super.key, required this.serviceId});
  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  final _notesController = TextEditingController();
  final List<TimeOfDay> _times = const [
    TimeOfDay(hour: 9, minute: 0),
    TimeOfDay(hour: 10, minute: 30),
    TimeOfDay(hour: 12, minute: 0),
    TimeOfDay(hour: 14, minute: 30),
    TimeOfDay(hour: 16, minute: 0)
  ];
  Service? _service;
  bool _isLoading = true;
  String? _error;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  DateTime _focusedDay = DateTime.now().add(const Duration(days: 1));
  int _selectedTimeIndex = 1;
  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr');
    _loadService();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadService() async {
    try {
      final id = int.tryParse(widget.serviceId);
      if (id == null)
        throw const FormatException('Identifiant de service invalide');
      final service =
          await context.read<ServiceProvider>().fetchServiceById(id);
      if (!mounted) return;
      setState(() {
        _service = service;
        _error = service == null ? 'Service introuvable' : null;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Impossible de charger le service';
        _isLoading = false;
      });
    }
  }

  DateTime _slot(int index) => DateTime(_selectedDate.year, _selectedDate.month,
      _selectedDate.day, _times[index].hour, _times[index].minute);
  Future<void> _confirmBooking() async {
    final service = _service;
    if (service == null || !service.isAvailable) return;
    if (!_slot(_selectedTimeIndex).isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Veuillez choisir un horaire à venir.')));
      return;
    }
    final bookingProvider = context.read<BookingProvider>();
    final success = await bookingProvider.createBooking(
        serviceId: service.id,
        dateTime: _slot(_selectedTimeIndex),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim());
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Demande de réservation envoyée !')));
      context.go('/bookings');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Impossible de créer la réservation. Réessayez.'),
          backgroundColor: AppColors.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_error != null || _service == null)
      return Scaffold(
          appBar: AppBar(title: const Text('Réservation')),
          body: Center(
              child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(_error ?? 'Service introuvable'),
                    const SizedBox(height: 24),
                    CustomButton(
                        text: 'Découvrir les services',
                        isOutlined: true,
                        onPressed: () => context.go('/services'))
                  ]))));
    final service = _service!;
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
              onPressed: () =>
                  context.canPop() ? context.pop() : context.go('/services'),
              icon: const Icon(Icons.arrow_back, color: AppColors.primary)),
          title: const Text('Demande de réservation')),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(service.name,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.primary, fontWeight: FontWeight.w800)),
            const SizedBox(height: 20),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                      width: 64,
                      height: 64,
                      child: service.imageUrl != null
                          ? Image.network(service.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.spa_outlined))
                          : const ColoredBox(
                              color: AppColors.navyBackground,
                              child: Icon(Icons.spa_outlined,
                                  color: AppColors.primary)))),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(service.technician?.fullName ?? 'Votre prestataire',
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(service.description,
                        style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 6),
                    Text(
                        '${ServiceCard.price(service.price)} · ${service.durationMinutes} min',
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700))
                  ])),
            ]),
            const SizedBox(height: 24),
            _title('Choisir une date'),
            const SizedBox(height: 14),
            Container(
                decoration: BoxDecoration(
                    color: AppColors.navyBackground,
                    borderRadius: BorderRadius.circular(16)),
                child: TableCalendar<void>(
                  locale: 'fr',
                  firstDay: DateTime.now(),
                  lastDay: DateTime.now().add(const Duration(days: 90)),
                  focusedDay: _focusedDay,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
                  headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700)),
                  calendarStyle: const CalendarStyle(
                      outsideDaysVisible: false,
                      selectedDecoration: BoxDecoration(
                          color: AppColors.primary, shape: BoxShape.circle),
                      todayDecoration: BoxDecoration(
                          color: AppColors.orangePale, shape: BoxShape.circle),
                      todayTextStyle: TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w700)),
                  onPageChanged: (day) => _focusedDay = day,
                  onDaySelected: (day, focused) => setState(() {
                    _selectedDate = day;
                    _focusedDay = focused;
                  }),
                )),
            const SizedBox(height: 24),
            _title('Choisir un horaire'),
            const SizedBox(height: 14),
            SizedBox(
                height: 44,
                child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _times.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final selected = index == _selectedTimeIndex;
                      final enabled = _slot(index).isAfter(DateTime.now());
                      final time = _times[index];
                      return ChoiceChip(
                          label: Text(
                              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}'),
                          selected: selected,
                          showCheckmark: false,
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.navyBackground,
                          side: BorderSide.none,
                          labelStyle: TextStyle(
                              color:
                                  selected ? Colors.white : AppColors.primary),
                          onSelected: enabled
                              ? (_) =>
                                  setState(() => _selectedTimeIndex = index)
                              : null);
                    })),
            const SizedBox(height: 20),
            const Text('Notes pour le prestataire',
                style: TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
                controller: _notesController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                    hintText: 'Une envie, une précision ? (facultatif)')),
          ])),
      bottomNavigationBar: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          decoration: BoxDecoration(
              color: Colors.white, boxShadow: AppColors.sheetShadow),
          child: SafeArea(
              top: false,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total du service · ${service.durationMinutes} min',
                          style: Theme.of(context).textTheme.bodySmall),
                      Text(ServiceCard.price(service.price),
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 20,
                              fontWeight: FontWeight.w800))
                    ]),
                const SizedBox(height: 6),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                        'Frais de réservation : ${ServiceCard.price(kBookingFeeXaf)}',
                        style: const TextStyle(
                            color: AppColors.primary, fontSize: 11))),
                const SizedBox(height: 10),
                Consumer<BookingProvider>(
                    builder: (context, provider, _) => CustomButton(
                        text: service.isAvailable
                            ? 'Confirmer la réservation'
                            : 'Indisponible',
                        isLoading: provider.isLoading,
                        onPressed:
                            service.isAvailable ? _confirmBooking : null)),
              ]))),
    );
  }

  Widget _title(String text) => Text(text,
      style: Theme.of(context)
          .textTheme
          .titleLarge
          ?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700));
}

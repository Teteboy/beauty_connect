import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/storage_helper.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/utils/navigation.dart';

/// Écran « Mes disponibilités » (prestataire).
///
/// Les horaires sont persistés localement (SharedPreferences) tant qu'il
/// n'existe pas d'endpoint backend `/availability`. Au moment de
/// l'enregistrement, un appel `ApiService.put('/availability', ...)` pourra
/// remplacer [_persist] — voir [_save].
class AvailabilityScreen extends StatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  State<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _DaySchedule {
  bool isOpen;
  TimeOfDay open;
  TimeOfDay close;

  _DaySchedule({
    required this.isOpen,
    required this.open,
    required this.close,
  });

  Map<String, dynamic> toJson() => {
        'isOpen': isOpen,
        'open': '${open.hour.toString().padLeft(2, '0')}:'
            '${open.minute.toString().padLeft(2, '0')}',
        'close': '${close.hour.toString().padLeft(2, '0')}:'
            '${close.minute.toString().padLeft(2, '0')}',
      };

  static TimeOfDay _parse(String value) {
    final parts = value.split(':');
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 8,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }

  factory _DaySchedule.fromJson(Map<String, dynamic> json) => _DaySchedule(
        isOpen: json['isOpen'] as bool? ?? false,
        open: _parse(json['open']?.toString() ?? '08:00'),
        close: _parse(json['close']?.toString() ?? '18:00'),
      );
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  static const String _storageKey = 'availability_schedule';
  static const String _lunchKey = 'availability_lunch_break';

  static const List<String> _days = [
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
    'Samedi',
    'Dimanche',
  ];

  final Map<String, _DaySchedule> _schedule = {
    for (final day in _days)
      day: _DaySchedule(
        isOpen: day != 'Dimanche',
        open: const TimeOfDay(hour: 8, minute: 0),
        close: const TimeOfDay(hour: 18, minute: 0),
      ),
  };

  bool _lunchBreakEnabled = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final raw = await StorageHelper.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        decoded.forEach((day, value) {
          if (_schedule.containsKey(day) && value is Map<String, dynamic>) {
            _schedule[day] = _DaySchedule.fromJson(value);
          }
        });
      }
      _lunchBreakEnabled =
          await StorageHelper.getBool(_lunchKey) ?? _lunchBreakEnabled;
      if (mounted) setState(() {});
    } catch (_) {
      // Garde les valeurs par défaut en cas de données corrompues.
    }
  }

  Future<void> _persist() async {
    await StorageHelper.saveString(
      _storageKey,
      jsonEncode(_schedule.map((day, s) => MapEntry(day, s.toJson()))),
    );
    await StorageHelper.saveBool(_lunchKey, _lunchBreakEnabled);
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      // NOTE : il n'existe pas encore d'endpoint backend pour les
      // disponibilités. Quand il sera disponible, envoyer aussi :
      //   await ApiService.put('/availability', payload);
      await _persist();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Horaires enregistrés'),
          backgroundColor: AppColors.success,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _goBack() {
    if (context.canPop()) {
      safePop(context, fallback: '/profile');
    } else {
      context.go('/profile');
    }
  }

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickTime(String day, bool isOpenTime) async {
    final schedule = _schedule[day]!;
    final initial = isOpenTime ? schedule.open : schedule.close;
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isOpenTime) {
        schedule.open = picked;
      } else {
        schedule.close = picked;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Espace prestataire / Agenda'),
        leading: IconButton(
          onPressed: _goBack,
          icon: const Icon(LucideIcons.arrowLeft),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              children: [
                Text(
                  'Mes disponibilités',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Définissez vos créneaux récurrents. Les réservations confirmées restent protégées.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMedium,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Africa/Douala · UTC+1',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Horaires chaque semaine',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.textDark,
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                      const SizedBox(height: 8),
                      for (final day in _days) _dayRow(day),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.navyBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pause quotidienne',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: AppColors.textDark,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Lun–Ven · 12:30 – 13:30',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.textMedium),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _lunchBreakEnabled,
                        activeColor: AppColors.primary,
                        onChanged: (v) =>
                            setState(() => _lunchBreakEnabled = v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Seuls les horaires sans conflit seront enregistrés. Aucun rendez-vous n\'est annulé automatiquement.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textLight,
                      ),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: CustomButton(
              text: 'Enregistrer les horaires',
              isLoading: _isSaving,
              onPressed: _save,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dayRow(String day) {
    final schedule = _schedule[day]!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              day,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          if (schedule.isOpen) ...[
            _timeChip(day, schedule.open, true),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Text('–', style: TextStyle(color: AppColors.textLight)),
            ),
            _timeChip(day, schedule.close, false),
          ] else
            const Text(
              'Fermé',
              style: TextStyle(color: AppColors.textLight, fontSize: 13),
            ),
          const SizedBox(width: 8),
          Switch(
            value: schedule.isOpen,
            activeColor: AppColors.primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onChanged: (v) => setState(() => schedule.isOpen = v),
          ),
        ],
      ),
    );
  }

  Widget _timeChip(String day, TimeOfDay time, bool isOpenTime) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => _pickTime(day, isOpenTime),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.chipBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.divider),
        ),
        child: Text(
          _fmt(time),
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

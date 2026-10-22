import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/concept_banner.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';

/// A locally persisted payment method (demo data — no backend endpoint yet).
class PaymentMethod {
  final String id;
  final String type; // 'orange_money' | 'mtn_momo' | 'card'
  final String label;
  final String detail;
  final bool isDefault;

  const PaymentMethod({
    required this.id,
    required this.type,
    required this.label,
    required this.detail,
    this.isDefault = false,
  });

  PaymentMethod copyWith({bool? isDefault}) => PaymentMethod(
        id: id,
        type: type,
        label: label,
        detail: detail,
        isDefault: isDefault ?? this.isDefault,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'label': label,
        'detail': detail,
        'isDefault': isDefault,
      };

  factory PaymentMethod.fromJson(Map<String, dynamic> json) => PaymentMethod(
        id: json['id'] as String,
        type: json['type'] as String,
        label: json['label'] as String,
        detail: json['detail'] as String,
        isDefault: json['isDefault'] as bool? ?? false,
      );
}

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  static const _storageKey = 'payment_methods_v1';

  List<PaymentMethod> _methods = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      final list = (jsonDecode(raw) as List)
          .map((e) => PaymentMethod.fromJson(e as Map<String, dynamic>))
          .toList();
      setState(() {
        _methods = list;
        _loading = false;
      });
    } else {
      // Seed with demo data matching the Figma frame.
      setState(() {
        _methods = [
          const PaymentMethod(
            id: 'demo-om',
            type: 'orange_money',
            label: 'Orange Money',
            detail: '+237 6 77 •• •• 56 · Exemple',
            isDefault: true,
          ),
        ];
        _loading = false;
      });
      _save();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(_methods.map((m) => m.toJson()).toList()),
    );
  }

  void _setDefault(String id) {
    setState(() {
      _methods =
          _methods.map((m) => m.copyWith(isDefault: m.id == id)).toList();
    });
    _save();
  }

  void _delete(String id) {
    setState(() {
      _methods.removeWhere((m) => m.id == id);
      if (_methods.isNotEmpty && !_methods.any((m) => m.isDefault)) {
        _methods[0] = _methods[0].copyWith(isDefault: true);
      }
    });
    _save();
  }

  void _openAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _AddMethodSheet(
        onAdd: (method) {
          setState(() => _methods.add(method));
          _save();
        },
      ),
    );
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'card':
        return Icons.credit_card_outlined;
      case 'mtn_momo':
      case 'orange_money':
      default:
        return Icons.smartphone_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mobileMoney =
        _methods.where((m) => m.type != 'card').toList(growable: false);
    final others =
        _methods.where((m) => m.type == 'card').toList(growable: false);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary))
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                children: [
                  const ConceptHeader(title: 'Vos moyens de paiement'),
                  const SizedBox(height: 16),
                  const ConceptBanner(),
                  const SizedBox(height: 20),
                  Text(
                    'Choisissez comment vous aimeriez régler vos prochains '
                    'rendez-vous.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textMedium,
                          height: 1.4,
                        ),
                  ),
                  const SizedBox(height: 20),

                  // ── Mobile Money ──────────────────────────────────────
                  Text('Mobile Money',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  ...mobileMoney.map((m) => _MethodTile(
                        method: m,
                        icon: _iconFor(m.type),
                        onSetDefault: () => _setDefault(m.id),
                        onDelete: () => _delete(m.id),
                      )),
                  _AddMethodTile(
                    label: 'MTN Mobile Money',
                    subtitle: 'Ajouter un numéro · Concept',
                    icon: Icons.smartphone_outlined,
                    onTap: _openAddSheet,
                  ),

                  const SizedBox(height: 24),

                  // ── Autres options ────────────────────────────────────
                  Text('Autres options',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Ajouter une carte',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w700)),
                            Text(
                              'Disponibilité selon le futur partenaire de '
                              'paiement',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.textMedium),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _openAddSheet,
                        icon: const Icon(Icons.credit_card_outlined,
                            color: AppColors.textDark),
                      ),
                    ],
                  ),
                  const Divider(color: AppColors.divider),
                  ...others.map((m) => _MethodTile(
                        method: m,
                        icon: _iconFor(m.type),
                        onSetDefault: () => _setDefault(m.id),
                        onDelete: () => _delete(m.id),
                      )),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: 'Ajouter un moyen · Concept',
                    isOutlined: true,
                    onPressed: _openAddSheet,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Les intégrations et frais seront définis avant lancement.',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.textLight),
                  ),
                ],
              ),
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  final PaymentMethod method;
  final IconData icon;
  final VoidCallback onSetDefault;
  final VoidCallback onDelete;

  const _MethodTile({
    required this.method,
    required this.icon,
    required this.onSetDefault,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: method.isDefault ? AppColors.accent : AppColors.divider,
          width: method.isDefault ? 1.6 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.orangePale,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        method.label,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                      ),
                    ),
                    if (method.isDefault) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.orangePale,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Par défaut',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  method.detail,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.textMedium),
                ),
              ],
            ),
          ),
          if (method.isDefault)
            const Icon(Icons.check_circle_outline, color: AppColors.accent)
          else
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppColors.textLight),
              onSelected: (value) {
                if (value == 'default') onSetDefault();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'default',
                  child: Text('Définir par défaut'),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text('Supprimer',
                      style: TextStyle(color: AppColors.error)),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _AddMethodTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _AddMethodTile({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.orangePale,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  Text(subtitle,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.textMedium)),
                ],
              ),
            ),
            const Icon(Icons.add_circle_outline, color: AppColors.accent),
          ],
        ),
      ),
    );
  }
}

class _AddMethodSheet extends StatefulWidget {
  final void Function(PaymentMethod method) onAdd;

  const _AddMethodSheet({required this.onAdd});

  @override
  State<_AddMethodSheet> createState() => _AddMethodSheetState();
}

class _AddMethodSheetState extends State<_AddMethodSheet> {
  final _holderController = TextEditingController();
  final _numberController = TextEditingController();
  String _type = 'orange_money';

  static const _types = {
    'orange_money': 'Orange Money',
    'mtn_momo': 'MTN Mobile Money',
    'card': 'Carte bancaire',
  };

  @override
  void dispose() {
    _holderController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  void _submit() {
    final number = _numberController.text.trim();
    if (number.isEmpty) return;
    final isCard = _type == 'card';
    widget.onAdd(
      PaymentMethod(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: _type,
        label: _types[_type]!,
        detail: isCard
            ? '•••• ${number.length > 4 ? number.substring(number.length - 4) : number} · ${_holderController.text.trim()}'
            : '$number · ${_holderController.text.trim()}',
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isCard = _type == 'card';
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Ajouter un moyen de paiement',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'orange_money', label: Text('Orange')),
              ButtonSegment(value: 'mtn_momo', label: Text('MTN')),
              ButtonSegment(value: 'card', label: Text('Carte')),
            ],
            selected: {_type},
            onSelectionChanged: (s) => setState(() => _type = s.first),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _holderController,
            label: isCard ? 'Nom du titulaire' : 'Nom du compte',
            hintText: 'Léa Mballa',
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _numberController,
            label: isCard ? 'Numéro de carte' : 'Numéro de téléphone',
            hintText: isCard ? '0000 0000 0000 0000' : '+237 6 00 00 00 00',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 20),
          CustomButton(text: 'Enregistrer · Concept', onPressed: _submit),
        ],
      ),
    );
  }
}

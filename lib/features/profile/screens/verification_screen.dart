import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/api_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/storage_helper.dart';
import '../../../core/widgets/custom_button.dart';

/// Écran « Vérifier mon profil » (prestataire).
///
/// Il n'existe pas d'endpoint `/verification` côté backend. Les documents
/// image sont envoyés via l'endpoint existant `POST /upload/image`
/// ([ApiService.uploadImage]) et le statut du dossier est persisté
/// localement (SharedPreferences). Quand un endpoint dédié existera,
/// remplacer la persistance locale dans [_submit].
class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _DocSlot {
  final String key;
  final String title;
  final String subtitle;
  final IconData icon;

  const _DocSlot({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class _VerificationScreenState extends State<VerificationScreen> {
  static const String _statusKey = 'verification_status';
  static const String _docsKey = 'verification_docs';

  static const List<_DocSlot> _slots = [
    _DocSlot(
      key: 'cni',
      title: 'CNI / Passeport',
      subtitle: 'Recto et verso · PDF, JPG · 10 Mo max.',
      icon: LucideIcons.badgeCheck,
    ),
    _DocSlot(
      key: 'selfie',
      title: 'Selfie de vérification',
      subtitle: 'Visage net, sans filtre · JPG, PNG.',
      icon: LucideIcons.user,
    ),
    _DocSlot(
      key: 'certificat',
      title: 'Certificat / Portfolio',
      subtitle: 'Diplôme ou réalisations · PDF, JPG.',
      icon: LucideIcons.crown,
    ),
  ];

  /// key du slot -> chemin local ou URL distante du document.
  final Map<String, String> _documents = {};
  String _status = 'brouillon'; // brouillon | en_cours | verifie | rejete
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      _status = await StorageHelper.getString(_statusKey) ?? _status;
      final raw = await StorageHelper.getString(_docsKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        decoded.forEach((key, value) {
          if (value is String) _documents[key] = value;
        });
      }
      if (mounted) setState(() {});
    } catch (_) {
      // Données corrompues : repartir d'un dossier vide.
    }
  }

  Future<void> _persist() async {
    await StorageHelper.saveString(_statusKey, _status);
    await StorageHelper.saveString(_docsKey, jsonEncode(_documents));
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/profile');
    }
  }

  bool get _allDocsProvided => _slots.every((s) => _documents[s.key] != null);

  Future<void> _pickDocument(_DocSlot slot) async {
    String? path;
    if (slot.key == 'selfie') {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      path = picked?.path;
    } else {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );
      path = result?.files.single.path;
    }
    if (path == null) return;
    setState(() {
      _documents[slot.key] = path!;
      if (_status == 'rejete') _status = 'brouillon';
    });
    await _persist();
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    try {
      // Envoie les documents image via l'endpoint d'upload existant.
      // NOTE : pas d'endpoint `/verification` ; quand il existera,
      // associer les URLs retournées au dossier via
      // `ApiService.post('/verification', {'documents': urls})`.
      for (final entry in _documents.entries) {
        final path = entry.value;
        final isImage = RegExp(r'\.(jpe?g|png|webp|gif)$', caseSensitive: false)
            .hasMatch(path);
        final isLocal = !path.startsWith('http');
        if (isImage && isLocal) {
          final url = await ApiService.uploadImage(File(path));
          if (url != null) _documents[entry.key] = url;
        }
      }
      _status = 'en_cours';
      await _persist();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dossier soumis pour examen'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Échec de l\'envoi : $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Espace prestataire / Vérification'),
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
                  'Vérifier mon profil',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Un profil de confiance pour vos clientes et clients.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMedium,
                      ),
                ),
                const SizedBox(height: 16),
                _steps(),
                const SizedBox(height: 16),
                if (_status == 'rejete') _rejectedBanner(),
                for (final slot in _slots) _slotCard(slot),
                const SizedBox(height: 8),
                CustomButton(
                  text: 'Ajouter une nouvelle pièce',
                  isOutlined: true,
                  onPressed: () => _pickDocument(_slots.first),
                ),
                const SizedBox(height: 16),
                _reviewNote(),
                const SizedBox(height: 12),
                _privacyNote(),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: CustomButton(
              text: _status == 'en_cours'
                  ? 'Dossier en examen'
                  : 'Soumettre à nouveau',
              isLoading: _isSubmitting,
              onPressed:
                  _allDocsProvided && _status != 'en_cours' ? _submit : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _steps() {
    final steps = [
      (label: 'Profil', done: true, active: false),
      (label: '02 · Documents', done: false, active: _status != 'verifie'),
      (
        label: '03 · Examen',
        done: _status == 'verifie',
        active: _status == 'en_cours'
      ),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: steps.map((step) {
          final color = step.done
              ? AppColors.primary
              : step.active
                  ? AppColors.accent
                  : AppColors.textLight;
          return Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (step.done)
                  const Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: Icon(LucideIcons.check,
                        size: 14, color: AppColors.primary),
                  ),
                Flexible(
                  child: Text(
                    step.label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _rejectedBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.circleAlert, color: AppColors.error),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pièce d\'identité rejetée',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Photo floue : les informations ne sont pas lisibles. Ajoutez un recto et un verso nets, sans reflet.',
                  style: TextStyle(color: AppColors.textMedium, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _slotCard(_DocSlot slot) {
    final hasDoc = _documents.containsKey(slot.key);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.navyBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(slot.icon, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slot.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  hasDoc
                      ? _documents[slot.key]!.split('/').last
                      : slot.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMedium,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => _pickDocument(slot),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: hasDoc
                    ? AppColors.success.withValues(alpha: 0.12)
                    : AppColors.navyBackground,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                hasDoc ? 'Reçu' : 'À ajouter',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: hasDoc ? AppColors.success : AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _reviewNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Après votre nouvel envoi',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              if (_status == 'en_cours')
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.orangePale,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'En attente',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Votre dossier passe en examen. Vous serez informé dans l\'app ; aucun délai de validation n\'est garanti.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textMedium,
                ),
          ),
        ],
      ),
    );
  }

  Widget _privacyNote() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(LucideIcons.shieldCheck,
            size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Documents privés, réservés aux vérificateurs habilités. Ils ne sont jamais visibles sur votre profil public.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textLight,
                ),
          ),
        ),
      ],
    );
  }
}

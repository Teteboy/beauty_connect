import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/concept_banner.dart';
import '../../../core/widgets/custom_button.dart';

/// Future-concept screen: mock video consultation.
/// Demo only — no video backend exists; the "call" is a simulated UI.
class VideoCallScreen extends StatefulWidget {
  final String userId;
  final String? peerName;

  const VideoCallScreen({super.key, required this.userId, this.peerName});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  bool _inCall = false;
  bool _micOn = true;
  bool _camOn = true;
  int _elapsed = 0;
  Timer? _timer;

  String get _name => (widget.peerName != null && widget.peerName!.isNotEmpty)
      ? widget.peerName!
      : 'Amina Njoya';

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _join() {
    setState(() {
      _inCall = true;
      _elapsed = 0;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed++);
    });
  }

  void _hangUp() {
    _timer?.cancel();
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      setState(() => _inCall = false);
    }
  }

  String get _duration {
    final m = (_elapsed ~/ 60).toString().padLeft(2, '0');
    final s = (_elapsed % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _inCall ? Colors.black : AppColors.scaffoldBackground,
      body: SafeArea(
        child: _inCall ? _buildCall() : _buildPreJoin(),
      ),
    );
  }

  // ── Pre-join ──────────────────────────────────────────────────────────
  Widget _buildPreJoin() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        const ConceptHeader(
          title: 'Consultation vidéo',
          trailing: Icon(Icons.more_horiz, color: AppColors.textDark, size: 22),
        ),
        const SizedBox(height: 16),
        const ConceptBanner(
          message: 'Consultation optionnelle avant une réservation. '
              'Aucune opération réelle n\'est effectuée.',
        ),
        const SizedBox(height: 28),
        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 56,
                backgroundColor: AppColors.orangePale,
                child: Text(
                  _initials(_name),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.accent, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: 16),
              Text(_name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.primary, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text('Consultation vidéo · Aperçu',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.textMedium)),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ToggleButton(
              icon: _micOn ? Icons.mic_outlined : Icons.mic_off_outlined,
              label: 'Micro',
              active: _micOn,
              onTap: () => setState(() => _micOn = !_micOn),
            ),
            const SizedBox(width: 20),
            _ToggleButton(
              icon: _camOn
                  ? Icons.videocam_outlined
                  : Icons.videocam_off_outlined,
              label: 'Caméra',
              active: _camOn,
              onTap: () => setState(() => _camOn = !_camOn),
            ),
          ],
        ),
        const SizedBox(height: 32),
        CustomButton(text: 'Rejoindre · Concept', onPressed: _join),
        const SizedBox(height: 16),
        Text(
          'Un échange pour parler de vos envies, sans engagement de '
          'réservation.',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: AppColors.textLight, height: 1.4),
        ),
      ],
    );
  }

  // ── In-call mock UI ───────────────────────────────────────────────────
  Widget _buildCall() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(
            children: [
              const ConceptEyebrow(),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_horiz, color: Colors.white),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Stack(
              children: [
                // Remote "video" placeholder
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.midNavy, AppColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: CircleAvatar(
                      radius: 56,
                      backgroundColor: Colors.white.withValues(alpha: 0.15),
                      child: Text(
                        _initials(_name),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ),
                // Name + duration chip
                Positioned(
                  left: 16,
                  bottom: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700)),
                        Text('Consultation · Aperçu $_duration',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 12)),
                      ],
                    ),
                  ),
                ),
                // Self view PiP
                Positioned(
                  right: 16,
                  top: 16,
                  child: Container(
                    width: 92,
                    height: 128,
                    decoration: BoxDecoration(
                      color: _camOn
                          ? AppColors.accent.withValues(alpha: 0.8)
                          : Colors.black54,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Icon(
                      _camOn
                          ? Icons.person_outline
                          : Icons.videocam_off_outlined,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _CallControl(
              icon: _micOn ? Icons.mic : Icons.mic_off,
              background: AppColors.navyBackground,
              color: AppColors.primary,
              onTap: () => setState(() => _micOn = !_micOn),
            ),
            const SizedBox(width: 20),
            _CallControl(
              icon: _camOn ? Icons.videocam : Icons.videocam_off,
              background: AppColors.navyBackground,
              color: AppColors.primary,
              onTap: () => setState(() => _camOn = !_camOn),
            ),
            const SizedBox(width: 20),
            _CallControl(
              icon: Icons.call_end,
              background: AppColors.error,
              color: Colors.white,
              size: 68,
              onTap: _hangUp,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Un échange pour parler de vos envies, sans engagement de '
            'réservation.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
                height: 1.4),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

class _ToggleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: active ? AppColors.navyBackground : AppColors.orangePale,
              shape: BoxShape.circle,
              border: Border.all(
                color: active ? AppColors.divider : AppColors.accent,
              ),
            ),
            child: Icon(icon,
                color: active ? AppColors.primary : AppColors.accent),
          ),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: AppColors.textMedium)),
      ],
    );
  }
}

class _CallControl extends StatelessWidget {
  final IconData icon;
  final Color background;
  final Color color;
  final double size;
  final VoidCallback onTap;

  const _CallControl({
    required this.icon,
    required this.background,
    required this.color,
    required this.onTap,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        child: Icon(icon, color: color),
      ),
    );
  }
}

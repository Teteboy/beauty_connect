import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/message_provider.dart';

class MainLayout extends StatefulWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _getCurrentIndex(String location) {
    if (location.startsWith('/home') ||
        location.startsWith('/technician-home')) {
      return 0;
    }
    if (location.startsWith('/services') ||
        location.startsWith('/my-services')) {
      return 1;
    }
    if (location.startsWith('/bookings') ||
        location.startsWith('/my-bookings') ||
        location.startsWith('/booking-detail') ||
        location.startsWith('/technician-bookings')) {
      return 2;
    }
    if (location.startsWith('/messages') || location.startsWith('/chat')) {
      return 3;
    }
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final isCustomer = user?.role == 'customer';
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _getCurrentIndex(location);

    final items = <_NavItem>[
      _NavItem(
        icon: isCustomer ? LucideIcons.home : LucideIcons.layoutDashboard,
        activeIcon: isCustomer ? LucideIcons.home : LucideIcons.layoutDashboard,
        label: isCustomer ? 'Accueil' : 'Dashboard',
      ),
      _NavItem(
        icon: isCustomer ? LucideIcons.search : LucideIcons.scissors,
        activeIcon: isCustomer ? LucideIcons.search : LucideIcons.scissors,
        label: isCustomer ? 'Recherche' : 'Services',
      ),
      const _NavItem(
        icon: LucideIcons.calendar,
        activeIcon: LucideIcons.calendar,
        label: 'Réservations',
      ),
      const _NavItem(
        icon: LucideIcons.messageCircle,
        activeIcon: LucideIcons.messageCircle,
        label: 'Messages',
        isMessages: true,
      ),
      const _NavItem(
        icon: LucideIcons.user,
        activeIcon: LucideIcons.user,
        label: 'Profil',
      ),
    ];

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.textDark.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              children: List.generate(items.length, (index) {
                final item = items[index];
                final active = index == currentIndex;
                return Expanded(
                  child: InkWell(
                    onTap: () => _onTap(index, isCustomer),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        item.isMessages
                            ? _MessageIcon(active: active)
                            : Icon(
                                active ? item.activeIcon : item.icon,
                                color: active
                                    ? AppColors.accent
                                    : AppColors.textLight,
                                size: 24,
                              ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight:
                                active ? FontWeight.w700 : FontWeight.w500,
                            color:
                                active ? AppColors.accent : AppColors.textLight,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                active ? AppColors.accent : Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  void _onTap(int index, bool isCustomer) {
    switch (index) {
      case 0:
        context.go(isCustomer ? '/home' : '/technician-home');
        break;
      case 1:
        context.go(isCustomer ? '/services' : '/my-services');
        break;
      case 2:
        context.go(isCustomer ? '/bookings' : '/technician-bookings');
        break;
      case 3:
        context.go('/messages');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isMessages;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.isMessages = false,
  });
}

class _MessageIcon extends StatelessWidget {
  final bool active;

  const _MessageIcon({required this.active});

  @override
  Widget build(BuildContext context) {
    final unreadCount = context
        .watch<MessageProvider>()
        .conversations
        .fold<int>(0, (sum, conv) => sum + conv.unreadCount);
    final icon = active ? LucideIcons.messageCircle : LucideIcons.messageCircle;

    final iconWidget = Icon(
      icon,
      color: active ? AppColors.accent : AppColors.textLight,
      size: 24,
    );
    if (unreadCount <= 0) return iconWidget;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        iconWidget,
        Positioned(
          right: -6,
          top: -4,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
            ),
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            child: Text(
              unreadCount > 99 ? '99+' : unreadCount.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

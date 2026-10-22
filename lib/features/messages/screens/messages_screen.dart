import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/models/conversation.dart';
import '../../../core/providers/message_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/search_field.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MessageProvider>().fetchConversations();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Conversation> _getFilteredConversations(
      List<Conversation> conversations) {
    if (_searchQuery.isEmpty) return conversations;
    return conversations.where((conversation) {
      final name =
          '${conversation.user.firstName} ${conversation.user.lastName}'
              .toLowerCase();
      return name.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CHAT · CLIENT / PRESTATAIRE',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Messages',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.go('/users'),
                    icon: const Icon(Icons.edit_square,
                        color: AppColors.textDark, size: 22),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SearchField(
                controller: _searchController,
                hintText: 'Rechercher une conversation',
                showFilterButton: false,
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.navyBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Restons connectés',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Messagerie et présence en cours de finalisation.',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textMedium,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Consumer<MessageProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading && provider.conversations.isEmpty) {
                    return const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary),
                    );
                  }

                  if (provider.error != null &&
                      provider.conversations.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 64, color: AppColors.error),
                          const SizedBox(height: 16),
                          Text('Échec du chargement des messages',
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => provider.fetchConversations(),
                            child: const Text('Réessayer'),
                          ),
                        ],
                      ),
                    );
                  }

                  final conversations =
                      _getFilteredConversations(provider.conversations);

                  if (conversations.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline,
                              size: 64,
                              color:
                                  AppColors.textLight.withValues(alpha: 0.5)),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'Aucun message pour le moment'
                                : 'Aucune conversation trouvée',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Démarrez une conversation avec un professionnel de la beauté',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.accent,
                    onRefresh: () => provider.fetchConversations(),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                      itemCount: conversations.length,
                      separatorBuilder: (_, __) => const Divider(
                        height: 1,
                        color: AppColors.divider,
                        indent: 72,
                      ),
                      itemBuilder: (context, index) {
                        return _ConversationRow(
                          conversation: conversations[index],
                          onTap: () => context
                              .go('/chat/${conversations[index].user.id}'),
                        );
                      },
                    ),
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

class _ConversationRow extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;

  const _ConversationRow({required this.conversation, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final user = conversation.user;
    final time = conversation.lastMessageTime;
    final unreadCount = conversation.unreadCount;
    final isOnline = conversation.isOnline;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.navyBackground,
                  backgroundImage:
                      user.profileImage != null && user.profileImage!.isNotEmpty
                          ? CachedNetworkImageProvider(user.profileImage!)
                          : null,
                  child: user.profileImage == null || user.profileImage!.isEmpty
                      ? Text(
                          user.initials,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : null,
                ),
                if (isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                        color: AppColors.online,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${user.firstName} ${user.lastName}',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.textDark,
                                    fontWeight: FontWeight.w700,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (time != null)
                        Text(
                          _formatTime(time),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: unreadCount > 0
                                        ? AppColors.accent
                                        : AppColors.textLight,
                                    fontWeight: unreadCount > 0
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.lastMessageContent ??
                              'Démarrez une conversation',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textMedium,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            unreadCount > 9 ? '9+' : unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inDays == 0) {
      return DateFormat('HH:mm').format(time);
    } else if (diff.inDays == 1) {
      return 'Hier';
    } else if (diff.inDays < 7) {
      const days = ['Lun.', 'Mar.', 'Mer.', 'Jeu.', 'Ven.', 'Sam.', 'Dim.'];
      return days[time.weekday - 1];
    } else {
      return DateFormat('dd/MM').format(time);
    }
  }
}

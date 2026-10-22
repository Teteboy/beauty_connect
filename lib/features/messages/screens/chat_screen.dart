import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/models/message.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/message_provider.dart';
import '../../../core/services/api_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/asset_url.dart';

class ChatScreen extends StatefulWidget {
  final String userId;

  const ChatScreen({
    super.key,
    required this.userId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _otherUserName;
  String? _otherUserAvatar;
  bool _isOnline = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMessages();
      _findOtherUserInfo();
      context.read<MessageProvider>().markAsRead(widget.userId);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMessages() {
    context.read<MessageProvider>().fetchMessages(widget.userId);
  }

  void _findOtherUserInfo() async {
    final conversations = context.read<MessageProvider>().conversations;
    try {
      final conversation = conversations.firstWhere(
        (conv) => conv.user.id.toString() == widget.userId,
      );
      setState(() {
        _otherUserName =
            '${conversation.user.firstName} ${conversation.user.lastName}';
        _otherUserAvatar = conversation.user.profileImage;
        _isOnline = true;
      });
      return;
    } catch (_) {}

    // Nouvelle conversation : récupérer le profil via l'API utilisateurs
    try {
      final response = await ApiService.get('/users/${widget.userId}');
      if (response is Map<String, dynamic>) {
        final user = response['user'] is Map<String, dynamic>
            ? response['user'] as Map<String, dynamic>
            : response;
        if (!mounted) return;
        setState(() {
          _otherUserName =
              '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}'.trim();
          _otherUserAvatar = resolveAssetUrl(
              user['profileImage']?.toString());
        });
      }
    } catch (_) {
      if (mounted) setState(() => _otherUserName = 'Utilisateur');
    }
  }

  void _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    _messageController.clear();

    final success = await context.read<MessageProvider>().sendMessage(
          receiverId: widget.userId,
          content: content,
        );

    if (mounted) {
      setState(() => _isSending = false);
      if (success) {
        _scrollToBottom();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Échec de l\'envoi du message'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        toolbarHeight: 72,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: IconButton(
            onPressed: () => context.go('/messages'),
            icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textDark),
          ),
        ),
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.navyBackground,
                  backgroundImage:
                      _otherUserAvatar != null && _otherUserAvatar!.isNotEmpty
                          ? CachedNetworkImageProvider(_otherUserAvatar!)
                          : null,
                  child: _otherUserAvatar == null || _otherUserAvatar!.isEmpty
                      ? const Icon(LucideIcons.user, color: AppColors.textLight)
                      : null,
                ),
                if (_isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.online,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _otherUserName ?? 'Chargement...',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (_isOnline)
                    Text(
                      'En ligne',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.online,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Consultation vidéo',
            onPressed: () => context.push(
              '/video-call/${widget.userId}',
              extra: _otherUserName,
            ),
            icon:
                const Icon(LucideIcons.video, color: AppColors.textDark),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<MessageProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                final messages = provider.messages;

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.messageCircle,
                            size: 64,
                            color: AppColors.textLight.withValues(alpha: 0.5)),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun message pour le moment',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Envoyez un message pour démarrer la conversation',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  itemCount: messages.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return const _TodayPill();
                    }
                    final message = messages[index - 1];
                    final isMe = message.senderId == currentUser?.id;
                    return _MessageBubble(
                      message: message,
                      isMe: isMe,
                    );
                  },
                );
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.divider.withValues(alpha: 0.6)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Écrire un message...',
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textLight,
                      ),
                  filled: true,
                  fillColor: AppColors.navyBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _isSending ? null : _sendMessage,
                icon: _isSending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(LucideIcons.send, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayPill extends StatelessWidget {
  const _TodayPill();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Text(
          'Aujourd\'hui',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textMedium,
                fontWeight: FontWeight.w500,
              ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const _MessageBubble({
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('HH:mm').format(message.timestamp);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: const BoxConstraints(maxWidth: 280),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: isMe ? AppColors.accent : AppColors.navyBackground,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isMe ? 20 : 6),
                  bottomRight: Radius.circular(isMe ? 6 : 20),
                ),
              ),
              child: Text(
                message.content,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isMe ? Colors.white : AppColors.primary,
                      height: 1.4,
                    ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: EdgeInsets.only(
                left: isMe ? 0 : 8,
                right: isMe ? 8 : 0,
              ),
              child: Text(
                isMe ? '$time · Lu' : time,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textLight,
                      fontSize: 10,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

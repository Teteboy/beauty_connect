import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/providers/message_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/message.dart';

class ChatScreen extends StatefulWidget {
  final String userId;

  const ChatScreen({
    super.key,
    required this.userId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  
  String? _otherUserName;
  String? _otherUserPhone;
  bool _isOnline = false;
  bool _isTyping = false;
  bool _showAttachmentOptions = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMessages();
      _findOtherUserInfo();
      _animationController.forward();
      // Mark messages as read when opening chat
      context.read<MessageProvider>().markAsRead(widget.userId);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _loadMessages() {
    context.read<MessageProvider>().fetchMessages(widget.userId);
  }

  void _findOtherUserInfo() {
    final conversations = context.read<MessageProvider>().conversations;
    
    try {
      final conversation = conversations.firstWhere(
        (conv) => conv.user.id.toString() == widget.userId,
      );
      
      setState(() {
        _otherUserName = '${conversation.user.firstName} ${conversation.user.lastName}';
        _otherUserPhone = conversation.user.phone;
        _isOnline = false; // User model doesn't have isOnline property
      });
    } catch (e) {
      setState(() {
        _otherUserName = 'User';
        _otherUserPhone = null;
        _isOnline = false;
      });
    }
  }

  void _sendMessage({String? content, String? fileUrl, String? fileType}) async {
    final messageContent = content ?? _messageController.text.trim();
    if (messageContent.isEmpty && fileUrl == null) return;

    if (content == null) _messageController.clear();
    
    final success = await context.read<MessageProvider>().sendMessage(
      receiverId: widget.userId,
      content: messageContent,
    );

    if (success) {
      _scrollToBottom();
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

  void _makePhoneCall() async {
    if (_otherUserPhone != null) {
      // Request phone permission
      final phonePermission = await Permission.phone.request();
      
      if (phonePermission.isGranted) {
        final uri = Uri(scheme: 'tel', path: _otherUserPhone);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          _showSnackBar('Could not launch phone dialer');
        }
      } else {
        _showSnackBar('Phone permission denied');
      }
    } else {
      _showSnackBar('Phone number not available');
    }
  }

  void _startVideoCall() async {
    if (_otherUserName != null) {
      // Request camera and microphone permissions
      final cameraPermission = await Permission.camera.request();
      final microphonePermission = await Permission.microphone.request();
      
      if (cameraPermission.isGranted && microphonePermission.isGranted) {
        // Show video call dialog
        _showVideoCallDialog();
      } else {
        _showSnackBar('Camera and microphone permissions required for video calls');
      }
    } else {
      _showSnackBar('Cannot start video call - user information not available');
    }
  }

  void _startAudioCall() async {
    if (_otherUserName != null) {
      // Request microphone permission
      final microphonePermission = await Permission.microphone.request();
      
      if (microphonePermission.isGranted) {
        // Show audio call dialog
        _showAudioCallDialog();
      } else {
        _showSnackBar('Microphone permission required for audio calls');
      }
    } else {
      _showSnackBar('Cannot start audio call - user information not available');
    }
  }

  void _showAudioCallDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.call, color: Colors.blue),
            const SizedBox(width: 8),
            const Text('Audio Call'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Start an audio call with ${_otherUserName ?? 'this user'}?'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _initiateAudioCall();
              },
              icon: const Icon(Icons.call),
              label: const Text('Start Call'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(150, 45),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showVideoCallDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.videocam, color: Colors.green),
            const SizedBox(width: 8),
            const Text('Video Call'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Start a video call with ${_otherUserName ?? 'this user'}?'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _initiateVideoCall();
                  },
                  icon: const Icon(Icons.videocam),
                  label: const Text('Video'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _initiateAudioCall();
                  },
                  icon: const Icon(Icons.call),
                  label: const Text('Audio'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _initiateVideoCall() async {
    try {
      _showSnackBar('Starting video call with ${_otherUserName ?? 'user'}...');
      
      // Send a message indicating video call attempt
      await context.read<MessageProvider>().sendMessage(
        receiverId: widget.userId,
        content: '📹 Started a video call',
      );
      
      // Simulate call duration
      await Future.delayed(const Duration(seconds: 2));
      
      // Show call in progress dialog
      _showCallInProgressDialog(isVideo: true);
      
    } catch (e) {
      _showSnackBar('Failed to start video call: $e');
    }
  }

  void _initiateAudioCall() async {
    try {
      _showSnackBar('Starting audio call with ${_otherUserName ?? 'user'}...');
      
      // Send a message indicating audio call attempt
      await context.read<MessageProvider>().sendMessage(
        receiverId: widget.userId,
        content: '📞 Started an audio call',
      );
      
      // Simulate call duration
      await Future.delayed(const Duration(seconds: 2));
      
      // Show call in progress dialog
      _showCallInProgressDialog(isVideo: false);
      
    } catch (e) {
      _showSnackBar('Failed to start audio call: $e');
    }
  }

  void _showCallInProgressDialog({required bool isVideo}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              isVideo ? Icons.videocam : Icons.call,
              color: isVideo ? Colors.green : Colors.blue,
            ),
            const SizedBox(width: 8),
            Text('${isVideo ? 'Video' : 'Audio'} Call'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Text(
                _otherUserName?.substring(0, 1) ?? 'U',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _otherUserName ?? 'User',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Calling...',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (isVideo)
                  IconButton(
                    onPressed: () {
                      // Toggle camera
                      _showSnackBar('Camera toggled');
                    },
                    icon: const Icon(Icons.videocam_off),
                    iconSize: 32,
                    color: Colors.grey[600],
                  ),
                IconButton(
                  onPressed: () {
                    // Toggle microphone
                    _showSnackBar('Microphone toggled');
                  },
                  icon: const Icon(Icons.mic_off),
                  iconSize: 32,
                  color: Colors.grey[600],
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _endCall(isVideo: isVideo);
                  },
                  icon: const Icon(Icons.call_end),
                  iconSize: 32,
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _endCall({required bool isVideo}) async {
    _showSnackBar('Call ended');
    
    // Send a message indicating call ended
    await context.read<MessageProvider>().sendMessage(
      receiverId: widget.userId,
      content: '${isVideo ? '📹' : '📞'} Call ended',
    );
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      // Upload image and send message
      _sendMessage(
        content: 'Sent an image',
        fileUrl: image.path,
        fileType: 'image',
      );
    }
    setState(() => _showAttachmentOptions = false);
  }

  void _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    
    if (result != null && result.files.single.path != null) {
      final file = result.files.single;
      _sendMessage(
        content: 'Sent a file: ${file.name}',
        fileUrl: file.path!,
        fileType: 'file',
      );
    }
    setState(() => _showAttachmentOptions = false);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthProvider>().user;
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/messages');
            }
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: Text(
                _otherUserName?.substring(0, 1) ?? 'U',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _otherUserName ?? 'Chat',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _isOnline ? 'Online' : 'Last seen recently',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (_otherUserPhone != null)
            IconButton(
              onPressed: _makePhoneCall,
              icon: const Icon(Icons.call),
              tooltip: 'Call',
            ),
          IconButton(
            onPressed: _startAudioCall,
            icon: const Icon(Icons.phone),
            tooltip: 'Audio Call',
          ),
          IconButton(
            onPressed: _startVideoCall,
            icon: const Icon(Icons.videocam),
            tooltip: 'Video Call',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'view_profile':
                  context.go('/user-profile/${widget.userId}');
                  break;
                case 'clear_chat':
                  _showClearChatDialog();
                  break;
                case 'block_user':
                  _showBlockUserDialog();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'view_profile',
                child: Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 12),
                    Text('View Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear_chat',
                child: Row(
                  children: [
                    Icon(Icons.clear_all),
                    SizedBox(width: 12),
                    Text('Clear Chat'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'block_user',
                child: Row(
                  children: [
                    Icon(Icons.block, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Block User', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(_slideAnimation),
        child: Column(
          children: [
            Expanded(
              child: Consumer<MessageProvider>(
                builder: (context, messageProvider, _) {
                  if (messageProvider.isLoading && messageProvider.messages.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (messageProvider.error != null && messageProvider.messages.isEmpty) {
                    return _buildErrorState(messageProvider.error!);
                  }

                  final messages = messageProvider.messages;

                  if (messages.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe = message.senderId == currentUser?.id;
                      final showTimestamp = index == 0 || 
                          messages[index - 1].timestamp.difference(message.timestamp).inMinutes.abs() > 5;

                      return Column(
                        children: [
                          if (showTimestamp)
                            _buildTimestamp(message.timestamp),
                          _MessageBubble(
                            message: message,
                            isMe: isMe,
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            if (_isTyping)
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const SizedBox(width: 50),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Text('Typing...'),
                    ),
                  ],
                ),
              ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(error),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadMessages,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No messages yet. Start the conversation!',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildTimestamp(DateTime timestamp) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          DateFormat('MMM d, h:mm a').format(timestamp),
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          if (_showAttachmentOptions)
            _buildAttachmentOptions(),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _showAttachmentOptions = !_showAttachmentOptions;
                  });
                },
                icon: Icon(
                  _showAttachmentOptions ? Icons.close : Icons.attach_file,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () => _sendMessage(),
                  icon: const Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentOptions() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _AttachmentOption(
            icon: Icons.photo,
            label: 'Photo',
            color: Colors.blue,
            onTap: _pickImage,
          ),
          _AttachmentOption(
            icon: Icons.insert_drive_file,
            label: 'File',
            color: Colors.orange,
            onTap: _pickFile,
          ),
          _AttachmentOption(
            icon: Icons.camera_alt,
            label: 'Camera',
            color: Colors.green,
            onTap: () async {
              final picker = ImagePicker();
              final image = await picker.pickImage(source: ImageSource.camera);
              if (image != null) {
                _sendMessage(
                  content: 'Sent a photo',
                  fileUrl: image.path,
                  fileType: 'image',
                );
              }
              setState(() => _showAttachmentOptions = false);
            },
          ),
          _AttachmentOption(
            icon: Icons.location_on,
            label: 'Location',
            color: Colors.red,
            onTap: () {
              _sendMessage(content: 'Shared location');
              setState(() => _showAttachmentOptions = false);
            },
          ),
        ],
      ),
    );
  }

  void _showClearChatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat'),
        content: const Text('Are you sure you want to clear this chat? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement clear chat functionality
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showBlockUserDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block User'),
        content: Text('Are you sure you want to block ${_otherUserName ?? 'this user'}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement block user functionality
            },
            child: const Text('Block', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _AttachmentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AttachmentOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
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
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe 
              ? Theme.of(context).primaryColor 
              : Colors.white,
          borderRadius: BorderRadius.circular(18).copyWith(
            bottomRight: isMe ? const Radius.circular(4) : null,
            bottomLeft: !isMe ? const Radius.circular(4) : null,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('h:mm a').format(message.timestamp),
                  style: TextStyle(
                    color: isMe ? Colors.white70 : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead ? Icons.done_all : Icons.done,
                    size: 16,
                    color: message.isRead ? Colors.blue[300] : Colors.white70,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}









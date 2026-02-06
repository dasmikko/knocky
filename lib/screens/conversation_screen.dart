import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/conversation.dart';
import '../models/message.dart';
import '../models/thread_user.dart';
import '../data/role_colors.dart';
import '../services/knockout_api_service.dart';
import '../widgets/bbcode_renderer.dart';
import 'user_screen.dart';

class ConversationScreen extends StatefulWidget {
  final Conversation? conversation;
  final ThreadUser? recipient;

  const ConversationScreen({
    super.key,
    this.conversation,
    this.recipient,
  }) : assert(conversation != null || recipient != null);

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  Conversation? _fullConversation;
  bool _isLoading = false;
  bool _isSending = false;
  bool _isRefreshing = false;
  String? _error;

  bool get _isNewConversation => widget.conversation == null;
  int _getCurrentUserId(BuildContext context) => context.read<KnockoutApiService>().syncData?.id ?? 0;

  @override
  void initState() {
    super.initState();
    if (!_isNewConversation) {
      _loadFullConversation();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _refreshConversation() async {
    if (_isNewConversation || _isRefreshing) return;

    setState(() => _isRefreshing = true);

    try {
      final conversation = await context.read<KnockoutApiService>().getConversation(widget.conversation!.id);
      if (mounted) {
        setState(() {
          _fullConversation = conversation;
          _isRefreshing = false;
        });
        if (conversation.messages.isNotEmpty) {
          context.read<KnockoutApiService>().markMessagesRead(conversation.messages.first.id);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  Future<void> _loadFullConversation() async {
    if (widget.conversation == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiService = context.read<KnockoutApiService>();
      final conversation = await apiService.getConversation(widget.conversation!.id);
      setState(() {
        _fullConversation = conversation;
        _isLoading = false;
      });
      // Mark messages as read using the latest message ID
      if (conversation.messages.isNotEmpty) {
        apiService.markMessagesRead(conversation.messages.first.id);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _getTitle() {
    if (_isNewConversation) {
      return widget.recipient?.username ?? 'New Message';
    }
    final conversation = _fullConversation ?? widget.conversation!;
    final otherUsers = conversation.getOtherUsers(_getCurrentUserId(context));
    if (otherUsers.isEmpty) return 'Conversation';
    return otherUsers.map((u) => u.username).join(', ');
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty || _isSending) return;

    int receivingUserId;
    int? conversationId;

    if (_isNewConversation) {
      receivingUserId = widget.recipient!.id;
      conversationId = null;
    } else {
      final conversation = _fullConversation ?? widget.conversation!;
      final otherUsers = conversation.getOtherUsers(_getCurrentUserId(context));
      if (otherUsers.isEmpty) return;
      receivingUserId = otherUsers.first.id;
      conversationId = conversation.id;
    }

    setState(() => _isSending = true);

    final success = await context.read<KnockoutApiService>().sendMessage(
      receivingUserId: receivingUserId,
      content: content,
      conversationId: conversationId,
    );

    if (mounted) {
      setState(() => _isSending = false);

      if (success) {
        _messageController.clear();
        if (_isNewConversation) {
          // Go back to conversations list after sending first message
          Navigator.pop(context, true);
        } else {
          await _loadFullConversation();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send message'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  String _formatTime(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return timeago.format(date, locale: 'en_short');
    } catch (e) {
      return '';
    }
  }

  Widget _buildMessageBubble(Message message, bool isMe) {
    final avatarUrl = message.user.avatarUrl;
    final hasAvatar = avatarUrl.isNotEmpty && avatarUrl != 'none.webp';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserScreen(userId: message.user.id),
                  ),
                );
              },
              child: CircleAvatar(
                radius: 16,
                backgroundImage: hasAvatar
                    ? CachedNetworkImageProvider('https://cdn.knockout.chat/image/$avatarUrl')
                    : null,
                child: hasAvatar ? null : const Icon(Icons.person, size: 18),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMe ? 18 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 18),
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (!isMe)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: RoleColoredUsername(
                        username: message.user.username,
                        roleCode: message.user.role.code,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  BbcodeRenderer(
                    content: message.content,
                    postId: message.id,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.createdAt),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserScreen(userId: message.user.id),
                  ),
                );
              },
              child: CircleAvatar(
                radius: 16,
                backgroundImage: hasAvatar
                    ? CachedNetworkImageProvider('https://cdn.knockout.chat/image/$avatarUrl')
                    : null,
                child: hasAvatar ? null : const Icon(Icons.person, size: 18),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(_getTitle())),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(_getTitle())),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text('Error: $_error', textAlign: TextAlign.center),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadFullConversation,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Messages are in reverse chronological order from API, which works with reverse: true
    final messages = _isNewConversation ? <Message>[] : (_fullConversation?.messages ?? []);

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        actions: [
          if (!_isNewConversation)
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.arrowsRotate, size: 18),
              onPressed: _isRefreshing ? null : _refreshConversation,
            ),
        ],
        bottom: _isRefreshing
            ? const PreferredSize(
                preferredSize: Size.fromHeight(4),
                child: LinearProgressIndicator(),
              )
            : null,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.only(top: 12, bottom: 12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isMe = message.user.id == _getCurrentUserId(context);
                return _buildMessageBubble(message, isMe);
              },
            ),
          ),
          _buildMessageInput(bottomPadding),
        ],
      ),
    );
  }

  Widget _buildMessageInput(double bottomPadding) {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 8,
        bottom: bottomPadding + 8,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              textCapitalization: TextCapitalization.sentences,
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: _isSending ? null : _sendMessage,
            icon: _isSending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const FaIcon(FontAwesomeIcons.paperPlane, size: 18),
          ),
        ],
      ),
    );
  }
}

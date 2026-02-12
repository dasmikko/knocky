import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/notification.dart';
import '../services/knockout_api_service.dart';
import '../screens/conversation_screen.dart';
import '../screens/conversations_screen.dart';
import '../screens/thread_screen.dart';
import '../screens/user_screen.dart';

class NotificationsOverlay extends StatefulWidget {
  final VoidCallback onClose;
  final Offset anchorPosition;
  final Size anchorSize;

  const NotificationsOverlay({
    super.key,
    required this.onClose,
    required this.anchorPosition,
    required this.anchorSize,
  });

  @override
  State<NotificationsOverlay> createState() => _NotificationsOverlayState();
}

class _NotificationsOverlayState extends State<NotificationsOverlay>
    with SingleTickerProviderStateMixin {
  final KnockoutApiService _apiService = KnockoutApiService();
  List<KnockyNotification>? _notifications;
  bool _isLoading = true;
  bool _isMarkingAllRead = false;
  String? _error;

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  List<KnockyNotification> get _unreadNotifications =>
      _notifications?.where((n) => !n.read).toList() ?? [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInCirc,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInCirc,
    ));

    _animationController.forward();
    _loadNotifications();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _close() async {
    await _animationController.reverse();
    widget.onClose();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final notifications = await _apiService.getNotifications();
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _markAllAsRead() async {
    final unreadIds = _unreadNotifications.map((n) => n.id).toList();
    if (unreadIds.isEmpty) return;

    setState(() => _isMarkingAllRead = true);

    final success = await _apiService.markNotificationsRead(unreadIds);

    if (success && mounted) {
      await _loadNotifications();
    }

    if (mounted) {
      setState(() => _isMarkingAllRead = false);
    }
  }

  void _onNotificationTap(KnockyNotification notification) {
    if (!notification.read) {
      _apiService.markNotificationsRead([notification.id]);
    }

    final rawData = notification.rawData;

    switch (notification.type) {
      case 'MESSAGE':
        if (notification.data != null) {
          widget.onClose();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ConversationScreen(conversation: notification.data!),
            ),
          );
        }

      case 'POST_REPLY' || 'POST_MENTION':
        final thread = rawData?['thread'] as Map<String, dynamic>?;
        final threadId = thread?['id'] as int? ?? rawData?['threadId'] as int?;
        final threadTitle = thread?['title'] as String? ?? 'Thread';
        final page = rawData?['page'] as int? ?? 1;
        if (threadId != null) {
          widget.onClose();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ThreadScreen(
                threadId: threadId,
                threadTitle: threadTitle,
                page: page,
              ),
            ),
          );
        }

      case 'PROFILE_COMMENT':
        final userProfileId = rawData?['userProfile'] as int?;
        if (userProfileId != null) {
          widget.onClose();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserScreen(userId: userProfileId),
            ),
          );
        }

      case 'REPORT_RESOLUTION':
        // No navigation - just mark as read
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Position overlay below the anchor, aligned to the right edge
    final screenSize = MediaQuery.of(context).size;
    final safePadding = MediaQuery.of(context).padding;
    const screenMargin = 8.0;
    final overlayWidth = 320.0.clamp(0.0, screenSize.width - screenMargin * 2);

    final overlayTop = widget.anchorPosition.dy + widget.anchorSize.height + 8;
    final overlayRight =
        screenSize.width - widget.anchorPosition.dx - widget.anchorSize.width;

    // Clamp so the overlay stays within screen bounds
    final clampedRight = overlayRight.clamp(
      screenMargin,
      screenSize.width - overlayWidth - screenMargin,
    );
    final clampedTop = overlayTop.clamp(
      safePadding.top + screenMargin,
      screenSize.height * 0.4,
    );

    // Fit content up to 60% of screen, but never exceed available space
    final availableHeight =
        screenSize.height - clampedTop - safePadding.bottom - screenMargin;
    final maxOverlayHeight = (screenSize.height * 0.6).clamp(0.0, availableHeight);

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Backdrop
          GestureDetector(
            onTap: _close,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(color: Colors.black26),
            ),
          ),
          // Overlay positioned under the notification icon
          Positioned(
            top: clampedTop,
            right: clampedRight,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  width: overlayWidth,
                  constraints: BoxConstraints(
                    maxHeight: maxOverlayHeight,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    alignment: Alignment.topCenter,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildHeader(),
                        const Divider(height: 1),
                        Flexible(child: _buildContent()),
                        const Divider(height: 1),
                        _buildViewMessagesButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final hasUnread = _unreadNotifications.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.notifications, size: 20),
          const SizedBox(width: 8),
          const Text(
            'Notifications',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          if (hasUnread && !_isLoading)
            TextButton(
              onPressed: _isMarkingAllRead ? null : _markAllAsRead,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: _isMarkingAllRead
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Mark all read', style: TextStyle(fontSize: 12)),
            ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: _close,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(height: 8),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loadNotifications,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_notifications == null || _notifications!.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Text(
            'No notifications',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: _notifications!.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final notification = _notifications![index];
        return _NotificationTile(
          notification: notification,
          currentUserId: _apiService.syncData?.id ?? 0,
          onTap: () => _onNotificationTap(notification),
        );
      },
    );
  }

  Widget _buildViewMessagesButton() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: SizedBox(
        width: double.infinity,
        child: TextButton.icon(
          onPressed: () {
            widget.onClose();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ConversationsScreen()),
            );
          },
          icon: const Icon(Icons.mail_outline, size: 18),
          label: const Text('View messages'),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final KnockyNotification notification;
  final int currentUserId;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notification,
    required this.currentUserId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.read;
    final rawData = notification.rawData;

    String title = 'Notification';
    String subtitle = '';
    String? avatarUrl;
    IconData fallbackIcon = Icons.notifications;

    switch (notification.type) {
      case 'MESSAGE':
        fallbackIcon = Icons.mail;
        final conversation = notification.data;
        if (conversation != null) {
          final otherUsers = conversation.getOtherUsers(currentUserId);
          if (otherUsers.isNotEmpty) {
            title = otherUsers.map((u) => u.username).join(', ');
            final avatar = otherUsers.first.avatarUrl;
            if (avatar.isNotEmpty && avatar != 'none.webp') {
              avatarUrl = 'https://cdn.knockout.chat/image/$avatar';
            }
          }
          final latestMessage = conversation.latestMessage;
          if (latestMessage != null) {
            subtitle = latestMessage.content;
          }
        }

      case 'POST_REPLY':
        fallbackIcon = Icons.reply;
        final user = rawData?['user'] as Map<String, dynamic>?;
        final thread = rawData?['thread'] as Map<String, dynamic>?;
        final username = user?['username'] as String? ?? 'Someone';
        final threadTitle = thread?['title'] as String?;
        title = username;
        subtitle = threadTitle != null
            ? 'Replied to your post in $threadTitle'
            : 'Replied to your post';
        avatarUrl = _extractAvatarUrl(user);

      case 'POST_MENTION':
        fallbackIcon = Icons.alternate_email;
        final user = rawData?['user'] as Map<String, dynamic>?;
        final thread = rawData?['thread'] as Map<String, dynamic>?;
        final username = user?['username'] as String? ?? 'Someone';
        final threadTitle = thread?['title'] as String?;
        title = username;
        subtitle = threadTitle != null
            ? 'Mentioned you in $threadTitle'
            : 'Mentioned you in a post';
        avatarUrl = _extractAvatarUrl(user);

      case 'PROFILE_COMMENT':
        fallbackIcon = Icons.comment;
        final author = rawData?['author'];
        if (author is Map<String, dynamic>) {
          final username = author['username'] as String? ?? 'Someone';
          title = username;
          avatarUrl = _extractAvatarUrl(author);
        } else {
          title = 'Someone';
        }
        subtitle = 'Commented on your profile';

      case 'REPORT_RESOLUTION':
        fallbackIcon = Icons.shield;
        title = 'Moderation';
        subtitle = 'Action has been taken on a post you reported';
    }

    final createdAt = DateTime.tryParse(notification.createdAt);
    final timeAgo =
        createdAt != null ? timeago.format(createdAt) : notification.createdAt;

    return ListTile(
      onTap: onTap,
      tileColor: isUnread
          ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
          : null,
      leading: CircleAvatar(
        backgroundImage: avatarUrl != null ? CachedNetworkImageProvider(avatarUrl) : null,
        child: avatarUrl == null ? Icon(fallbackIcon) : null,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            timeAgo,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
      subtitle: subtitle.isNotEmpty
          ? Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isUnread ? null : Colors.grey[600],
              ),
            )
          : null,
    );
  }

  String? _extractAvatarUrl(Map<String, dynamic>? user) {
    final avatar = user?['avatarUrl'] as String?;
    if (avatar != null && avatar.isNotEmpty && avatar != 'none.webp') {
      return 'https://cdn.knockout.chat/image/$avatar';
    }
    return null;
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../data/role_colors.dart';
import '../data/thread_icons.dart';
import '../models/alert.dart';
import '../screens/thread_screen.dart';
import '../screens/user_screen.dart';

/// A list item widget for displaying subscription alerts.
class SubscriptionListItem extends StatelessWidget {
  final Alert alert;

  const SubscriptionListItem({
    super.key,
    required this.alert,
  });

  String _formatTimeAgo(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return timeago.format(date, locale: 'en_short');
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final thread = alert.thread;
    final hasUnread = alert.unreadPosts > 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ThreadScreen(threadId: thread.id, threadTitle: thread.title),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thread icon
              Padding(
                padding: const EdgeInsets.only(right: 12, top: 2),
                child: getThreadIconById(thread.iconId).buildIcon(
                  width: 32,
                  height: 32,
                ),
              ),
              // Thread content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thread title and status badges
                    _buildTitleRow(hasUnread),
                    const SizedBox(height: 8),

                    // Thread metadata
                    _buildMetadataRow(context),
                    const SizedBox(height: 8),

                    // Last post info
                    if (thread.lastPost != null) _buildLastPostRow(context),

                    // Unread count badge
                    if (hasUnread) _buildUnreadBadge(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleRow(bool hasUnread) {
    final thread = alert.thread;
    return Row(
      children: [
        if (thread.pinned)
          const Icon(Icons.push_pin, size: 16, color: Colors.orange),
        if (thread.locked)
          const Padding(
            padding: EdgeInsets.only(left: 4),
            child: Icon(Icons.lock, size: 16, color: Colors.grey),
          ),
        if (thread.pinned || thread.locked) const SizedBox(width: 8),
        Expanded(
          child: Text(
            thread.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildMetadataRow(BuildContext context) {
    final thread = alert.thread;
    return Row(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundImage: thread.user.avatarUrl.isNotEmpty &&
                  thread.user.avatarUrl != 'none.webp'
              ? CachedNetworkImageProvider(
                  'https://cdn.knockout.chat/image/${thread.user.avatarUrl}',
                )
              : null,
          child: thread.user.avatarUrl.isEmpty ||
                  thread.user.avatarUrl == 'none.webp'
              ? const Icon(Icons.person, size: 16)
              : null,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserScreen(userId: thread.user.id),
                ),
              );
            },
            child: RoleColoredUsername(
              username: thread.user.username,
              roleCode: thread.user.role.code,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        Text(
          '${thread.postCount} posts',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildLastPostRow(BuildContext context) {
    final thread = alert.thread;
    return Row(
      children: [
        const Icon(Icons.comment, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      UserScreen(userId: thread.lastPost!.user.id),
                ),
              );
            },
            child: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'Last post by ',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  TextSpan(
                    text: thread.lastPost!.user.username,
                    style: TextStyle(
                      fontSize: 11,
                      color: getRoleColor(
                        thread.lastPost!.user.role.code,
                        brightness: Theme.of(context).brightness,
                      ),
                    ),
                  ),
                ],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        Text(
          _formatTimeAgo(thread.lastPost!.createdAt),
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildUnreadBadge(BuildContext context) {
    final thread = alert.thread;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: GestureDetector(
        onTap: () {
          final lastPostNumber = thread.postCount - alert.unreadPosts;
          final page = (lastPostNumber ~/ 20) + 1;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ThreadScreen(
                threadId: thread.id,
                threadTitle: thread.title,
                page: page,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${alert.unreadPosts} unread',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }
}

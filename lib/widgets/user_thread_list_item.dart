import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../data/role_colors.dart';
import '../data/thread_icons.dart';
import '../models/user_thread.dart';
import '../screens/thread_screen.dart';
import '../screens/user_screen.dart';

/// A list item widget for displaying threads created by a user.
class UserThreadListItem extends StatelessWidget {
  final UserThread thread;

  const UserThreadListItem({
    super.key,
    required this.thread,
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
    final hasUnread =
        thread.readThread != null && thread.readThread!.unreadPostCount > 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      clipBehavior: Clip.antiAlias,
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
        child: Stack(
          children: [
            // Background thread icon in corner with radial fade
            Positioned(
              right: -20,
              bottom: -20,
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return RadialGradient(
                    center: Alignment.center,
                    radius: 0.8,
                    colors: [
                      Colors.white.withValues(alpha: 0.8),
                      Colors.white.withValues(alpha: 0.4),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: Opacity(
                  opacity: 0.25,
                  child: getThreadIconById(thread.iconId).buildIcon(
                    width: 80,
                    height: 80,
                  ),
                ),
              ),
            ),
            // Thread content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thread title and status badges
                  _buildTitleRow(hasUnread),
                  const SizedBox(height: 8),

                  // Thread metadata
                  _buildMetadataRow(),

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
    );
  }

  Widget _buildTitleRow(bool hasUnread) {
    return Row(
      children: [
        if (thread.pinned)
          const Padding(
            padding: EdgeInsets.only(right: 8),
            child: Icon(Icons.push_pin, size: 16, color: Colors.orange),
          ),
        if (thread.locked)
          const Padding(
            padding: EdgeInsets.only(right: 8),
            child: Icon(Icons.lock, size: 16, color: Colors.grey),
          ),
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

  Widget _buildMetadataRow() {
    return Row(
      children: [
        Text(
          '${thread.postCount} posts',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(width: 16),
        Text(
          'Created ${_formatTimeAgo(thread.createdAt)}',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildLastPostRow(BuildContext context) {
    final lastPost = thread.lastPost!;
    final lastPostUser = lastPost.user;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          const Icon(Icons.comment, size: 14, color: Colors.grey),
          const SizedBox(width: 4),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserScreen(userId: lastPostUser.id),
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
                      text: lastPostUser.username,
                      style: TextStyle(
                        fontSize: 11,
                        color: getRoleColor(
                          lastPostUser.role.code,
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
            _formatTimeAgo(lastPost.createdAt),
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildUnreadBadge(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: GestureDetector(
        onTap: () {
          final page = (thread.readThread!.lastPostNumber ~/ 20) + 1;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ThreadScreen(
                threadId: thread.id,
                threadTitle: thread.title,
                page: page,
                scrollToUnread: true,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${thread.readThread!.unreadPostCount} unread',
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
        ),
      ),
    );
  }
}

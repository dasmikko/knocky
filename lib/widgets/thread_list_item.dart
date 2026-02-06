import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../data/role_colors.dart';
import '../data/thread_icons.dart';
import '../models/thread.dart' as thread_model;
import '../screens/thread_screen.dart';
import '../screens/user_screen.dart';

/// A list item widget for displaying threads in latest/popular thread lists.
class ThreadListItem extends StatelessWidget {
  final thread_model.Thread thread;

  /// Whether to show "Created" or "Updated" timestamp
  final bool showCreatedTime;

  /// Number of unread posts (for subscriptions)
  final int? unreadPosts;

  /// Custom onTap handler (for navigating to first unread)
  final VoidCallback? onUnreadTap;

  const ThreadListItem({
    super.key,
    required this.thread,
    this.showCreatedTime = true,
    this.unreadPosts,
    this.onUnreadTap,
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
                  Row(
                    children: [
                      if (thread.pinned)
                        const Icon(
                          Icons.push_pin,
                          size: 16,
                          color: Colors.orange,
                        ),
                      if (thread.locked)
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Icon(Icons.lock, size: 16, color: Colors.grey),
                        ),
                      if (thread.pinned || thread.locked)
                        const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          thread.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: unreadPosts == null ||
                                    (unreadPosts != null && unreadPosts! > 0)
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Thread metadata
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundImage:
                            thread.user.avatarUrl.isNotEmpty &&
                                thread.user.avatarUrl != 'none.webp'
                            ? CachedNetworkImageProvider(
                                'https://cdn.knockout.chat/image/${thread.user.avatarUrl}',
                              )
                            : null,
                        child:
                            thread.user.avatarUrl.isEmpty ||
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
                                builder: (context) =>
                                    UserScreen(userId: thread.user.id),
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
                      if (thread.viewers != null) ...[
                        const Icon(
                          Icons.visibility,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${thread.viewers!.memberCount} viewing',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Created/Updated time
                  Text(
                    '${showCreatedTime ? 'Created' : 'Updated'} ${_formatTimeAgo(showCreatedTime ? thread.createdAt : thread.updatedAt)}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),

                  // Unread badge (for subscriptions)
                  if (unreadPosts != null && unreadPosts! > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: GestureDetector(
                        onTap: onUnreadTap,
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
                            '$unreadPosts unread',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

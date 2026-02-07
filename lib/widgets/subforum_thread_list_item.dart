import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../data/ratings.dart';
import '../data/role_colors.dart';
import '../data/thread_icons.dart';
import '../models/thread.dart' as thread_model;
import '../screens/thread_screen.dart';
import '../screens/user_screen.dart';

/// A list item widget for displaying threads in a subforum with full details.
class SubforumThreadListItem extends StatelessWidget {
  final thread_model.Thread thread;
  final VoidCallback? onLongPress;

  const SubforumThreadListItem({
    super.key,
    required this.thread,
    this.onLongPress,
  });

  String _formatTimeAgo(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return timeago.format(date, locale: 'en_short');
    } catch (e) {
      return '';
    }
  }

  bool get _isNsfw {
    if (thread.tags.isEmpty) return false;
    final tag = thread.tags.first;
    if (tag is Map) {
      final value = tag.values.firstOrNull?.toString().toLowerCase() ?? '';
      return value == 'nsfw';
    }
    return tag.toString().toLowerCase() == 'nsfw';
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
        onLongPress: onLongPress,
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
                  _buildMetadataRow(context),
                  const SizedBox(height: 8),

                  // Last post info
                  if (thread.lastPost != null) _buildLastPostRow(context),

                  // Unread count badge
                  if (hasUnread) _buildUnreadBadge(context),

                  // Top rating
                  if (thread.firstPostTopRating != null) _buildTopRating(),

                  // Viewers
                  if (thread.viewers != null &&
                      (thread.viewers!.memberCount > 0 ||
                          thread.viewers!.guestCount > 0))
                    _buildViewers(),
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
        if (_isNsfw)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'NSFW',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
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

  Widget _buildMetadataRow(BuildContext context) {
    return Row(
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

  Widget _buildTopRating() {
    final ratingCode = thread.firstPostTopRating!.rating.toLowerCase();
    final rating = ratingMap[ratingCode];
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          if (rating != null)
            Image.asset(
              rating.assetPath,
              width: 16,
              height: 16,
              filterQuality: FilterQuality.high,
            )
          else
            const Icon(Icons.star, size: 14, color: Colors.amber),
          const SizedBox(width: 4),
          Text(
            '${rating?.name ?? thread.firstPostTopRating!.rating}: ${thread.firstPostTopRating!.count}',
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildViewers() {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          const Icon(Icons.visibility, size: 14, color: Colors.grey),
          const SizedBox(width: 4),
          Text(
            'Viewing: ${thread.viewers!.memberCount} members, ${thread.viewers!.guestCount} guests',
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../data/ratings.dart';
import '../../data/role_colors.dart';
import '../../models/ticker_event.dart';
import '../../screens/thread_screen.dart';
import '../../screens/user_screen.dart';

class TickerEventItem extends StatelessWidget {
  const TickerEventItem({super.key, required this.event});

  final TickerEvent event;

  @override
  Widget build(BuildContext context) {
    final info = _getEventInfo(event);

    return InkWell(
      onTap: info.onTap != null ? () => info.onTap!(context) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 28,
              child: info.iconWidget ??
                  Text(
                    info.emoji,
                    style: const TextStyle(fontSize: 20),
                  ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  info.description,
                  const SizedBox(height: 2),
                  Text(
                    _timeAgo(DateTime.parse(event.createdAt)),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withValues(alpha: 0.5),
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

  static String _timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }
}

class _EventInfo {
  final String emoji;
  final Widget? iconWidget;
  final Widget description;
  final void Function(BuildContext context)? onTap;

  _EventInfo({
    required this.emoji,
    this.iconWidget,
    required this.description,
    this.onTap,
  });
}

void _navigateToThread(BuildContext context, TickerEvent event,
    {int? page, int? scrollToPostId}) {
  final threadId = event.threadId;
  if (threadId == null) return;
  final title = event.threadTitle ?? event.nestedThreadTitle ?? '';
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ThreadScreen(
        threadId: threadId,
        threadTitle: title,
        page: page,
        scrollToPostId: scrollToPostId,
      ),
    ),
  );
}

void _navigateToUser(BuildContext context, int userId) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => UserScreen(userId: userId)),
  );
}

WidgetSpan _creatorSpan(TickerEvent event) {
  return WidgetSpan(
    alignment: PlaceholderAlignment.baseline,
    baseline: TextBaseline.alphabetic,
    child: RoleColoredUsername(
      username: event.creator.username,
      roleCode: event.creator.role.code,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
    ),
  );
}

TextSpan _threadSpan(String title) {
  return TextSpan(
    text: title,
    style: const TextStyle(color: Color(0xFF3FACFF), fontSize: 14),
  );
}

TextSpan _userSpan(String username) {
  return TextSpan(
    text: username,
    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
  );
}

TextSpan _highlightSpan(String text) {
  return TextSpan(
    text: text,
    style: const TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 14,
      fontStyle: FontStyle.italic,
    ),
  );
}

Widget _richText(List<InlineSpan> children) {
  return Text.rich(
    TextSpan(
      style: const TextStyle(fontSize: 14),
      children: children,
    ),
  );
}

_EventInfo _getEventInfo(TickerEvent event) {
  switch (event.type) {
    case 'thread-created':
      return _EventInfo(
        emoji: '\u{1F4F0}',
        description: _richText([
          _creatorSpan(event),
          const TextSpan(text: ' created '),
          _threadSpan(event.threadTitle ?? ''),
        ]),
        onTap: (ctx) => _navigateToThread(ctx, event),
      );
    case 'thread-background-updated':
      return _EventInfo(
        emoji: '\u{1F5BC}\u{FE0F}',
        description: _richText([
          _creatorSpan(event),
          const TextSpan(text: ' updated the background of '),
          _threadSpan(event.threadTitle ?? ''),
        ]),
        onTap: (ctx) => _navigateToThread(ctx, event),
      );
    case 'thread-deleted':
      return _EventInfo(
        emoji: '\u{1F5D1}\u{FE0F}',
        description: _richText([
          _creatorSpan(event),
          const TextSpan(text: ' deleted a thread'),
        ]),
      );
    case 'thread-moved':
      return _EventInfo(
        emoji: '\u{1F69A}',
        description: _richText([
          _creatorSpan(event),
          const TextSpan(text: ' moved '),
          _threadSpan(event.threadTitle ?? ''),
          TextSpan(text: ' to ${event.subforumName ?? 'another subforum'}'),
        ]),
        onTap: (ctx) => _navigateToThread(ctx, event),
      );
    case 'thread-pinned':
      return _EventInfo(
        emoji: '\u{1F4CC}',
        description: _richText([
          _creatorSpan(event),
          const TextSpan(text: ' pinned '),
          _threadSpan(event.threadTitle ?? ''),
        ]),
        onTap: (ctx) => _navigateToThread(ctx, event),
      );
    case 'thread-unpinned':
      return _EventInfo(
        emoji: '\u{267B}\u{FE0F}',
        description: _richText([
          _creatorSpan(event),
          const TextSpan(text: ' unpinned '),
          _threadSpan(event.threadTitle ?? ''),
        ]),
        onTap: (ctx) => _navigateToThread(ctx, event),
      );
    case 'thread-locked':
      return _EventInfo(
        emoji: '\u{1F512}',
        description: _richText([
          _creatorSpan(event),
          const TextSpan(text: ' locked '),
          _threadSpan(event.threadTitle ?? ''),
        ]),
        onTap: (ctx) => _navigateToThread(ctx, event),
      );
    case 'thread-unlocked':
      return _EventInfo(
        emoji: '\u{1F513}',
        description: _richText([
          _creatorSpan(event),
          const TextSpan(text: ' unlocked '),
          _threadSpan(event.threadTitle ?? ''),
        ]),
        onTap: (ctx) => _navigateToThread(ctx, event),
      );
    case 'thread-renamed':
      final oldTitle = event.content['oldTitle'] as String? ?? '';
      final newTitle =
          event.content['newTitle'] as String? ?? event.threadTitle ?? '';
      return _EventInfo(
        emoji: '\u{270F}\u{FE0F}',
        description: _richText([
          _creatorSpan(event),
          const TextSpan(text: ' renamed '),
          _highlightSpan(oldTitle),
          const TextSpan(text: ' to '),
          _threadSpan(newTitle),
        ]),
        onTap: (ctx) => _navigateToThread(ctx, event),
      );
    case 'thread-restored':
      return _EventInfo(
        emoji: '\u{1F504}',
        description: _richText([
          _creatorSpan(event),
          const TextSpan(text: ' restored '),
          _threadSpan(event.threadTitle ?? ''),
        ]),
        onTap: (ctx) => _navigateToThread(ctx, event),
      );
    case 'thread-post-limit-reached':
      return _EventInfo(
        emoji: '\u{1F6D1}',
        description: _richText([
          _threadSpan(event.threadTitle ?? ''),
          const TextSpan(
              text: ' reached its post limit and was automatically locked'),
        ]),
        onTap: (ctx) => _navigateToThread(ctx, event),
      );
    case 'user-avatar-removed':
      return _EventInfo(
        emoji: '\u{1F51E}',
        description: _richText([
          _creatorSpan(event),
          const TextSpan(text: ' removed '),
          _userSpan(event.targetUsername ?? 'a user'),
          const TextSpan(text: "'s avatar"),
        ]),
        onTap: event.targetUserId != null
            ? (ctx) => _navigateToUser(ctx, event.targetUserId!)
            : null,
      );
    case 'user-background-removed':
      return _EventInfo(
        emoji: '\u{1F51E}',
        description: _richText([
          _creatorSpan(event),
          const TextSpan(text: ' removed '),
          _userSpan(event.targetUsername ?? 'a user'),
          const TextSpan(text: "'s background"),
        ]),
        onTap: event.targetUserId != null
            ? (ctx) => _navigateToUser(ctx, event.targetUserId!)
            : null,
      );
    case 'user-unbanned':
      return _EventInfo(
        emoji: '\u{1F44F}',
        description: _richText([
          _creatorSpan(event),
          const TextSpan(text: ' reversed one of '),
          _userSpan(event.targetUsername ?? 'a user'),
          const TextSpan(text: "'s mutes"),
        ]),
        onTap: event.targetUserId != null
            ? (ctx) => _navigateToUser(ctx, event.targetUserId!)
            : null,
      );
    case 'user-profile-removed':
      return _EventInfo(
        emoji: '\u{1F51E}',
        description: _richText([
          _creatorSpan(event),
          const TextSpan(text: ' removed '),
          _userSpan(event.targetUsername ?? 'a user'),
          const TextSpan(text: "'s profile customizations"),
        ]),
        onTap: event.targetUserId != null
            ? (ctx) => _navigateToUser(ctx, event.targetUserId!)
            : null,
      );
    case 'user-banned':
      return _EventInfo(
        emoji: '\u{26D4}',
        description: _richText([
          _creatorSpan(event),
          const TextSpan(text: ' muted '),
          _userSpan(event.targetUsername ?? 'a user'),
          if (event.banReason != null) ...[
            const TextSpan(text: ' with reason "'),
            _highlightSpan(event.banReason!),
            const TextSpan(text: '"'),
          ],
        ]),
        onTap: event.threadId != null
            ? (ctx) => _navigateToThread(ctx, event,
                page: event.postPage, scrollToPostId: event.postId)
            : null,
      );
    case 'ban-reason-edited':
      final oldReason = event.content['oldReason'] as String? ?? '';
      final newReason = event.content['newReason'] as String? ?? '';
      return _EventInfo(
        emoji: '\u{1FA9B}',
        description: _richText([
          _creatorSpan(event),
          const TextSpan(text: ' edited the reason for '),
          _userSpan(event.targetUsername ?? 'a user'),
          const TextSpan(text: '\'s ban from "'),
          _highlightSpan(oldReason),
          const TextSpan(text: '" to "'),
          TextSpan(text: newReason),
          const TextSpan(text: '"'),
        ]),
      );
    case 'user-wiped':
      return _EventInfo(
        emoji: '\u{1F4A5}',
        description: _richText([
          _creatorSpan(event),
          const TextSpan(
              text: ' permanently banned and wiped a user\'s account'),
          if (event.banReason != null) ...[
            const TextSpan(text: ', with reason "'),
            _highlightSpan(event.banReason!),
            const TextSpan(text: '"'),
          ],
        ]),
      );
    case 'post-created':
      return _EventInfo(
        emoji: '\u{1F4AC}',
        description: _richText([
          _creatorSpan(event),
          const TextSpan(text: ' created a new post in '),
          _threadSpan(event.nestedThreadTitle ?? ''),
        ]),
        onTap: (ctx) => _navigateToThread(ctx, event,
            page: event.postPage, scrollToPostId: event.postId),
      );
    case 'rating-created':
      final ratingCode = event.content['rating'] as String?;
      Widget? ratingIcon;
      if (ratingCode != null) {
        final rating =
            ratings.where((r) => r.code == ratingCode).firstOrNull;
        if (rating != null) {
          ratingIcon = Image.asset(rating.assetPath, width: 24, height: 24);
        }
      }
      return _EventInfo(
        emoji: '\u{2B50}',
        iconWidget: ratingIcon,
        description: _richText([
          _creatorSpan(event),
          const TextSpan(text: ' rated a post in '),
          _threadSpan(event.nestedThreadTitle ?? ''),
        ]),
        onTap: (ctx) => _navigateToThread(ctx, event,
            page: event.postPage, scrollToPostId: event.postId),
      );
    case 'profile-comment-created':
      return _EventInfo(
        emoji: '\u{1F4DD}',
        description: _richText([
          _creatorSpan(event),
          const TextSpan(text: ' commented on '),
          _userSpan(event.targetUsername ?? 'a user'),
          const TextSpan(text: "'s profile"),
        ]),
        onTap: event.targetUserId != null
            ? (ctx) => _navigateToUser(ctx, event.targetUserId!)
            : null,
      );
    case 'gold-earned':
      return _EventInfo(
        emoji: '\u{1F3C6}',
        description: _richText([
          _creatorSpan(event),
          const TextSpan(text: ' is now a Gold Member'),
        ]),
        onTap: (ctx) => _navigateToUser(ctx, event.creator.id),
      );
    case 'gold-lost':
      return _EventInfo(
        emoji: '\u{1F4B8}',
        description: _richText([
          _creatorSpan(event),
          const TextSpan(text: ' is no longer a Gold Member'),
        ]),
        onTap: (ctx) => _navigateToUser(ctx, event.creator.id),
      );
    default:
      return _EventInfo(
        emoji: '\u{26A0}\u{FE0F}',
        description: Text(
          'Unknown event: ${event.type}',
          style: const TextStyle(fontSize: 14),
        ),
      );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/conversation.dart';
import '../screens/conversation_screen.dart';
import '../screens/user_screen.dart';

/// A list item widget for displaying conversations.
class ConversationListItem extends StatelessWidget {
  final Conversation conversation;
  final int currentUserId;
  final VoidCallback? onLongPress;

  const ConversationListItem({
    super.key,
    required this.conversation,
    required this.currentUserId,
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

  @override
  Widget build(BuildContext context) {
    final otherUsers = conversation.getOtherUsers(currentUserId);
    final latestMessage = conversation.latestMessage;
    final hasUnread = conversation.hasUnread(currentUserId);

    final displayName = otherUsers.isNotEmpty
        ? otherUsers.map((u) => u.username).join(', ')
        : 'Unknown';

    final avatarUrl = otherUsers.isNotEmpty ? otherUsers.first.avatarUrl : '';
    final hasAvatar = avatarUrl.isNotEmpty && avatarUrl != 'none.webp';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: ListTile(
        leading: GestureDetector(
          onTap: otherUsers.isNotEmpty
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          UserScreen(userId: otherUsers.first.id),
                    ),
                  );
                }
              : null,
          child: CircleAvatar(
            backgroundImage: hasAvatar
                ? CachedNetworkImageProvider('https://cdn.knockout.chat/image/$avatarUrl')
                : null,
            child: hasAvatar ? null : const Icon(Icons.person),
          ),
        ),
        title: Text(
          displayName,
          style: TextStyle(
            fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: latestMessage != null
            ? Text(
                latestMessage.content,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: hasUnread ? null : Colors.grey),
              )
            : null,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatTimeAgo(conversation.updatedAt ?? ''),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            if (hasUnread)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ConversationScreen(conversation: conversation),
            ),
          );
        },
        onLongPress: onLongPress,
      ),
    );
  }
}

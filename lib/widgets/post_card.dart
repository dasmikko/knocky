import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../data/ratings.dart';
import '../data/role_colors.dart';
import '../models/thread_post.dart';
import '../screens/user_screen.dart';
import 'bbcode_renderer.dart';

/// A card widget for displaying a single post in a thread.
class PostCard extends StatelessWidget {
  final ThreadPost post;
  final bool isAuthenticated;
  final bool isOwnPost;
  final String? userRatingCode;
  final VoidCallback? onQuote;
  final VoidCallback? onEdit;
  final VoidCallback? onRate;
  final void Function(String ratingName, String? assetPath, List<dynamic> users)?
      onShowRatingUsers;
  final bool isUnread;

  const PostCard({
    super.key,
    required this.post,
    this.isAuthenticated = false,
    this.isOwnPost = false,
    this.isUnread = false,
    this.userRatingCode,
    this.onQuote,
    this.onEdit,
    this.onRate,
    this.onShowRatingUsers,
  });

  String _formatTimeAgo(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return timeago.format(date, locale: 'en_short');
    } catch (e) {
      return '';
    }
  }

  /// Convert ISO country code to flag emoji
  String? _countryCodeToFlag(String? countryCode) {
    if (countryCode == null || countryCode.length != 2) return null;
    // Convert each letter to regional indicator symbol
    // A = 🇦 (U+1F1E6), B = 🇧 (U+1F1E7), etc.
    final upper = countryCode.toUpperCase();
    final flag = upper.codeUnits
        .map((char) => String.fromCharCode(char + 127397))
        .join();
    return flag;
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl = post.user.avatarUrl;
    final hasAvatar = avatarUrl.isNotEmpty && avatarUrl != 'none.webp';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post header: avatar, username, time
            _buildHeader(context, hasAvatar, avatarUrl),
            const SizedBox(height: 12),
            // Post content rendered as BBCode
            if (post.content.isNotEmpty)
              BbcodeRenderer(content: post.content, postId: post.id),
            // Ratings and action buttons
            const Divider(height: 20),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool hasAvatar, String avatarUrl) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundImage: hasAvatar
              ? CachedNetworkImageProvider(
                  'https://cdn.knockout.chat/image/$avatarUrl',
                )
              : null,
          child: hasAvatar ? null : const Icon(Icons.person, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserScreen(userId: post.user.id),
                    ),
                  );
                },
                child: RoleColoredUsername(
                  username: post.user.username,
                  roleCode: post.user.role.code,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              if (post.user.title != null && post.user.title!.isNotEmpty)
                Text(
                  post.user.title!,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isUnread) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'NEW',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                if (post.countryCode != null) ...[
                  Tooltip(
                    message: post.countryName ?? post.countryCode!,
                    child: Text(
                      _countryCodeToFlag(post.countryCode) ?? '',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  '#${post.threadPostNumber}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
            Text(
              _formatTimeAgo(post.createdAt),
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: post.ratings.isNotEmpty
              ? _buildRatings(context, post.ratings)
              : const SizedBox.shrink(),
        ),
        if (isAuthenticated)
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.quoteLeft, size: 16),
            onPressed: onQuote,
            tooltip: 'Quote post',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            visualDensity: VisualDensity.compact,
          ),
        if (isAuthenticated) const SizedBox(width: 8),
        if (isAuthenticated && isOwnPost)
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.penToSquare, size: 18),
            onPressed: onEdit,
            tooltip: 'Edit post',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            visualDensity: VisualDensity.compact,
          ),
        if (isAuthenticated && isOwnPost) const SizedBox(width: 8),
        if (isAuthenticated)
          IconButton(
            icon: Icon(
              userRatingCode != null
                  ? Icons.add_reaction
                  : Icons.add_reaction_outlined,
              size: 20,
            ),
            onPressed: onRate,
            tooltip: userRatingCode != null ? 'Change rating' : 'Rate post',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            visualDensity: VisualDensity.compact,
          ),
      ],
    );
  }

  Widget _buildRatings(BuildContext context, List<dynamic> postRatings) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: postRatings.map<Widget>((r) {
        final ratingData = r as Map<String, dynamic>;
        final code = (ratingData['rating'] as String? ?? '').toLowerCase();
        final count = ratingData['count'] as int? ?? 0;
        final rating = ratingMap[code];
        final isUserRating = code == userRatingCode;
        final users = ratingData['users'] as List<dynamic>? ?? [];

        return GestureDetector(
          onTap: () => onShowRatingUsers?.call(
            rating?.name ?? code,
            rating?.assetPath,
            users,
          ),
          child: Tooltip(
            message: '${rating?.name ?? code}: $count',
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: isUserRating
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: isUserRating
                    ? Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 1.5,
                      )
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (rating != null)
                    Image.asset(
                      rating.assetPath,
                      width: 16,
                      height: 16,
                      filterQuality: FilterQuality.high,
                    )
                  else
                    const Icon(Icons.star, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    count.toString(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          isUserRating ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../data/role_colors.dart';
import '../models/subforum.dart';

/// Accent color pairs for subforums (gradient start, gradient end)
const List<List<Color>> subforumAccentColors = [
  [Color(0xFFF16D0F), Color(0xFFFF9E39)], // general - orange
  [Color(0xFFA7BDD9), Color(0xFF1E5FB3)], // fast threads - blue
  [Color(0xFFB53FB1), Color(0xFF80D8FF)], // videos - cyan to purple
  [Color(0xFF2599A5), Color(0xFF19D0A6)], // film tv - teal
  [Color(0xFF2DBBFF), Color(0xFF1BFFB1)], // gaming - green to blue
  [Color(0xFF1AA0FF), Color(0xFF18CAFF)], // game generals - light blue
  [Color(0xFFFFCE1A), Color(0xFF3CFF18)], // progress report - green to yellow
  [Color(0xFFDA2361), Color(0xFFDA46FF)], // creativity - magenta
  [Color(0xFF669529), Color(0xFFFFF94A)], // h&s - yellow to green
  [Color(0xFF3B5592), Color(0xFF4CAFE8)], // developers - blue
  [Color(0xFFF15A2A), Color(0xFFFF7C55)], // news - orange red
  [Color(0xFF753B24), Color(0xFFAF5C2D)], // politics - brown
  [Color(0xFFDEB67C), Color(0xFF946622)], // source - gold
  [Color(0xFFAE1C1C), Color(0xFFFB2E24)], // meta - red
  [Color(0xFFBD4045), Color(0xFFAB7977)], // facepunch - dusty rose
];

/// Get accent colors for a subforum by index
List<Color> getSubforumAccentColors(int index) {
  return subforumAccentColors[index % subforumAccentColors.length];
}

class SubforumListItem extends StatelessWidget {
  final Subforum subforum;
  final int index;
  final VoidCallback onTap;
  final VoidCallback? onLastPostTap;

  const SubforumListItem({
    super.key,
    required this.subforum,
    required this.index,
    required this.onTap,
    this.onLastPostTap,
  });

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}m';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }

  Widget _buildIcon() {
    return Positioned(
      right: 12,
      top: 0,
      bottom: 0,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: CachedNetworkImage(
            imageUrl: subforum.icon,
            height: 40,
            fit: BoxFit.contain,
            errorWidget: (context, url, error) =>
                const SizedBox(width: 40, height: 40),
          ),
        ),
      ),
    );
  }

  Widget _buildNameAndStats(BuildContext context) {
    final theme = Theme.of(context);

    return Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 60, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              subforum.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.forum_outlined,
                  size: 12,
                  color: theme.textTheme.bodySmall?.color,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatCount(subforum.totalThreads),
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                ),
                const SizedBox(width: 12),
                Opacity(
                  opacity: 0.5,
                  child: Row(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 12,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatCount(subforum.totalPosts),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccentLine(List<Color> colors) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: 2,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
      ),
    );
  }

  Widget _buildTopSection(
    BuildContext context,
    Color bgColor,
    List<Color> accentColors,
  ) {
    return Expanded(
      child: Material(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        child: InkWell(
          onTap: onTap,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          child: Stack(
            children: [
              _buildIcon(),
              _buildNameAndStats(context),
              _buildAccentLine(accentColors),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimeAgo(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return timeago.format(date, locale: 'en_short');
    } catch (e) {
      return '';
    }
  }

  Widget _buildBottomSection(BuildContext context, Color bgColor) {
    final theme = Theme.of(context);
    final lastPost = subforum.lastPost;
    final threadInfo = lastPost?.threadInfo;

    return Material(
      color: bgColor,
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
      child: InkWell(
        onTap: onLastPostTap,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: lastPost != null
              ? Row(
                  children: [
                    // User avatar
                    CircleAvatar(
                      radius: 12,
                      backgroundImage:
                          lastPost.user.avatarUrl.isNotEmpty &&
                              lastPost.user.avatarUrl != 'none.webp'
                          ? CachedNetworkImageProvider(
                              'https://cdn.knockout.chat/image/${lastPost.user.avatarUrl}',
                            )
                          : null,
                      child:
                          lastPost.user.avatarUrl.isEmpty ||
                              lastPost.user.avatarUrl == 'none.webp'
                          ? const Icon(Icons.person, size: 14)
                          : null,
                    ),
                    const SizedBox(width: 8),
                    // Last post info with thread title
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (threadInfo != null)
                            Text(
                              threadInfo.title,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'by ',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 11,
                                    color: theme.textTheme.bodySmall?.color
                                        ?.withValues(alpha: 0.7),
                                  ),
                                ),
                                TextSpan(
                                  text: lastPost.user.username,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 11,
                                    color: getRoleColor(
                                      lastPost.user.role.code,
                                      brightness: theme.brightness,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Time ago
                    Text(
                      _formatTimeAgo(lastPost.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: theme.textTheme.bodySmall?.color?.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ],
                )
              : Text(
                  subforum.description,
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accentColors = getSubforumAccentColors(index);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final topBgColor = isDark
        ? const Color(0xFF1F2C39)
        : const Color(0xFFE6E6E6);
    final bottomBgColor = isDark
        ? const Color(0xFF161D24)
        : const Color(0xFFF2F3F5);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 112,
            child: Column(
              children: [
                _buildTopSection(context, topBgColor, accentColors),
                _buildBottomSection(context, bottomBgColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

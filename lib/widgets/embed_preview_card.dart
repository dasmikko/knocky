import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/oembed_service.dart';

/// Provider-specific styling configuration
class _ProviderConfig {
  final String label;
  final IconData icon;
  final Color color;

  const _ProviderConfig({
    required this.label,
    required this.icon,
    required this.color,
  });
}

const _providerConfigs = {
  'youtube': _ProviderConfig(
    label: 'YouTube',
    icon: FontAwesomeIcons.youtube,
    color: Colors.red,
  ),
  'vimeo': _ProviderConfig(
    label: 'Vimeo',
    icon: FontAwesomeIcons.vimeo,
    color: Color(0xFF1AB7EA),
  ),
  'streamable': _ProviderConfig(
    label: 'Streamable',
    icon: Icons.stream,
    color: Color(0xFF0F90FA),
  ),
  'vocaroo': _ProviderConfig(
    label: 'Vocaroo',
    icon: Icons.mic,
    color: Color(0xFF4CAF50),
  ),
  'spotify': _ProviderConfig(
    label: 'Spotify',
    icon: Icons.music_note,
    color: Color(0xFF1DB954),
  ),
  'soundcloud': _ProviderConfig(
    label: 'SoundCloud',
    icon: FontAwesomeIcons.soundcloud,
    color: Color(0xFFFF5500),
  ),
  'twitter': _ProviderConfig(
    label: 'Twitter',
    icon: FontAwesomeIcons.twitter,
    color: Color(0xFF1DA1F2),
  ),
  'reddit': _ProviderConfig(
    label: 'Reddit',
    icon: FontAwesomeIcons.reddit,
    color: Colors.deepOrange,
  ),
  'twitch': _ProviderConfig(
    label: 'Twitch',
    icon: FontAwesomeIcons.twitch,
    color: Color(0xFF9146FF),
  ),
  'bluesky': _ProviderConfig(
    label: 'Bluesky',
    icon: FontAwesomeIcons.bluesky,
    color: Color(0xFF0085FF),
  ),
  'instagram': _ProviderConfig(
    label: 'Instagram',
    icon: FontAwesomeIcons.instagram,
    color: Color(0xFFE1306C),
  ),
  'tiktok': _ProviderConfig(
    label: 'TikTok',
    icon: FontAwesomeIcons.tiktok,
    color: Color(0xFF010101),
  ),
  'tumblr': _ProviderConfig(
    label: 'Tumblr',
    icon: FontAwesomeIcons.tumblr,
    color: Color(0xFF36465D),
  ),
  'mastodon': _ProviderConfig(
    label: 'Mastodon',
    icon: FontAwesomeIcons.mastodon,
    color: Color(0xFF6364FF),
  ),
};

/// A preview card for embedded content (YouTube, Twitter, Reddit, etc.)
/// Uses a fixed height to prevent layout shifts while loading.
class EmbedPreviewCard extends StatefulWidget {
  final String url;
  final String provider;

  const EmbedPreviewCard({
    super.key,
    required this.url,
    required this.provider,
  });

  @override
  State<EmbedPreviewCard> createState() => _EmbedPreviewCardState();
}

class _EmbedPreviewCardState extends State<EmbedPreviewCard> {
  final _oembedService = OEmbedService();
  EmbedMetadata? _metadata;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    // Check cache synchronously to avoid loading flicker on revisit
    final cached = _oembedService.getCached(widget.url);
    if (cached != null) {
      _metadata = cached;
      _isLoading = false;
    } else {
      _fetchMetadata();
    }
  }

  Future<void> _fetchMetadata() async {
    final metadata = await _oembedService.fetchMetadata(
      widget.url.trim(),
      widget.provider,
    );

    if (mounted) {
      setState(() {
        _metadata = metadata;
        _isLoading = false;
        _hasError = metadata == null;
      });
    }
  }

  Future<void> _launchUrl() async {
    final uri = Uri.tryParse(widget.url.trim());
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _providerConfigs[widget.provider] ??
        const _ProviderConfig(
          label: 'Link',
          icon: Icons.link,
          color: Colors.grey,
        );

    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 1, right: 1),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _launchUrl,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 100, // Fixed height to prevent layout shifts
              decoration: BoxDecoration(
                border: Border.all(
                  color: config.color.withValues(alpha: 0.3),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: _isLoading
                  ? _buildLoadingState(config)
                  : _hasError
                      ? _buildErrorState(config)
                      : _buildContent(config),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(_ProviderConfig config) {
    return Row(
      children: [
        // Thumbnail placeholder
        Container(
          width: 100,
          decoration: BoxDecoration(
            color: config.color.withValues(alpha: 0.1),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(11),
              bottomLeft: Radius.circular(11),
            ),
          ),
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(config.color),
              ),
            ),
          ),
        ),
        // Content placeholder
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProviderBadge(config),
                const SizedBox(height: 8),
                Container(
                  height: 14,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 14,
                  width: 150,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(_ProviderConfig config) {
    // Fallback to simple link display
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(config.icon, color: config.color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildProviderBadge(config),
                const SizedBox(height: 4),
                Text(
                  widget.url,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(
            Icons.open_in_new,
            size: 18,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(_ProviderConfig config) {
    final metadata = _metadata!;
    final hasThumbnail = metadata.thumbnailUrl != null;

    return Row(
      children: [
        // Thumbnail
        if (hasThumbnail)
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(11),
              bottomLeft: Radius.circular(11),
            ),
            child: SizedBox(
              width: 100,
              child: CachedNetworkImage(
                imageUrl: metadata.thumbnailUrl!,
                fit: BoxFit.cover,
                height: double.infinity,
                errorWidget: (context, url, error) => Container(
                  color: config.color.withValues(alpha: 0.1),
                  child: Icon(config.icon, color: config.color, size: 32),
                ),
              ),
            ),
          )
        else
          Container(
            width: 60,
            decoration: BoxDecoration(
              color: config.color.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(11),
                bottomLeft: Radius.circular(11),
              ),
            ),
            child: Center(
              child: Icon(config.icon, color: config.color, size: 28),
            ),
          ),
        // Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProviderBadge(config),
                const SizedBox(height: 4),
                if (metadata.title != null || metadata.description != null)
                  Expanded(
                    child: Text(
                      metadata.title ?? metadata.description ?? '',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if (metadata.authorName != null) ...[
                  const Spacer(),
                  Text(
                    metadata.authorName!,
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
        // Open icon
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Icon(
            Icons.open_in_new,
            size: 18,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildProviderBadge(_ProviderConfig config) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(config.icon, size: 14, color: config.color),
        const SizedBox(width: 4),
        Text(
          config.label,
          style: TextStyle(
            color: config.color,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
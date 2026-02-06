import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Base class for toolbar items
sealed class ToolbarItem {
  const ToolbarItem();
}

/// A separator between toolbar button groups
class ToolbarSeparator extends ToolbarItem {
  const ToolbarSeparator();
}

/// Configuration for an inline tag (wraps selected text)
class InlineTagConfig extends ToolbarItem {
  final String id;
  final IconData icon;
  final String tooltip;
  final String openTag;
  final String closeTag;
  final String? placeholder;

  const InlineTagConfig({
    required this.id,
    required this.icon,
    required this.tooltip,
    required this.openTag,
    required this.closeTag,
    this.placeholder,
  });
}

/// Configuration for a tag that requires a dialog to get additional input
class DialogTagConfig extends ToolbarItem {
  final String id;
  final IconData icon;
  final String tooltip;
  final DialogType dialogType;

  const DialogTagConfig({
    required this.id,
    required this.icon,
    required this.tooltip,
    required this.dialogType,
  });
}

/// Types of dialogs that can be shown
enum DialogType {
  url,
  image,
  video,
  youtube,
  vimeo,
  streamable,
  vocaroo,
  spotify,
  soundcloud,
  twitter,
  reddit,
  twitch,
  bluesky,
  instagram,
  tiktok,
  tumblr,
  mastodon,
  quote,
  emote,
}

/// Default toolbar configuration matching BbcodeRenderer supported tags
class BbcodeToolbarConfig {
  final List<ToolbarItem> items;

  const BbcodeToolbarConfig({this.items = defaultToolbarItems});

  static const List<ToolbarItem> defaultToolbarItems = [
    // Text formatting
    InlineTagConfig(
      id: 'bold',
      icon: Icons.format_bold,
      tooltip: 'Bold',
      openTag: '[b]',
      closeTag: '[/b]',
      placeholder: 'bold text',
    ),
    InlineTagConfig(
      id: 'italic',
      icon: Icons.format_italic,
      tooltip: 'Italic',
      openTag: '[i]',
      closeTag: '[/i]',
      placeholder: 'italic text',
    ),
    InlineTagConfig(
      id: 'underline',
      icon: Icons.format_underlined,
      tooltip: 'Underline',
      openTag: '[u]',
      closeTag: '[/u]',
      placeholder: 'underlined text',
    ),
    InlineTagConfig(
      id: 'strikethrough',
      icon: Icons.strikethrough_s,
      tooltip: 'Strikethrough',
      openTag: '[s]',
      closeTag: '[/s]',
      placeholder: 'strikethrough text',
    ),
    DialogTagConfig(
      id: 'emote',
      icon: Icons.emoji_emotions,
      tooltip: 'Insert Emote',
      dialogType: DialogType.emote,
    ),
    ToolbarSeparator(),

    // Headings & structure
    InlineTagConfig(
      id: 'h1',
      icon: Icons.looks_one,
      tooltip: 'Heading 1',
      openTag: '[h1]',
      closeTag: '[/h1]',
      placeholder: 'heading',
    ),
    InlineTagConfig(
      id: 'h2',
      icon: Icons.looks_two,
      tooltip: 'Heading 2',
      openTag: '[h2]',
      closeTag: '[/h2]',
      placeholder: 'heading',
    ),
    InlineTagConfig(
      id: 'code',
      icon: Icons.code,
      tooltip: 'Code',
      openTag: '[code]',
      closeTag: '[/code]',
      placeholder: 'code',
    ),
    InlineTagConfig(
      id: 'noparse',
      icon: Icons.code_off,
      tooltip: 'No Parse',
      openTag: '[noparse]',
      closeTag: '[/noparse]',
      placeholder: 'raw text',
    ),
    ToolbarSeparator(),

    ToolbarSeparator(),

    // Block elements
    DialogTagConfig(
      id: 'quote',
      icon: Icons.format_quote,
      tooltip: 'Quote',
      dialogType: DialogType.quote,
    ),
    InlineTagConfig(
      id: 'blockquote',
      icon: Icons.format_indent_increase,
      tooltip: 'Block Quote',
      openTag: '[blockquote]',
      closeTag: '[/blockquote]',
      placeholder: 'quoted text',
    ),
    InlineTagConfig(
      id: 'spoiler',
      icon: Icons.visibility_off,
      tooltip: 'Spoiler',
      openTag: '[spoiler]',
      closeTag: '[/spoiler]',
      placeholder: 'spoiler content',
    ),
    InlineTagConfig(
      id: 'collapse',
      icon: Icons.expand_more,
      tooltip: 'Collapse',
      openTag: '[collapse title="Title"]',
      closeTag: '[/collapse]',
      placeholder: 'collapsible content',
    ),

    // Links & media
    DialogTagConfig(
      id: 'url',
      icon: Icons.link,
      tooltip: 'Insert Link',
      dialogType: DialogType.url,
    ),
    DialogTagConfig(
      id: 'image',
      icon: Icons.image,
      tooltip: 'Insert Image',
      dialogType: DialogType.image,
    ),
    DialogTagConfig(
      id: 'video',
      icon: Icons.videocam,
      tooltip: 'Insert Video',
      dialogType: DialogType.video,
    ),
    ToolbarSeparator(),

    // Video embeds
    DialogTagConfig(
      id: 'youtube',
      icon: FontAwesomeIcons.youtube,
      tooltip: 'YouTube',
      dialogType: DialogType.youtube,
    ),
    DialogTagConfig(
      id: 'vimeo',
      icon: FontAwesomeIcons.vimeo,
      tooltip: 'Vimeo',
      dialogType: DialogType.vimeo,
    ),
    DialogTagConfig(
      id: 'streamable',
      icon: Icons.stream,
      tooltip: 'Streamable',
      dialogType: DialogType.streamable,
    ),
    ToolbarSeparator(),

    // Audio embeds
    DialogTagConfig(
      id: 'vocaroo',
      icon: Icons.mic,
      tooltip: 'Vocaroo',
      dialogType: DialogType.vocaroo,
    ),
    DialogTagConfig(
      id: 'spotify',
      icon: Icons.music_note,
      tooltip: 'Spotify',
      dialogType: DialogType.spotify,
    ),
    DialogTagConfig(
      id: 'soundcloud',
      icon: FontAwesomeIcons.soundcloud,
      tooltip: 'SoundCloud',
      dialogType: DialogType.soundcloud,
    ),
    ToolbarSeparator(),

    // Social embeds
    DialogTagConfig(
      id: 'twitter',
      icon: FontAwesomeIcons.twitter,
      tooltip: 'Twitter/X',
      dialogType: DialogType.twitter,
    ),
    DialogTagConfig(
      id: 'reddit',
      icon: FontAwesomeIcons.reddit,
      tooltip: 'Reddit',
      dialogType: DialogType.reddit,
    ),
    DialogTagConfig(
      id: 'twitch',
      icon: FontAwesomeIcons.twitch,
      tooltip: 'Twitch',
      dialogType: DialogType.twitch,
    ),
    DialogTagConfig(
      id: 'bluesky',
      icon: FontAwesomeIcons.bluesky,
      tooltip: 'Bluesky',
      dialogType: DialogType.bluesky,
    ),
    DialogTagConfig(
      id: 'instagram',
      icon: FontAwesomeIcons.instagram,
      tooltip: 'Instagram',
      dialogType: DialogType.instagram,
    ),
    DialogTagConfig(
      id: 'tiktok',
      icon: FontAwesomeIcons.tiktok,
      tooltip: 'TikTok',
      dialogType: DialogType.tiktok,
    ),
    DialogTagConfig(
      id: 'tumblr',
      icon: FontAwesomeIcons.tumblr,
      tooltip: 'Tumblr',
      dialogType: DialogType.tumblr,
    ),
    DialogTagConfig(
      id: 'mastodon',
      icon: FontAwesomeIcons.mastodon,
      tooltip: 'Mastodon',
      dialogType: DialogType.mastodon,
    ),
  ];
}

import 'package:flutter/material.dart';

import 'bbcode_text_controller.dart';
import 'bbcode_toolbar_config.dart';
import 'dialogs/emote_picker_dialog.dart';
import 'dialogs/media_dialog.dart';
import 'dialogs/quote_dialog.dart';
import 'dialogs/url_dialog.dart';

/// Horizontal scrollable toolbar for BBCode formatting
class BbcodeToolbar extends StatelessWidget {
  final BbcodeTextController controller;
  final BbcodeToolbarConfig config;

  const BbcodeToolbar({
    super.key,
    required this.controller,
    this.config = const BbcodeToolbarConfig(),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: config.items.map((item) => _buildItem(context, item)).toList(),
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, ToolbarItem item) {
    return switch (item) {
      ToolbarSeparator() => const SizedBox(
          height: 24,
          child: VerticalDivider(width: 16),
        ),
      InlineTagConfig() => _buildInlineTagButton(context, item),
      DialogTagConfig() => _buildDialogTagButton(context, item),
    };
  }

  Widget _buildInlineTagButton(BuildContext context, InlineTagConfig config) {
    return IconButton(
      icon: Icon(config.icon),
      tooltip: config.tooltip,
      onPressed: () {
        controller.wrapSelection(
          config.openTag,
          config.closeTag,
          placeholder: config.placeholder,
        );
      },
    );
  }

  Widget _buildDialogTagButton(BuildContext context, DialogTagConfig config) {
    return IconButton(
      icon: Icon(config.icon),
      tooltip: config.tooltip,
      onPressed: () => _handleDialogTag(context, config),
    );
  }

  Future<void> _handleDialogTag(BuildContext context, DialogTagConfig config) async {
    // Get current selection to use as initial text for some dialogs
    final selection = controller.selection;
    String? selectedText;
    if (selection.isValid && selection.start != selection.end) {
      selectedText = controller.text.substring(selection.start, selection.end);
    }

    switch (config.dialogType) {
      case DialogType.url:
        final result = await showUrlDialog(context, initialText: selectedText);
        if (result != null) {
          controller.insertUrl(result.url, linkText: result.linkText);
        }

      case DialogType.image:
        final result = await showMediaDialog(context, MediaType.image);
        if (result != null) {
          controller.insertImage(result.url, thumbnail: result.thumbnail);
        }

      case DialogType.video:
        final result = await showMediaDialog(context, MediaType.video);
        if (result != null) {
          controller.insertVideo(result.url);
        }

      case DialogType.youtube:
        final result = await showMediaDialog(context, MediaType.youtube);
        if (result != null) {
          controller.insertEmbed('youtube', result.url);
        }

      case DialogType.vimeo:
        final result = await showMediaDialog(context, MediaType.vimeo);
        if (result != null) {
          controller.insertEmbed('vimeo', result.url);
        }

      case DialogType.streamable:
        final result = await showMediaDialog(context, MediaType.streamable);
        if (result != null) {
          controller.insertEmbed('streamable', result.url);
        }

      case DialogType.vocaroo:
        final result = await showMediaDialog(context, MediaType.vocaroo);
        if (result != null) {
          controller.insertEmbed('vocaroo', result.url);
        }

      case DialogType.spotify:
        final result = await showMediaDialog(context, MediaType.spotify);
        if (result != null) {
          controller.insertEmbed('spotify', result.url);
        }

      case DialogType.soundcloud:
        final result = await showMediaDialog(context, MediaType.soundcloud);
        if (result != null) {
          controller.insertEmbed('soundcloud', result.url);
        }

      case DialogType.twitter:
        final result = await showMediaDialog(context, MediaType.twitter);
        if (result != null) {
          controller.insertEmbed('twitter', result.url);
        }

      case DialogType.reddit:
        final result = await showMediaDialog(context, MediaType.reddit);
        if (result != null) {
          controller.insertEmbed('reddit', result.url);
        }

      case DialogType.twitch:
        final result = await showMediaDialog(context, MediaType.twitch);
        if (result != null) {
          controller.insertEmbed('twitch', result.url);
        }

      case DialogType.bluesky:
        final result = await showMediaDialog(context, MediaType.bluesky);
        if (result != null) {
          controller.insertEmbed('bluesky', result.url);
        }

      case DialogType.instagram:
        final result = await showMediaDialog(context, MediaType.instagram);
        if (result != null) {
          controller.insertEmbed('instagram', result.url);
        }

      case DialogType.tiktok:
        final result = await showMediaDialog(context, MediaType.tiktok);
        if (result != null) {
          controller.insertEmbed('tiktok', result.url);
        }

      case DialogType.tumblr:
        final result = await showMediaDialog(context, MediaType.tumblr);
        if (result != null) {
          controller.insertEmbed('tumblr', result.url);
        }

      case DialogType.mastodon:
        final result = await showMediaDialog(context, MediaType.mastodon);
        if (result != null) {
          controller.insertEmbed('mastodon', result.url);
        }

      case DialogType.quote:
        final result = await showQuoteDialog(context, initialContent: selectedText);
        if (result != null) {
          controller.insertQuote(result.content, username: result.username);
        }

      case DialogType.emote:
        final emote = await showEmotePickerDialog(context);
        if (emote != null) {
          controller.insertTag(':${emote.code}:');
        }
    }
  }
}

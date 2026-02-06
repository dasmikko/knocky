import 'package:flutter/material.dart';

/// Controller for BBCode editor that handles text manipulation and selection
class BbcodeTextController extends TextEditingController {
  BbcodeTextController({super.text});

  /// Returns the current BBCode content
  String get bbcode => text;

  /// Wraps the current selection with opening and closing tags.
  /// If no text is selected, inserts the tags with an optional placeholder.
  void wrapSelection(String openTag, String closeTag, {String? placeholder}) {
    final selection = this.selection;
    final currentText = text;

    if (!selection.isValid) {
      // No valid selection, insert at end
      text = '$currentText$openTag${placeholder ?? ''}$closeTag';
      return;
    }

    final start = selection.start;
    final end = selection.end;
    final selectedText = selection.textInside(currentText);

    if (selectedText.isEmpty && placeholder != null) {
      // No selection - insert tags with placeholder
      final newText =
          currentText.substring(0, start) +
          openTag +
          placeholder +
          closeTag +
          currentText.substring(end);
      text = newText;

      // Select the placeholder text
      this.selection = TextSelection(
        baseOffset: start + openTag.length,
        extentOffset: start + openTag.length + placeholder.length,
      );
    } else {
      // Wrap selected text
      final newText =
          currentText.substring(0, start) +
          openTag +
          selectedText +
          closeTag +
          currentText.substring(end);
      text = newText;

      // Move cursor to end of wrapped text
      this.selection = TextSelection.collapsed(
        offset: start + openTag.length + selectedText.length + closeTag.length,
      );
    }
  }

  /// Inserts a complete tag (like [img]url[/img]) at the current cursor position
  void insertTag(String fullTag) {
    final selection = this.selection;
    final currentText = text;

    if (!selection.isValid) {
      // No valid selection, insert at end
      text = '$currentText$fullTag';
      this.selection = TextSelection.collapsed(offset: text.length);
      return;
    }

    final start = selection.start;
    final end = selection.end;

    final newText =
        currentText.substring(0, start) + fullTag + currentText.substring(end);
    text = newText;

    // Move cursor to end of inserted tag
    this.selection = TextSelection.collapsed(offset: start + fullTag.length);
  }

  /// Inserts a URL tag, optionally with link text
  void insertUrl(String url, {String? linkText}) {
    if (linkText != null && linkText.isNotEmpty && linkText != url) {
      insertTag('[url href="$url"]$linkText[/url]');
    } else {
      insertTag('[url href="$url"][/url]');
    }
  }

  /// Inserts an image tag
  void insertImage(String url, {bool thumbnail = false}) {
    final tag = thumbnail ? '[img thumbnail]' : '[img]';
    insertTag('$tag$url[/img]');
  }

  /// Inserts a video tag
  void insertVideo(String url) {
    insertTag('[video]$url[/video]');
  }

  /// Inserts a quote tag with optional username and post metadata
  void insertQuote(
    String content, {
    String? username,
    int? mentionsUser,
    int? postId,
    int? threadPage,
    int? threadId,
  }) {
    final attrs = <String>[];
    if (mentionsUser != null) attrs.add('mentionsUser="$mentionsUser"');
    if (postId != null) attrs.add('postId="$postId"');
    if (threadPage != null) attrs.add('threadPage="$threadPage"');
    if (threadId != null) attrs.add('threadId="$threadId"');
    if (username != null && username.isNotEmpty)
      attrs.add('username="$username"');

    if (attrs.isNotEmpty) {
      insertTag('[quote ${attrs.join(' ')}]$content[/quote]\n\n');
    } else {
      insertTag('[quote]$content[/quote]\n\n');
    }
  }

  /// Inserts an embed tag (youtube, twitter, reddit, etc.)
  void insertEmbed(String tagName, String url) {
    insertTag('[$tagName]$url[/$tagName]');
  }

  /// Clears all content
  void clearContent() {
    text = '';
    selection = const TextSelection.collapsed(offset: 0);
  }
}

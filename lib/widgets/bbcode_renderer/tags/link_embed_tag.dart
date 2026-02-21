import 'package:bbob_dart/bbob_dart.dart' as bbob;
import 'package:flutter/material.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';

import 'embed_preview_card.dart';

/// [youtube]url[/youtube], [twitter]url[/twitter], etc. — embed preview card.
/// Factory-constructed for each link provider.
class LinkEmbedTag extends AdvancedTag {
  final String provider;

  LinkEmbedTag({required String tag, required this.provider}) : super(tag);

  @override
  List<InlineSpan> parse(FlutterRenderer renderer, bbob.Element element) {
    if (element.children.isEmpty) return [];

    final url = element.children.first.textContent.trim();

    return [
      WidgetSpan(child: EmbedPreviewCard(url: url, provider: provider)),
    ];
  }
}

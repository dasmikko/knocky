import 'package:bbob_dart/bbob_dart.dart' as bbob;
import 'package:flutter/material.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';

/// [video]url[/video] — play button link to video player.
class KnockoutVideoTag extends AdvancedTag {
  final void Function(String url)? onTap;

  KnockoutVideoTag({this.onTap}) : super('video');

  @override
  List<InlineSpan> parse(FlutterRenderer renderer, bbob.Element element) {
    if (element.children.isEmpty) {
      return [TextSpan(text: '[video]', style: renderer.getCurrentStyle())];
    }

    final url = element.children.first.textContent.trim();
    final filename =
        Uri.tryParse(url)?.pathSegments.lastOrNull ?? 'Video';

    return [
      WidgetSpan(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GestureDetector(
            onTap: onTap != null ? () => onTap!(url) : null,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                border:
                    Border.all(color: Colors.purple.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.play_circle_outline,
                      size: 18, color: Colors.purple),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      filename,
                      style:
                          const TextStyle(color: Colors.purple, fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ];
  }
}

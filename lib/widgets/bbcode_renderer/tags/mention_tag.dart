import 'package:bbob_dart/bbob_dart.dart' as bbob;
import 'package:flutter/material.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';

import '../../../data/role_colors.dart';

/// [mention=userId][/mention] — colored mention chip with tap-to-navigate.
class MentionTag extends AdvancedTag {
  final Map<int, Map<String, dynamic>> mentionUserMap;
  final Brightness brightness;
  final void Function(int userId)? onTap;

  MentionTag({
    required this.mentionUserMap,
    required this.brightness,
    this.onTap,
  }) : super('mention');

  @override
  List<InlineSpan> parse(FlutterRenderer renderer, bbob.Element element) {
    final userIdStr = element.attributes.isNotEmpty
        ? element.attributes.keys.first
        : null;
    final userId = userIdStr != null ? int.tryParse(userIdStr) : null;
    final user = userId != null ? mentionUserMap[userId] : null;

    if (user == null) {
      return [
        TextSpan(text: '@unknown', style: renderer.getCurrentStyle()),
      ];
    }

    final username = user['username'] as String? ?? 'Unknown';
    final roleCode =
        (user['role'] as Map<String, dynamic>?)?['code'] as String?;
    final color = getRoleColor(roleCode, brightness: brightness);

    return [
      WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: GestureDetector(
          onTap: onTap != null && userId != null ? () => onTap!(userId) : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              '@$username',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
      ),
    ];
  }
}

import 'package:bbob_dart/bbob_dart.dart' as bbob;
import 'package:flutter/material.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:knocky/widgets/bbcode_renderer/stylesheet.dart';

/// [icode]...[/icode] — inline monospace code with border/padding.
class InlineCodeTag extends AdvancedTag {
  final bool isDark;

  InlineCodeTag({required this.isDark}) : super('icode');

  @override
  List<InlineSpan> parse(FlutterRenderer renderer, bbob.Element element) {
    final text = element.children.isNotEmpty
        ? element.children.map((c) => c.textContent).join()
        : '';

    final bgColor = isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF5F5F5);
    final borderColor =
        isDark ? const Color(0xFF2D2D44) : const Color(0xFFE0E0E0);
    final textColor =
        isDark ? const Color(0xFFE0E0E0) : const Color(0xFF333333);

    return [
      WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Text(
            text,
            style: GoogleFonts.sourceCodePro(
              fontSize: bbcodeFontSize-2,
              color: textColor,
            ),
          ),
        ),
      ),
    ];
  }
}

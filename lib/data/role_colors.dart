import 'package:flutter/material.dart';

/// Returns the color for a username based on their role code.
///
/// Role codes:
/// - banned-user: Red
/// - limited-user, basic-user: Blue
/// - gold-user, paid-gold-user: Gold
/// - moderator: Green
/// - moderator-in-training: Light green
/// - admin: Gold
/// - orange-user: Orange
Color getRoleColor(String? roleCode, {Brightness brightness = Brightness.dark}) {
  final isLight = brightness == Brightness.light;

  switch (roleCode) {
    case 'banned-user':
      return const Color(0xFFE04545);
    case 'limited-user':
    case 'basic-user':
      return isLight ? const Color(0xFF3B9AE3) : const Color(0xFF3FACFF);
    case 'gold-user':
    case 'paid-gold-user':
    case 'admin':
      return const Color(0xFFFCBE20); // Gold - gradient fallback
    case 'moderator':
      return isLight ? const Color(0xFF12AB1A) : const Color(0xFF41FF74);
    case 'moderator-in-training':
      return isLight ? const Color(0xFF30B655) : const Color(0xFF4CCF6F);
    case 'orange-user':
      return const Color(0xFFF07C00);
    default:
      return isLight ? const Color(0xFF3B9AE3) : const Color(0xFF3FACFF);
  }
}

/// Returns whether the role should have a gold gradient effect.
bool hasGoldGradient(String? roleCode) {
  return roleCode == 'gold-user' ||
         roleCode == 'paid-gold-user' ||
         roleCode == 'admin';
}

/// Gold gradient colors for special users.
const goldGradientColors = [
  Color(0xFFFCBE20),
  Color(0xFFFCBE20),
  Color(0xFFFFE770),
  Color(0xFFFCBE20),
  Color(0xFFFCBE20),
];

/// Creates a gold gradient shader for text.
Shader createGoldGradientShader(Rect bounds) {
  return const LinearGradient(
    colors: goldGradientColors,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ).createShader(bounds);
}

/// A widget that displays a username with role-based coloring.
class RoleColoredUsername extends StatelessWidget {
  final String username;
  final String? roleCode;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;

  const RoleColoredUsername({
    super.key,
    required this.username,
    this.roleCode,
    this.style,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final baseStyle = style ?? const TextStyle();
    final color = getRoleColor(roleCode, brightness: brightness);

    if (hasGoldGradient(roleCode)) {
      return ShaderMask(
        shaderCallback: createGoldGradientShader,
        child: Text(
          username,
          style: baseStyle.copyWith(color: Colors.white),
          maxLines: maxLines,
          overflow: overflow,
        ),
      );
    }

    return Text(
      username,
      style: baseStyle.copyWith(color: color),
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

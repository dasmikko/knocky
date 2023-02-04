import 'package:flutter/material.dart';
import 'package:knocky/models/v2/userRole.dart';
import 'package:knocky/models/usergroup.dart';

class AppColors {
  BuildContext? context;
  Brightness? currentBrightness;

  AppColors(BuildContext? context) {
    this.context = context;
    this.currentBrightness = Theme.of(this.context!).brightness;
  }

  Color switchColor() {
    return this.currentBrightness == Brightness.dark ? Colors.red : Colors.red;
  }

  Color userQuoteBodyBackground() {
    return this.currentBrightness == Brightness.dark
        ? HexColor('2d2d30')
        : HexColor('e6e6e6');
  }

  Color userQuoteHeaderBackground() {
    return this.currentBrightness == Brightness.dark
        ? HexColor('28282c')
        : HexColor('ebedef');
  }

  Color ratingsListUserHeader() {
    return this.currentBrightness == Brightness.dark
        ? HexColor('28282c')
        : HexColor('ebedef');
  }

  Color twitterEmbedBackground() {
    return this.currentBrightness == Brightness.dark
        ? HexColor('000000')
        : HexColor('ffffff');
  }

  Color twitterEmbedText() {
    return this.currentBrightness == Brightness.dark
        ? HexColor('ffffff')
        : HexColor('000000');
  }

  Color unreadPostsColor() {
    return Color.fromRGBO(255, 201, 63, 1);
  }

  Color bannedColor() {
    return HexColor('e04545');
  }

  Color userGroupToColor(Usergroup usergroup, {bool banned = false}) {
    if (banned) {
      return bannedColor();
    }
    switch (usergroup) {
      case Usergroup.regular:
        return HexColor('3facff');
      case Usergroup.gold:
        return HexColor('fcbe20');
      case Usergroup.moderator:
        return HexColor('08f760');
      case Usergroup.admin:
        return HexColor('c448ff');
      case Usergroup.staff:
        return HexColor('ff6cb4');
      default:
        return HexColor('3facff');
    }
  }

  Color userRoleToColor(RoleCode? userRoleCode, {bool banned = false}) {
    if (banned) {
      return bannedColor();
    }

    switch (userRoleCode) {
      case RoleCode.LIMITED_USER:
        return HexColor('3facff');
      case RoleCode.GOLD_USER:
      case RoleCode.PAID_GOLD_USER:
        return HexColor('fcbe20');
      case RoleCode.MODERATOR:
      case RoleCode.MODERATOR_IN_TRAINING:
      case RoleCode.SUPER_MODERATOR:
        return HexColor('08f760');
      case RoleCode.ADMIN:
        return HexColor('fcbe20');
      default:
        return HexColor('3facff');
    }
  }

  Color darken(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  Color lighten(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

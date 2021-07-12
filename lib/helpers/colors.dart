import 'package:flutter/material.dart';
import 'package:knocky/models/usergroup.dart';

class AppColors {
  BuildContext context;
  Brightness currentBrightness;

  AppColors(BuildContext context) {
    this.context = context;
    this.currentBrightness = Theme.of(this.context).brightness;
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

  Color userGroupToColor(Usergroup usergroup) {
    switch (usergroup) {
      case Usergroup.banned:
        return HexColor('e04545');
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

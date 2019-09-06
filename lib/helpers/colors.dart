import 'package:flutter/material.dart';
import 'package:dynamic_theme/dynamic_theme.dart';

class AppColors {
  BuildContext context;
  Brightness currentBrightness;

  AppColors(BuildContext context) {
    this.context = context;
    this.currentBrightness = DynamicTheme.of(this.context).brightness;
  }

  Color switchColor() {
    return this.currentBrightness == Brightness.dark
        ? Colors.red
        : Colors.red;
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

  Color normalUserColor () {
    return HexColor('3facff');
  }

  Color modUserColor () {
    return HexColor('08f760');
  }

  Color goldUserColor () {
    return HexColor('ffb100');
  }

  Color adminUserColor () {
    return HexColor('c448ff');
  }

  Color devUserColor () {
    return HexColor('ff6cb4');
  }

  Color userGroupToColor (int usergroup) {
    switch (usergroup) {
      case 1:
        return normalUserColor();
      case 2:
        return goldUserColor();
      case 3:
        return modUserColor();
      case 4:
        return adminUserColor();
      case 5:
        return devUserColor();
      default:
        return normalUserColor();
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

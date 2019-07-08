import 'package:flutter/material.dart';
import 'package:knocky/helpers/colors.dart';

ThemeData DarkTheme() {
  Color userQuoteBody = HexColor('#2d2d30');

  return ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.red,
    scaffoldBackgroundColor: HexColor('#111015'),
    cardColor: HexColor('#222226')
  );
}
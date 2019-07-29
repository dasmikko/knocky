import 'package:flutter/material.dart';
import 'package:knocky/helpers/colors.dart';

ThemeData DarkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.red,
    accentColor: Colors.red,
    scaffoldBackgroundColor: HexColor('#111015'),
    cardColor: HexColor('#222226'),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
    ),
  );
}
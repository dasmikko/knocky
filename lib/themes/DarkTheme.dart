import 'package:flutter/material.dart';
import 'package:knocky/helpers/colors.dart';

ThemeData darkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    appBarTheme: AppBarTheme(
      color: Colors.grey[900],
    ),
    textTheme: TextTheme(),
    bottomAppBarTheme: BottomAppBarTheme(
      color: Colors.grey[900],
    ),
    primarySwatch: Colors.red,
    accentColor: Colors.red,
    scaffoldBackgroundColor: HexColor('#141414'),
    cardColor: Color.fromRGBO(45, 45, 45, 1),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
    ),
  );
}

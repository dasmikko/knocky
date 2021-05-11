import 'package:flutter/material.dart';
import 'package:knocky/helpers/colors.dart';

Color primary = Color.fromRGBO(31, 44, 57, 1);
Color primaryDark = Color.fromRGBO(22, 29, 36, 1);

ThemeData darkTheme() {
  return ThemeData(
    backgroundColor: Color.fromRGBO(13, 16, 19, 1),
    cardTheme: CardTheme(color: primaryDark, clipBehavior: Clip.antiAlias),
    primaryColor: primary,
    primaryColorDark: primaryDark,
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

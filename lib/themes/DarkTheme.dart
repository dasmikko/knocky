import 'package:flutter/material.dart';
import 'package:knocky_edge/helpers/colors.dart';

ThemeData darkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    appBarTheme: AppBarTheme(
      color: Colors.grey[900],
    ),
    bottomAppBarTheme: BottomAppBarTheme(
      color: Colors.grey[900],
    ),
    primarySwatch: Colors.red,
    accentColor: Colors.red,
    scaffoldBackgroundColor: Colors.black12,
    cardColor: Colors.grey[900],
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
    ),
  );
}

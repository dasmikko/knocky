import 'package:flutter/material.dart';

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
    scaffoldBackgroundColor: Colors.black,
    cardColor: Colors.grey[900],
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
    ),
  );
}

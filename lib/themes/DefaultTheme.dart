import 'package:flutter/material.dart';

ThemeData defaultTheme() {
  return ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.red,
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
    ),
    scaffoldBackgroundColor: Colors.grey[400],
    cardTheme: CardTheme(
      color: Colors.grey[100],
    ),
  );
}

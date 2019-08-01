import 'package:flutter/material.dart';

ThemeData defaultTheme() {
  return ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.red,
    textTheme: TextTheme(
      body1: TextStyle(
        color: Colors.black
      )
    ),
  );
}


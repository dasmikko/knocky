import 'package:flutter/material.dart';

ThemeData DefaultTheme() {
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


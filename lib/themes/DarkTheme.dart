import 'package:flutter/material.dart';
import 'package:knocky/helpers/colors.dart';

Color primary = Color.fromRGBO(45, 45, 48, 1);
Color primaryDark = Color.fromRGBO(34, 34, 38, 1);

ThemeData darkTheme() {
  final theme = ThemeData.dark();
  return theme.copyWith(
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
    //primarySwatch: Colors.red,
    colorScheme: theme.colorScheme.copyWith(
      primary: Colors.red,
      secondary: Colors.red,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      refreshBackgroundColor: Colors.grey[800],
      color: Colors.red,
    ),
    //accentColor: Colors.red,
    scaffoldBackgroundColor: HexColor('#141414'),
    cardColor: Color.fromRGBO(45, 45, 45, 1),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
    ),
  );
}

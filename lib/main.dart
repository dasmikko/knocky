import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'screens/home.dart';

void main() {
  Widget rv;
  
  SharedPreferences.getInstance().then((prefs) {
    prefs.setBool('showNSFWThreads', prefs.getBool('showNSFWThreads') != null ? prefs.getBool('showNSFWThreads') : false);
  });

  rv = new DynamicTheme(
    defaultBrightness: Brightness.dark,
    data: (brightness) => ThemeData(
      primarySwatch: Colors.red,
      brightness: brightness,
      accentColor: Colors.red
    ),
    themedWidgetBuilder: (context, theme) {
      return MaterialApp(
        title: 'Knocky',
        theme: theme,
        home: HomeScreen()
      );
    });


  runApp(rv);
}

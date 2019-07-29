import 'package:flutter/material.dart';
import 'package:knocky/state/appState.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'themes/DarkTheme.dart';
import 'screens/home.dart';
import 'package:knocky/state/authentication.dart';
import 'package:knocky/state/settings.dart';
import 'package:knocky/state/subscriptions.dart';

void main() {
  Widget rv;

  // Set default settings
  SharedPreferences.getInstance().then((prefs) {
    prefs.setBool('showNSFWThreads', prefs.getBool('showNSFWThreads') != null ? prefs.getBool('showNSFWThreads') : false);

    if (prefs.getString('env').toString() == 'null') {
      prefs.setString('env', 'knockout');
    }
  });

  rv = new DynamicTheme(
    defaultBrightness: Brightness.dark,
    data: (brightness) => DarkTheme(),
    themedWidgetBuilder: (context, theme) {
      return MaterialApp(
        title: 'Knocky',
        theme: theme,
        home: HomeScreen()
      );
    });

    rv = ScopedModel<AuthenticationModel>(model: AuthenticationModel(), child: rv);
    rv = ScopedModel<SettingsModel>(model: SettingsModel(), child: rv);
    rv = ScopedModel<SubscriptionModel>(model: SubscriptionModel(), child: rv);
    rv = ScopedModel<AppStateModel>(model: AppStateModel(), child: rv);

  runApp(rv);
}

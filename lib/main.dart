import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:knocky/helpers/hiveHelper.dart';
import 'package:knocky/state/appState.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'themes/DarkTheme.dart';
import 'screens/home.dart';
import 'package:knocky/state/authentication.dart';
import 'package:knocky/state/subscriptions.dart';
import 'package:hive/hive.dart';

void main() async {
  Widget rv;

  // Init hive
  await AppHiveBox.initHive();
  Box box = await AppHiveBox.getBox();

  // Setup default values
  if (await box.get('showNSFWThreads') == null) {
    await box.put('showNSFWThreads', false);
  }

  if (await box.get('env') == null) {
    await box.put('env', 'knockout');
  }

  rv = new DynamicTheme(
    defaultBrightness: Brightness.dark,
    data: (brightness) => darkTheme(),
    themedWidgetBuilder: (context, theme) {
      return MaterialApp(
        title: 'Knocky',
        theme: theme,
        home: HomeScreen()
      );
    });

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.grey[900],
      systemNavigationBarIconBrightness: Brightness.light

    ));

    rv = ScopedModel<AuthenticationModel>(model: AuthenticationModel(), child: rv);
    rv = ScopedModel<SubscriptionModel>(model: SubscriptionModel(), child: rv);
    rv = ScopedModel<AppStateModel>(model: AppStateModel(), child: rv);

  runApp(rv);
}

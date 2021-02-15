import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:knocky_edge/screens/forum.dart';
import 'package:knocky_edge/state/appState.dart';
import 'package:knocky_edge/state/authentication.dart';
import 'package:knocky_edge/state/subscriptions.dart';
import 'package:knocky_edge/themes/DarkTheme.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  Widget rv;

  // Init dotenv
  await DotEnv().load('assets/.env');

  // Init prefs values
  SharedPreferences prefs = await SharedPreferences.getInstance();

  if (prefs.getBool('isLoggedIn') == null) {
    await prefs.setBool('isLoggedIn', false);
  }

  if (prefs.getBool('showNSFWThreads') == null) {
    await prefs.setBool('showNSFWThreads', false);
  }

  if (prefs.getBool('useInlineYoutubePlayer') == null) {
    await prefs.setBool('useInlineYoutubePlayer', true);
  }

  if (prefs.getString('env') == null) {
    await prefs.setString('env', 'knockout');
  }

  // Init hive
  //await AppHiveBox.initHive();
  //Box box = await AppHiveBox.getBox();

  // Setup default values
  /*if (await box.get('showNSFWThreads') == null) {
    await box.put('showNSFWThreads', false);
  }*/

  /*if (await box.get('useInlineYoutubePlayer') == null) {
    await box.put('useInlineYoutubePlayer', true);
  }

  if (await box.get('env') == null) {
    await box.put('env', 'knockout');
  }*/

  rv = new DynamicTheme(
      defaultBrightness: Brightness.dark,
      data: (brightness) => darkTheme(),
      themedWidgetBuilder: (context, theme) {
        if (theme.brightness == Brightness.dark) {
          SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
              systemNavigationBarColor: Colors.grey[900],
              systemNavigationBarIconBrightness: Brightness.light));
        }

        return MaterialApp(title: 'Knocky', theme: theme, home: ForumScreen());
      });

  rv =
      ScopedModel<AuthenticationModel>(model: AuthenticationModel(), child: rv);
  rv = ScopedModel<SubscriptionModel>(model: SubscriptionModel(), child: rv);
  rv = ScopedModel<AppStateModel>(model: AppStateModel(), child: rv);

  runApp(rv);
}

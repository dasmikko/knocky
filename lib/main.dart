import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:get/get.dart';
import 'package:knocky/controllers/authController.dart';
import 'package:knocky/controllers/settingsController.dart';
import 'package:knocky/helpers/themeService.dart';
import 'package:knocky/helpers/twitterApi.dart';
import 'package:knocky/screens/forum.dart';
import 'package:get_storage/get_storage.dart';
import 'package:knocky/themes/DarkTheme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:layout/layout.dart';

void main() async {
  final AuthController authController = Get.put(AuthController());
  final SettingsController settingsController = Get.put(SettingsController());
  await GetStorage.init();

  // Setup flavor
  FlavorConfig(
      name: "FDroid",
      color: Colors.red,
      location: BannerLocation.bottomStart,
      variables: {
        "allowUpdater": false,
      });

  // Init dotenv
  await dotenv.load(fileName: 'assets/.env');

  GetStorage prefs = GetStorage();

  if (prefs.read('env') == null) {
    await prefs.write('env', 'knockout');
  }

  if (!prefs.hasData('showNSFW')) {
    await prefs.write('showNSFW', false);
  } else {
    settingsController.showNSFWThreads.value = prefs.read('showNSFW');
  }

  if (prefs.hasData('apiEndpoint')) {
    settingsController.apiEndpoint.value = prefs.read('apiEndpoint');
  }

  authController.getStoredAuthInfo();

  try {
    await TwitterHelper().getBearerToken();
  } catch (e) {
    print('Fetching bearer token failed');
  }

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.grey[900],
      systemNavigationBarIconBrightness: Brightness.light));

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    precacheImage(AssetImage('assets/logo.png'), context);
    return Layout(
      child: GetMaterialApp(
        title: 'Flutter Demo',
        theme: darkTheme(),
        darkTheme: darkTheme(),
        themeMode: ThemeService().theme,
        home: ForumScreen(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knocky/controllers/authController.dart';
import 'package:knocky/helpers/twitterApi.dart';
import 'package:knocky/screens/forum.dart';
import 'package:get_storage/get_storage.dart';
import 'package:knocky/themes/DarkTheme.dart';
import 'package:flutter_portal/flutter_portal.dart';
//import 'package:knocky/themes/DefaultTheme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  final AuthController authController = Get.put(AuthController());
  await GetStorage.init();

  // Init dotenv
  await dotenv.load(fileName: 'assets/.env');

  GetStorage prefs = GetStorage();

  if (prefs.read('env') == null) {
    await prefs.write('env', 'knockout');
  }

  authController.getStoredAuthInfo();

  try {
    await TwitterHelper().getBearerToken();
  } catch (e) {
    print('Fetching bearer token failed');
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Portal(
      // Portal is for overlaying widgets
      child: GetMaterialApp(
        title: 'Flutter Demo',
        theme: darkTheme(),
        home: ForumScreen(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knocky/screens/forum.dart';
import 'package:get_storage/get_storage.dart';
import 'package:knocky/themes/DarkTheme.dart';
//import 'package:knocky/themes/DefaultTheme.dart';

void main() async {
  await GetStorage.init();

  GetStorage prefs = GetStorage();

  if (prefs.read('env') == null) {
    await prefs.write('env', 'knockout');
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: darkTheme(),
      home: ForumScreen(),
    );
  }
}

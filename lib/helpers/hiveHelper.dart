import 'dart:io';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AppHiveBox {
  static Future<void> initHive() async {
    // Init hive
    await Hive.initFlutter();
  }

  static Future<Box> getBox() async {
    var box = await Hive.openBox('knocky2',
        compactionStrategy: (entries, deletedEntries) {
      return deletedEntries > 50;
    });
    return box;
  }
}

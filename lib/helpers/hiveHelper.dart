import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';

class AppHiveBox {
  static Future<void> initHive() async {
    // Init hive
    Directory appDoc = await getApplicationDocumentsDirectory();
    Hive.init(appDoc.path);
  }

  static Future<Box> getBox() async {
    return Hive.openBox('knockyBox', compactionStrategy: (entries, deletedEntries) {
      return deletedEntries > 50;
    });
  }
}

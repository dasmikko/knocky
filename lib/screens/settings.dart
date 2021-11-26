import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Container(
        child: Column(
          children: [
            ListTile(
              title: Text('Reset image size cache'),
              onTap: () {
                final box = GetStorage('sizeCache');
                box.erase();

                Get.snackbar('Success', 'Image size cache cleared');
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:knocky/controllers/forumController.dart';

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
            ListTile(
              title: Text('Clear list of hidden motds'),
              onTap: () {
                ForumController forumController = Get.put(ForumController());
                GetStorage storage = GetStorage();

                forumController.hiddenMotds.value = [];
                storage.write('hiddenMotds', forumController.hiddenMotds.value);
                Get.snackbar('Success', 'Hidden Motds cleared');
              },
            ),
          ],
        ),
      ),
    );
  }
}

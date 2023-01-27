import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:knocky/controllers/forumController.dart';
import 'package:knocky/controllers/settingsController.dart';
import 'package:knocky/helpers/snackbar.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SettingsController settingsController = Get.put(SettingsController());

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Container(
        child: Column(
          children: [
            ListTile(
              dense: true,
              title: Text(
                'Filter',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            Obx(
              () => SwitchListTile(
                title: Text('Show NSFW Threads'),
                value: settingsController.showNSFWThreads.value,
                onChanged: (bool value) {
                  settingsController.showNSFWThreads.value = value;
                  GetStorage prefs = GetStorage();
                  prefs.write('showNSFW', value);
                },
              ),
            ),
            ListTile(
              dense: true,
              title: Text(
                'Cache',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            ListTile(
              title: Text('Reset widget size cache'),
              onTap: () {
                final box = GetStorage('sizeCache');
                box.erase();

                KnockySnackbar.success('Widget size cache cleared');
              },
            ),
            ListTile(
              title: Text('Clear list of hidden motds'),
              onTap: () {
                ForumController forumController = Get.put(ForumController());
                GetStorage storage = GetStorage();

                forumController.hiddenMotds.value = [];
                storage.write('hiddenMotds', forumController.hiddenMotds);
                KnockySnackbar.success('Hidden Motds cleared');
              },
            ),

            /**
             * API
             */

            ListTile(
              dense: true,
              title: Text(
                'API',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),

            /**
             * Other
             */
            ListTile(
              dense: true,
              title: Text(
                'Other',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            ListTile(
              title: Text('About Knocky'),
              onTap: () async {
                PackageInfo packageInfo = await PackageInfo.fromPlatform();

                Get.dialog(AboutDialog(
                  applicationIcon: Image(
                    width: 50,
                    image: AssetImage('assets/logo.png'),
                  ),
                  applicationName: "Knocky",
                  applicationVersion: packageInfo.version,
                  children: [
                    Text(
                        'Huge thanks to PITR and NoRegard for their help and support!')
                  ],
                ));
              },
            ),
          ],
        ),
      ),
    );
  }
}

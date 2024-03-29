import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:knocky/controllers/authController.dart';
import 'package:knocky/controllers/settingsController.dart';
import 'package:knocky/dialogs/inputDialog.dart';
import 'package:knocky/helpers/snackbar.dart';
import 'package:knocky/screens/forum.dart';
import 'package:uni_links/uni_links.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

late StreamSubscription _sub;

class _LoginScreenState extends State<LoginScreen> {
  void initiateLogin(String provider) async {
    final SettingsController settingsController = Get.put(SettingsController());
    // Start listening to auth finish url
    initUniLinks();

    if (settingsController.useDevAPI.value) {
      print(
          '${settingsController.apiEndpoint.value}auth/$provider/login?redirect=${settingsController.apiEndpoint.value}handleAuth');
      await launch(
          '${settingsController.apiEndpoint.value}auth/$provider/login?redirect=${settingsController.apiEndpoint.value}handleAuth');
    } else {
      // Launch login url
      await launch(
          'https://api.knockout.chat/auth/$provider/login?redirect=${settingsController.apiEndpoint.value}handleAuth');
    }
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  Future<void> initUniLinks() async {
    // ... check initialLink

    // Attach a listener to the stream
    _sub = linkStream.listen((String? link) async {
      print(link);

      String knockoutJWT = link!.replaceAll('knocky://finishAuth/', '');

      AuthController authController = Get.put(AuthController());
      await authController.loginWithJWTOnly(knockoutJWT);
      Get.offAll(() => ForumScreen());
      KnockySnackbar.success('Login was successfull!', icon: Icon(Icons.check));
      // Parse the link and warn the user, if it is not correct
    }, onError: (err) {
      print('Unilinks error: ' + err);
      // Handle exception by warning the user their action did not succeed
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login with'),
        actions: [
          TextButton(
            onPressed: () async {
              var dialogResult = await Get.dialog(InputDialog(
                title: 'Enter JWT token',
              ));

              if (dialogResult != false) {
                AuthController authController = Get.put(AuthController());
                authController.loginWithJWTOnly(dialogResult);
                Get.offAll(() => ForumScreen());
                KnockySnackbar.success(
                  'Login was successfull!',
                  icon: Icon(Icons.check),
                );
              }
            },
            child: Text('JWT'),
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.only(left: 20, right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.all(10),
                ),
                onPressed: () async {
                  initiateLogin('google');
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(right: 10),
                      child: Icon(
                        FontAwesomeIcons.google,
                        color: Colors.white,
                        size: 24.0,
                      ),
                    ),
                    Text(
                      'Google',
                      style: TextStyle(fontSize: 18),
                    )
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(10),
                  backgroundColor: Colors.grey[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => {initiateLogin('github')},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(right: 10),
                      child: Icon(
                        FontAwesomeIcons.github,
                        color: Colors.white,
                        size: 24.0,
                      ),
                    ),
                    Text(
                      'Github',
                      style: TextStyle(fontSize: 18),
                    )
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(10),
                  backgroundColor: Colors.grey[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => {initiateLogin('steam')},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(right: 10),
                      child: Icon(
                        FontAwesomeIcons.steam,
                        color: Colors.white,
                        size: 24.0,
                      ),
                    ),
                    Text(
                      'Steam',
                      style: TextStyle(fontSize: 18),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

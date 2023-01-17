import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:knocky/controllers/authController.dart';
import 'package:knocky/dialogs/inputDialog.dart';
import 'package:knocky/dialogs/qrDialog.dart';
import 'package:knocky/helpers/snackbar.dart';
import 'package:knocky/screens/forum.dart';
import 'package:knocky/screens/loginWebview.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher_string.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

StreamSubscription _sub;

class _LoginScreenState extends State<LoginScreen> {
  void initiateLogin(String provider) async {
    initUniLinks();

    await launch(
        'https://api.knockout.chat/auth/$provider/login?redirect=https://knockyauth.rekna.xyz/handleAuth');
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  Future<void> initUniLinks() async {
    // ... check initialLink

    // Attach a listener to the stream
    _sub = linkStream.listen((String link) async {
      print(link);

      if (link != null) {
        String knockoutJWT = link.replaceAll('knocky://finishAuth/', '');

        AuthController authController = Get.put(AuthController());
        await authController.loginWithJWTOnly(knockoutJWT);
        Get.offAll(ForumScreen());
        KnockySnackbar.success('Login was successfull!',
            icon: Icon(Icons.check));
      }
      // Parse the link and warn the user, if it is not correct
    }, onError: (err) {
      print('Unilinks error: ' + err);
      // Handle exception by warning the user their action did not succeed
    });
  }

  void scanQRCode() async {
    GetStorage prefs = GetStorage();

    bool qrDialogRemember = await prefs.read('qrDialogRemember') != null
        ? await prefs.read('qrDialogRemember')
        : false;

    if (!qrDialogRemember) {
      var dialogResult = await Get.dialog(QRDialog());

      if (!dialogResult) return;
    }

    AuthController authController = Get.put(AuthController());

    String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666", "Cancel", false, ScanMode.DEFAULT);

    if (barcodeScanRes != null) {
      SnackbarController snackbarController = KnockySnackbar.normal(
          'Logging in', 'Got QR code, logging in with it...',
          isDismissible: false, showProgressIndicator: true);

      // login and fetch user info
      await authController.loginWithJWTOnly(barcodeScanRes);
      snackbarController.close();
      Get.offAll(ForumScreen());
      KnockySnackbar.success('Login was successfull!', icon: Icon(Icons.check));
    } else {
      KnockySnackbar.error('Login was canceled', icon: Icon(Icons.warning));
    }
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
                Get.offAll(ForumScreen());
                KnockySnackbar.success('Login was successfull!',
                    icon: Icon(Icons.check));
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
                  primary: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => {initiateLogin('twitter')},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(right: 10),
                      child: Icon(
                        FontAwesomeIcons.twitter,
                        color: Colors.white,
                        size: 24.0,
                      ),
                    ),
                    Text(
                      'Twitter',
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
                  primary: Colors.grey[600],
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
                  primary: Colors.grey[800],
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
            Container(
              margin: EdgeInsets.only(bottom: 10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(10),
                  primary: Colors.indigo[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: scanQRCode,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(right: 10),
                      child: Icon(
                        FontAwesomeIcons.camera,
                        color: Colors.white,
                        size: 24.0,
                      ),
                    ),
                    Text(
                      'Scan QR Code',
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

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:knocky/controllers/authController.dart';
import 'package:knocky/dialogs/qrDialog.dart';
import 'package:knocky/screens/forum.dart';
import 'package:knocky/screens/loginWebview.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  void initiateLogin(String provider) async {
    var loginResult = await Get.to(
      () => LoginWebviewScreen(
        loginUrl: 'https://api.knockout.chat/auth/' + provider + '/login',
      ),
    );

    if (loginResult == true) {
      Get.offAll(ForumScreen());
      Get.snackbar(
        'Success',
        'Login was successfull!',
        icon: Icon(Icons.check),
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Error',
        'Login was canceled',
        icon: Icon(Icons.warning),
        snackPosition: SnackPosition.BOTTOM,
        animationDuration: Duration(milliseconds: 500),
        forwardAnimationCurve: Curves.easeOutCirc,
        reverseAnimationCurve: Curves.easeOutCirc,
        margin: EdgeInsets.only(
          bottom: 14,
          left: 14,
          right: 14,
        ),
      );
    }
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
      await authController.loginWithJWTOnly(barcodeScanRes);
      Get.offAll(ForumScreen());
      Get.snackbar(
        'Success',
        'Login was successfull',
        icon: Icon(Icons.check),
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Error',
        'Login was canceled',
        icon: Icon(Icons.warning),
        snackPosition: SnackPosition.BOTTOM,
        animationDuration: Duration(milliseconds: 500),
        forwardAnimationCurve: Curves.easeOutCirc,
        reverseAnimationCurve: Curves.easeOutCirc,
        margin: EdgeInsets.only(
          bottom: 14,
          left: 14,
          right: 14,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login with'),
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

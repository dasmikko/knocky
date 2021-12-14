import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:url_launcher/url_launcher.dart';

class QRDialog extends StatefulWidget {
  @override
  State<QRDialog> createState() => _QRDialogState();
}

class _QRDialogState extends State<QRDialog> {
  bool rememberCheckbox = false;
  GetStorage prefs = GetStorage();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Notice'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "If it's your first time logging in via QR, remember to install the requires extension. You can find it, in the Knocky thread",
          ),
          CheckboxListTile(
            value: rememberCheckbox,
            onChanged: (value) {
              setState(() {
                rememberCheckbox = value;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            title: Text('Do not show this again'),
          )
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            if (await canLaunch(
                'https://github.com/dasmikko/knocky-qr-extension')) {
              await launch('https://github.com/dasmikko/knocky-qr-extension');
            }
            Get.back(result: false);
          },
          child: Text('Go to extension'),
        ),
        ElevatedButton(
          onPressed: () {
            prefs.write('qrDialogRemember', rememberCheckbox);
            Get.back(result: true);
          },
          child: Text('OK'),
        ),
      ],
    );
  }
}

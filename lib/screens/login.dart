import 'package:flutter/material.dart';
import 'package:after_layout/after_layout.dart';
import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';

class LoginScreen extends StatefulWidget {

  LoginScreen();

  @override
  _ThreadScreenState createState() => _ThreadScreenState();
}

class _ThreadScreenState extends State<LoginScreen>
    with AfterLayoutMixin<LoginScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) {

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: InAppWebView(
        initialUrl: 'https://knockout.chat/login',
        initialOptions: {

        },
      )
    );
  }
}

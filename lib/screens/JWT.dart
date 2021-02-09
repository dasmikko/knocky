import 'package:flutter/material.dart';
import 'package:knocky_edge/models/syncData.dart';
import 'package:knocky_edge/helpers/api.dart';
import 'package:knocky_edge/state/authentication.dart';
import 'package:scoped_model/scoped_model.dart';

class JWTScreen extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void onPressButton(BuildContext context) async {
    await ScopedModel.of<AuthenticationModel>(context)
        .setCookieString('knockoutJwt=' + _controller.text);

    try {
      SyncDataModel syncData = await KnockoutAPI().getSyncData();
      print(syncData.toJson());

      if (syncData.id == null) {
        print('Token was not valid!');
        ScopedModel.of<AuthenticationModel>(context).logout();
        _scaffoldKey.currentState.showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'Token was not valid.',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      } else {
        await ScopedModel.of<AuthenticationModel>(context).setLoginState(
            true,
            syncData.id,
            syncData.username,
            syncData.avatarUrl,
            syncData.backgroundUrl,
            syncData.usergroup);

        Navigator.of(context).pop(true);
      }
    } catch (error) {
      print('Something went horribly wrong!');
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Enter JWT Token'),
      ),
      body: Container(
        padding: EdgeInsets.only(left: 20, right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 15),
              child: Text(
                  'If you have issues with the login providers, you can also enter your JWT token manually.'),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 15),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter token here...',
                ),
              ),
            ),
            RaisedButton(
              onPressed: () => onPressButton(context),
              child: Text('Login with JWT'),
            ),
          ],
        ),
      ),
    );
  }
}

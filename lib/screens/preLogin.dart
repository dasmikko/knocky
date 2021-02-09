import 'package:flutter/material.dart';
import 'package:knocky_edge/screens/JWT.dart';
import 'package:knocky_edge/screens/login.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class PreLoginScreen extends StatelessWidget {
  void onPressButton(BuildContext context, String type) async {
    String loginUrl = 'login';

    if (type == 'jwt') {
      bool wasLoggedIn = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => JWTScreen(),
        ),
      );

      if (wasLoggedIn) Navigator.of(context).pop(wasLoggedIn);

      return;
    }

    bool wasLoggedIn = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(
          loginUrl: 'https://api.knockout.chat/auth/' + type + '/login',
        ),
      ),
    );

    Navigator.of(context).pop(wasLoggedIn);
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
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.all(10),
                onPressed: () => onPressButton(context, 'google'),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(right: 10),
                      child: Icon(
                        MdiIcons.google,
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
              child: RaisedButton(
                padding: EdgeInsets.all(10),
                color: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                onPressed: () => onPressButton(context, 'twitter'),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(right: 10),
                      child: Icon(
                        MdiIcons.twitter,
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
              child: RaisedButton(
                padding: EdgeInsets.all(10),
                color: Colors.grey[600],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                onPressed: () => onPressButton(context, 'github'),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(right: 10),
                      child: Icon(
                        MdiIcons.githubBox,
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
              child: RaisedButton(
                padding: EdgeInsets.all(10),
                color: Colors.grey[800],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                onPressed: () => onPressButton(context, 'steam'),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(right: 10),
                      child: Icon(
                        MdiIcons.steam,
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
              child: RaisedButton(
                padding: EdgeInsets.all(10),
                color: Colors.indigo[800],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                onPressed: () => onPressButton(context, 'jwt'),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(right: 10),
                      child: Icon(
                        MdiIcons.key,
                        color: Colors.white,
                        size: 24.0,
                      ),
                    ),
                    Text(
                      'JWT token',
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

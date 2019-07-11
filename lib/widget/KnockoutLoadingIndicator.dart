import 'package:flutter/material.dart';

class KnockoutLoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 12),
              child: Text(
                'Node graph out of date. Rebuilding...',
                style: TextStyle(fontSize: 14, fontFamily: 'RobotoMono'),
              ),
            ),
            CircularProgressIndicator()
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class PageSelector extends StatelessWidget {
  final Function onNext;

  PageSelector({@required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(right: 8),
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          TextButton(
              child: Text('Next', style: TextStyle(color: Colors.white)),
              style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColorDark,
                  primary: Theme.of(context).primaryColor),
              onPressed: onNext)
        ]));
  }
}

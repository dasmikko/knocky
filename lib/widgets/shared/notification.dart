import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class NotificationIndicator extends StatelessWidget {
  final int count;
  final bool showWhenZero;
  NotificationIndicator({this.count = 0, this.showWhenZero = false});

  Widget countText() {
    return Align(
        alignment: Alignment.center,
        child: Container(
            margin: EdgeInsets.fromLTRB(1, 1, 0, 0),
            child: Text(count.toString(),
                style: TextStyle(fontSize: 7, fontWeight: FontWeight.w900))));
  }

  @override
  Widget build(BuildContext context) {
    if (count == 0 && !showWhenZero) {
      return Container();
    }
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Container(
            margin: EdgeInsets.fromLTRB(16, 16, 0, 0),
            child: OverflowBox(
              minWidth: 11,
              maxWidth: 11,
              minHeight: 11,
              maxHeight: 11,
              child: Container(
                  child: countText(),
                  decoration: BoxDecoration(
                      color: Theme.of(context).accentColor,
                      shape: BoxShape.circle)),
            )),
      ),
    );
  }
}

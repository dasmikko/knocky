import 'package:flutter/material.dart';

class InkWellOverWidget extends StatelessWidget {
  final Widget? child;
  final Function? onTap;
  final Function? onLongPress;
  final Function? onDoubleTap;
  final Function? onTapDown;

  InkWellOverWidget({this.child, this.onTap, this.onTapDown, this.onDoubleTap, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        child!,
        Positioned.fill(
          child: new Material(
            color: Colors.transparent,
            child: new InkWell(
              onTap: onTap as void Function()?,
              onLongPress: onLongPress as void Function()?,
              onDoubleTap: onDoubleTap as void Function()?,
              onTapDown: onTapDown as void Function(TapDownDetails)?,
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:knocky/models/thread.dart';

class Toolbar extends StatelessWidget {
  final ThreadPost post;

  Toolbar({@required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).primaryColor,
        height: 30,
        child: Row() // todo: post metadata + controls
        );
  }
}

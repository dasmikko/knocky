import 'package:flutter/material.dart';
import 'package:knocky/models/subforumDetails.dart';

class SignificantThreadListItem extends StatelessWidget {
  final SignificantThread thread;

  SignificantThreadListItem({@required this.thread});

  @override
  Widget build(BuildContext context) {
    return Card(child: Text(thread.title));
  }
}

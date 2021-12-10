import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:knocky/helpers/format.dart';
import 'package:knocky/models/thread.dart';

class Toolbar extends StatelessWidget {
  final ThreadPost post;
  final bool showThreadPostNumber;

  Toolbar({@required this.post, this.showThreadPostNumber = true});

  static Widget toolbarBox(Color color, List<Widget> contents) {
    return Container(
        padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
        color: color,
        height: 30,
        child: Row(
          children: [...contents],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return toolbarBox(Theme.of(context).primaryColor, contents());
  }

  @protected
  List<Widget> contents() {
    return [timestamp(), postNumber(), Expanded(child: controls())];
  }

  @protected
  Widget timestamp() {
    return Text(Format.humanReadableTimeSince(post.createdAt));
  }

  Widget postNumber() {
    return Container(
        margin: EdgeInsets.only(left: 8),
        child: Text(
          "#${post.threadPostNumber.toString()}",
          style: TextStyle(color: Colors.white60),
        ));
  }

  // TODO: post tags + controls
  // ignore: missing_return
  Widget tags() {}

  // ignore: missing_return
  Widget controls() {
    return Material(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            iconSize: 12,
            icon: FaIcon(
              FontAwesomeIcons.code,
            ),
            onPressed: () {},
          ),
          IconButton(
            iconSize: 12,
            icon: FaIcon(
              FontAwesomeIcons.reply,
            ),
            onPressed: () {},
          )
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:knocky/helpers/colors.dart';
import 'package:knocky/models/usergroup.dart';

class Username extends StatelessWidget {
  final String username;
  final String title;
  final String pronouns;
  final Usergroup usergroup;
  final bool bold;
  final Function onClick;
  final double fontSize;
  final double titleFontSize;
  final bool banned;

  Username({
    @required this.username,
    @required this.title,
    @required this.pronouns,
    @required this.usergroup,
    this.bold,
    this.onClick,
    this.banned = false,
    this.fontSize = 14,
    this.titleFontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
        style: ButtonStyle(
            padding:
                MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.zero)),
        onPressed: onClick,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              username,
              style: TextStyle(
                fontSize: fontSize,
                color: AppColors(context).userGroupToColor(
                  usergroup,
                  banned: banned,
                ),
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            title != null
                ? Container(
                    margin: EdgeInsets.only(top: 4),
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: titleFontSize,
                        color: Colors.white,
                      ),
                    ),
                  )
                : Container(),
            pronouns != null
                ? Container(
                    margin: EdgeInsets.only(top: 4),
                    child: Text(
                      pronouns,
                      style: TextStyle(
                        fontSize: titleFontSize,
                        color: Colors.white,
                      ),
                    ),
                  )
                : Container()
          ],
        ));
  }
}

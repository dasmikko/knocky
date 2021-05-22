import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DrawerListTile extends StatelessWidget {
  final IconData iconData;
  final String title;
  final Function onTap;
  final bool disabled;
  final Color tileColor;

  final double _leadingWidth = 16;

  DrawerListTile({
    this.disabled = false,
    @required this.iconData,
    @required this.title,
    @required this.onTap,
    this.tileColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ListTile(
          tileColor: this.tileColor,
          enabled: !disabled,
          minLeadingWidth: _leadingWidth,
          leading: Container(
            alignment: Alignment.center,
            width: _leadingWidth,
            child: FaIcon(iconData, size: _leadingWidth),
          ),
          title: Text(title),
          onTap: onTap),
    );
  }
}

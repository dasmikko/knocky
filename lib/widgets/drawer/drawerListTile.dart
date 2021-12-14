import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DrawerListTile extends StatelessWidget {
  final IconData iconData;
  final String title;
  final Function onTap;
  final bool disabled;
  final Color tileColor;

  static const double LEADING_WIDTH = 16;

  DrawerListTile({
    this.disabled = false,
    @required this.iconData,
    @required this.title,
    @required this.onTap,
    this.tileColor,
  });

  @protected
  Widget titleSection(BuildContext context) {
    return Text(title);
  }

  @protected
  icon(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: LEADING_WIDTH,
      child: FaIcon(iconData, size: LEADING_WIDTH),
    );
  }

  @protected
  Widget leadingSection(BuildContext context) {
    return icon(context);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ListTile(
          tileColor: this.tileColor,
          enabled: !disabled,
          minLeadingWidth: LEADING_WIDTH,
          leading: leadingSection(context),
          title: titleSection(context),
          onTap: onTap),
    );
  }
}

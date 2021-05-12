import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'drawerListTile.dart';

class MainDrawer extends StatelessWidget {
  final bool loggedIn = false; // TODO: get actual value injected
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(padding: EdgeInsets.zero, children: <Widget>[
      DrawerHeader(
        child: null, // TODO: insert user bg/avatar info here
        decoration: BoxDecoration(
          color: Colors.redAccent,
        ),
      ),
      DrawerListTile(
          iconData: FontAwesomeIcons.thList, title: 'Forum', onTap: () => {}),
      DrawerListTile(
          iconData: FontAwesomeIcons.solidNewspaper,
          title: 'Subscriptions',
          onTap: () => {}),
      DrawerListTile(
          iconData: FontAwesomeIcons.solidClock,
          title: 'Latest Threads',
          onTap: () => {}),
      DrawerListTile(
          iconData: FontAwesomeIcons.fire,
          title: 'Popular Threads',
          onTap: () => {}),
      Divider(color: Colors.white),
      DrawerListTile(
          iconData: FontAwesomeIcons.bullhorn,
          title: 'Events',
          onTap: () => {}),
      DrawerListTile(
          iconData: FontAwesomeIcons.discord,
          title: 'Discord',
          onTap: () => {}),
      DrawerListTile(
          iconData: FontAwesomeIcons.cog, title: 'Events', onTap: () => {}),
      if (loggedIn)
        DrawerListTile(
            iconData: FontAwesomeIcons.signOutAlt,
            title: 'Log Out',
            onTap: () => {}),
      DrawerListTile(
          iconData: FontAwesomeIcons.solidComment,
          title: 'Mentions',
          onTap: () => {}),
    ]));
  }
}

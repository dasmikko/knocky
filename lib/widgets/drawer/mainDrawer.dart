import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:knocky/controllers/authController.dart';
import 'package:knocky/screens/login.dart';

import 'drawerListTile.dart';

class MainDrawer extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(padding: EdgeInsets.zero, children: <Widget>[
      DrawerHeader(
        child: null, // todo: insert user bg/avatar info here
        decoration: BoxDecoration(
          color: Colors.redAccent,
        ),
      ),
      DrawerListTile(
        iconData: FontAwesomeIcons.thList,
        title: 'Forum',
        onTap: () => {},
      ),
      DrawerListTile(
          disabled: !authController.isAuthenticated.value,
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
      DrawerListTile(
        iconData: FontAwesomeIcons.cog,
        title: 'Settings',
        onTap: () => {},
      ),
      authController.isAuthenticated.value
          ? DrawerListTile(
              iconData: FontAwesomeIcons.signOutAlt,
              title: 'Log Out',
              onTap: () => {})
          : DrawerListTile(
              iconData: FontAwesomeIcons.signInAlt,
              title: 'Log in',
              onTap: () => {
                Get.to(LoginScreen()),
              },
            ),
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
      DrawerListTile(
          iconData: FontAwesomeIcons.solidComment,
          title: 'Mentions',
          onTap: () => {}),
    ]));
  }
}

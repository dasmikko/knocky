import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:knocky/controllers/authController.dart';
import 'package:knocky/models/significantThreads.dart';
import 'package:knocky/screens/event.dart';
import 'package:knocky/screens/login.dart';
import 'package:knocky/screens/significantThreads.dart';

import 'drawerListTile.dart';

class MainDrawer extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());

  navigateTo(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  onListTileTap(BuildContext context, Function onTap) {
    Navigator.of(context).pop(); // close the drawer
    onTap();
  }

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
          onTap: () => onListTileTap(
              context,
              () => navigateTo(
                  context,
                  SignificantThreadsScreen(
                    threadsToShow: SignificantThreads.Latest,
                  )))),
      DrawerListTile(
          iconData: FontAwesomeIcons.fire,
          title: 'Popular Threads',
          onTap: () => onListTileTap(
              context,
              () => navigateTo(
                  context,
                  SignificantThreadsScreen(
                    threadsToShow: SignificantThreads.Popular,
                  )))),
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
          onTap: () =>
              onListTileTap(context, () => navigateTo(context, EventScreen()))),
      DrawerListTile(
          iconData: FontAwesomeIcons.discord,
          title: 'Discord',
          onTap: () => {}),
      DrawerListTile(
          iconData: FontAwesomeIcons.solidComment,
          title: 'Mentions',
          onTap: () => {}),
    ]));
  }
}

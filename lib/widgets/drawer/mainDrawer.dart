import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:knocky/controllers/authController.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/models/significantThreads.dart';
import 'package:knocky/screens/event.dart';
import 'package:knocky/screens/login.dart';
import 'package:knocky/screens/significantThreads.dart';

import 'drawerListTile.dart';

class MainDrawer extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());

  navigateTo(Widget screen) {
    Get.to(screen);
  }

  onListTileTap(BuildContext context, Function onTap) {
    Get.back();
    //Navigator.of(context).pop(); // close the drawer
    onTap();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Obx(
            () => authController.isAuthenticated.value
                ? UserAccountsDrawerHeader(
                    accountName: Text(authController.username.value),
                    accountEmail: null,
                    onDetailsPressed: () => print('Clicked!'),
                    decoration: BoxDecoration(
                      image: authController.isAuthenticated.value
                          ? DecorationImage(
                              fit: BoxFit.cover,
                              image: CachedNetworkImageProvider(
                                  "${KnockoutAPI.CDN_URL}/${authController.background.value}"),
                            )
                          : null,
                      color: Colors.redAccent,
                    ),
                    currentAccountPicture: CachedNetworkImage(
                        placeholder: (BuildContext context, String url) =>
                            CircularProgressIndicator(),
                        imageUrl:
                            "${KnockoutAPI.CDN_URL}/${authController.avatar.value}"),
                  )
                : DrawerHeader(
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: 16),
                          child: authController.isAuthenticated.value
                              ? CachedNetworkImage(
                                  height: 80,
                                  width: 80,
                                  placeholder:
                                      (BuildContext context, String url) =>
                                          CircularProgressIndicator(),
                                  imageUrl:
                                      "${KnockoutAPI.CDN_URL}/${authController.avatar.value}")
                              : null,
                        ),
                        Text(
                            '${authController.isAuthenticated.value ? authController.username : 'Not logged in'}'),
                      ],
                    ), // TODO: insert user bg/avatar info here
                    decoration: BoxDecoration(
                      image: authController.isAuthenticated.value
                          ? DecorationImage(
                              fit: BoxFit.cover,
                              image: CachedNetworkImageProvider(
                                  "${KnockoutAPI.CDN_URL}/${authController.background.value}"),
                            )
                          : null,
                      color: Colors.redAccent,
                    ),
                  ),
          ),
          DrawerListTile(
            iconData: FontAwesomeIcons.thList,
            title: 'Forum',
            onTap: () => {},
          ),
          Obx(
            () => DrawerListTile(
                disabled: !authController.isAuthenticated.value,
                iconData: FontAwesomeIcons.solidNewspaper,
                title: 'Subscriptions',
                onTap: () => {}),
          ),
          DrawerListTile(
              iconData: FontAwesomeIcons.solidClock,
              title: 'Latest Threads',
              onTap: () => onListTileTap(
                  context,
                  () => navigateTo(SignificantThreadsScreen(
                        threadsToShow: SignificantThreads.Latest,
                      )))),
          DrawerListTile(
            iconData: FontAwesomeIcons.fire,
            title: 'Popular Threads',
            onTap: () => onListTileTap(
              context,
              () => navigateTo(
                SignificantThreadsScreen(
                  threadsToShow: SignificantThreads.Popular,
                ),
              ),
            ),
          ),
          DrawerListTile(
            iconData: FontAwesomeIcons.cog,
            title: 'Settings',
            onTap: () => {},
          ),
          Obx(
            () => authController.isAuthenticated.value
                ? DrawerListTile(
                    iconData: FontAwesomeIcons.signOutAlt,
                    title: 'Log Out',
                    onTap: () {
                      authController.logout();
                    })
                : DrawerListTile(
                    iconData: FontAwesomeIcons.signInAlt,
                    title: 'Log in',
                    onTap: () => {
                      navigateTo(LoginScreen()),
                    },
                  ),
          ),
          Divider(color: Colors.white),
          DrawerListTile(
              iconData: FontAwesomeIcons.bullhorn,
              title: 'Events',
              onTap: () =>
                  onListTileTap(context, () => navigateTo(EventScreen()))),
          DrawerListTile(
              iconData: FontAwesomeIcons.discord,
              title: 'Discord',
              onTap: () => {}),
          DrawerListTile(
              iconData: FontAwesomeIcons.solidComment,
              title: 'Mentions',
              onTap: () => {}),
        ],
      ),
    );
  }
}

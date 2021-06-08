import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:knocky/widgets/shared/notification.dart';
import 'drawerListTile.dart';

class DrawerNotificationsListTile extends DrawerListTile {
  final IconData iconData;
  final String title;
  final Function onTap;
  final bool disabled;
  final Color tileColor;
  final RxInt notificationCount;

  DrawerNotificationsListTile(
      {this.disabled = false,
      @required this.iconData,
      @required this.title,
      @required this.onTap,
      this.tileColor,
      this.notificationCount})
      : super(
            disabled: disabled,
            iconData: iconData,
            title: title,
            onTap: onTap,
            tileColor: tileColor);

  notificationIndicator() {
    return Obx(() => notificationCount.value > 0 && !disabled
        ? NotificationIndicator(count: notificationCount.value)
        : Container());
  }

  @override
  Widget leadingSection(BuildContext context) {
    return Container(
        width: DrawerListTile.LEADING_WIDTH,
        child: Stack(children: [icon(context), notificationIndicator()]));
  }
}

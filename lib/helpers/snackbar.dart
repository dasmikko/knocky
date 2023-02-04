import 'package:flutter/material.dart';
import 'package:get/get.dart';

const forwardAnimationCurve = Curves.easeOutExpo;
const reverseAnimationCurve = Curves.easeOutExpo;
const animationDuration = Duration(milliseconds: 600);

class KnockySnackbar {
  static SnackbarController normal(
    String title,
    String content, {
    Widget? icon,
    bool isDismissible = true,
    bool showProgressIndicator = false,
  }) {
    return Get.snackbar(
      title,
      content,
      icon: icon,
      animationDuration: animationDuration,
      forwardAnimationCurve: forwardAnimationCurve,
      reverseAnimationCurve: reverseAnimationCurve,
      isDismissible: isDismissible,
      showProgressIndicator: showProgressIndicator,
      borderRadius: 0,
    );
  }

  static SnackbarController success(
    String content, {
    String title = 'Success',
    Widget? icon,
    bool isDismissible = true,
    bool showProgressIndicator = false,
  }) {
    return Get.snackbar(
      title,
      content,
      icon: icon,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      animationDuration: animationDuration,
      forwardAnimationCurve: forwardAnimationCurve,
      reverseAnimationCurve: reverseAnimationCurve,
      isDismissible: isDismissible,
      showProgressIndicator: showProgressIndicator,
      borderRadius: 0,
    );
  }

  static SnackbarController error(
    String content, {
    String title = 'Error',
    Widget? icon,
    bool isDismissible = true,
    bool showProgressIndicator = false,
  }) {
    return Get.snackbar(
      title,
      content,
      icon: icon,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      animationDuration: animationDuration,
      forwardAnimationCurve: forwardAnimationCurve,
      reverseAnimationCurve: reverseAnimationCurve,
      isDismissible: isDismissible,
      showProgressIndicator: showProgressIndicator,
      borderRadius: 0,
    );
  }
}

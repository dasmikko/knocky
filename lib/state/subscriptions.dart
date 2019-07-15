import 'dart:async';

import 'package:flutter/material.dart';
import 'package:knocky/models/threadAlert.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:knocky/helpers/api.dart';

class SubscriptionModel extends Model {
  List<ThreadAlert> _alerts = List();
  int _totalUnreadPosts = 0;

  List<ThreadAlert> get subscriptions => _alerts;
  int get totalUnreadPosts => _totalUnreadPosts;

  StreamSubscription getSubscriptions () {
    StreamSubscription sub = KnockoutAPI().getAlerts().asStream().listen((res) {
      _alerts = res;
      _calcTotalUnreadPosts();
      notifyListeners();
    });
    return sub;
  }

  void _calcTotalUnreadPosts () {
    int count = 0;
    _alerts.forEach((item) {
      count = count + item.unreadPosts;
    });

    _totalUnreadPosts = count;
    notifyListeners();
  }



  static SubscriptionModel of(BuildContext context) =>
    ScopedModel.of<SubscriptionModel>(context, rebuildOnChange: true);
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:knocky_edge/models/threadAlert.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:knocky_edge/helpers/api.dart';

class SubscriptionModel extends Model {
  List<ThreadAlert> _alerts = List();
  int _totalUnreadPosts = 0;
  bool _isFetching = false;
  bool _hasFailed = false;

  List<ThreadAlert> get subscriptions => _alerts;
  int get totalUnreadPosts => _totalUnreadPosts;
  bool get isFetching => _isFetching;
  bool get hasFailed => _hasFailed;

  Future getSubscriptions({Function errorCallback}) {
    _isFetching = true;
    notifyListeners();

    Future _future = KnockoutAPI().getAlerts().then((res) {
      if (res != null) {
        _alerts = res;
        _isFetching = false;
        _calcTotalUnreadPosts();
        notifyListeners();
      }
    }).catchError((error) {
      _hasFailed = true;
      _isFetching = false;

      if (errorCallback != null) errorCallback();
      notifyListeners();
    });

    return _future;
  }

  void resetHasFailedState() {
    _hasFailed = false;
  }

  void clearList() {
    _alerts = List();
    _calcTotalUnreadPosts();
    notifyListeners();
  }

  void _calcTotalUnreadPosts() {
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

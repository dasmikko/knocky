import 'package:flutter/cupertino.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:knocky/state/authentication.dart';
import 'package:knocky/state/subscriptions.dart';

class AppStateModel extends Model {
  BuildContext context;
  AppStateModel({this.context});

  AuthenticationModel authenticationModel () {
    return ScopedModel.of<AuthenticationModel>(context);
  }

  SubscriptionModel subscriptionModel () {
    return ScopedModel.of<SubscriptionModel>(context);
  } 

}
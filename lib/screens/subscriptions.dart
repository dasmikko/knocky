import 'package:flutter/material.dart';
import 'package:after_layout/after_layout.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/models/threadAlert.dart';

class SubscriptionScreen extends StatefulWidget {
  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> with AfterLayoutMixin<SubscriptionScreen> {
  List<ThreadAlert> alerts = List();

  @override
  void afterFirstLayout(BuildContext context) {
    KnockoutAPI().getAlerts().then((List<ThreadAlert> res) {
      print('Got events...');
      
      setState(() {
       alerts = res; 
      });

    });
  }

  @override
  Widget build(BuildContext context) {
    print(alerts.length);

    return Scaffold(
      appBar: AppBar(
        title: Text('Subscriptions'),
      ),
      body: ListView.builder(
        itemCount: alerts.length,
        itemBuilder: (BuildContext context, int index) {
          ThreadAlert item = alerts[index];
          return ListTile(
            title: Text(item.threadTitle)
          );
        },
      ),
    );
  }
}

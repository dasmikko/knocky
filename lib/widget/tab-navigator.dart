import 'package:flutter/material.dart';
import 'package:knocky/screens/popularThreads.dart';
import 'package:knocky/screens/latestThreads.dart';
import 'package:knocky/screens/forum.dart';
import 'package:knocky/screens/subscriptions.dart';

class TabNavigatorRoutes {
  static const String root = '/';
  static const String subforum = '/subforum';
  static const String thread = '/thread';
}

class TabNavigator extends StatelessWidget {
  TabNavigator({this.navigatorKey, this.tabItem});
  final int tabItem;
  final GlobalKey<NavigatorState> navigatorKey;

  Map<String, WidgetBuilder> _routeBuilders(BuildContext context) {
    switch (tabItem) {
      case 0:
        return {
          TabNavigatorRoutes.root: (context) => ForumScreen(),
        };
        break;
      case 1:
        return {
          TabNavigatorRoutes.root: (context) => SubscriptionScreen(),
        };
        break;
      case 2:
        return {
          TabNavigatorRoutes.root: (context) => LatestThreadsScreen(),
        };
        break;
      case 3:
        return {
          TabNavigatorRoutes.root: (context) => PopularThreadsScreen(),
        };
        break;
      default:
       return {
          TabNavigatorRoutes.root: (context) => ForumScreen(),
        };
    }
    
  }

  @override
  Widget build(BuildContext context) {
    var routeBuilders = _routeBuilders(context);

    return Navigator(
        key: navigatorKey,
        initialRoute: TabNavigatorRoutes.root,
        onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(
              builder: (context) {
                return routeBuilders[routeSettings.name](context);
              });
        });
  }
}
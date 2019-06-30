import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:knocky/models/subforum.dart';
import 'package:knocky/models/subforumDetails.dart';
import 'package:knocky/models/thread.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KnockoutAPI {
  static bool _isDev;

  static String baseurlSite =
      !_isDev ? "https://knockout.chat/" : "https://forums.stylepunch.club/";
  static String baseurl = !_isDev
      ? "https://api.knockout.chat/"
      : "https://forums.stylepunch.club:3000/";

  List<Subforum> parseSubforums(String responseBody) {
    final parsed =
        json.decode(responseBody)['list'].cast<Map<String, dynamic>>();

    return parsed.map<Subforum>((json) => Subforum.fromJson(json)).toList();
  }

  Future<List<Subforum>> getSubforums() async {
    final response = await http.get(baseurl + 'subforum');

    return parseSubforums(response.body);
  }

  Future<SubforumDetails> getSubforumDetails(int id) async {
    final response = await http.get(baseurl + 'subforum/' + id.toString());

    return SubforumDetails.fromJson(json.decode(response.body));
  }

  Future<Thread> getThread(int id, {int page: 1}) async {
    final response = await http
        .get(baseurl + 'thread/' + id.toString() + '/' + page.toString());

    return Thread.fromJson(json.decode(response.body));
  }

  Future<Thread> authCheck() async {
    print('Checking auth state...');

    SharedPreferences prefs = await SharedPreferences.getInstance();

    final response = await http.get(baseurl + 'user/authCheck',
        headers: {'Cookie': prefs.getString('cookieString')});

    print('Auth: ' + response.body);
  }

  Future<void> getAlerts() async {
    final response = await http.get(baseurl + 'alert/list', headers: {});

    print(response.body);
  }

  Future<void> getEvetns() async {
    final response = await http.get(baseurl + 'events', headers: {});

    print(response.body);
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:knocky/models/subforum.dart';
import 'package:knocky/models/subforumDetails.dart';
import 'package:knocky/models/thread.dart';
import 'package:knocky/models/threadAlert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:knocky/models/readThreads.dart';

class KnockoutAPI {
  static bool _isDev = false;

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
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final response = await http.get(baseurl + 'subforum', headers: {'Cookie': prefs.getString('cookieString')});

    return parseSubforums(response.body);
  }

  Future<SubforumDetails> getSubforumDetails(int id, {int page = 1}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final response = await http.get(baseurl + 'subforum/' + id.toString() + '/' + page.toString() , headers: {'Cookie': prefs.getString('cookieString')});

    return SubforumDetails.fromJson(json.decode(response.body));
  }

  Future<Thread> getThread(int id, {int page: 1}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    final response = await http
        .get(baseurl + 'thread/' + id.toString() + '/' + page.toString(), headers: {'Cookie': prefs.getString('cookieString')});

    return Thread.fromJson(json.decode(response.body));
  }

  Future<Thread> authCheck() async {
    print('Checking auth state...');

    SharedPreferences prefs = await SharedPreferences.getInstance();

    final response = await http.get(baseurl + 'user/authCheck',
        headers: {'Cookie': prefs.getString('cookieString')}
    );

    print('Auth: ' + response.body);
  }

  Future<List<ThreadAlert>> getAlerts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final response = await http.post(baseurl + 'alert/list', headers: {
      'Cookie': prefs.getString('cookieString')
    });

    final parsedJson =
        json.decode(response.body).cast<Map<String, dynamic>>();

    return parsedJson.map<ThreadAlert>((json) => ThreadAlert.fromJson(json)).toList();
  }

  Future<void> readThreads(DateTime lastseen, int threadId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    ReadThreads jsonToPost = new ReadThreads(lastSeen: lastseen, threadId: threadId);

    final response = await http.post(
      baseurl + 'readThreads', 
      body: json.encode(jsonToPost.toJson()),
      headers: {
        'Cookie': prefs.getString('cookieString'),
        "Content-Type": "application/json"
      }
    );
    
    print(response.body);
  }

  Future<List<ThreadAlert>> getEvents() async {
    final response = await http.get(baseurl + 'events', headers: {});

    final parsedJson =
        json.decode(response.body).cast<Map<String, dynamic>>();

    return parsedJson.map<ThreadAlert>((json) => ThreadAlert.fromJson(json)).toList();
  }
}

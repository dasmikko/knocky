import 'package:flutter/material.dart';
import 'package:after_layout/after_layout.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';

class TwitterEmbedWidget extends StatefulWidget {
  final String twitterUrl;

  TwitterEmbedWidget({this.twitterUrl});

  @override
  _TwitterEmbedWidgetState createState() => _TwitterEmbedWidgetState();
}

class _TwitterEmbedWidgetState extends State<TwitterEmbedWidget>
    with AfterLayoutMixin<TwitterEmbedWidget> {
  bool _isLoading = true;
  String _embedHtml;

  @override
  void afterFirstLayout(BuildContext context) {
    fetchTwitterJson();
  }

  void fetchTwitterJson() async {
    String twitterApi = "https://publish.twitter.com/oembed?url=";

    final response = await http.get(twitterApi + this.widget.twitterUrl);

    print(json.decode(response.body));

    setState(() {
     _isLoading = false;
     _embedHtml = json.decode(response.body)['html']; 
    });
  }

  @override
  Widget build(BuildContext context) {
        

    if (!_isLoading) {
      final String contentBase64 =
        base64Encode(const Utf8Encoder().convert(_embedHtml));

      return LimitedBox(
        maxHeight: 600,
        child: InAppWebView(
          initialOptions: {
            'useWideViewPort': false,
            'javaScriptEnabled': true,
            'transparentBackground': true
          },
          initialUrl: 'data:text/html;base64,$contentBase64',
        ),
      );
    } else {
      return CircularProgressIndicator();
    }
  }
}

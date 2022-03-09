import 'dart:async';
import 'dart:convert';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:knocky/widgets/InkWellOnWidget.dart';
import 'package:url_launcher/url_launcher.dart';
//import 'package:intent/intent.dart' as intent;
//import 'package:intent/action.dart' as action;

class EmbedWidget extends StatefulWidget {
  final String url;

  EmbedWidget({this.url});

  @override
  _EmbedWidgetState createState() => _EmbedWidgetState();
}

class _EmbedWidgetState extends State<EmbedWidget> {
  String _title = "Fetching embed...";
  String _description = "";
  String _imageUrl;
  StreamSubscription<http.Response> _dataSub;

  @override
  void initState() {
    super.initState();
    if (widget.url == null) return null;
    _dataSub = http
        .get(Uri.parse('https://ograph.knockout.chat/?url=' + widget.url),
            headers: {'Origin': 'https://knockout.chat'})
        .asStream()
        .listen((response) {
          print('body' + response.body);
          compute(parseJson, response.body).then((data) {
            if (this.mounted) {
              setState(() {
                if (data['title'] != null) {
                  _title = data['title'];
                }

                if (data['description'] != null) {
                  _description = data['description'];
                }

                if (data['image'] != null) {
                  _imageUrl = data['image'];
                }
              });
            }
          });
        });
  }

  @override
  void dispose() {
    _dataSub?.cancel();
    super.dispose();
  }

  static Map parseJson(String json) {
    return jsonDecode(json);
  }

  bool notNull(Object o) => o != null;

  Widget handleImage(String url) {
    return Container(
      width: 100,
      height: 100,
      margin: EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        image: DecorationImage(
            image: ExtendedNetworkImageProvider(url),
            fit: BoxFit.cover,
            alignment: Alignment.topCenter),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        clipBehavior: Clip.antiAlias,
        child: InkWellOverWidget(
          onTap: () async {
            if (await canLaunch(this.widget.url)) {
              await launch(this.widget.url);
            } else {
              throw 'Could not launch $this.widget.url';
            }
          },
          child: Container(
            padding: EdgeInsets.all(10),
            color: Colors.grey[800],
            child: Row(
              children: <Widget>[
                _imageUrl != null ? handleImage(_imageUrl) : null,
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                          margin: EdgeInsets.only(bottom: 15),
                          child: Text(
                            _title,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                      Container(
                        margin: EdgeInsets.only(bottom: 15),
                        child:
                            Text(_description, style: TextStyle(fontSize: 12)),
                      ),
                      Text(
                          this.widget.url != null
                              ? this.widget.url
                              : 'wtf no url',
                          style: TextStyle(fontSize: 12, color: Colors.blue)),
                    ],
                  ),
                ),
              ].where(notNull).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:knocky/widget/InkWellOnWidget.dart';
import 'package:intent/intent.dart' as intent;
import 'package:intent/action.dart' as action;

class EmbedWidget extends StatefulWidget {
  final String url;

  EmbedWidget({this.url});

  @override
  _EmbedWidgetState createState() => _EmbedWidgetState();
}

class _EmbedWidgetState extends State<EmbedWidget>
    with AutomaticKeepAliveClientMixin {
  String _title = "Fetching embed...";
  String _description = "";
  String _imageUrl;

  @override
  void initState() {
    super.initState();
    
    compute(fetchHtml, widget.url).then((data) {
      print('got html and data');
      setState(() {
        if (data['title'] != null) {
          _title = data['title'];
        }

        if (data['description'] != null ) {
          _description = data['description'];
        }

        if (data['imageUrl'] != null) {
          _imageUrl = data['imageUrl'];
        }
      });
    });
  }

  static Future<Map> fetchHtml(url) async {
    var response = await http.get(url);
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      var document = parse(response.body);

      var list = document.getElementsByTagName('meta');

      String title;
      String description;
      String imageUrl;

      for (var item in list) {
        if (item.attributes['property'] == "og:title") {
          title = item.attributes['content'];
        }

        if (item.attributes['property'] == "og:description") {
          description = item.attributes['content'];
        }

        if (item.attributes['property'] == "og:image") {
          imageUrl = item.attributes['content'];
        }
      }

      var map = Map<String,String>();
      map['title'] = title;
      map['description'] = description;
      map['imageUrl'] = imageUrl;

      return map;
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load post');
    }
  }

  bool notNull(Object o) => o != null;

  Widget handleImage(String url) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        image: DecorationImage(image: CachedNetworkImageProvider(url), fit: BoxFit.cover, alignment: Alignment.topCenter),
        border: Border(bottom: BorderSide(color: Colors.black))
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    //UrlEmbedModel.of(context).fetchHtml(this.url);
    return Container(
      margin: EdgeInsets.only(bottom: 12.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        clipBehavior: Clip.antiAlias,
        child: Container(
          color: Colors.grey,
          child: InkWellOverWidget(
            onTap: () async {
              intent.Intent()
                ..setAction(action.Action.ACTION_VIEW)
                ..setData(Uri.parse(this.widget.url))
                ..startActivity().catchError((e) => print(e));
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _imageUrl != null ? handleImage(_imageUrl) : null,
                ListTile(
                  title: Text(_title),
                  subtitle: Text(_description),
                ),
              ].where(notNull).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

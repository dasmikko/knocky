import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;

class YoutubeVideoEmbed extends StatefulWidget {
  final String url;

  YoutubeVideoEmbed({this.url});

  @override
  _YoutubeEmbedState createState() => _YoutubeEmbedState();
}

class _YoutubeEmbedState extends State<YoutubeVideoEmbed> {
  String maxResThumbnail;
  String sdResThumbnail;
  String defaultThumbnail;
  String res;
  String _title;

  @override
  void initState() {
    super.initState();

    var id = Uri.parse(this.widget.url.trim()).queryParameters['v'];

    if (id == null) {
      id = this.widget.url.split("/").last.split('?').first;
    }

    maxResThumbnail =
        "https://img.youtube.com/vi/${id}/0.jpg"; //ignore: unnecessary_brace_in_string_interps
    sdResThumbnail =
        "https://img.youtube.com/vi/${id}/sddefault.jpg"; //ignore: unnecessary_brace_in_string_interps
    defaultThumbnail =
        "https://img.youtube.com/vi/${id}/default.jpg"; //ignore: unnecessary_brace_in_string_interps
    res = 'max';

    this.getVideoInfo(this.widget.url);
  }

  void getVideoInfo(String url) async {
    GetConnect().get('https://noembed.com/embed?url=${url}').then((res) {
      Map jsonData = jsonDecode(res.bodyString);
      if (this.mounted) {
        setState(() {
          _title = jsonData['title'];
        });
      }
    });
  }

  void playYouTubeVideo(String url) async {
    if (await canLaunch(url)) {
      if (Platform.isIOS) {
        await launch(url, forceSafariVC: false);
      } else {
        await launch(url, forceWebView: false);
      }
    } else {
      throw 'Could not launch $url';
    }
  }

  void switchRes(String newRes) {
    setState(() {
      res = newRes;
    });
  }

  @override
  Widget build(BuildContext context) {
    String thumbnailUrl = "UNKOWN";

    switch (res) {
      case 'max':
        thumbnailUrl = maxResThumbnail;
        break;
      case 'sd':
        thumbnailUrl = sdResThumbnail;
        break;
      case 'default':
        thumbnailUrl = defaultThumbnail;
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Container(
            margin: EdgeInsets.only(bottom: 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.all(
                Radius.circular(8),
              ),
              child: Stack(
                alignment: Alignment(0, 0),
                children: <Widget>[
                  CachedNetworkImage(
                    imageUrl: thumbnailUrl,
                    placeholder: (BuildContext context, String url) =>
                        CircularProgressIndicator(),
                  ),
                  if (_title != null)
                    Positioned.fill(
                      top: 10,
                      left: 10,
                      child: Text(
                        _title,
                        style: TextStyle(
                          fontSize: 16,
                          shadows: [
                            Shadow(
                              blurRadius: 2.0,
                              offset: Offset(0, 0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Icon(
                    FontAwesomeIcons.youtube,
                    color: Colors.white,
                    size: 124.0,
                  ),
                  new Positioned.fill(
                    child: new Material(
                      color: Colors.transparent,
                      child: new InkWell(
                        onTap: () => playYouTubeVideo(this.widget.url),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}

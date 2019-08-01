import 'package:flutter/material.dart';
import 'package:flutter_youtube/flutter_youtube.dart';
import 'package:cached_network_image/cached_network_image.dart';

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

  @override
  void initState() {
    super.initState();

    var id = Uri.parse(this.widget.url).queryParameters['v'];

    if (id == null) {
      id = this.widget.url.split("/").last.split('?').first;
    }

    maxResThumbnail = "https://img.youtube.com/vi/${id}/0.jpg"; //ignore: unnecessary_brace_in_string_interps
    sdResThumbnail = "https://img.youtube.com/vi/${id}/sddefault.jpg"; //ignore: unnecessary_brace_in_string_interps
    defaultThumbnail = "https://img.youtube.com/vi/${id}/default.jpg"; //ignore: unnecessary_brace_in_string_interps
    res = 'max';
  }

  void playYouTubeVideo(String url) {
    FlutterYoutube.playYoutubeVideoByUrl(
      apiKey: "AIzaSyBehHEbtDN5ExcdWydEBp5R8EYlB6cf6nM",
      videoUrl: url,
      autoPlay: true, //default falase
      fullScreen: false //default false
    );
  }

  void switchRes (String newRes) {
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

    return Container(
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
            Icon(
              Icons.play_circle_outline,
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
    );
  }
}

import 'package:flutter/material.dart';
import 'package:after_layout/after_layout.dart';
import 'package:knocky/helpers/colors.dart';
import 'package:knocky/helpers/twitterApi.dart';
import 'package:tweet_ui/models/api/tweet.dart';
import 'package:tweet_ui/tweet_view.dart';

class TwitterEmbedWidget extends StatefulWidget {
  final String twitterUrl;
  final Function onTapImage;

  TwitterEmbedWidget({this.twitterUrl, this.onTapImage});

  @override
  _TwitterEmbedWidgetState createState() => _TwitterEmbedWidgetState();
}

class _TwitterEmbedWidgetState extends State<TwitterEmbedWidget>
    with AfterLayoutMixin<TwitterEmbedWidget> {
  bool _isLoading = true;
  Map _twitterJson;

  @override
  void afterFirstLayout(BuildContext context) {
    fetchTwitterJson();
  }

  void fetchTwitterJson() async {
    Uri url = Uri.parse(this.widget.twitterUrl);
    int tweetId = int.parse(url.pathSegments.last);
    Map<String, dynamic> twitterJson = await TwitterHelper().getTweet(tweetId);
    setState(() {
      _isLoading = false;
      _twitterJson = twitterJson;
    });
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = AppColors(context).twitterEmbedBackground();

    if (!_isLoading) {
      return Card(
        clipBehavior: Clip.antiAlias,
        color: backgroundColor,
        child: Container(
          padding: EdgeInsets.only(bottom: 10),
          child: TweetView.fromTweet(
            Tweet.fromJson(_twitterJson),
            useVideoPlayer: true,
            backgroundColor: backgroundColor,
            textStyle: TextStyle(color: AppColors(context).twitterEmbedText()),
            onTapImage: this.widget.onTapImage,
          ),
        ),
      );
    } else {
      return CircularProgressIndicator();
    }
  }
}

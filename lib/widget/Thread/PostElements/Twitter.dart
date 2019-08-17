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
  bool _failed = false;
  Map _twitterJson;

  @override
  void afterFirstLayout(BuildContext context) {
    fetchTwitterJson();
  }

  void fetchTwitterJson() async {
    Uri url = Uri.parse(this.widget.twitterUrl);
    int tweetId = int.parse(url.pathSegments.last);
    Map<String, dynamic> twitterJson = await TwitterHelper().getTweet(tweetId);
    print(twitterJson);

    if (twitterJson['errors'] != null) {
      if (this.mounted) {
        setState(() {
          _isLoading = false;
          _failed = true;
          _twitterJson = twitterJson;
        });
      }
    } else {
      if (this.mounted) {
        setState(() {
          _isLoading = false;
          _twitterJson = twitterJson;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = AppColors(context).twitterEmbedBackground();

    if (!_isLoading) {
      if (!_failed) {
        return Card(
          clipBehavior: Clip.antiAlias,
          color: backgroundColor,
          child: Container(
            child: TweetView.fromTweet(
              Tweet.fromJson(_twitterJson),
              useVideoPlayer: true,
              backgroundColor: backgroundColor,
              textStyle:
                  TextStyle(color: AppColors(context).twitterEmbedText()),
              onTapImage: this.widget.onTapImage,
            ),
          ),
        );
      } else {
        return Card(
          clipBehavior: Clip.antiAlias,
          color: backgroundColor,
          child: Container(
            padding: EdgeInsets.all(10),
            child: Text('Error fetching tweet: ' + _twitterJson['errors'][0]['message']),
          ),
        );
      }
    } else {
      return CircularProgressIndicator();
    }
  }
}

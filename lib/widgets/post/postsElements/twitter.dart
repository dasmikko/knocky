import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:knocky/helpers/twitterApi.dart';
import 'package:tweet_ui/models/api/tweet.dart';
import 'package:tweet_ui/tweet_ui.dart';
import 'package:tweet_ui/tweet_view.dart';

class TwitterCard extends StatefulWidget {
  final String tweetUrl;
  final Function onTapImage;

  TwitterCard({this.tweetUrl, this.onTapImage});

  @override
  _TwitterCardState createState() => _TwitterCardState();
}

class _TwitterCardState extends State<TwitterCard>
    with AfterLayoutMixin<TwitterCard> {
  bool _isLoading = true;
  bool _failed = false;
  Map _twitterJson;

  @override
  void afterFirstLayout(BuildContext context) {
    fetchTwitterJson();
  }

  void fetchTwitterJson() async {
    Uri url = Uri.parse(this.widget.tweetUrl);
    int tweetId = int.parse(url.pathSegments.last);
    Map<String, dynamic> twitterJson = await TwitterHelper().getTweet(tweetId);

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
    if (_isLoading) return CircularProgressIndicator();
    if (_failed) return Text('failed to load tweet');
    return EmbeddedTweetView.fromTweet(Tweet.fromJson(_twitterJson));
  }
}

import 'package:after_layout/after_layout.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knocky/helpers/twitterApi.dart';
import 'package:knocky/widgets/CachedSizeWidget.dart';
import 'package:tweet_ui/models/api/tweet.dart';
import 'package:tweet_ui/tweet_ui.dart';

class TwitterCard extends StatefulWidget {
  final Key key;
  final String tweetUrl;
  final Function onTapImage;

  TwitterCard({this.key, this.tweetUrl, this.onTapImage}) : super(key: key);

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

  @override
  void dispose() {
    super.dispose();
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
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 600,
      ),
      child: EmbeddedTweetView.fromTweet(
        Tweet.fromJson(_twitterJson),
        backgroundColor: Get.isDarkMode ? Colors.grey[800] : Colors.white,
        darkMode: Get.isDarkMode,
      ),
    );
  }
}

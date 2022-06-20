import 'package:after_layout/after_layout.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:knocky/helpers/twitterApi.dart';
import 'package:knocky/widgets/CachedSizeWidget.dart';
import 'package:measure_size/measure_size.dart';
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
    final box = GetStorage('sizeCache');
    Size loadedWidgetSize = Size.zero;
    final bool hasCachedSize = box.hasData(this.widget.tweetUrl);

    // Check if we have cached the image size
    if (hasCachedSize) {
      Map cachedSize = box.read(this.widget.tweetUrl);
      print('Found cached size: ' + cachedSize.toString());
      loadedWidgetSize = Size(
        cachedSize['width'],
        cachedSize['height'],
      );
    } else {
      print('Found no cached size');
    }

    if (_isLoading)
      return Container(
        height: loadedWidgetSize != Size.zero ? loadedWidgetSize.height : null,
        width: 300,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    if (_failed) return Text('failed to load tweet');
    return MeasureSize(
      onChange: (size) {
        if (!hasCachedSize) {
          var sizeMap = Map();
          sizeMap['height'] = size.height;
          sizeMap['width'] = size.width;
          box.writeIfNull(this.widget.tweetUrl, sizeMap);
        } else {
          print('mesured size updated ' + size.toString());
          print(this.widget.tweetUrl + ' using cached size');
          if (loadedWidgetSize.height < size.height ||
              loadedWidgetSize.width < size.width) {
            print('Cache is smaller, update it');
            var sizeMap = Map();
            sizeMap['height'] = size.height;
            sizeMap['width'] = size.width;
            box.writeIfNull(this.widget.tweetUrl, sizeMap);
          } else {
            print('Cache is up to date');
          }
        }
      },
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 600,
        ),
        child: EmbeddedTweetView.fromTweetV1(
          TweetV1Response.fromJson(_twitterJson),
          backgroundColor: Get.isDarkMode ? Colors.grey[800] : Colors.white,
          darkMode: Get.isDarkMode,
        ),
      ),
    );
  }
}

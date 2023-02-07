import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:knocky/helpers/twitterApi.dart';
import 'package:knocky/widgets/InkWellOnWidget.dart';
import 'package:measure_size/measure_size.dart';
import 'package:tweet_ui/tweet_ui.dart';
import 'package:url_launcher/url_launcher_string.dart';

class TwitterCard extends StatefulWidget {
  final Key? key;
  final String? tweetUrl;
  final Function? onTapImage;

  TwitterCard({this.key, this.tweetUrl, this.onTapImage}) : super(key: key);

  @override
  _TwitterCardState createState() => _TwitterCardState();
}

class _TwitterCardState extends State<TwitterCard>
    with AfterLayoutMixin<TwitterCard> {
  bool _isLoading = true;
  bool _failed = false;
  late Map _twitterJson;

  @override
  void afterFirstLayout(BuildContext context) {
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget handleImage() {
    return Container(
      width: 100,
      height: 100,
      margin: EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/twitter_logo_blue.png'),
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
            try {
              await launchUrlString(this.widget.url!,
                  mode: LaunchMode.externalNonBrowserApplication);
            } catch (e) {
              throw 'Could not launch $this.widget.url';
            }
          },
          child: Container(
            padding: EdgeInsets.all(10),
            color: Colors.grey[800],
            child: Row(
              children: [
                handleImage(),
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                          margin: EdgeInsets.only(bottom: 15),
                          child: Text(
                            'Open tweet',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                      Container(
                        margin: EdgeInsets.only(bottom: 15),
                        child:
                        Text(_description!, style: TextStyle(fontSize: 12)),
                      ),
                      Text(
                          this.widget.url != null
                              ? this.widget.url!
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

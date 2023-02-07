import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:knocky/widgets/InkWellOnWidget.dart';
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
  void afterFirstLayout(BuildContext context) {}

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
            fit: BoxFit.fitWidth,
            alignment: Alignment.center),
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
              await launchUrlString(this.widget.tweetUrl!,
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
                            'Tweet',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                      Container(
                        margin: EdgeInsets.only(bottom: 15),
                        child: Text('Tap to view tweet',
                            style: TextStyle(fontSize: 12)),
                      ),
                      Text(
                          this.widget.tweetUrl != null
                              ? this.widget.tweetUrl!
                              : 'wtf no url',
                          style: TextStyle(fontSize: 12, color: Colors.blue)),
                    ],
                  ),
                ),
              ].toList(),
            ),
          ),
        ),
      ),
    );
  }
}

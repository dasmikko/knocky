import 'package:bbob_dart/bbob_dart.dart' as bbob;
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/zoomable.dart';
import 'package:knocky_edge/widget/ZoomWidget.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:knocky_edge/helpers/bbcodeparser.dart' as bbcodeparser;
import 'package:knocky_edge/models/thread.dart';
import 'package:knocky_edge/widget/Thread/PostElements/Twitter.dart';
import 'package:knocky_edge/widget/Thread/PostElements/Video.dart';
import 'package:knocky_edge/widget/Thread/PostElements/YouTubeEmbed.dart';

class ThreadGalleryScreen extends StatefulWidget {
  final Thread thread;

  ThreadGalleryScreen({this.thread});

  @override
  _ThreadGalleryScreenState createState() => _ThreadGalleryScreenState();
}

class _ThreadGalleryScreenState extends State<ThreadGalleryScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<String> urls = new List();
  List<bbob.Element> elements = new List();
  int _currentPage = 0;
  bool _isZooming = false;

  @override
  void initState() {
    super.initState();
    _currentPage = 0;
    print(this.widget.thread.posts.length);

    // Get all image urls
    this.widget.thread.posts.forEach((post) {
      List<bbob.Node> nodes = bbcodeparser.BBCodeParser().parse(post.content);
      nodes.forEach((node) {
        if (node.runtimeType == bbob.Element) {
          var element = node as bbob.Element;

          switch (element.tag) {
            case 'img':
            case 'twitter':
            case 'video':
            case 'youtube':
              this.elements.add(element);
              break;
          }

          /*if (element.tag == 'img') {
            print(element.textContent);
            this.urls.add(element.textContent);
          }*/
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(200, 0, 0, 0),
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Thread Gallery"),
        actions: <Widget>[
          // action button
          IconButton(
            icon: Icon(Icons.file_download),
            tooltip: "Download image",
            onPressed: () async {},
          ),
          IconButton(
            icon: Icon(Icons.content_copy),
            tooltip: "Copy image link",
            onPressed: () async {
              Clipboard.setData(
                  new ClipboardData(text: this.urls[_currentPage]));
              _scaffoldKey.currentState.showSnackBar(new SnackBar(
                content: Text('Image link copied to clipboard'),
              ));
            },
          ),
        ],
      ),
      body: PageView.builder(
        physics: !_isZooming
            ? AlwaysScrollableScrollPhysics()
            : NeverScrollableScrollPhysics(),
        controller: PageController(
          initialPage: 0,
        ),
        onPageChanged: (int newIndex) {
          setState(() {
            _currentPage = newIndex;
          });
        },
        itemCount: this.elements.length,
        itemBuilder: (BuildContext context, int index) {
          bbob.Element element = this.elements[index];
          print(element);

          switch (element.tag) {
            case 'img':
              return Container(
                child: CustomZoomWidget(
                  onZoomStateChange: (bool zoomState) {
                    setState(() {
                      _isZooming = zoomState;
                    });
                  },
                  // default factor is 1.0, use 0.0 to disable boundary
                  child: CachedNetworkImage(
                    placeholder: (context, url) => CircularProgressIndicator(),
                    imageUrl: element.textContent,
                  ),
                ),
              );
            case 'twitter':
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    child: TwitterEmbedWidget(
                      onTapImage: (List<String> allPhotos, int photoIndex,
                              String hashcode) =>
                          {},
                      twitterUrl: element.textContent,
                    ),
                  )
                ],
              );
            case 'youtube':
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    child: YoutubeVideoEmbed(
                      url: element.textContent,
                    ),
                  )
                ],
              );
            case 'video':
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    child: VideoElement(
                      url: element.textContent,
                    ),
                  )
                ],
              );
            default:
              return Text('Not supported element');
          }
        },
      ),
    );
  }
}

import 'dart:io';
import 'package:bbob_dart/bbob_dart.dart' as bbob;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:knocky_edge/widget/ZoomWidget.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:knocky_edge/helpers/bbcodeparser.dart' as bbcodeparser;
import 'package:knocky_edge/models/thread.dart';
import 'package:knocky_edge/widget/Thread/PostElements/Twitter.dart';
import 'package:knocky_edge/widget/Thread/PostElements/Video.dart';
import 'package:knocky_edge/widget/Thread/PostElements/YouTubeEmbed.dart';
import 'package:mime/mime.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:knocky_edge/widget/ImageViewerBottomSheet.dart';
import 'package:path_provider/path_provider.dart';

class ThreadGalleryScreen extends StatefulWidget {
  final Thread thread;

  ThreadGalleryScreen({this.thread});

  @override
  _ThreadGalleryScreenState createState() => _ThreadGalleryScreenState();
}

class _ThreadGalleryScreenState extends State<ThreadGalleryScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  GlobalKey bottomSheetKey = GlobalKey();

  List<String> urls = new List();
  List<bbob.Element> elements = new List();
  int _currentPage = 0;
  bool _isZooming = false;
  bool _isOpen = false;

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

  void copyUrl(context) {
    bbob.Element element = this.elements[_currentPage];
    Clipboard.setData(new ClipboardData(text: element.textContent));
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: Text('URL copied to clipboard'),
    ));
    Navigator.pop(context);
  }

  void openURL() async {
    bbob.Element element = this.elements[_currentPage];
    String url = element.textContent;

    if (await canLaunch(url)) {
      if (Platform.isIOS) {
        await launch(url, forceSafariVC: false);
      } else {
        await launch(url, forceWebView: false);
      }
    } else {
      throw 'Could not launch $url';
    }
    Navigator.pop(context);
  }

  void shareURL() async {
    bbob.Element element = this.elements[_currentPage];
    Uri url = Uri.parse(element.textContent);

    bool isDirectSharable = element.tag == 'img' || element.tag == 'video';

    // Make temp url for the image
    Directory tempDir = await getTemporaryDirectory();
    String fileUrl = tempDir.path + '/' + url.pathSegments.last;

    if (isDirectSharable) {
      // Download the element
      Response response;
      Dio dio = new Dio();
      response =
          await dio.download(element.textContent, fileUrl, deleteOnError: true);

      print(lookupMimeType(fileUrl));
      // Share the temp file
      await Share.shareFiles([fileUrl], mimeTypes: [lookupMimeType(fileUrl)]);

      // Delete the temp file
      final file = File(fileUrl);
      file.delete();
    } else {
      Share.share(element.textContent);
    }
    Navigator.pop(context);
  }

  void downloadEmbed(BuildContext context) async {
    bbob.Element element = this.elements[_currentPage];
    Uri url = Uri.parse(element.textContent);

    // Make temp url for the image
    String saveDir = '/storage/emulated/0/Knocky/';
    String fileUrl = saveDir + url.pathSegments.last;

    print(fileUrl.toString());

    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();

// You can request multiple permissions at once.

    print(statuses[Permission.storage]);

    if (statuses[Permission.storage].isDenied) return;

    // Download the element
    GallerySaver.saveImage(url.toString(), albumName: 'Knocky').then(
      (bool success) async {
        if (success) {
          _scaffoldKey.currentState.showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Text(
                'Image was saved to gallery',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
          Navigator.pop(context);
        } else {
          _scaffoldKey.currentState.showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                'Error saving image to gallery..',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
          Navigator.pop(context);
        }
      },
    );
  }

  void showBottomSheet(BuildContext scaffoldcontext) {
    bbob.Element element = this.elements[_currentPage];

    showModalBottomSheet(
      backgroundColor: Colors.grey[900].withOpacity(0.5),
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Wrap(
            children: [
              Wrap(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Text(element.textContent),
                  ),
                ],
              ),
              Container(
                color: Colors.grey[900],
                padding: EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(Icons.copy),
                      onPressed: () => copyUrl(scaffoldcontext),
                    ),
                    IconButton(
                        icon: Icon(Icons.open_in_browser), onPressed: openURL),
                    IconButton(icon: Icon(Icons.share), onPressed: shareURL),
                    IconButton(
                        icon: Icon(Icons.file_download),
                        onPressed: () => downloadEmbed(scaffoldcontext)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
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
      bottomNavigationBar: ImageViewerBottomSheet(
          currentPage: _currentPage,
          totalPages: elements.length,
          url: elements[_currentPage].textContent,
          embedType: elements[_currentPage].tag,
          scaffoldKey: _scaffoldKey),
    );
  }
}

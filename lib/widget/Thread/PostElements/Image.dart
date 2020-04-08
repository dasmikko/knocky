import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:knocky/helpers/bbcodehelper.dart';
import 'package:knocky/models/slateDocument.dart';
import 'package:knocky/screens/imageViewer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:path/path.dart';

class ImageWidget extends StatefulWidget {
  final String url;
  final int postId;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final SlateObject slateObject;
  final String bbcode;

  ImageWidget({this.url, this.scaffoldKey, this.slateObject, this.bbcode, this.postId});

  @override
  _ImageWidgetState createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  List<String> findAllImages() {
    List<String> urls = List();

    if (this.widget.slateObject == null) {
      urls = BBCodeHelper().getUrls(this.widget.bbcode);
    } else {
      this.widget.slateObject.document.nodes.forEach((item) {
        if (item.type == 'image') {
          urls.add(item.data.src);
        }
      });
    }

    return urls;
  }

  void imageLongPress(BuildContext context, String url) async {
    String fileName = basename(url);

    switch (await showDialog<int>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text(fileName),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 1);
                },
                child: const Text('Copy image link'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 2);
                },
                child: const Text('Download image'),
              ),
            ],
          );
        })) {
      case 1:
        Clipboard.setData(new ClipboardData(text: url));
        this.widget.scaffoldKey.currentState.showSnackBar(new SnackBar(
              content: Text('Image link copied to clipboard'),
            ));
        break;
      case 2:
        //DownloadHelper().downloadFile(url, this.widget.scaffoldKey);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => this.imageLongPress(context, this.widget.url),
      onTap: () {
        Navigator.of(context, rootNavigator: true).push(
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (context, anim, anim2) => ImageViewerScreen(
              url: this.widget.url,
              urls: findAllImages(),
              postId: widget.postId,
            ),
            transitionsBuilder: (___, Animation<double> animation, ____, Widget child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            }
          ),
        );
      },
      child: Hero(
        tag: this.widget.url + this.widget.postId.toString(),
        child: CachedNetworkImage(
          placeholder: (BuildContext context, String url) {
            return CircularProgressIndicator();
          },
          imageUrl: this.widget.url,
        ),
      ),
    );
  }
}

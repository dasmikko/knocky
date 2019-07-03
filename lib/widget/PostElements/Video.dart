import "package:flutter/material.dart";
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'package:knocky/helpers/Download.dart';

class VideoElement extends StatefulWidget {
  String url;
  GlobalKey<ScaffoldState> scaffoldKey;


  VideoElement(@required this.url, this.scaffoldKey);

  @override
  _VideoElementState createState() => _VideoElementState();
}

class _VideoElementState extends State<VideoElement> {
  VideoPlayerController vidController;
  ChewieController chewieController;
  Size size = new Size(16, 9);

  @override
  void initState() {
    super.initState();

    vidController = VideoPlayerController.network(widget.url);

    vidController
      ..initialize().then((onValue) {
        print(vidController.value.size);
        setState(() {
          size = vidController.value.size;

          chewieController = ChewieController(
              videoPlayerController: vidController,
              aspectRatio: size.width / size.height,
              autoInitialize: false,
              looping: true,
              autoPlay: false);
        });
      });

    chewieController = ChewieController(
        videoPlayerController: vidController,
        aspectRatio: size.width / size.height,
        autoInitialize: false,
        looping: true,
        autoPlay: false);
  }

  @override
  void dispose() {
    vidController.dispose();
    chewieController.dispose();
    super.dispose();
  }

  void onLongPress(BuildContext context, String url) async {
    String fileName = basename(url);
    
    switch (await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(fileName),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () { Navigator.pop(context, 1); },
              child: const Text('Copy video link'),
            ),
            SimpleDialogOption(
              onPressed: () { Navigator.pop(context, 2); },
              child: const Text('Download video'),
            ),
          ],
        );
      }
    )) {
      case 1:
        Clipboard.setData(new ClipboardData(text: url));
        this.widget.scaffoldKey.currentState.showSnackBar(new SnackBar(
          content: Text('Image link copied to clipboard'),
        ));
      break;
      case 2:
         DownloadHelper().downloadFile(url, this.widget.scaffoldKey);  
      break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.0),
      child: GestureDetector(
        onLongPress: () => this.onLongPress(context, this.widget.url),
        child: Chewie(
          controller: chewieController,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher_string.dart';

class VideoEmbed extends StatefulWidget {
  final String url;

  VideoEmbed({this.url});

  @override
  _VideoEmbedState createState() => _VideoEmbedState();
}

class _VideoEmbedState extends State<VideoEmbed> {
  VideoPlayerController videoPlayerController;
  ChewieController chewieController;

  @override
  void initState() {
    super.initState();
    initializePlayer();
  }

  Future<void> initializePlayer() async {
    videoPlayerController = VideoPlayerController.network(widget.url);
    await videoPlayerController.initialize();
    chewieController = ChewieController(
        videoPlayerController: videoPlayerController,
        additionalOptions: (context) {
          return <OptionItem>[
            OptionItem(
                onTap: () async {
                  try {
                    await launch(this.widget.url);
                  } catch (e) {
                    throw 'Could not launch $this.widget.url';
                  }
                },
                iconData: Icons.open_in_browser,
                title: "Open in browser")
          ];
        });
    setState(() {});
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    chewieController.dispose();

    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.all(
          Radius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black54,
          ),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: chewieController != null &&
                    chewieController.videoPlayerController.value.isInitialized
                ? Chewie(
                    controller: chewieController,
                  )
                : Text('Loading'),
          ),
        ),
      ),
    );
  }
}

import 'package:chewie/chewie.dart';
import 'package:chewie_audio/chewie_audio.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:video_player/video_player.dart';

class VocarooEmbed extends StatefulWidget {
  final String? url;
  const VocarooEmbed({Key? key, this.url}) : super(key: key);

  @override
  State<VocarooEmbed> createState() => _VocarooEmbedState();
}

class _VocarooEmbedState extends State<VocarooEmbed> {
  late VideoPlayerController videoPlayerController;
  ChewieAudioController? chewieController;

  @override
  void initState() {
    super.initState();
    initializePlayer();
  }

  Future<void> initializePlayer() async {
    String id = widget.url!.split('/').last;
    videoPlayerController = VideoPlayerController.network(
        "https://media1.vocaroo.com/mp3/$id",
        formatHint: VideoFormat.other,
        httpHeaders: {
          'Referer': 'https://vocaroo.com/',
        });
    await videoPlayerController.initialize();
    chewieController = await ChewieAudioController(
      videoPlayerController: videoPlayerController,
    );
    setState(() {});
  }

  @override
  void dispose() {
    videoPlayerController?.dispose();
    chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.all(
          Radius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 202, 255, 112),
          ),
          child: chewieController != null &&
                  chewieController!.videoPlayerController.value.isInitialized
              ? Column(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: 12),
                          child: ExtendedImage.network(
                            "https://cdn.vocaroo.com/images/mascot-robot-100px.png",
                          ),
                        ),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(width: 2.0, color: Colors.black54),
                          ),
                          child: Text(
                            'Open in browser',
                            style: TextStyle(color: Colors.black54),
                          ),
                          onPressed: () async {
                            try {
                              await launch(this.widget.url!);
                            } catch (e) {
                              throw 'Could not launch $this.widget.url';
                            }
                          },
                        ),
                      ],
                    ),
                    ChewieAudio(
                      controller: chewieController!,
                    )
                  ],
                )
              : Center(child: Text('Loading vocaroo embed')),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:better_player/better_player.dart';

class VideoEmbed extends StatefulWidget {
  final String url;

  VideoEmbed({this.url});

  @override
  _VideoEmbedState createState() => _VideoEmbedState();
}

class _VideoEmbedState extends State<VideoEmbed> {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height - 124,
      ),
      child: BetterPlayer.network(
        this.widget.url,
        betterPlayerConfiguration: BetterPlayerConfiguration(
          controlsConfiguration: BetterPlayerControlsConfiguration(
            enableSkips: false,
          ),
          autoDetectFullscreenDeviceOrientation: true,
          fit: BoxFit.contain,
          aspectRatio: 16 / 9,
        ),
      ),
    );
  }
}

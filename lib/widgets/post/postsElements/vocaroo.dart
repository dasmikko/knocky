import 'package:better_player/better_player.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

class VocarooEmbed extends StatelessWidget {
  final String? url;
  const VocarooEmbed({Key? key, this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String id = url!.split('/').last;

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: BetterPlayer.network(
          "https://media1.vocaroo.com/mp3/$id",
          betterPlayerConfiguration: BetterPlayerConfiguration(
            overlay: Container(
              color: Color.fromARGB(255, 202, 255, 112),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 12),
                    child: ExtendedImage.network(
                      "https://cdn.vocaroo.com/images/mascot-robot-100px.png",
                    ),
                  ),
                  Text(
                    'Vocaroo',
                    style: TextStyle(color: Colors.grey[800]),
                  )
                ],
              ),
            ),
            controlsConfiguration: BetterPlayerControlsConfiguration(
              enableQualities: false,
              enableSubtitles: false,
              enableAudioTracks: true,
              enableFullscreen: false,
              enableSkips: false,
            ),
            autoDetectFullscreenDeviceOrientation: true,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

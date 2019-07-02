import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PostHeader extends StatelessWidget {
  String username;
  String avatarUrl;
  String backgroundUrl;

  PostHeader({this.avatarUrl, this.backgroundUrl, this.username});

  @override
  Widget build(BuildContext context) {
    print('avatar: ' +  avatarUrl);
    print('background : ' + backgroundUrl);

    bool hasBg = (backgroundUrl != null || backgroundUrl != '' || backgroundUrl != 'none.webp');
    bool hasAvatar = (avatarUrl != null || avatarUrl != '');

    return Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        image: hasBg != null ? DecorationImage(
          alignment: Alignment.center,
          fit: BoxFit.cover,
          colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.dstATop),
          image: CachedNetworkImageProvider('https://knockout-production-assets.nyc3.digitaloceanspaces.com/image/' + backgroundUrl)
        ) : null
      ),
      child: Row(children: <Widget>[
        if(hasAvatar) 
          Container(
            margin: EdgeInsets.only(right: 10),
            height: 40,
            child: CachedNetworkImage(
              imageUrl: 'https://knockout-production-assets.nyc3.digitaloceanspaces.com/image/' + avatarUrl,
            ),
          ),
        Text(username, style: TextStyle(fontWeight: FontWeight.bold),)
      ],),
    );
  }
}
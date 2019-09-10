import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/models/userProfile.dart';

class UserProfileScreen extends StatefulWidget {
  final int userId;
  final String username;
  final String avatarUrl;
  final String backgroundUrl;

  UserProfileScreen(
      {this.userId, this.username, this.avatarUrl, this.backgroundUrl});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  UserProfile _profile;
  bool _fetched = false;
  int _sharedValue = 0;

  @override
  void initState() {
    super.initState();
    getProfile();
  }

  void getProfile() async {
    UserProfile profile =
        await KnockoutAPI().getUserProfile(this.widget.userId);
    setState(() {
      _profile = profile;
      _fetched = true;
    });
    print(profile);
  }

  Widget contentLoaded(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          dialogCard(),
          Positioned(
            left: 16,
            right: 16,
            child: CachedNetworkImage(
              imageUrl:
                  'https://knockout-production-assets.nyc3.digitaloceanspaces.com/image/' +
                      this.widget.avatarUrl,
            ),
          ),
        ],
      ),
    );
  }

  Widget dialogCard() {
    return Container(
      width: 300,
      height: 400,
      padding: EdgeInsets.only(
        top: 80,
        bottom: 32,
        left: 36,
        right: 36,
      ),
      margin: EdgeInsets.only(top: 130),
      decoration: new BoxDecoration(
        image: DecorationImage(
          image: CachedNetworkImageProvider(
              'https://knockout-production-assets.nyc3.digitaloceanspaces.com/image/' +
                  this.widget.backgroundUrl),
          fit: BoxFit.cover,
          colorFilter: new ColorFilter.mode(
              Colors.black.withOpacity(0.2), BlendMode.dstATop),
        ),
        color: Colors.grey[800],
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            offset: const Offset(0.0, 10.0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
            CrossAxisAlignment.stretch, // To make the card compact
        children: <Widget>[
          Align(
            child: Text(
              this.widget.username,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: contentLoaded(context),
    );
  }
}

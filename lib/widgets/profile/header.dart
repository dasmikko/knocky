import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:knocky/models/userProfile.dart';
import 'package:knocky/models/userProfileDetails.dart';
import 'package:knocky/models/userProfileRatings.dart';
import 'package:knocky/widgets/profile/ratings.dart';
import 'package:knocky/widgets/shared/avatar.dart';
import 'package:knocky/widgets/shared/background.dart';
import 'package:knocky/widgets/shared/usergroup.dart';
import 'package:knocky/widgets/shared/username.dart';

class ProfileHeader extends StatefulWidget {
  final UserProfileRatings ratings;
  final UserProfile profile;
  final UserProfileDetails details;

  ProfileHeader(
      {@required this.profile, @required this.ratings, @required this.details});

  @override
  _ProfileHeaderState createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader>
    with SingleTickerProviderStateMixin {
  bool showingLinks = false;
  final double _linkIconSize = 16;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned.fill(
          child: Container(
              child: Background(backgroundUrl: widget.profile.backgroundUrl))),
      Positioned.fill(child: gradientOverlay()),
      content(),
      controls()
    ]);
  }

  Widget content() {
    return Container(
        margin: EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Column(children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Avatar(
                avatarUrl: widget.profile?.avatarUrl,
                isBanned: widget.profile?.banned),
            headerLabels(context),
          ]),
          Container(height: 40, child: ProfileRatings(ratings: widget.ratings)),
        ]));
  }

  Widget controls() {
    return Positioned(top: 0, right: 0, child: linksButton());
  }

  Widget linksButton() {
    return (widget.details?.social?.entries?.length ?? 0) > 0
        ? IconButton(
            icon: FaIcon(showingLinks
                ? FontAwesomeIcons.addressCard
                : FontAwesomeIcons.link),
            onPressed: () => onLinksButtonTapped())
        : Container();
  }

  onLinksButtonTapped() {
    setState(() {
      showingLinks = !showingLinks;
    });
  }

  Widget headerLabels(BuildContext context) {
    return Expanded(
        child: Container(
            height: 148,
            margin: EdgeInsets.fromLTRB(8, 0, 0, 8),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Username(
                  username: widget.profile.username,
                  usergroup: widget.profile.usergroup,
                  bold: true,
                  banned: widget.profile?.banned,
                  fontSize: 26),
              ...(showingLinks ? linksSubtitle() : regularSubtitle()),
            ])));
  }

  List<Widget> regularSubtitle() {
    return [
      UsergroupLabel(
          usergroup: widget.profile.usergroup,
          banned: widget.profile?.banned,
          joinDate: widget.profile.joinDate),
      Container(
          margin: EdgeInsets.only(top: 4),
          child: Text(widget.details?.bio ?? '',
              style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Color.fromRGBO(255, 255, 255, 0.6))))
    ];
  }

  List<Widget> linksSubtitle() {
    return [
      Container(
          height: 100,
          child: ListView(children: [
            ...getLink('website', (website) => website, FontAwesomeIcons.link),
            ...getLink(
                'discord', (discord) => discord, FontAwesomeIcons.discord),
            ...getLink('github', (github) => github, FontAwesomeIcons.github),
            ...getLink('gitlab', (gitlab) => gitlab, FontAwesomeIcons.gitlab),
            ...getLink(
                'steam', (steam) => steam["url"], FontAwesomeIcons.steam),
            ...getLink('tumblr', (tumblr) => tumblr, FontAwesomeIcons.tumblr),
            ...getLink('twitch', (twitch) => twitch, FontAwesomeIcons.twitch),
            ...getLink(
                'twitter', (twitter) => twitter, FontAwesomeIcons.twitter),
          ]))
    ];
  }

  // TODO: add onTap function here
  List<Widget> getLink(String key, Function extractionMethod, IconData icon) {
    if (widget?.details?.social == null ||
        !widget.details.social.containsKey(key)) {
      return [];
    }
    String textLabel = extractionMethod(widget.details.social[key]);
    return [
      Container(
          margin: EdgeInsets.only(bottom: 8),
          child: Row(children: [
            Container(
                margin: EdgeInsets.only(right: 4),
                height: _linkIconSize,
                width: _linkIconSize,
                child: Center(child: FaIcon(icon, size: _linkIconSize))),
            Expanded(child: Text(textLabel, overflow: TextOverflow.clip))
          ]))
    ];
  }

  getSocialUrl() {}

  Widget gradientOverlay() {
    return Container(
        alignment: Alignment.bottomCenter,
        child: Container(
            height: 64,
            decoration: BoxDecoration(
                gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Color.fromRGBO(0, 0, 0, 0.75)],
            ))));
  }
}

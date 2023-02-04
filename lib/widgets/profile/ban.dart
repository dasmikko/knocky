import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:knocky/helpers/colors.dart';
import 'package:knocky/helpers/format.dart';
import 'package:knocky/models/userBans.dart';
import 'package:knocky/widgets/post/toolbar.dart';

class ProfileBan extends StatelessWidget {
  final UserBan ban;

  ProfileBan({required this.ban});

  @override
  Widget build(BuildContext context) {
    var bannedRed = AppColors(context).bannedColor();
    var bannedDarkRed = AppColors(context).darken(bannedRed, 0.2);
    return Container(
        child: Opacity(
            opacity: isRetracted() ? 0.66 : 1,
            child: Card(
                color: bannedRed,
                margin: EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: Column(children: [
                  Toolbar.toolbarBox(bannedDarkRed, [expirationTime()]),
                  body(),
                  footer()
                ]))));
  }

  bool isRetracted() {
    // they set the expiration date to 20 years ago if they take the ban back???
    return ban.expiresAt!.year < 2010;
  }

  Widget expirationTime() {
    var isInPast = true;
    var time = Format.humanReadableTimeSince(ban.expiresAt!);
    var label = isRetracted()
        ? "Retracted"
        : "${isInPast ? 'Expired' : 'Expires in'} $time";
    return Text(label, style: TextStyle(fontWeight: FontWeight.bold));
  }

  Widget banReason() {
    return Container(
        width: double.infinity,
        margin: EdgeInsets.only(top: 8),
        child: Text("“${ban.banReason}”",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)));
  }

  Widget agoTimeInThread() {
    return Container(
        width: double.infinity,
        margin: EdgeInsets.only(top: 16),
        child: Text(
            "${Format.humanReadableTimeSince(ban.createdAt!)} in ${ban.thread['title']}",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            overflow: TextOverflow.ellipsis,
            maxLines: 3));
  }

  Widget banTime() {
    var duration = Format.duration(ban.createdAt!, ban.expiresAt!);
    return Row(children: [
      FaIcon(FontAwesomeIcons.solidClock, size: 16, color: Colors.white),
      Container(margin: EdgeInsets.only(left: 4), child: Text("$duration"))
    ]);
  }

  Widget bannedBy() {
    return Text("by ${ban.bannedBy["username"]}",
        overflow: TextOverflow.ellipsis);
  }

  Widget footer() {
    return Container(
        margin: EdgeInsets.fromLTRB(8, 32, 8, 16),
        child: Row(children: [Expanded(child: bannedBy()), banTime()]));
  }

  Widget body() {
    return Container(
        margin: EdgeInsets.all(8),
        child: Column(children: [banReason(), agoTimeInThread()]));
  }
}

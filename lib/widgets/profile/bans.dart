import 'package:flutter/widgets.dart';
import 'package:knocky/models/userBans.dart';
import 'package:knocky/widgets/profile/ban.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ProfileBans extends StatelessWidget {
  final UserBans? bans;
  final itemScrollController = new ItemScrollController();

  ProfileBans({required this.bans});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.fromLTRB(4, 16, 4, 16),
        child: ScrollablePositionedList.builder(
          itemScrollController: itemScrollController,
          addAutomaticKeepAlives: true,
          minCacheExtent: MediaQuery.of(context).size.height,
          itemCount: bans!.userBans!.length,
          itemBuilder: (BuildContext context, int index) {
            var userBan = bans!.userBans![index];
            return ProfileBan(ban: userBan);
          },
        ));
  }
}

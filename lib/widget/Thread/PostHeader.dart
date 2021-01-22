import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:knocky_edge/helpers/colors.dart';
import 'package:knocky_edge/models/thread.dart';
//import 'package:knocky_edge/screens/userProfile.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:scoped_model/scoped_model.dart';
import 'package:knocky_edge/state/authentication.dart';

class PostHeader extends StatelessWidget {
  final BuildContext context;
  final int userId;
  final int userGroup;
  final String username;
  final String avatarUrl;
  final String backgroundUrl;
  final ThreadPost threadPost;
  final Thread thread;
  final int currentPage;
  final bool textSelectable;
  final Function onTextSelectableChanged;

  PostHeader(
      {this.avatarUrl,
      this.backgroundUrl,
      this.username,
      this.userId,
      this.userGroup,
      this.threadPost,
      this.context,
      this.thread,
      this.currentPage,
      this.textSelectable,
      this.onTextSelectableChanged});

  void onSelectOverflowItem(int item) {
    switch (item) {
      case 0:
        Clipboard.setData(new ClipboardData(
            text:
                'https://knockout.chat/thread/${thread.id}/${currentPage}#post-${threadPost.id}'));
        break;
      case 99:
        this.onTextSelectableChanged(!this.textSelectable);
        break;
      default:
    }
  }

  void onTapUsername(BuildContext context) {
    /*Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => UserProfileScreen(
          userId: this.userId,
          username: this.username,
          avatarUrl: this.avatarUrl,
          backgroundUrl: this.backgroundUrl,
          postId: this.threadPost.id,
        ),
      ),
    );*/
  }

  PopupMenuItem<int> overFlowItem(Icon icon, String title, int value) {
    return PopupMenuItem<int>(
        value: value,
        child: ListTile(
          title: Text(title),
          leading: icon,
        ));
  }

  PopupMenuItem<int> overFlowItemCheckbox(String title) {
    return CheckedPopupMenuItem(
      checked: this.textSelectable,
      value: 99,
      child: Text(title),
    );
  }

  Border postHeaderBorder() {
    final int ownUserId =
        ScopedModel.of<AuthenticationModel>(context, rebuildOnChange: true)
            .userId;

    if (ownUserId == userId) {
      return Border(
        left: BorderSide(color: Color.fromRGBO(255, 216, 23, 1), width: 2),
      );
    }

    if (thread.isSubscribedTo == 1 &&
        thread.subscriptionLastSeen.isBefore(threadPost.createdAt)) {
      return Border(
        left: BorderSide(color: Color.fromRGBO(67, 104, 173, 1), width: 2),
      );
    }

    if (thread.readThreadLastSeen != null &&
        thread.readThreadLastSeen.isBefore(threadPost.createdAt)) {
      return Border(
        left: BorderSide(color: Color.fromRGBO(67, 104, 173, 1), width: 2),
      );
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final int ownUserId =
        ScopedModel.of<AuthenticationModel>(context, rebuildOnChange: true)
            .userId;

    print(username);
    print('avatarurl ' + avatarUrl);
    print('bgurl ' + backgroundUrl);

    bool hasAvatar = avatarUrl.isNotEmpty;
    bool hasBg = backgroundUrl.isNotEmpty;

    print('has avatarurl ' + hasAvatar.toString());
    print('has bgurl ' + hasBg.toString());

    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
              border: postHeaderBorder(),
              image: hasBg != false
                  ? DecorationImage(
                      alignment: Alignment.center,
                      fit: BoxFit.cover,
                      colorFilter: new ColorFilter.mode(
                          Colors.black.withOpacity(0.2), BlendMode.dstATop),
                      image: CachedNetworkImageProvider(
                          'https://knockout-production-assets.nyc3.digitaloceanspaces.com/image/' +
                              backgroundUrl))
                  : null),
          child: Row(
            children: <Widget>[
              GestureDetector(
                onTap: () => onTapUsername(context),
                child: Row(
                  children: <Widget>[
                    if (hasAvatar)
                      Container(
                        margin: EdgeInsets.only(right: 10),
                        width: 40,
                        height: 40,
                        child: Hero(
                          tag: avatarUrl + threadPost.id.toString(),
                          child: CachedNetworkImage(
                            imageUrl:
                                'https://knockout-production-assets.nyc3.digitaloceanspaces.com/image/' +
                                    avatarUrl,
                          ),
                        ),
                      ),
                    Text(
                      username,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                              AppColors(context).userGroupToColor(userGroup)),
                    ),
                  ],
                ),
              ),
              Flexible(
                flex: 1,
                child: Container(
                  alignment: Alignment.centerRight,
                  child: PopupMenuButton(
                    onSelected: onSelectOverflowItem,
                    itemBuilder: (BuildContext context) {
                      return [
                        overFlowItem(
                            Icon(Icons.content_copy), 'Copy post link', 0),
                        overFlowItemCheckbox('Make text selectable'),
                      ];
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
          color: Theme.of(context).brightness == Brightness.dark
              ? Color.fromRGBO(45, 45, 48, 1)
              : Color.fromRGBO(230, 230, 230, 1),
          child: Row(
            children: <Widget>[Text(timeago.format(threadPost.createdAt))],
          ),
        )
      ],
    );
  }
}

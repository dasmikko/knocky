import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/models/thread.dart';
import 'package:knocky/models/userProfile.dart';
import 'package:knocky/models/userProfilePosts.dart';
import 'package:knocky/widget/Thread/ThreadPostItem.dart';
import 'package:knocky/widget/UserProfilePostListItem.dart';

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
  UserProfilePosts _posts;

  @override
  void initState() {
    super.initState();
    getProfile();
    fetchPostsList();
  }

  void fetchPostsList() async {
    UserProfilePosts items =
        await KnockoutAPI().getUserProfilePosts(this.widget.userId);
    setState(() {
      _posts = items;
    });
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

  List<Widget> contentLoaded(BuildContext context) {
    return <Widget>[];
  }

  Widget dialogCard() {
    return Container(
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
    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  expandedHeight: 400,
                  pinned: true,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    title: Text(this.widget.username),
                    background: Stack(
                      fit: StackFit.passthrough,
                      children: <Widget>[
                        CachedNetworkImage(
                          color: Colors.grey,
                          colorBlendMode: BlendMode.darken,
                          fit: BoxFit.fitWidth,
                          alignment: Alignment.topCenter,
                          imageUrl:
                              'https://knockout-production-assets.nyc3.digitaloceanspaces.com/image/' +
                                  this.widget.backgroundUrl,
                        ),
                        Positioned(
                          child: Align(
                            alignment: Alignment.center,
                            child: CachedNetworkImage(
                              imageUrl:
                                  'https://knockout-production-assets.nyc3.digitaloceanspaces.com/image/' +
                                      this.widget.avatarUrl,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey,
                      tabs: [
                        Tab(icon: Icon(Icons.message), text: "Posts"),
                        Tab(
                            icon: Icon(Icons.insert_drive_file),
                            text: "Threads"),
                      ],
                    ),
                  ),
                  pinned: true,
                ),
              ];
            },
            body: TabBarView(
              children: <Widget>[
                Container(
                    child: ListView.builder(
                  itemCount: _posts != null ? _posts.posts.length : 0,
                  itemBuilder: (BuildContext bcontext, int index) {
                    return Card(
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: UserProfilePostListItem(
                          post: _posts.posts[index],
                        ),
                      ),
                    );
                  },
                )),
                Container(child: Text('Threads'))
              ],
            )),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Container(
      color: Colors.grey[900],
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

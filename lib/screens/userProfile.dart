import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/models/thread.dart';
import 'package:knocky/models/userProfile.dart';
import 'package:knocky/models/userProfilePosts.dart';
import 'package:knocky/models/userProfileThreads.dart';
import 'package:knocky/widget/SubforumDetailListItem.dart';
import 'package:knocky/widget/SubforumPopularLatestDetailListItem.dart';
import 'package:knocky/widget/Thread/ThreadPostItem.dart';
import 'package:knocky/widget/UserProfilePostListItem.dart';

class UserProfileScreen extends StatefulWidget {
  final int userId;
  final String username;
  final String avatarUrl;
  final String backgroundUrl;
  final int postId;

  UserProfileScreen(
      {this.userId, this.username, this.avatarUrl, this.backgroundUrl, this.postId});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  UserProfile _profile;
  bool _fetched = false;
  int _sharedValue = 0;
  UserProfilePosts _posts;
  UserProfileThreads _threads;

  @override
  void initState() {
    super.initState();
    getProfile();
    fetchPostsList();
    fetchThreadsList();
  }

  void fetchPostsList() async {
    UserProfilePosts items =
        await KnockoutAPI().getUserProfilePosts(this.widget.userId);
    setState(() {
      _posts = items;
    });
  }

  void fetchThreadsList() async {
    UserProfileThreads items =
        await KnockoutAPI().getUserProfileThreads(this.widget.userId);
    setState(() {
      _threads = items;
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
                            child: Hero(
                              tag: this.widget.avatarUrl + this.widget.postId.toString(),
                              child: CachedNetworkImage(
                                imageUrl:
                                    'https://knockout-production-assets.nyc3.digitaloceanspaces.com/image/' +
                                        this.widget.avatarUrl,
                              ),
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
                        Tab(
                            icon: Icon(Icons.message),
                            text: _posts == null
                                ? "Posts"
                                : 'Posts (${_posts.posts.length})'),
                        Tab(
                            icon: Icon(Icons.insert_drive_file),
                            text: _threads == null
                                ? "Threads"
                                : 'Threads (${_threads.threads.length})'),
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
                        clipBehavior: Clip.antiAlias,
                        child: Container(
                          child: UserProfilePostListItem(
                            post: _posts.posts[index],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  child: ListView.builder(
                    itemCount: _threads != null ? _threads.threads.length : 0,
                    itemBuilder: (BuildContext bcontext, int index) {
                      return SubforumPopularLatestDetailListItem(
                        threadDetails: _threads.threads[index],
                      );
                    },
                  ),
                )
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

import 'package:flutter/material.dart';
import 'package:knocky_edge/models/subforum.dart';
import 'package:after_layout/after_layout.dart';
import 'package:knocky_edge/models/subforumDetails.dart';
import 'package:knocky_edge/widget/subforumPage.dart';
import 'package:knocky_edge/widget/Drawer.dart';
import 'package:numberpicker/numberpicker.dart';

class SubforumScreen extends StatefulWidget {
  final Subforum subforumModel;

  SubforumScreen({this.subforumModel});

  @override
  _SubforumScreenState createState() => _SubforumScreenState();
}

class _SubforumScreenState extends State<SubforumScreen>
    with AfterLayoutMixin<SubforumScreen>, SingleTickerProviderStateMixin {
  SubforumDetails details;
  PageController _pageController = new PageController();
  bool isSwiping = false;
  int _totalPages;
  int _currentPage = 1;
  bool _bottomBarVisible = true;
  AnimationController expandController;
  Animation<double> animation;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    prepareAnimations();
    _totalPages = (widget.subforumModel.totalThreads / 40).ceil();
  }

  @override
  void afterFirstLayout(BuildContext context) async {
    setState(() {});
  }

  void prepareAnimations() {
    expandController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 250));
    Animation curve = CurvedAnimation(
      parent: expandController,
      curve: Curves.fastOutSlowIn,
    );
    animation = Tween(begin: 1.0, end: 0.0).animate(curve);
  }

  void showJumpDialog() {
    showDialog<int>(
        context: context,
        builder: (BuildContext context) {
          return new NumberPickerDialog.integer(
            minValue: 1,
            maxValue: _totalPages,
            title: new Text("Jump to page"),
            initialIntegerValue: 1,
          );
        }).then((int value) {
      if (value != null) _pageController.jumpToPage(value - 1);
    });
  }

  Widget content(sContext) {
    return PageView.builder(
      itemCount: _totalPages,
      onPageChanged: (int page) {
        // Show bottombar on page change
        if (!_bottomBarVisible) {
          expandController.reverse();
        }

        setState(() {
          _currentPage = page + 1;

          // Show bottombar on page change
          if (!_bottomBarVisible) {
            _bottomBarVisible = true;
          }
        });
      },
      controller: _pageController,
      itemBuilder: (BuildContext context, int position) {
        return SubforumPage(
          subforumModel: widget.subforumModel,
          page: position + 1,
          bottomBarVisible: _bottomBarVisible,
          onError: () => onFetchError(context),
          isScrollingUp: () {
            expandController.reverse();
            setState(() {
              _bottomBarVisible = true;
            });
          },
          isScrollingDown: () {
            expandController.forward();
            setState(() {
              _bottomBarVisible = false;
            });
          },
        );
      },
    );
  }

  void onFetchError(context) {
    Scaffold.of(context).hideCurrentSnackBar();
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text('Failed to load page. Try again.'),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.subforumModel.name),
        leading: BackButton(),
      ),
      body: content(context),
      drawerEdgeDragWidth: 30.0,
      drawer: DrawerWidget(
        scaffoldKey: _scaffoldKey,
      ),
      extendBody: false,
      bottomNavigationBar: SizeTransition(
        axisAlignment: -1.0,
        sizeFactor: animation,
        child: BottomAppBar(
          child: Container(
            padding: EdgeInsets.only(left: 10, right: 10),
            height: 56,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text('Page ' +
                      _currentPage.toString() +
                      ' of ' +
                      _totalPages.toString()),
                ),
                IconButton(
                  onPressed: _totalPages > 1 ? showJumpDialog : null,
                  icon: Icon(Icons.redo),
                  tooltip: 'Jump to page',
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

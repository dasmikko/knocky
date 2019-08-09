import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:knocky/models/slateDocument.dart';
import 'package:knocky/models/thread.dart';
import 'package:knocky/widget/SlateDocumentParser/SlateDocumentParser.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class PostEditor extends StatefulWidget {
  final SlateObject document;
  final Function onTapTextBlock;
  final Function onTapImageBlock;
  final Function onTapVideoBlock;
  final Function onTapYouTubeBlock;
  final Function onTapQuoteBlock;
  final Function onTapListBlock;
  final Function onTapUserQuoteBlock;
  final Function onTapTwitterBlock;
  final Function onTapStrawpollBlock;

  // Toolbar callbacks
  final Function onTapAddTextBlock;
  final Function onTapAddHeadingOne;
  final Function onTapAddHeadingTwo;
  final Function onTapAddImage;
  final Function onTapAddQuote;
  final Function onTapAddYouTubeVideo;
  final Function onTapAddVideo;
  final Function onReorderHandler;
  final Function onTapAddBulletedList;
  final Function onTapAddNumberedList;
  final Function onTapAddUserQuote;
  final Function onTapAddTwitterEmbed;
  final Function onTapAddStrawPollEmbed;

  final List<ThreadPost> replyList;

  PostEditor(
      {this.document,
      this.onTapTextBlock,
      this.onTapImageBlock,
      this.onTapListBlock,
      this.onTapQuoteBlock,
      this.onTapTwitterBlock,
      this.onTapUserQuoteBlock,
      this.onTapVideoBlock,
      this.onTapYouTubeBlock,
      this.onTapStrawpollBlock,
      this.onTapAddHeadingOne,
      this.onTapAddHeadingTwo,
      this.onTapAddImage,
      this.onTapAddQuote,
      this.onTapAddTextBlock,
      this.onTapAddVideo,
      this.onTapAddYouTubeVideo,
      this.onReorderHandler,
      this.onTapAddBulletedList,
      this.onTapAddNumberedList,
      this.onTapAddUserQuote,
      this.onTapAddTwitterEmbed,
      this.onTapAddStrawPollEmbed,
      this.replyList});

  @override
  _PostEditorState createState() => _PostEditorState();
}

class _PostEditorState extends State<PostEditor> {
  @override
  void initState() {
    super.initState();
    print(this.widget.replyList);
  }

  Widget _quoteHandler(
      SlateNode node, Function inlineHandler, Function leafHandler) {
    List<TextSpan> lines = List();
    // Handle block nodes
    node.nodes.forEach((line) {
      if (line.leaves != null) {
        double headingSize = 14.0;

        if (node.type.contains('-one')) {
          headingSize = 30.0;
        }

        if (node.type.contains('-two')) {
          headingSize = 20.0;
        }

        // Handle node leaves
        lines.addAll(leafHandler(line.leaves, fontSize: headingSize));
      }

      // Handle inline element
      if (line.object == 'inline') {
        // Handle links
        inlineHandler(node, line);
      }
    });

    return ListTile(
      onTap: () => this.widget.onTapQuoteBlock(context, node),
      leading: Icon(Icons.format_quote),
      title: RichText(
        text: TextSpan(
            children:
                lines.length > 0 ? lines : [TextSpan(text: '- empty quote')]),
      ),
    );
  }

  Widget _youtubeHandler(String youTubeUrl, SlateNode node) {
    return ListTile(
      onTap: () => this.widget.onTapYouTubeBlock(youTubeUrl, node),
      leading: Icon(Icons.ondemand_video),
      title: Text(youTubeUrl),
    );
  }

  Widget _videoHandler(SlateNode node) {
    return ListTile(
      onTap: () => this.widget.onTapVideoBlock(node),
      leading: Icon(Icons.videocam),
      title: Text(node.data.src),
    );
  }

  Widget _bulletedListHandler(List<Widget> listItemsContent, SlateNode node) {
    List<Widget> listItems = List();
    // Handle block nodes
    listItemsContent.forEach((item) {
      listItems.add(
        Container(
          margin: EdgeInsets.only(bottom: 5.0),
          child: Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(right: 10.0),
                height: 5.0,
                width: 5.0,
                decoration: new BoxDecoration(
                  color: Theme.of(context).textTheme.body1.color,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(child: item)
            ],
          ),
        ),
      );
    });

    return ListTile(
      onTap: () => this.widget.onTapListBlock(node),
      leading: Icon(Icons.format_list_bulleted),
      title: Container(
        margin: EdgeInsets.only(top: 10, bottom: 10),
        child: listItems.length > 0
            ? Text('${listItems.length} items')
            : Text('- empty list -'),
      ),
    );
  }

  Widget _numberedListHandler(List<Widget> listItemsContent, SlateNode node) {
    List<Widget> listItems = List();
    // Handle block nodes
    listItemsContent.forEach((item) {
      listItems.add(
        Container(
          margin: EdgeInsets.only(bottom: 5.0),
          child: Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(right: 10.0),
                child: Text(
                  (listItems.length + 1).toString(),
                ),
              ),
              Expanded(
                child: item,
              )
            ],
          ),
        ),
      );
    });

    return ListTile(
      onTap: () => this.widget.onTapListBlock(node),
      leading: Icon(Icons.format_list_numbered),
      title: Container(
        margin: EdgeInsets.only(top: 10, bottom: 10),
        child: listItems.length > 0
            ? Text('${listItems.length} items')
            : Text('- empty list -'),
      ),
    );
  }

  Widget _imageWidgetHandler(String imageUrl, slateObject, SlateNode node) {
    return ListTile(
      leading: Icon(Icons.image),
      onTap: () {
        this.widget.onTapImageBlock(slateObject, node);
      },
      title: Container(
        margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[Text('Image block'), Text(imageUrl)],
        ),
      ),
    );
  }

  Widget headingHandler(
      SlateNode node, Function inlineHandler, Function leafHandler) {
    List<TextSpan> lines = List();

    // Handle block nodes
    node.nodes.forEach((line) {
      if (line.leaves != null) {
        double headingSize = 14.0;

        if (node.type.contains('-one')) {
          headingSize = 30.0;
        }

        if (node.type.contains('-two')) {
          headingSize = 20.0;
        }

        // Handle node leaves
        lines.addAll(leafHandler(line.leaves, fontSize: headingSize));
      }

      // Handle inline element
      if (line.object == 'inline') {
        // Handle links
        inlineHandler(node, line);
      }
    });

    return ListTile(
      leading: Icon(node.type.contains('-one')
          ? MdiIcons.formatHeader1
          : MdiIcons.formatHeader2),
      onTap: () {
        this.widget.onTapTextBlock(context, node);
      },
      title: Container(
        margin: EdgeInsets.only(bottom: 10),
        child: RichText(
          text: lines.length > 0
              ? TextSpan(children: lines)
              : TextSpan(text: '- empty heading block -'),
        ),
      ),
    );
  }

  Widget paragraphHandler(SlateNode node, Function leafHandler) {
    List<TextSpan> lines = List();

    // Handle block nodes
    node.nodes.forEach((line) {
      if (line.leaves != null) {
        lines.addAll(leafHandler(line.leaves));
      }

      // Handle inline element
      if (line.object == 'inline') {
        // Handle links
        if (line.type == 'link') {
          line.nodes.forEach((inlineNode) {
            inlineNode.leaves.forEach((leaf) {
              lines.add(TextSpan(
                text: leaf.text,
                style: TextStyle(color: Colors.blue),
              ));
            });
          });
        } else {
          line.nodes.forEach((inlineNode) {
            inlineNode.leaves.forEach((leaf) {
              lines.add(TextSpan(text: leaf.text));
            });
          });
        }
      }
    });

    return ListTile(
      leading: Icon(Icons.text_format),
      onTap: () {
        this.widget.onTapTextBlock(context, node);
      },
      title: Container(
        margin: EdgeInsets.only(bottom: 5),
        child: RichText(
            text: lines.length > 0
                ? TextSpan(children: lines)
                : TextSpan(text: '- empty text block -')),
      ),
    );
  }

  Widget _twitterHandler(String twitterUrl, SlateNode node) {
    return ListTile(
      onTap: () => this.widget.onTapTwitterBlock(twitterUrl, node),
      leading: Icon(MdiIcons.twitter),
      title: Text(twitterUrl),
    );
  }

  Widget _strawpollHandler(SlateNode node) {
    return ListTile(
      onTap: () => this.widget.onTapStrawpollBlock(node.data.src, node),
      leading: Icon(MdiIcons.poll),
      title: Text(node.data.src),
    );
  }

  Widget _userquoteHandler(
      String username, List<Widget> widgets, bool isChild, SlateNode node) {
    return ListTile(
      onTap: () => this.widget.onTapUserQuoteBlock(node),
      leading: Icon(Icons.message),
      title: Text(username),
    );
  }

  List<Widget> editorContent() {
    return SlateDocumentParser(
      slateObject: this.widget.document,
      context: context,
      paragraphHandler: this.paragraphHandler,
      headingHandler: this.headingHandler,
      imageWidgetHandler: this._imageWidgetHandler,
      quotesHandler: _quoteHandler,
      youTubeWidgetHandler: this._youtubeHandler,
      videoWidgetHandler: this._videoHandler,
      bulletedListHandler: this._bulletedListHandler,
      numberedListHandler: this._numberedListHandler,
      twitterEmbedHandler: this._twitterHandler,
      strawpollHandler: this._strawpollHandler,
      userQuoteHandler: this._userquoteHandler,
    )
        .asWidgetList()
        .map((widget) => Container(
              key: ValueKey(widget),
              child: widget,
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: ReorderableListView(
            onReorder: this.widget.onReorderHandler,
            children: editorContent(),
          ),
        ),
        Container(
          color: Colors.grey[600],
          padding: EdgeInsets.all(0),
          child: Wrap(
            children: <Widget>[
              IconButton(
                icon: Icon(MdiIcons.textbox),
                onPressed: this.widget.onTapAddTextBlock,
              ),
              IconButton(
                icon: Icon(MdiIcons.formatHeader1),
                onPressed: this.widget.onTapAddHeadingOne,
              ),
              IconButton(
                icon: Icon(MdiIcons.formatHeader2),
                onPressed: this.widget.onTapAddHeadingTwo,
              ),
              IconButton(
                icon: Icon(Icons.format_quote),
                onPressed: this.widget.onTapAddQuote,
              ),
              IconButton(
                icon: Icon(Icons.format_list_bulleted),
                onPressed: this.widget.onTapAddBulletedList,
              ),
              IconButton(
                icon: Icon(Icons.format_list_numbered),
                onPressed: this.widget.onTapAddNumberedList,
              ),
              IconButton(
                icon: Icon(Icons.image),
                onPressed: this.widget.onTapAddImage,
              ),
              IconButton(
                icon: Icon(Icons.ondemand_video),
                onPressed: this.widget.onTapAddYouTubeVideo,
              ),
              IconButton(
                icon: Icon(Icons.videocam),
                onPressed: this.widget.onTapAddVideo,
              ),
              IconButton(
                icon: Icon(MdiIcons.twitter),
                onPressed: this.widget.onTapAddTwitterEmbed,
              ),
              IconButton(
                icon: Icon(MdiIcons.poll),
                onPressed: this.widget.onTapAddStrawPollEmbed,
              ),
              if (this.widget.replyList.length > 0)
                Builder(
                  builder: (BuildContext bcontext) {
                    return IconButton(
                      tooltip: 'Insert userquote',
                      icon: Icon(Icons.message),
                      onPressed: this.widget.onTapAddUserQuote,
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}

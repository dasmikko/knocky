import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:knocky/helpers/bbcode.dart';
import 'package:knocky/models/slateDocument.dart';
import 'package:knocky/models/thread.dart';
import 'package:knocky/widget/PostEditor.dart';
import 'package:knocky/widget/SlateDocumentParser/SlateDocumentParser.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/widget/KnockoutLoadingIndicator.dart';
import 'package:knocky/widget/Thread/PostElements/Embed.dart';
import 'package:knocky/widget/Thread/PostElements/Image.dart';
import 'package:knocky/widget/Thread/PostElements/UserQuote.dart';
import 'package:knocky/widget/Thread/PostElements/Video.dart';
import 'package:knocky/widget/Thread/PostElements/YouTubeEmbed.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class NewPostScreen extends StatefulWidget {
  final ThreadPost replyTo;
  final Thread thread;
  final List<ThreadPost> replyList;

  NewPostScreen({this.replyTo, this.thread, this.replyList});

  @override
  _NewPostScreenState createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  SlateObject document = new SlateObject(
    document: SlateDocument(nodes: List()),
  );
  GlobalKey _scaffoldKey;
  bool _isPosting = false;
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    //document = BBCodeHandler()
    //  .parse(controller.text, this.widget.thread, this.widget.replyList);
  }

  void onPressPost() async {
    setState(() {
      _isPosting = true;
    });
    await KnockoutAPI().newPost(document.toJson(), this.widget.thread.id);
    Navigator.pop(context, true);
  }

  void refreshPreview() {}

  void onPressSpoiler(BuildContext context, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          content: new Text(content),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void addTagAtSelection(
      TextEditingController controller, int start, int end, String tag) {
    RegExp regExp = new RegExp(
      r'(\[([^/].*?)(=(.+?))?\](.*?)\[/\2\]|\[([^/].*?)(=(.+?))?\])',
      caseSensitive: false,
      multiLine: false,
    );

    String newline = tag == 'h1' || tag == 'h2' ? "\n" : '';
    String selectedText = controller.text.substring(start, end);
    String replaceWith = '';

    if (regExp.hasMatch(selectedText)) {
      replaceWith = selectedText.replaceAll(
          '[${tag}]', ''); //ignore: unnecessary_brace_in_string_interps
      replaceWith = replaceWith.replaceAll(
          '[/${tag}]', ''); //ignore: unnecessary_brace_in_string_interps
    } else {
      replaceWith = newline +
          '[${tag}]' +
          selectedText +
          '[/${tag}]'; //ignore: unnecessary_brace_in_string_interps
    }
    controller.text = controller.text.replaceRange(start, end, replaceWith);

    refreshPreview();
  }

  /**
   * Toolbar callbacks
   */

  void addImageDialog() async {
    ClipboardData clipBoardText = await Clipboard.getData('text/plain');
    TextEditingController imgurlController =
        TextEditingController(text: clipBoardText.text);
    await showDialog<String>(
      context: context,
      child: new AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        content: new Row(
          children: <Widget>[
            new Expanded(
              child: new TextField(
                autofocus: true,
                keyboardType: TextInputType.url,
                controller: imgurlController,
                decoration: new InputDecoration(labelText: 'Image url'),
              ),
            )
          ],
        ),
        actions: <Widget>[
          new FlatButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              }),
          new FlatButton(
              child: const Text('Insert'),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
                setState(() {
                  document.document.nodes.add(
                    SlateNode(
                      object: 'block',
                      type: 'image',
                      data: SlateNodeData(src: imgurlController.text),
                    ),
                  );
                });
              })
        ],
      ),
    );
  }

  void addLinkDialog(TextEditingController mainController) async {
    ClipboardData clipBoardText = await Clipboard.getData('text/plain');
    TextEditingController urlController =
        TextEditingController(text: clipBoardText.text);
    await showDialog<String>(
      context: context,
      child: new AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        content: new Row(
          children: <Widget>[
            new Expanded(
              child: new TextField(
                autofocus: true,
                keyboardType: TextInputType.url,
                controller: urlController,
                decoration: new InputDecoration(labelText: 'Url'),
              ),
            )
          ],
        ),
        actions: <Widget>[
          new FlatButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              }),
          new FlatButton(
              child: const Text('Insert'),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();

                if (mainController.text.endsWith('\n') ||
                    controller.text.isEmpty) {
                  mainController.text =
                      mainController.text + '[url]${urlController.text}[/url]';
                } else {
                  mainController.text = mainController.text +
                      '\n[url]${urlController.text}[/url]';
                }

                refreshPreview();
              })
        ],
      ),
    );
  }

  void addYoutubeVideoDialog() async {
    ClipboardData clipBoardText = await Clipboard.getData('text/plain');
    TextEditingController urlController =
        TextEditingController(text: clipBoardText.text);
    await showDialog<String>(
      context: context,
      child: new AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        content: new Row(
          children: <Widget>[
            new Expanded(
              child: new TextField(
                autofocus: true,
                keyboardType: TextInputType.url,
                controller: urlController,
                decoration: new InputDecoration(labelText: 'YouTube URL'),
              ),
            )
          ],
        ),
        actions: <Widget>[
          new FlatButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              }),
          new FlatButton(
              child: const Text('Insert'),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();

                if (controller.text.endsWith('\n') || controller.text.isEmpty) {
                  controller.text = controller.text +
                      '[youtube]${urlController.text}[/youtube]';
                } else {
                  controller.text = controller.text +
                      '\n[youtube]${urlController.text}[/youtube]';
                }
                refreshPreview();
              })
        ],
      ),
    );
  }

  void addVideoDialog() async {
    ClipboardData clipBoardText = await Clipboard.getData('text/plain');
    TextEditingController urlController =
        TextEditingController(text: clipBoardText.text);
    await showDialog<String>(
      context: context,
      child: new AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        content: new Row(
          children: <Widget>[
            new Expanded(
              child: new TextField(
                autofocus: true,
                keyboardType: TextInputType.url,
                controller: urlController,
                decoration:
                    new InputDecoration(labelText: 'Video URL (Webm/mp4)'),
              ),
            )
          ],
        ),
        actions: <Widget>[
          new FlatButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              }),
          new FlatButton(
              child: const Text('Insert'),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();

                if (controller.text.endsWith('\n') || controller.text.isEmpty) {
                  controller.text =
                      controller.text + '[video]${urlController.text}[/video]';
                } else {
                  controller.text = controller.text +
                      '\n[video]${urlController.text}[/video]';
                }
                refreshPreview();
              })
        ],
      ),
    );
  }

  void addUserquoteDialog(bcontext) async {
    await showDialog<int>(
      context: bcontext,
      child: new AlertDialog(
        title: Text('Select post'),
        contentPadding: const EdgeInsets.all(16.0),
        content: Container(
          height: 400,
          width: 200,
          child: ListView.builder(
            itemCount: this.widget.replyList.length,
            itemBuilder: (BuildContext context, int index) {
              ThreadPost item = this.widget.replyList[index];
              return ListTile(
                title: Text(item.user.username),
                onTap: () {
                  Navigator.of(bcontext, rootNavigator: true).pop();

                  if (controller.text.endsWith('\n') ||
                      controller.text.isEmpty) {
                    controller.text =
                        controller.text + '[userquote]${index + 1}[/userquote]';
                  } else {
                    controller.text = controller.text +
                        '\n[userquote]${index + 1}[/userquote]';
                  }
                  refreshPreview();
                },
              );
            },
          ),
        ),
        actions: <Widget>[
          new FlatButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(bcontext, rootNavigator: true).pop();
              }),
        ],
      ),
    );
  }

  void addTextBlock() {
    setState(
      () {
        this.document.document.nodes.add(
              SlateNode(
                type: 'paragraph',
                object: 'block',
                nodes: [
                  SlateNode(
                    object: 'text',
                    leaves: [],
                  ),
                ],
              ),
            );
      },
    );
  }

  void addHeadingBlock(String type) {
    setState(
      () {
        this.document.document.nodes.add(
              SlateNode(
                type: 'heading-' + type,
                object: 'block',
                nodes: [
                  SlateNode(
                    object: 'text',
                    leaves: [],
                  ),
                ],
              ),
            );
      },
    );
  }

  /*
  Block tap callbacks
  */
  void showTextEditDialog(BuildContext context, SlateNode node) {
    String bbcodeText = BBCodeHandler().slateParagraphToBBCode(node);
    TextEditingController textEditingController =
        TextEditingController(text: bbcodeText);

    showDialog(
        context: context,
        builder: (BuildContext bcontext) {
          return AlertDialog(
            actions: <Widget>[
              FlatButton(
                child: Text('Remove'),
                onPressed: () {
                  setState(() {
                    int index = this.document.document.nodes.indexOf(node);
                    this.document.document.nodes.removeAt(index);
                  });
                  Navigator.pop(bcontext);
                },
              ),
              FlatButton(
                child: Text('Save'),
                onPressed: () {
                  SlateNode newNode = BBCodeHandler()
                      .parse(textEditingController.text, type: node.type);
                  print(BBCodeHandler().slateParagraphToBBCode(newNode));
                  print(newNode.toJson());
                  Navigator.pop(bcontext, newNode);
                },
              )
            ],
            title: Text('Edit text block'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: TextField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    controller: textEditingController,
                  ),
                ),
                Container(
                  color: Colors.grey[600],
                  padding: EdgeInsets.all(0),
                  child: Wrap(
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.format_bold),
                        onPressed: () {
                          TextSelection theSelection =
                              textEditingController.selection;
                          addTagAtSelection(textEditingController,
                              theSelection.start, theSelection.end, 'b');
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.format_italic),
                        onPressed: () {
                          TextSelection theSelection =
                              textEditingController.selection;
                          addTagAtSelection(textEditingController,
                              theSelection.start, theSelection.end, 'i');
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.format_underlined),
                        onPressed: () {
                          TextSelection theSelection =
                              textEditingController.selection;
                          addTagAtSelection(textEditingController,
                              theSelection.start, theSelection.end, 'u');
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.code),
                        onPressed: () {
                          TextSelection theSelection =
                              textEditingController.selection;
                          addTagAtSelection(textEditingController,
                              theSelection.start, theSelection.end, 'code');
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.link),
                        onPressed: () {
                          addLinkDialog(textEditingController);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).then((newNode) {
      setState(() {
        if (newNode != null) {
          int index = this.document.document.nodes.indexOf(node);
          this.document.document.nodes[index] = newNode;
        }
      });
    });
  }

  void editImageDialog(slateObject, SlateNode node) async {
    TextEditingController imgurlController =
        TextEditingController(text: node.data.src);
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return new AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          content: new Row(
            children: <Widget>[
              new Expanded(
                child: new TextField(
                  autofocus: true,
                  keyboardType: TextInputType.url,
                  controller: imgurlController,
                  decoration: new InputDecoration(labelText: 'Image url'),
                ),
              )
            ],
          ),
          actions: <Widget>[
            new FlatButton(
                child: const Text('Remove'),
                onPressed: () {
                  setState(() {
                    int index = this.document.document.nodes.indexOf(node);
                    this.document.document.nodes.removeAt(index);
                  });
                  Navigator.of(context, rootNavigator: true).pop();
                }),
            new FlatButton(
                child: const Text('Update'),
                onPressed: () {
                  setState(() {
                    int index = this.document.document.nodes.indexOf(node);
                    this.document.document.nodes[index].data.src =
                        imgurlController.text;
                  });
                  Navigator.of(context, rootNavigator: true).pop();
                })
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext wcontext) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('New post'),
          actions: <Widget>[
            IconButton(
              onPressed: !_isPosting ? onPressPost : null,
              icon: Icon(Icons.send),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(
                text: 'Edit',
              ),
              Tab(text: 'Preview'),
            ],
          ),
        ),
        body: KnockoutLoadingIndicator(
          show: _isPosting,
          child: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: [
              PostEditor(
                document: document,
                // Blocks
                onTapTextBlock: showTextEditDialog,
                onTapImageBlock: editImageDialog,
                // Toolbar
                onTapAddTextBlock: addTextBlock,
                onTapAddHeadingOne: () => addHeadingBlock('one'),
                onTapAddHeadingTwo: () => addHeadingBlock('two'),
                onTapAddImage: addImageDialog,
                onReorderHandler: (int oldIndex, int newIndex) {
                  if (oldIndex < newIndex) {
                    // removing the item at oldIndex will shorten the list by 1.
                    newIndex -= 1;
                  }
                  setState(() {
                    final SlateNode element =
                        document.document.nodes.removeAt(oldIndex);
                    document.document.nodes.insert(newIndex, element);
                  });
                },
              ),
              Container(
                child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(15),
                    child: SlateDocumentParser(
                      context: context,
                      scaffoldkey: _scaffoldKey,
                      slateObject: document,
                      onPressSpoiler: (content) {
                        onPressSpoiler(context, content);
                      },
                      paragraphHandler: (SlateNode node, Function leafHandler) {
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

                        return Container(
                          child: RichText(
                            text: TextSpan(children: lines),
                          ),
                        );
                      },
                      headingHandler: (SlateNode node, Function inlineHandler,
                          Function leafHandler) {
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
                            lines.addAll(leafHandler(line.leaves,
                                fontSize: headingSize));
                          }

                          // Handle inline element
                          if (line.object == 'inline') {
                            // Handle links
                            inlineHandler(node, line);
                          }
                        });

                        return Container(
                          margin: EdgeInsets.only(bottom: 10),
                          child: RichText(
                            text: TextSpan(children: lines),
                          ),
                        );
                      },
                      imageWidgetHandler:
                          (String imageUrl, slateObject, SlateNode node) {
                        return Container(
                          margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
                          child: LimitedBox(
                            maxHeight: 300,
                            child: ImageWidget(
                                url: imageUrl, slateObject: slateObject),
                          ),
                        );
                      },
                      videoWidgetHandler: (String videoUrl) {
                        return VideoElement(
                          url: videoUrl,
                          scaffoldKey: this._scaffoldKey,
                        );
                      },
                      youTubeWidgetHandler: (String youTubeUrl) {
                        return YoutubeVideoEmbed(
                          url: youTubeUrl,
                        );
                      },
                      twitterEmbedHandler: (String embedUrl) {
                        return EmbedWidget(
                          url: embedUrl,
                        );
                      },
                      userQuoteHandler: (String username, List<Widget> widgets,
                          bool isChild) {
                        return UserQuoteWidget(
                          username: username,
                          children: widgets,
                          isChild: isChild,
                        );
                      },
                      bulletedListHandler: (List<Widget> listItemsContent) {
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
                                      color: Theme.of(context)
                                          .textTheme
                                          .body1
                                          .color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  Expanded(child: item)
                                ],
                              ),
                            ),
                          );
                        });

                        return Container(
                          margin: EdgeInsets.only(top: 10, bottom: 10),
                          child: Column(children: listItems),
                        );
                      },
                      numberedListHandler: (List<Widget> listItemsContent) {
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

                        return Container(
                          margin: EdgeInsets.only(bottom: 10),
                          child: Column(children: listItems),
                        );
                      },
                      quotesHandler: (Widget content) {
                        return Container(
                          margin: EdgeInsets.only(bottom: 10.0),
                          padding: EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(color: Colors.blue, width: 3.0),
                            ),
                            color: Colors.grey,
                          ),
                          child: content,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

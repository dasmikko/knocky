import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:knocky/helpers/bbcode.dart';
import 'package:knocky/models/slateDocument.dart';
import 'package:knocky/models/thread.dart';
import 'package:knocky/widget/ListEditor.dart';
import 'package:knocky/widget/PostEditor.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/widget/KnockoutLoadingIndicator.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:knocky/widget/Thread/PostContent.dart';

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
    TextEditingController imgurlController = TextEditingController(
        text: clipBoardText != null ? clipBoardText.text : '');
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
                setState(() {
                  this.document.document.nodes.add(SlateNode(
                      type: 'youtube',
                      data: SlateNodeData(src: urlController.text)));
                });

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
      builder: (BuildContext context) => new AlertDialog(
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
                setState(() {
                  this.document.document.nodes.add(
                        SlateNode(
                          type: 'video',
                          data: SlateNodeData(src: urlController.text),
                        ),
                      );
                });

                Navigator.of(context, rootNavigator: true).pop();
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

  void addQuoteBlock() {
    setState(() {
      this
          .document
          .document
          .nodes
          .add(SlateNode(type: 'block-quote', nodes: List()));
    });
  }

  void addListBlock(String type) {
    setState(() {
      this
          .document
          .document
          .nodes
          .add(SlateNode(object: 'block', type: type, nodes: List()));
    });
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

  void editYoutubeVideoDialog(String youTubeUrl, SlateNode node) async {
    TextEditingController urlController =
        TextEditingController(text: node.data.src);
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
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
                      urlController.text;
                });
                Navigator.of(context, rootNavigator: true).pop();
              })
        ],
      ),
    );
  }

  void editVideoDialog() async {
    ClipboardData clipBoardText = await Clipboard.getData('text/plain');
    TextEditingController urlController =
        TextEditingController(text: clipBoardText.text);
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) => new AlertDialog(
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
                setState(() {
                  this.document.document.nodes.add(
                        SlateNode(
                          type: 'video',
                          data: SlateNodeData(src: urlController.text),
                        ),
                      );
                });

                Navigator.of(context, rootNavigator: true).pop();
              })
        ],
      ),
    );
  }

  void editList(SlateNode node) async {
    List<SlateNode> listItems = List();

    node.nodes.forEach((listItem) {
      listItems.add(listItem);
    });

    await showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Edit list'),
        contentPadding: const EdgeInsets.all(16.0),
        content: ListEditor(
          oldListItems: listItems,
          onListUpdated: (newListItems) {
            setState(() {
              int index = this.document.document.nodes.indexOf(node);
              this.document.document.nodes[index].nodes = newListItems;
            });
          },
        ),
        actions: <Widget>[
          new FlatButton(
              child: const Text('Remove'),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              }),
          new FlatButton(
              child: const Text('Update'),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              })
        ],
      ),
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
                onTapTextBlock: this.showTextEditDialog,
                onTapImageBlock: this.editImageDialog,
                onTapQuoteBlock: this.showTextEditDialog,
                onTapYouTubeBlock: this.editYoutubeVideoDialog,
                onTapListBlock: this.editList,
                // Toolbar
                onTapAddTextBlock: this.addTextBlock,
                onTapAddHeadingOne: () => this.addHeadingBlock('one'),
                onTapAddHeadingTwo: () => this.addHeadingBlock('two'),
                onTapAddImage: this.addImageDialog,
                onTapAddQuote: this.addQuoteBlock,
                onTapAddYouTubeVideo: this.addYoutubeVideoDialog,
                onTapAddVideo: this.addVideoDialog,
                onTapAddBulletedList: () => this.addListBlock('bulleted-list'),
                onTapAddNumberedList: () => this.addListBlock('numbered-list'),
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
                    child: PostContent(
                        content: document,
                        onTapSpoiler: (text) {
                          onPressSpoiler(context, text);
                        },
                        scaffoldKey: this._scaffoldKey),
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

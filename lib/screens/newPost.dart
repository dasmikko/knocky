import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:knocky/helpers/bbcode.dart';
import 'package:knocky/models/slateDocument.dart';
import 'package:knocky/models/thread.dart';
import 'package:knocky/widget/SlateDocumentParser/SlateDocumentParser.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/widget/KnockoutLoadingIndicator.dart';

class NewPostScreen extends StatefulWidget {
  final ThreadPost replyTo;
  final Thread thread;
  final List<ThreadPost> replyList;

  NewPostScreen(
      {this.replyTo, this.thread, this.replyList});

  @override
  _NewPostScreenState createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  TextEditingController controller = TextEditingController(text: '');
  SlateObject document;
  GlobalKey _scaffoldKey;
  FocusNode textFocusNode = FocusNode();
  bool _isPosting = false;

  List<String> history = List();

  @override
  void initState() {
    super.initState();

    document = BBCodeHandler()
        .parse(controller.text, this.widget.thread, this.widget.replyList);
  }

  void onPressPost() async {
    setState(() {
      _isPosting = true;
    });
    await KnockoutAPI().newPost(document.toJson(), this.widget.thread.id);
    Navigator.pop(context, true);
  }

  void refreshPreview() {
    setState(() {
      document = BBCodeHandler()
          .parse(controller.text, this.widget.thread, this.widget.replyList);
    });
  }

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

  void addTagAtSelection(int start, int end, String tag) {
    RegExp regExp = new RegExp(
      r'(\[([^/].*?)(=(.+?))?\](.*?)\[/\2\]|\[([^/].*?)(=(.+?))?\])',
      caseSensitive: false,
      multiLine: false,
    );

    String newline = tag == 'h1' || tag == 'h2' ? "\n" : '';
    String selectedText = controller.text.substring(start, end);
    String replaceWith = '';

    if (regExp.hasMatch(selectedText)) {
      replaceWith = selectedText.replaceAll('[${tag}]', ''); //ignore: unnecessary_brace_in_string_interps
      replaceWith = replaceWith.replaceAll('[/${tag}]', ''); //ignore: unnecessary_brace_in_string_interps
    } else {
      replaceWith = newline + '[${tag}]' + selectedText + '[/${tag}]'; //ignore: unnecessary_brace_in_string_interps
    }
    controller.text = controller.text.replaceRange(start, end, replaceWith);

    refreshPreview();
  }

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

                if(controller.text.endsWith('\n') || controller.text.isEmpty) {
                  controller.text =
                    controller.text + '[img]${imgurlController.text}[/img]';
                } else {
                  controller.text =
                    controller.text + '\n[img]${imgurlController.text}[/img]';
                }
                refreshPreview();
              })
        ],
      ),
    );
  }

  void addLinkDialog() async {
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

                if(controller.text.endsWith('\n') || controller.text.isEmpty) {
                  controller.text =
                    controller.text + '[url]${urlController.text}[/url]';
                } else {
                  controller.text =
                    controller.text + '\n[url]${urlController.text}[/url]';
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

                if(controller.text.endsWith('\n') || controller.text.isEmpty) {
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

                if(controller.text.endsWith('\n') || controller.text.isEmpty) {
                  controller.text =
                    controller.text + '[video]${urlController.text}[/video]';
                } else {
                  controller.text =
                    controller.text + '\n[video]${urlController.text}[/video]';
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

                  if(controller.text.endsWith('\n') || controller.text.isEmpty) {
                    controller.text =
                      controller.text + '[userquote]${index + 1}[/userquote]';
                  } else {
                    controller.text =
                      controller.text + '\n[userquote]${index + 1}[/userquote]';
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(25),
                      child: TextField(
                        controller: controller,
                        focusNode: textFocusNode,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        onChanged: (text) {
                          setState(() {
                            document = BBCodeHandler().parse(text,
                                this.widget.thread, this.widget.replyList);
                          });
                        },
                      ),
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
                            TextSelection theSelection = controller.selection;
                            addTagAtSelection(
                                theSelection.start, theSelection.end, 'b');
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.format_italic),
                          onPressed: () {
                            TextSelection theSelection = controller.selection;
                            addTagAtSelection(
                                theSelection.start, theSelection.end, 'i');
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.format_underlined),
                          onPressed: () {
                            TextSelection theSelection = controller.selection;
                            addTagAtSelection(
                                theSelection.start, theSelection.end, 'u');
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.code),
                          onPressed: () {
                            TextSelection theSelection = controller.selection;
                            addTagAtSelection(
                                theSelection.start, theSelection.end, 'code');
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.title),
                          onPressed: () {
                            TextSelection theSelection = controller.selection;
                            addTagAtSelection(
                                theSelection.start, theSelection.end, 'h1');
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.format_size),
                          onPressed: () {
                            TextSelection theSelection = controller.selection;
                            addTagAtSelection(
                                theSelection.start, theSelection.end, 'h2');
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.format_quote),
                          onPressed: () {
                            TextSelection theSelection = controller.selection;
                            addTagAtSelection(
                                theSelection.start, theSelection.end, 'blockquote');
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.image),
                          onPressed: () {
                            addImageDialog();
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.link),
                          onPressed: () {
                            addLinkDialog();
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.ondemand_video),
                          onPressed: () {
                            addYoutubeVideoDialog();
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.videocam),
                          onPressed: () {
                            addVideoDialog();
                          },
                        ),
                        if (this.widget.replyList.length > 0)
                          Builder(
                            builder: (BuildContext bcontext) {
                              return IconButton(
                                tooltip: 'Insert userquote',
                                icon: Icon(Icons.message),
                                onPressed: () {
                                  addUserquoteDialog(bcontext);
                                },
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ],
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:knocky/helpers/bbcode.dart';
import 'package:knocky/models/slateDocument.dart';
import 'package:knocky/widget/SlateDocumentParser/SlateDocumentParser.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/widget/KnockoutLoadingIndicator.dart';

class NewPostScreen extends StatefulWidget {
  final int threadId;

  NewPostScreen({@required this.threadId});

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
    document = BBCodeHandler().parse(controller.text);
  }

  void onPressPost() async {
    print('Pressed post');
    setState(() {
      _isPosting = true;
    });
    await KnockoutAPI().newPost(document.toJson(), this.widget.threadId);
    Navigator.pop(context, true);
  }

  void refreshPreview() {
    setState(() {
      document = BBCodeHandler().parse(controller.text);
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
      replaceWith = selectedText.replaceAll('[${tag}]', '');
      replaceWith = replaceWith.replaceAll('[/${tag}]', '');
    } else {
      replaceWith = newline + '[${tag}]' + selectedText + '[/${tag}]';
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
                Navigator.pop(context);
              }),
          new FlatButton(
              child: const Text('Insert'),
              onPressed: () {
                Navigator.pop(context);
                controller.text =
                    controller.text + '\n[img]${imgurlController.text}[/img]';
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
                Navigator.pop(context);
              }),
          new FlatButton(
              child: const Text('Insert'),
              onPressed: () {
                Navigator.pop(context);
                controller.text =
                    controller.text + '\n[url]${urlController.text}[/url]';
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
                Navigator.pop(context);
              }),
          new FlatButton(
              child: const Text('Insert'),
              onPressed: () {
                Navigator.pop(context);
                controller.text = controller.text +
                    '\n[youtube]${urlController.text}[/youtube]';
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
                Navigator.pop(context);
              }),
          new FlatButton(
              child: const Text('Insert'),
              onPressed: () {
                Navigator.pop(context);
                controller.text =
                    controller.text + '\n[video]${urlController.text}[/video]';
                refreshPreview();
              })
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            IconButton(
              onPressed: () {
                setState(() {
                  _isPosting = !_isPosting;
                });
              },
              icon: Icon(Icons.visibility),
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
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(15),
                      child: TextField(
                        controller: controller,
                        focusNode: textFocusNode,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        onChanged: (text) {
                          setState(() {
                            document = BBCodeHandler().parse(text);
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
                        )
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

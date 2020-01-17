import 'dart:io';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:knocky/helpers/bbcodeparser.dart';
import 'package:knocky/models/slateDocument.dart';
import 'package:knocky/models/thread.dart';
import 'package:knocky/screens/Modals/editTextBlock.dart';
import 'package:knocky/screens/Modals/knockoutDocument.dart';
import 'package:knocky/widget/LinkDialogContent.dart';
import 'package:knocky/widget/ListEditor.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/widget/KnockoutLoadingIndicator.dart';
import 'package:knocky/widget/PostEditorBBCode.dart';
import 'package:knocky/widget/Thread/PostElements/Image.dart';
import 'package:knocky/widget/UploadProgressDialogContent.dart';

class NewPostScreen extends StatefulWidget {
  final ThreadPost post;
  final Thread thread;
  final List<ThreadPost> replyList;
  final bool editingPost;

  NewPostScreen(
      {this.post, this.thread, this.replyList, this.editingPost = false});

  @override
  _NewPostScreenState createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen>
    with AfterLayoutMixin<NewPostScreen>, SingleTickerProviderStateMixin {
  SlateObject document = new SlateObject(
    object: 'value',
    document: SlateDocument(object: 'document', nodes: List()),
  );
  GlobalKey _scaffoldKey;
  bool _isPosting = false;
  TextEditingController controller = TextEditingController();
  List<ThreadPost> replyListConverted = List();
  //String postBBcode =
    //  'Hello [i][b]inacio world[/b][/i] here is an image [img]https://i.redd.it/lvwmx2t34sa41.jpg[/img] here is text after it';

  String postBBcode =
      'Hello [b]this[/b] is an [b][i]simple[/i][/b] text! [b]DONE![/b] I can do what i fucking want bitch';

  BBCodeParser bbCodeParser;
  KnockoutDocument knockoutDocument;

  @override
  void initState() {
    super.initState();

    this.replyListConverted = this.widget.replyList;

    if (this.widget.editingPost) {
      this.document = this.widget.post.content;
    } else {
      if (this.replyListConverted.length > 0) {
        this.convertReplyEmbedsToText();
      }
    }

    if (this.replyListConverted.length == 1) {
      ThreadPost item = this.replyListConverted.first;
      this.document.document.nodes.add(
            SlateNode(
                object: 'block',
                type: 'userquote',
                data: SlateNodeData(
                  postData: NodeDataPostData(
                    postId: item.id,
                    threadId: this.widget.thread.id,
                    threadPage: this.widget.thread.currentPage,
                    username: item.user.username,
                  ),
                ),
                nodes: item.content.document.nodes),
          );
    }
  }

  @override
  void afterFirstLayout(BuildContext context) async {
    // setup the parser
    this.bbCodeParser = new BBCodeParser();

    // Parse the bbcode
    KnockoutDocument document = bbCodeParser.parse(postBBcode);

    print('done parsing, going through the document now...');
    //print(document);

    document.nodes.forEach((node) {
        //print(node);
        print(node.type);
        if (node.url != null) print(node.url);

        node.children.forEach((leaf) {
          print('leaf: ' + leaf.toString());
        });
    });

    setState(() {
      this.knockoutDocument = document;
    });
  }

  TextSpan bbCodeTextHandler(String text, bool isBold, bool isItalic,
      bool isUnderlined, bool isCode, bool isSpoiler) {
    TextStyle textStyle = Theme.of(context).textTheme.body1.copyWith(
          fontFamily: isCode ? 'RobotoMono' : 'Roboto',
          decoration:
              isUnderlined ? TextDecoration.underline : TextDecoration.none,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
        );

    TextStyle spoilerStyle = textStyle.copyWith(
        background: Paint()..color = Theme.of(context).textTheme.body1.color,
        color: Theme.of(context).textTheme.body1.color);

    if (isSpoiler) {
      return TextSpan(
        text: text,
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            print('Clicked spoiler');
            this.onPressSpoiler(context, text);
          },
        style: spoilerStyle,
      );
    } else {
      return TextSpan(text: text, style: textStyle);
    }
  }

  Widget bbCodeImageHandler(String url) {
    return Container(
      margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
      child: ImageWidget(
        url: url,
        bbcode: postBBcode,
      ),
    );
  }

  void convertReplyEmbedsToText() {
    print('Convert embeds');
    setState(() {
      this.replyListConverted.forEach((reply) {
        reply.content.document.nodes.forEach((node) {
          switch (node.type) {
            case 'image':
            case 'youtube':
            case 'video':
            case 'strawpoll':
            case 'twitter':
              print('Should be convertet');
              int replyindex = this.replyListConverted.indexOf(reply);
              int nodeIndex = reply.content.document.nodes.indexOf(node);

              this
                  .replyListConverted[replyindex]
                  .content
                  .document
                  .nodes
                  .removeAt(nodeIndex);
              this
                  .replyListConverted[replyindex]
                  .content
                  .document
                  .nodes
                  .insert(nodeIndex, embedConverter(node.type, node.data.src));
              break;
          }
        });
      });
    });
  }

  SlateNode embedConverter(String type, String url) {
    return new SlateNode(type: 'paragraph', object: 'block', nodes: [
      SlateNode(object: 'text', leaves: [
        SlateLeaf(text: '[${type}: ${url}]', marks: [], object: 'leaf')
      ])
    ]);
  }

  void onPressPost() async {
    setState(() {
      _isPosting = true;
    });

    if (this.widget.editingPost) {
      await KnockoutAPI()
          .updatePost(
              document.toJson(), this.widget.post.id, this.widget.thread.id)
          .catchError((error) {
        print(error);
      });
    } else {
      await KnockoutAPI()
          .newPost(document.toJson(), this.widget.thread.id)
          .catchError((error) {
        print(error);
      });
    }

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
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) => new SimpleDialog(
        title: Text('Add image'),
        children: <Widget>[
          SimpleDialogOption(
            child: Row(
              children: <Widget>[
                Icon(Icons.camera_alt),
                Container(
                    margin: EdgeInsets.only(left: 10),
                    child: Text('Take picture and upload to Imgur')),
              ],
            ),
            onPressed: () async {
              File image =
                  await ImagePicker.pickImage(source: ImageSource.camera);
              Navigator.of(context, rootNavigator: true).pop();
              if (image != null) showUploadProgressDialog(image);
            },
          ),
          SimpleDialogOption(
            child: Row(
              children: <Widget>[
                Icon(Icons.file_upload),
                Container(
                    margin: EdgeInsets.only(left: 10),
                    child: Text('Upload existing image to Imgur')),
              ],
            ),
            onPressed: () async {
              File image =
                  await ImagePicker.pickImage(source: ImageSource.gallery);
              Navigator.of(context, rootNavigator: true).pop();
              if (image != null) showUploadProgressDialog(image);
            },
          ),
          SimpleDialogOption(
            child: Row(
              children: <Widget>[
                Icon(Icons.insert_link),
                Container(
                    margin: EdgeInsets.only(left: 10),
                    child: Text('Image url')),
              ],
            ),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              this.addImageUrlDialog();
            },
          )
        ],
      ),
    );
  }

  void showUploadProgressDialog(File selectedFile) async {
    await showDialog<String>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => new AlertDialog(
        title: Text('Uploading image'),
        content: UploadProgressDialogContent(
          selectedFile: selectedFile,
          onFinishedUploading: (String imageLink) {
            Navigator.of(context, rootNavigator: true).pop();
            setState(() {
              document.document.nodes.add(
                SlateNode(
                  object: 'block',
                  type: 'image',
                  data: SlateNodeData(src: imageLink),
                ),
              );
            });
          },
        ),
      ),
    );
  }

  void addImageUrlDialog() async {
    //ClipboardData clipBoardText = await Clipboard.getData('text/plain');
    TextEditingController imgurlController = TextEditingController(text: '');
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
    //ClipboardData clipBoardText = await Clipboard.getData('text/plain');
    TextEditingController urlController = TextEditingController(text: '');
    bool isRichLink = false;

    await showDialog<String>(
      context: context,
      child: new AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        content: new Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new TextField(
              autofocus: true,
              keyboardType: TextInputType.url,
              controller: urlController,
              decoration: new InputDecoration(labelText: 'Url'),
            ),
            Flexible(
              flex: 0,
              child: LinkDialogWidget(
                onChanged: (bool value) {
                  isRichLink = value;
                },
              ),
            ),
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

                String richTextAttribute = isRichLink ? ' rich=true' : '';
                if (mainController.text.endsWith('\n') ||
                    controller.text.isEmpty) {
                  mainController.text = mainController.text +
                      '[url${richTextAttribute}]${urlController.text}[/url]';
                } else {
                  mainController.text = mainController.text +
                      '\n[url${richTextAttribute}]${urlController.text}[/url]';
                }

                refreshPreview();
              })
        ],
      ),
    );
  }

  void addYoutubeVideoDialog() async {
    //ClipboardData clipBoardText = await Clipboard.getData('text/plain');
    TextEditingController urlController = TextEditingController(text: '');
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
                      object: 'block',
                      type: 'youtube',
                      data: SlateNodeData(src: urlController.text)));
                });

                Navigator.of(context, rootNavigator: true).pop();
              })
        ],
      ),
    );
  }

  void addVideoDialog() async {
    //ClipboardData clipBoardText = await Clipboard.getData('text/plain');
    TextEditingController urlController = TextEditingController(text: '');
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
                          object: 'block',
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
            itemCount: this.replyListConverted.length,
            itemBuilder: (BuildContext context, int index) {
              ThreadPost item = this.replyListConverted[index];
              return ListTile(
                title: Text(item.user.username),
                onTap: () {
                  setState(() {
                    this.document.document.nodes.add(
                          SlateNode(
                              object: 'block',
                              type: 'userquote',
                              data: SlateNodeData(
                                postData: NodeDataPostData(
                                  postId: item.id,
                                  threadId: this.widget.thread.id,
                                  threadPage: this.widget.thread.currentPage,
                                  username: item.user.username,
                                ),
                              ),
                              nodes: item.content.document.nodes),
                        );
                  });
                  Navigator.of(bcontext, rootNavigator: true).pop();
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

  void addTwitterEmbed() async {
    //ClipboardData clipBoardText = await Clipboard.getData('text/plain');
    TextEditingController urlController = TextEditingController(text: '');
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
                decoration: new InputDecoration(labelText: 'Twitter URL'),
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
                            type: 'twitter',
                            object: 'block',
                            data: SlateNodeData(src: urlController.text),
                            nodes: [
                              SlateNode(
                                object: 'text',
                                leaves: [
                                  SlateLeaf(text: '', marks: [], object: 'leaf')
                                ],
                              ),
                            ]),
                      );
                });

                Navigator.of(context, rootNavigator: true).pop();
              })
        ],
      ),
    );
  }

  void addStrawpollEmbed() async {
    //ClipboardData clipBoardText = await Clipboard.getData('text/plain');
    TextEditingController urlController = TextEditingController(text: '');
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
                decoration: new InputDecoration(labelText: 'Strawpoll URL'),
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
                            type: 'strawpoll',
                            object: 'block',
                            data: SlateNodeData(src: urlController.text),
                            nodes: [
                              SlateNode(
                                object: 'text',
                                leaves: [
                                  SlateLeaf(text: '', marks: [], object: 'leaf')
                                ],
                              ),
                            ]),
                      );
                });

                Navigator.of(context, rootNavigator: true).pop();
              })
        ],
      ),
    );
  }

  /*
  Block tap callbacks
  */
  void showTextEditDialog(BuildContext context, SlateNode node) async {
    var result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditTextBlockModal(
          node: node,
        ),
      ),
    );

    if (result is SlateNode) {
      int index = this.document.document.nodes.indexOf(node);
      this.document.document.nodes[index] = result;
    }

    if (result is bool && result == false) {
      setState(() {
        int index = this.document.document.nodes.indexOf(node);
        this.document.document.nodes.removeAt(index);
      });
    }
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

  void editVideoDialog(SlateNode node) async {
    TextEditingController urlController =
        TextEditingController(text: node.data.src);
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

  void editTwitterEmbed(String youTubeUrl, SlateNode node) async {
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
                decoration: new InputDecoration(labelText: 'Twitter URL'),
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

  void editStrawpollEmbed(String url, SlateNode node) async {
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
                decoration: new InputDecoration(labelText: 'Strawpoll URL'),
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

  void editUserQuote(SlateNode node) async {
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Remove user quote?'),
        contentPadding: const EdgeInsets.all(16.0),
        content: Text('Are you sure you want to remove the user quote?'),
        actions: <Widget>[
          new FlatButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              }),
          new FlatButton(
              child: const Text('Yes'),
              onPressed: () {
                setState(() {
                  int index = this.document.document.nodes.indexOf(node);
                  this.document.document.nodes.removeAt(index);
                });
                Navigator.of(context, rootNavigator: true).pop();
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
          title: Text(this.widget.editingPost ? 'Edit post ' : 'New post'),
          actions: <Widget>[
            IconButton(
              onPressed: !_isPosting ? onPressPost : null,
              icon: Icon(Icons.send),
            ),
            /*IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditorPage(),
                  ),
                );
              },
              icon: Icon(Icons.keyboard),
            ),*/
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
              PostEditorBBCode(
                postBBCode: postBBcode,
                replyList: this.replyListConverted,
                onInputChange: (String newBBcode) {
                  print('new bbcode: ' + newBBcode);
                  KnockoutDocument doc = this.bbCodeParser.parse(newBBcode);

                  print(doc);

                  setState(() {
                    this.postBBcode = newBBcode;
                    this.knockoutDocument = doc;
                  });
                },
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
                onTapAddTwitterEmbed: this.addTwitterEmbed,
                onTapAddStrawPollEmbed: this.addStrawpollEmbed,
                onTapAddUserQuote: () => this.addUserquoteDialog(context),
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [],

                      /*Container(
                    padding: EdgeInsets.all(15),
                    child: PostContent(
                        content: document,
                        onTapSpoiler: (text) {
                          onPressSpoiler(context, text);
                        },
                        scaffoldKey: this._scaffoldKey),
                  ),*/
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

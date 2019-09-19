import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:knocky/helpers/ImgurHelper.dart';
import 'package:knocky/helpers/bbcode.dart';
import 'package:knocky/models/slateDocument.dart';
import 'package:knocky/models/thread.dart';
import 'package:knocky/widget/LinkDialogContent.dart';
import 'package:knocky/widget/ListEditor.dart';
import 'package:knocky/widget/PostEditor.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/widget/KnockoutLoadingIndicator.dart';
import 'package:knocky/widget/Thread/PostContent.dart';
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

class _NewPostScreenState extends State<NewPostScreen> {
  SlateObject document = new SlateObject(
    object: 'value',
    document: SlateDocument(object: 'document', nodes: List()),
  );
  GlobalKey _scaffoldKey;
  bool _isPosting = false;
  TextEditingController controller = TextEditingController();
  List<ThreadPost> replyListConverted = List();

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
                Flexible(
                  child: Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                      ),
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      controller: textEditingController,
                      expands: false,
                    ),
                  ),
                ),
                Container(
                  color: Colors.grey[600],
                  padding: EdgeInsets.all(0),
                  child: Wrap(
                    children: <Widget>[
                      IconButton(
                        tooltip: 'Bold',
                        icon: Icon(Icons.format_bold),
                        onPressed: () {
                          TextSelection theSelection =
                              textEditingController.selection;
                          addTagAtSelection(textEditingController,
                              theSelection.start, theSelection.end, 'b');
                        },
                      ),
                      IconButton(
                        tooltip: 'Italic',
                        icon: Icon(Icons.format_italic),
                        onPressed: () {
                          TextSelection theSelection =
                              textEditingController.selection;
                          addTagAtSelection(textEditingController,
                              theSelection.start, theSelection.end, 'i');
                        },
                      ),
                      IconButton(
                        tooltip: 'Underlined',
                        icon: Icon(Icons.format_underlined),
                        onPressed: () {
                          TextSelection theSelection =
                              textEditingController.selection;
                          addTagAtSelection(textEditingController,
                              theSelection.start, theSelection.end, 'u');
                        },
                      ),
                      IconButton(
                        tooltip: 'Code',
                        icon: Icon(Icons.code),
                        onPressed: () {
                          TextSelection theSelection =
                              textEditingController.selection;
                          addTagAtSelection(textEditingController,
                              theSelection.start, theSelection.end, 'code');
                        },
                      ),
                      IconButton(
                        tooltip: 'Spoiler',
                        icon: Icon(Icons.visibility_off),
                        onPressed: () {
                          TextSelection theSelection =
                              textEditingController.selection;
                          addTagAtSelection(textEditingController,
                              theSelection.start, theSelection.end, 'spoiler');
                        },
                      ),
                      IconButton(
                        tooltip: 'Link',
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
    print(document.toJson());
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
                replyList: this.replyListConverted,
                // Blocks
                onTapTextBlock: this.showTextEditDialog,
                onTapImageBlock: this.editImageDialog,
                onTapQuoteBlock: this.showTextEditDialog,
                onTapYouTubeBlock: this.editYoutubeVideoDialog,
                onTapVideoBlock: this.editVideoDialog,
                onTapListBlock: this.editList,
                onTapTwitterBlock: this.editTwitterEmbed,
                onTapUserQuoteBlock: this.editUserQuote,
                onTapStrawpollBlock: this.editStrawpollEmbed,
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

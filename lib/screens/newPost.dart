import 'package:flutter/material.dart';
import 'package:knocky/helpers/bbcode.dart';
import 'package:knocky/models/slateDocument.dart';
import 'package:knocky/widget/SlateDocumentParser/SlateDocumentParser.dart';

class NewPostScreen extends StatefulWidget {
  @override
  _NewPostScreenState createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  TextEditingController controller =
      TextEditingController(
        text: """
  Hello [b]my[/b] [i]name[/i] [b][i]is[/i][/b] jurgen
  [u]New line[/u]
  [code]this.isCode = true[/code]
  [spoiler]Shhh... i'm a secret[/spoiler]""");
  SlateObject document = null;
  GlobalKey _scaffoldKey;

  @override
  void initState() {
    super.initState();
    document = BBCodeHandler().parse(controller.text);
  }

  void onPressPost() {
    print('Pressed post');

    setState(() {
      document = BBCodeHandler().parse(controller.text);
      print(document.toJson());
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
              onPressed: onPressPost,
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
        body: TabBarView(
          children: [
            Container(
              padding: EdgeInsets.all(15),
              child: TextField(
                controller: controller,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                onChanged: (text) {
                  setState(() {
                    document = BBCodeHandler().parse(text);
                  });
                },
              ),
            ),
            Container(
              child: SlateDocumentParser(
                context: context,
                scaffoldkey: _scaffoldKey,
                slateObject: document,
                onPressSpoiler: (content) {
                  onPressSpoiler(context, content);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

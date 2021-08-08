import 'package:flutter/material.dart';
import 'package:knocky/widgets/post/toolbar.dart';

class PostEditorBBCode extends StatefulWidget {
  final Function onInputChange;
  PostEditorBBCode({this.onInputChange});
  @override
  _PostEditorBBCodeState createState() => _PostEditorBBCodeState();
}

class _PostEditorBBCodeState extends State<PostEditorBBCode> {
  final textEditingController = new TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  Widget toolbar(BuildContext context) {
    return Toolbar.toolbarBox(Theme.of(context).primaryColor, []);
  }

  Widget editor(BuildContext context) {
    return Expanded(
        child: Container(
            color: Theme.of(context).primaryColorDark,
            child: TextField(
              autofocus: true,
              controller: textEditingController,
              textInputAction: TextInputAction.newline,
              maxLines: null,
              expands: true,
              onChanged: this.widget.onInputChange,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(8, 8, 8, 8)),
            )));
  }

  Widget footer() {
    return Container(
        height: 64,
        child: Expanded(
            child: Row(children: [
          Expanded(child: TextButton(child: Text('Preview'))),
          Expanded(child: TextButton(child: Text('Submit')))
        ])));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[toolbar(context), editor(context), footer()]);
  }
}

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/widgets/bbcode/bbcodeRenderer.dart';
import 'package:knocky/widgets/shared/postEditorBBCode.dart';

class NewPost extends StatefulWidget {
  final int threadId;
  final Function onSubmit;
  NewPost({this.threadId, this.onSubmit});
  @override
  _NewPostState createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {
  final textEditingController = new TextEditingController();
  bool previewing = false;
  @override
  void initState() {
    super.initState();
  }

  Widget body(BuildContext context) {
    return Container(
        color: Theme.of(context).primaryColorDark,
        child: previewing ? renderer() : editor());
  }

  Widget renderer() {
    return Container(
        height: 300,
        padding: EdgeInsets.all(8),
        child: BBcodeRenderer(
          parentContext: context,
          bbcode: textEditingController.text,
        ));
  }

  Widget editor() {
    return Container(
        height: 300,
        child: PostEditorBBCode(textEditingController: textEditingController));
  }

  Widget footer(BuildContext context) {
    return Container(
        color: Theme.of(context).primaryColorDark,
        child: Expanded(child: Row(children: [preview(), submit()])));
  }

  Widget preview() {
    return Expanded(
        child: TextButton.icon(
            icon: Icon(
                previewing ? FontAwesomeIcons.edit : FontAwesomeIcons.eye,
                size: 16),
            label: Text(previewing ? 'Edit' : 'Preview'),
            onPressed: () => setState(() {
                  previewing = !previewing;
                })));
  }

  Widget submit() {
    return Expanded(
        child: TextButton.icon(
            icon: Icon(FontAwesomeIcons.paperPlane, size: 16),
            label: Text('Submit'),
            onPressed: submitClicked));
  }

  submitClicked() async {
    await KnockoutAPI().newPost(textEditingController.text, widget.threadId);
    textEditingController.text = '';
    widget.onSubmit.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[body(context), footer(context)]);
  }
}

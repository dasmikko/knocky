import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:knocky/controllers/threadController.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/helpers/snackbar.dart';
import 'package:knocky/widgets/bbcode/bbcodeRendererNew.dart';
import 'package:knocky/widgets/shared/postEditorBBCode.dart';

class EditPost extends StatefulWidget {
  final int postId;
  final String content;
  final Function onSubmit;
  EditPost({this.postId, this.onSubmit, this.content});
  @override
  _EditPostState createState() => _EditPostState();
}

class _EditPostState extends State<EditPost> {
  final textEditingController = new TextEditingController();
  final ThreadController threadController = Get.put(ThreadController());
  final double height = 300;
  bool previewing = false;

  @override
  void initState() {
    super.initState();
    // rebuild the widget when text is changed so we can enable/disable
    // the submit button
    textEditingController.text = widget.content;
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  Widget body(BuildContext context) {
    return Container(
        color: Theme.of(context).primaryColorDark,
        child: previewing ? renderer() : editor());
  }

  Widget renderer() {
    return Container(
      height: height,
      padding: EdgeInsets.all(8),
      child: SingleChildScrollView(
        child: BBcodeRendererNew(
          parentContext: context,
          bbcode: textEditingController.text,
        ),
      ),
    );
  }

  Widget editor() {
    return Container(
        height: height,
        child: PostEditorBBCode(textEditingController: textEditingController));
  }

  Widget footer(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [preview(), submit()],
            ),
          ),
        ],
      ),
    );
  }

  Widget preview() {
    return Expanded(
      child: TextButton.icon(
        style: ButtonStyle(
            foregroundColor:
                MaterialStateColor.resolveWith((states) => Colors.white)),
        icon: Icon(previewing ? FontAwesomeIcons.edit : FontAwesomeIcons.eye,
            size: 16),
        label: Text(previewing ? 'Edit' : 'Preview'),
        onPressed: () => setState(
          () {
            previewing = !previewing;
          },
        ),
      ),
    );
  }

  Widget submit() {
    var onClick = textEditingController.text.length < 1 ? null : submitClicked;
    return Expanded(
        child: TextButton.icon(
            icon: Icon(FontAwesomeIcons.paperPlane, size: 16),
            label: Text('Submit'),
            onPressed: onClick));
  }

  submitClicked() async {
    SnackbarController snackbarController = KnockySnackbar.normal(
        'Submitting', "Submitting your post update...",
        isDismissible: false, showProgressIndicator: true);
    await KnockoutAPI().updatePost(textEditingController.text, widget.postId);
    snackbarController.close();

    KnockySnackbar.success('Post was updated');
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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:knocky/controllers/threadController.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/helpers/snackbar.dart';
import 'package:knocky/widgets/bbcode/bbcodeRendererNew.dart';
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
  final ThreadController threadController = Get.put(ThreadController());
  final double height = 300;
  bool previewing = false;
  StreamSubscription subscription;

  @override
  void initState() {
    super.initState();
    // rebuild the widget when text is changed so we can enable/disable
    // the submit button
    textEditingController.addListener(() {
      setState(() {});
      // Update the threadController newpost text
      threadController.currentNewPostText.value = textEditingController.text;
    });

    // Use the text inside the thread controller
    textEditingController.text = threadController.currentNewPostText.value;

    // Insert reply if there is any when initializing
    if (threadController.replyToAdd != null) {
      textEditingController.text =
          textEditingController.text + threadController.replyToAdd.value;
      // Reset the replyToAdd variable
      threadController.replyToAdd.value = '';
    }

    // Listen for changes, in case user modifies the replyToAdd variable, and add it to the post text if so. If the newPost widget is mounted
    subscription = threadController.replyToAdd.listen((String newValue) {
      if (newValue != null || newValue.isEmpty) {
        textEditingController.text = textEditingController.text + newValue;
        threadController.replyToAdd.value = '';
      }
    });
  }

  @override
  void dispose() {
    textEditingController.dispose();
    subscription.cancel();
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
        child: PostEditorBBCode(
          textEditingController: textEditingController,
          onInputChange: (String text) {},
        ));
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
        icon: Icon(
            previewing ? FontAwesomeIcons.penToSquare : FontAwesomeIcons.eye,
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
        'Submitting', "Submitting your post...",
        isDismissible: false, showProgressIndicator: true);
    await KnockoutAPI().newPost(textEditingController.text, widget.threadId);
    snackbarController.close();

    KnockySnackbar.success('Post was submitted');
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

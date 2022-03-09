import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:bbob_dart/bbob_dart.dart' as bbob;
import 'package:get/get.dart';
import 'package:knocky/helpers/bbcodeparser.dart';
import 'package:knocky/helpers/colors.dart';
import 'package:knocky/models/thread.dart';
import 'package:knocky/screens/imageViewer.dart';
import 'package:knocky/widgets/post/postsElements/Embed.dart';
import 'package:knocky/widgets/post/postsElements/image.dart';
import 'package:knocky/widgets/post/postsElements/twitter.dart';
import 'package:knocky/widgets/post/postsElements/video.dart';
import 'package:knocky/widgets/post/postsElements/vocaroo.dart';
import 'package:knocky/widgets/post/postsElements/youtube.dart';
import 'package:url_launcher/url_launcher.dart';

class BBcodeRendererNew extends StatelessWidget {
  final String bbcode;
  final BuildContext parentContext;
  final GlobalKey scaffoldKey;
  final ThreadPost postDetails;

  BBcodeRendererNew(
      {this.parentContext, this.bbcode, this.scaffoldKey, this.postDetails});

  InlineSpan _imageNodeHandler(bbob.Element node) {
    return WidgetSpan(
      child: Container(
        margin: EdgeInsets.only(bottom: 8),
        child: ImageWidget(
          postId: postDetails?.id,
          url: node.textContent,
          bbcode: this.bbcode,
        ),
      ),
    );
  }

  InlineSpan _videoNodeHandler(bbob.Element node) {
    return WidgetSpan(
        child: VideoEmbed(
      url: node.textContent,
    ));
  }

  InlineSpan _youtubeNodeHandler(bbob.Element node) {
    return WidgetSpan(
        child: YoutubeVideoEmbed(
      url: node.textContent,
    ));
  }

  InlineSpan _twitterNodeHandler(bbob.Element node) {
    return WidgetSpan(
        child: Container(
      margin: EdgeInsets.only(bottom: 8),
      child: TwitterCard(
        key: ValueKey(node.textContent),
        tweetUrl: node.textContent,
        onTapImage: (List<String> allPhotos, int photoIndex, String hashcode) {
          Get.to(
            () => ImageViewerScreen(
              url: allPhotos[photoIndex],
              urls: allPhotos,
            ),
          );
        },
      ),
    ));
  }

  InlineSpan _vocarooNodeHandler(bbob.Element node) {
    return WidgetSpan(
        child: VocarooEmbed(
      url: node.textContent,
    ));
  }

  InlineSpan _tumblrNodeHandler(bbob.Element node) {
    return WidgetSpan(
        child: EmbedWidget(
      url: node.textContent,
    ));
  }

  InlineSpan _styledTextNodeHandler(bbob.Element node,
      {TextStyle currentTextStyle}) {
    TextStyle textStyle;

    if (currentTextStyle == null) {
      textStyle = Theme.of(parentContext).textTheme.bodyText1.copyWith(
          fontFamily: node.tag == 'code' ? 'RobotoMono' : 'Roboto',
          decoration:
              node.tag == 'u' ? TextDecoration.underline : TextDecoration.none,
          fontWeight: node.tag == 'b' ? FontWeight.bold : FontWeight.normal,
          fontStyle: node.tag == 'i' ? FontStyle.italic : FontStyle.normal,
          fontSize: 14,
          backgroundColor: node.tag == 'spoiler' ? Colors.white : null);
    } else {
      switch (node.tag) {
        case 'code':
          textStyle = currentTextStyle.copyWith(fontFamily: 'RobotoMono');
          break;
        case 'u':
          textStyle =
              currentTextStyle.copyWith(decoration: TextDecoration.underline);
          break;
        case 'b':
          textStyle = currentTextStyle.copyWith(fontWeight: FontWeight.bold);
          break;
        case 'i':
          textStyle = currentTextStyle.copyWith(fontStyle: FontStyle.italic);
          break;
      }
    }

    if (node.tag == 'url' || node.tag == 'url smart') {
      String url;

      if (node.attributes.containsKey('href')) {
        url = node.attributes['href'];
      } else {
        url = node.textContent;
      }

      if (node.attributes.containsKey('smart')) {
        return WidgetSpan(
            child: EmbedWidget(
          url: url,
        ));
      } else {
        return TextSpan(
          text: node.textContent.isNotEmpty
              ? node.textContent
              : node.attributes['href'],
          style: TextStyle(color: Colors.blue),
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              if (await canLaunch(url)) {
                await launch(url);
              } else {
                throw 'Could not launch $url';
              }
            },
        );
      }
    }

    if (node.tag == 'spoiler') {
      return TextSpan(
        text: node.textContent,
        style: textStyle,
        recognizer: TapGestureRecognizer()
          ..onTap = () async {
            return showDialog<void>(
              context: parentContext,
              barrierDismissible: false, // user must tap button!
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Spoiler'),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: <Widget>[
                        SelectableText.rich(
                          TextSpan(children: _handleNodes(node.children)),
                        ),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: Text('Close'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
      );
    }

    if (node is bbob.Text) {
      return TextSpan(style: textStyle, text: (node as bbob.Text).text);
    }

    return TextSpan(
        style: textStyle,
        children: _handleNodes(node.children, currentTextStyle: textStyle));
  }

  InlineSpan _userQuoteNodeHandler(bbob.Element node) {
    AppColors appColors = AppColors(this.parentContext);

    return WidgetSpan(
      child: Container(
        margin: EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            color: appColors.userQuoteBodyBackground(),
            borderRadius: BorderRadius.all(Radius.circular(5.0))),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  color: appColors.userQuoteHeaderBackground(),
                  border: Border(
                    bottom: BorderSide(color: Colors.black, width: 1),
                  ),
                ),
                padding: EdgeInsets.all(10.0),
                child: Text(
                    node.attributes['username'] != null
                        ? node.attributes['username']
                        : 'User' + ' posted:',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: RichText(
                  text: TextSpan(children: _handleNodes(node.children)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InlineSpan _unorderedListNodeHandler(bbob.Element node) {
    return WidgetSpan(
        child: Container(
      margin: EdgeInsets.only(left: 5),
      child: RichText(
        text: TextSpan(
          children: _handleNodes(node.children),
        ),
      ),
    ));
  }

  List<InlineSpan> _handleNodes(List<bbob.Node> nodes,
      {TextStyle currentTextStyle}) {
    List<InlineSpan> spans = [];

    nodes.forEach((node) {
      if (node is bbob.Element) {
        // Special tags like quote and video etc...

        switch (node.tag) {
          case 'h1':
            spans.add(
              TextSpan(
                text: node.textContent + '\n\n',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
            break;
          case 'h2':
            spans.add(
              TextSpan(
                text: node.textContent + '\n\n',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),
            );
            break;
          case 'b':
          case 'i':
          case 'u':
          case 'code':
          case 'url':
          case 'url smart':
          case 'spoiler':
            spans.add(_styledTextNodeHandler(node,
                currentTextStyle: currentTextStyle));
            break;
          case 'twitter':
            spans.add(_twitterNodeHandler(node));
            break;
          case 'video':
            spans.add(_videoNodeHandler(node));
            break;
          case 'youtube':
            spans.add(_youtubeNodeHandler(node));
            break;
          case 'vocaroo':
            spans.add(_vocarooNodeHandler(node));
            break;
          case 'tumblr':
            spans.add(_tumblrNodeHandler(node));
            break;
          case 'img':
          case 'img thumbnail':
            spans.add(_imageNodeHandler(node));
            break;
          case 'blockquote':
            spans.add(
              WidgetSpan(
                child: Container(
                  margin: EdgeInsets.only(bottom: 5.0),
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: Colors.blue, width: 3.0),
                    ),
                    color: Color.fromRGBO(128, 128, 128, 0.1),
                  ),
                  child: SelectableText.rich(
                    TextSpan(children: _handleNodes(node.children)),
                  ),
                ),
              ),
            );
            break;
          case 'quote':
            spans.add(_userQuoteNodeHandler(node));
            break;
          case 'ul':
            spans.add(_unorderedListNodeHandler(node));
            break;
          case 'li':
            spans.add(
              WidgetSpan(
                child: Container(
                  margin: EdgeInsets.only(bottom: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(top: 6, right: 10.0),
                        height: 5.0,
                        width: 5.0,
                        decoration: new BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: SelectableText.rich(
                          TextSpan(
                              style: TextStyle(fontSize: 12),
                              children: _handleNodes(node.children,
                                  currentTextStyle: TextStyle(fontSize: 12))),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
            break;
          default:
            spans.add(TextSpan(text: node.tag));
        }
      }

      if (node is bbob.Text) {
        spans.add(TextSpan(text: node.text));
      }
    });

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    String bbcodeCleaned = this.bbcode.replaceAll('[img thumbnail]', '[img]');
    // Force images into new lines if there isn't any space between them
    bbcodeCleaned = bbcodeCleaned.replaceAll('[/img][img]', '[/img]\n[img]');
    bbcodeCleaned = bbcodeCleaned.replaceAll('[/img] [img]', '[/img]\n[img]');

    // Fix url tags that has smart tagged onto them
    bbcodeCleaned = bbcodeCleaned.replaceAll('[url smart]', '[url smart=true]');

    List<bbob.Node> nodes = new BBCodeParser().parse(bbcodeCleaned);

    return Container(
      child: SelectableText.rich(
        TextSpan(children: _handleNodes(nodes)),
      ),
    );
  }
}

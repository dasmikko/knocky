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
import 'package:url_launcher/url_launcher_string.dart';

class BBcodeRendererNew extends StatefulWidget {
  final String? bbcode;
  final BuildContext? parentContext;
  final GlobalKey? scaffoldKey;
  final ThreadPost? postDetails;

  BBcodeRendererNew(
      {this.parentContext, this.bbcode, this.scaffoldKey, this.postDetails});

  @override
  State<BBcodeRendererNew> createState() => _BBcodeRendererNewState();
}

class _BBcodeRendererNewState extends State<BBcodeRendererNew> {
  bool showSpoiler = false;

  @override
  void initState() {
    super.initState();
  }

  InlineSpan _imageNodeHandler(bbob.Element node) {
    return WidgetSpan(
      child: Container(
        margin: EdgeInsets.only(bottom: 8),
        child: ImageWidget(
          postId: widget.postDetails!.id,
          url: node.textContent,
          bbcode: this.widget.bbcode,
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
    print(node.textContent);
    return WidgetSpan(
      child: Container(
        margin: EdgeInsets.only(bottom: 8),
        child: EmbedWidget(
          url: node.textContent,
        ),
      ),
    );
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
      ),
    );
  }

  InlineSpan _styledTextNodeHandler(bbob.Element node,
      {TextStyle? currentTextStyle}) {
    TextStyle? textStyle;

    if (currentTextStyle == null) {
      textStyle = Theme.of(widget.parentContext!).textTheme.bodyLarge!.copyWith(
          fontFamily: node.tag == 'code' ? 'RobotoMono' : 'Roboto',
          decoration:
              node.tag == 'u' ? TextDecoration.underline : TextDecoration.none,
          fontWeight: node.tag == 'b' ? FontWeight.bold : FontWeight.normal,
          fontStyle: node.tag == 'i' ? FontStyle.italic : FontStyle.normal,
          fontSize: 14,
          backgroundColor:
              node.tag == 'spoiler' && !showSpoiler ? Colors.white : null);
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
      String? url;

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
              try {
                await launchUrlString(url!,
                    mode: LaunchMode.externalNonBrowserApplication);
              } catch (e) {
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
            // TODO: Make it so individual spoilers can be toggled.
            setState(() {
              showSpoiler = !showSpoiler;
            });
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
    AppColors appColors = AppColors(this.widget.parentContext);

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
                        ? node.attributes['username']!
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
      {TextStyle? currentTextStyle}) {
    List<InlineSpan> spans = [];

    nodes.forEach((node) {
      if (node is bbob.Element) {
        // Special tags like quote and video etc...

        switch (node.tag) {
          case 'h1':
            spans.add(
              TextSpan(
                text: node.textContent + '\n',
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
                text: node.textContent + '\n',
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
            print(node);
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
    String bbcodeCleaned = this.widget.bbcode!.trim();

    // Handle the different attributes for images TODO: Make a more clean solution
    bbcodeCleaned =
        bbcodeCleaned.replaceAll('[img thumbnail]', '[img thumbnail=true]');
    bbcodeCleaned = bbcodeCleaned.replaceAll('[img link]', '[img link=true]');
    bbcodeCleaned = bbcodeCleaned.replaceAll(
        '[img link thumbnail]', '[img link=true thumbnail=true]');
    bbcodeCleaned = bbcodeCleaned.replaceAll(
        '[img thumbnail link]', '[img thumbnail=true link=true]');

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

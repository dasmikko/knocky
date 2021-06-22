import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:bbob_dart/bbob_dart.dart' as bbob;
import 'package:get/get.dart';
import 'package:knocky/helpers/bbcodeparser.dart';
import 'package:knocky/helpers/colors.dart';
import 'package:knocky/models/thread.dart';
import 'package:knocky/screens/imageViewer.dart';
import 'package:knocky/widgets/post/postsElements/image.dart';
import 'package:knocky/widgets/post/postsElements/twitter.dart';
import 'package:knocky/widgets/post/postsElements/video.dart';
import 'package:knocky/widgets/post/postsElements/youtube.dart';
import 'package:url_launcher/url_launcher.dart';

class BBcodeRenderer extends StatelessWidget {
  final String bbcode;
  final BuildContext parentContext;
  final GlobalKey scaffoldKey;
  final ThreadPost postDetails;

  BBcodeRenderer(
      {this.parentContext, this.bbcode, this.scaffoldKey, this.postDetails});

  dynamic textHandler(bbob.Node node, bool isRoot) {
    if (isRoot) {
      return RichText(
        text: TextSpan(
          style: TextStyle(height: 2),
          text: node.textContent,
        ),
      );
    } else {
      return TextSpan(text: node.textContent);
    }
  }

  Widget imageHandler(bbob.Element node) {
    return ImageWidget(
      postId: postDetails.id,
      url: node.textContent,
      bbcode: this.bbcode,
    );
  }

  Widget videoHandler(bbob.Element node) {
    // TODO:
    /*
    if (node.textContent.endsWith('.wav') ||
        node.textContent.endsWith('.mp3') ||
        node.textContent.endsWith('.ogg')) {
      return AudioElement(
        url: node.textContent,
        scaffoldKey: this.scaffoldKey,
      );
    }
    */
    return VideoEmbed(
      url: node.textContent,
    );
  }

  Widget youtubeHandler(bbob.Element node) {
    return YoutubeVideoEmbed(
      url: node.textContent,
    );
  }

  Widget twitterHandler(bbob.Element node) {
    return TwitterCard(
      tweetUrl: node.textContent,
      onTapImage: (List<String> allPhotos, int photoIndex, String hashcode) {
        Get.to(
          () => ImageViewerScreen(
            url: allPhotos[photoIndex],
            urls: allPhotos,
          ),
        );
      },
    );
  }

  // TODO: Move out to own file
  Widget userQuoteHandler(bbob.Element node) {
    AppColors appColors = AppColors(this.parentContext);

    return Container(
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
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: nodeChildrenHandler(node.children),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget listItemHandler(node) {
    if (node is bbob.Text) {
      return Container(
        child: RichText(
          text: TextSpan(
            text: node.text,
            style: TextStyle(height: 2),
          ),
        ),
      );
    }

    if (node is bbob.Element) {
      return Container(
        child: Column(children: nodeChildrenHandler(node.children)),
      );
    }
  }

  Widget unorderedListHandler(bbob.Element node) {
    List<Widget> listItems = [];

    node.children.where((item) => item.textContent != "").forEach((item) {
      listItems.add(
        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(right: 10.0),
              height: 5.0,
              width: 5.0,
              decoration: new BoxDecoration(
                color: Theme.of(parentContext).textTheme.body1.color,
                shape: BoxShape.circle,
              ),
            ),
            listItemHandler(item)
          ],
        ),
      );
    });

    return Container(
      margin: EdgeInsets.only(left: 15),
      child: Column(children: listItems),
    );
  }

  TextSpan textElementHandler(List children, {TextStyle currentTextStyle}) {
    List<TextSpan> textSpans = [];

    // convert children to styleless textspans
    children.forEach((item) {
      if (item is bbob.Element) {
        TextStyle textStyle;

        if (currentTextStyle == null) {
          textStyle = Theme.of(parentContext).textTheme.body1.copyWith(
                fontFamily: item.tag == 'code' ? 'RobotoMono' : 'Roboto',
                decoration: item.tag == 'u'
                    ? TextDecoration.underline
                    : TextDecoration.none,
                fontWeight:
                    item.tag == 'b' ? FontWeight.bold : FontWeight.normal,
                fontStyle:
                    item.tag == 'i' ? FontStyle.italic : FontStyle.normal,
              );
        } else {
          switch (item.tag) {
            case 'code':
              textStyle = currentTextStyle.copyWith(fontFamily: 'RobotoMono');
              break;
            case 'u':
              textStyle = currentTextStyle.copyWith(
                  decoration: TextDecoration.underline);
              break;
            case 'b':
              textStyle =
                  currentTextStyle.copyWith(fontWeight: FontWeight.bold);
              break;
            case 'i':
              textStyle =
                  currentTextStyle.copyWith(fontStyle: FontStyle.italic);
              break;
          }
        }

        TextSpan textChildren =
            textElementHandler(item.children, currentTextStyle: textStyle);

        textSpans.add(
          TextSpan(
            style: textStyle,
            children: [textChildren],
          ),
        );
      }

      if (item is bbob.Text) {
        textSpans.add(TextSpan(text: item.text));
      }
    });

    return TextSpan(style: currentTextStyle, children: textSpans);
  }

  List<Widget> nodeChildrenHandler(List<bbob.Node> nodes) {
    List<Widget> widgetList = [];

    List<TextSpan> richTextContent = [];

    // Convert the nodes to widgets
    nodes.forEach((node) {
      if (node is bbob.Element) {
        switch (node.tag) {
          case 'h1':
            if (richTextContent.isNotEmpty) {
              widgetList.add(
                  RichText(text: TextSpan(children: richTextContent.toList())));
              richTextContent.clear();
            }

            widgetList.add(
              RichText(
                text: TextSpan(
                  text: node.textContent,
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                ),
              ),
            );
            break;
          case 'h2':
            if (richTextContent.isNotEmpty) {
              widgetList.add(
                  RichText(text: TextSpan(children: richTextContent.toList())));
              richTextContent.clear();
            }

            widgetList.add(
              RichText(
                text: TextSpan(
                  text: node.textContent,
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                ),
              ),
            );
            break;
          case 'b':
          case 'i':
          case 'u':
          case 'url':
          case 'spoiler':
            TextStyle textStyle = Theme.of(parentContext)
                .textTheme
                .body1
                .copyWith(
                    fontFamily: node.tag == 'code' ? 'RobotoMono' : 'Roboto',
                    decoration: node.tag == 'u'
                        ? TextDecoration.underline
                        : TextDecoration.none,
                    fontWeight:
                        node.tag == 'b' ? FontWeight.bold : FontWeight.normal,
                    fontStyle:
                        node.tag == 'i' ? FontStyle.italic : FontStyle.normal,
                    backgroundColor: node.tag == 'spoiler'
                        ? Theme.of(parentContext).textTheme.bodyText1.color
                        : null);

            if (node.tag == 'url') {
              String url;

              if (node.attributes.containsKey('href')) {
                url = node.attributes['href'];
              } else {
                url = node.textContent;
              }

              print(node.attributes);

              if (node.attributes['smart'] == 'smart') {
                // TODO:
                /*
                widgetList.add(EmbedWidget(
                  url: url,
                ));
                */
              } else {
                richTextContent.add(
                  TextSpan(
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
                        print('Clicked link: ' + url);
                      },
                  ),
                );
              }
            } else if (node.tag == 'spoiler') {
              print('spoiler element');
              richTextContent.add(
                TextSpan(
                  text: node.textContent,
                  style: textStyle,
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      print(node.textContent);
                      return showDialog<void>(
                        context: parentContext,
                        barrierDismissible: false, // user must tap button!
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Spoiler'),
                            content: SingleChildScrollView(
                              child: ListBody(
                                children: <Widget>[
                                  RichText(
                                    text: textElementHandler(node.children),
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
                ),
              );
            } else {
              richTextContent.add(
                textElementHandler(node.children, currentTextStyle: textStyle),
              );
            }

            break;
          case 'blockquote':
            if (richTextContent.isNotEmpty) {
              widgetList.add(
                  RichText(text: TextSpan(children: richTextContent.toList())));
              richTextContent.clear();
            }

            widgetList.add(
              Container(
                margin: EdgeInsets.only(bottom: 5.0),
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Colors.blue, width: 3.0),
                  ),
                  color: Color.fromRGBO(128, 128, 128, 0.1),
                ),
                child: RichText(
                  text: textElementHandler(node.children),
                ),
              ),
            );
            break;
          case 'img':
          case 'img thumbnail':
            if (richTextContent.isNotEmpty) {
              widgetList.add(
                  RichText(text: TextSpan(children: richTextContent.toList())));
              richTextContent.clear();
            }

            widgetList.add(imageHandler(node));
            break;
          case 'video':
            if (richTextContent.isNotEmpty) {
              widgetList.add(
                  RichText(text: TextSpan(children: richTextContent.toList())));
              richTextContent.clear();
            }

            widgetList.add(videoHandler(node));
            break;
          case 'youtube':
            if (richTextContent.isNotEmpty) {
              widgetList.add(
                  RichText(text: TextSpan(children: richTextContent.toList())));
              richTextContent.clear();
            }

            widgetList.add(youtubeHandler(node));
            break;
          case 'twitter':
            if (richTextContent.isNotEmpty) {
              widgetList.add(
                  RichText(text: TextSpan(children: richTextContent.toList())));
              richTextContent.clear();
            }

            widgetList.add(twitterHandler(node));
            break;
          case 'quote':
            if (richTextContent.isNotEmpty) {
              widgetList.add(
                  RichText(text: TextSpan(children: richTextContent.toList())));
              richTextContent.clear();
            }

            widgetList.add(userQuoteHandler(node));
            break;
          case 'ul':
            if (richTextContent.isNotEmpty) {
              widgetList.add(
                  RichText(text: TextSpan(children: richTextContent.toList())));
              richTextContent.clear();
            }

            widgetList.add(unorderedListHandler(node));
            break;
          default:
        }
      }

      if (node is bbob.Text) {
        richTextContent.add(TextSpan(text: node.text));
      }
    });

    if (richTextContent.isNotEmpty) {
      widgetList
          .add(RichText(text: TextSpan(children: richTextContent.toList())));
    }

    return widgetList;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgetList = [];

    // TODO: This is a dirty quickfix for images that should be displayed as thumbnails
    String bbcodeCleaned = this.bbcode.replaceAll('[img thumbnail]', '[img]');

    List<bbob.Node> nodes = new BBCodeParser().parse(bbcodeCleaned);

    widgetList = nodeChildrenHandler(nodes);

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgetList,
      ),
    );
  }
}

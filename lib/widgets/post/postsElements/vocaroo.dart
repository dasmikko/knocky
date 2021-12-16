import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class VocarooEmbed extends StatelessWidget {
  final String url;
  const VocarooEmbed({Key key, this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String id = url.split('/').last;

    return Container(
      height: 80,
      margin: EdgeInsets.only(bottom: 8),
      child: InAppWebView(
        initialOptions: InAppWebViewGroupOptions(
            android: AndroidInAppWebViewOptions(
          useWideViewPort: false,
          initialScale: 0,
          textZoom: 100,
        )),
        initialData: InAppWebViewInitialData(data: """
        <iframe title="1b1Y4dq0sSfg" type="text/html" width="100%" height="auto" src="https://vocaroo.com/embed/$id" frameborder="0" allowfullscreen="" class="sc-clsHhM dcyGMh"></iframe>
        """),
      ),
    );
  }
}

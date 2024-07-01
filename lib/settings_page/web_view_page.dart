import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../localaization/language_constant.dart';


class WebViewPage extends StatefulWidget {
  final String appBarTitleName;
  final String url;
  const WebViewPage({super.key, required this.appBarTitleName, required this.url});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late  WebViewController controller;
  bool internetDisconnected=false;
  var loadingPercentage = 0;


  @override
  void setState(VoidCallback fn) {
    if (mounted){
      super.setState(fn);
    }
  }

  @override
  void initState() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {

            setState(() {
              loadingPercentage = progress;
            });
          },
          onPageStarted: (String url) {
            setState(() {
              loadingPercentage = 0;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              loadingPercentage = 100;
            });
          },
          onWebResourceError: (error) {
            if (error.errorType == WebResourceErrorType.hostLookup) {
              setState(() {
                internetDisconnected = true;
              });
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.appBarTitleName,style: const TextStyle(fontSize: 18),)),
        body:  Stack(
          children: [
            !internetDisconnected?WebViewWidget(controller: controller):  Center(
              child:Text(
              translation(context).noInternetConnection,
                style: TextStyle(
                  fontSize: 24,
                ),
              )
            ),
            if (loadingPercentage < 100)
              LinearProgressIndicator(
                value: loadingPercentage / 100.0,
              ),
          ],
        )
    );
  }
}


// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DocScannerWebViewPage extends StatefulWidget {
  String appBarTitleName;
  String url;
  DocScannerWebViewPage({super.key,required this.url,required this.appBarTitleName});

  @override
  State<DocScannerWebViewPage> createState() => _DocScannerWebViewPageState();
}

class _DocScannerWebViewPageState extends State<DocScannerWebViewPage> {
  late final WebViewController controller;

  bool internetDisconnected=false;
  var loadingPercentage = 0;
  @override
  void initState() {
    super.initState();

    // #docregion webview_controller
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.

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
    // #enddocregion webview_controller
  }

  // #docregion webview_widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.appBarTitleName}')),
      body:  Stack(
        children: [
          !internetDisconnected?WebViewWidget(controller: controller): const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // SvgPicture.asset(
                //   "no_signal.svg",
                //   width: MediaQuery.sizeOf(context).width / 2,
                // ),
                SizedBox(height: 20),
                Text(
                  "no network",
                  style: TextStyle(
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
          if (loadingPercentage < 100)
            LinearProgressIndicator(
              value: loadingPercentage / 100.0,
            ),
        ],
      )
    );
  }
// #enddocregion webview_widget
}
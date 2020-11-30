import 'dart:core';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class appWebView extends StatefulWidget {
  String link;
  appWebView({this.link});
  _HomeState createState() => _HomeState(link);

}

class _HomeState extends State<appWebView> {
  String link;
  _HomeState(this.link);


  InAppWebViewController webView;
  double progress = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar : AppBar(
          centerTitle: true,
          title : Text("Stripe Web View"),
          elevation: 0.0,
          backgroundColor: Colors.amberAccent[400],
        ),
        body: Container(
            child: InAppWebView(
              initialUrl: link,
              initialHeaders: {},
              initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                    debuggingEnabled: true,
                  )
              ),
              onWebViewCreated: (InAppWebViewController controller) {
                webView = controller;
              },
              onLoadStart: (InAppWebViewController controller, String url) {
                if (url == "https://example.com/return") {
                  controller.goBack();
                  Navigator.pop(context);
                }
              },
              onLoadStop: (InAppWebViewController controller, String url) async {
                setState(() {
                  this.link = url;
                });
              },
              onProgressChanged: (InAppWebViewController controller, int progress) {
                setState(() {
                  this.progress = progress / 100;
                });
              },
            ),
          ),
        );
  }
}















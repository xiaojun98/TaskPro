import 'package:flutter/material.dart';

class LoadingDialog {
  static Future<void> showLoadingDialog(BuildContext context, GlobalKey key, String text) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(
                  key: key,
                  backgroundColor: Colors.white,
                  children: <Widget>[
                    Center(
                      child: Column(children: [
                        CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.amber[800]),),
                        SizedBox(height: 10,),
                        Text(text,style: TextStyle(color: Colors.amber[800],),)
                      ]),
                    )
                  ]));
        });
  }
}
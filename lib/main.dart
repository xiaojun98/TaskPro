import 'package:flutter/material.dart';
import 'screens/StartUp.dart';
import 'screens/Root.dart';

void main() => runApp(MaterialApp(
  theme: ThemeData(
    primaryColor: Colors.amberAccent[400],
    accentColor: Colors.amber[800],
    cursorColor: Colors.amberAccent[400],
  ),
  // home : StartUp(),
  home : OurRoot(),
  // builder: (context, child) {
  //   return MediaQuery(
  //     child: child,
  //     data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
  //   );
  // },
))
;

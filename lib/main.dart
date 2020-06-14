import 'package:flutter/material.dart';
import 'screens/MainPage.dart';

void main() => runApp(MaterialApp(
  theme: ThemeData(
    primaryColor: Colors.amberAccent[400],
    accentColor: Colors.amber[800],
    cursorColor: Colors.amberAccent[400],
  ),
  home : MainPage(),
)
)
;
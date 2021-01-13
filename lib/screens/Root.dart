import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'Login.dart';
import 'StartUp.dart';
import 'MainNavigation.dart';

enum AuthStatus { unknown, notLoggedIn, loggedIn }

class OurRoot extends StatefulWidget {
  @override
  _OurRootState createState() => _OurRootState();
}

class _OurRootState extends State<OurRoot> {
  AuthStatus _authStatus = AuthStatus.unknown;
  FirebaseUser user;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    FirebaseAuth _auth = FirebaseAuth.instance;
    user = await _auth.currentUser();

    if (user != null) {
      setState(() {
        _authStatus = AuthStatus.loggedIn;
      });
    } else {
      setState(() {
        _authStatus = AuthStatus.notLoggedIn;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget retVal;

    switch (_authStatus) {
      case AuthStatus.unknown:
        retVal = StartUp();
        break;
      case AuthStatus.notLoggedIn:
        retVal = StartUp();
        break;
      case AuthStatus.loggedIn:
        retVal = MainNavigation(user: user);
        break;
      default:
    }
    return retVal;
  }
}


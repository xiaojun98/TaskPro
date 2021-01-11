import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'Login.dart';
import 'Register.dart';

class StartUp extends StatefulWidget{
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<StartUp> {
  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics().setCurrentScreen(screenName: "StartUpScreen");
    return Scaffold(
      body: Center(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10) ,
            child: CircleAvatar (backgroundImage : AssetImage('assets/rocket.jpg'),radius: 60,),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0,10,0,20) ,
            child: Text('TaskPro', style: TextStyle(fontSize: 56,color: Colors.amberAccent[400],),),
          ),
          OutlineButton(
            onPressed: (){
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Login(), settings: RouteSettings(name: "LoginView")));
            },
            child: Text ('Login',style: TextStyle(fontSize: 18,color: Colors.amberAccent[400],fontFamily: 'OpenSansR')),
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
          ),
          OutlineButton(
            onPressed: (){
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Register(), settings: RouteSettings(name: "RegisterView")));
            },
            child: Text ('Register', style: TextStyle(fontSize: 18,color: Colors.amberAccent[400],fontFamily: 'OpenSansR')),
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),

          ),
        ],
      ),
      ),
    );
  }



}
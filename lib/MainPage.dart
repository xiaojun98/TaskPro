import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
  home : Home(),
)
)
;

class Home extends StatefulWidget{
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
//      appBar: AppBar(title : Text('TaskPro'),
//        centerTitle: true ,
//        elevation: 0.0,
//        backgroundColor: Colors.amberAccent[400],
//      ),
      body: Center(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10) ,
            child: CircleAvatar (backgroundImage : AssetImage('assets/rocket.jpg')),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0) ,
            child: Text('TaskPro', style: TextStyle(fontSize: 36,color: Colors.amberAccent[400]),),
          ),
          OutlineButton(
            onPressed: (){},
            child: Text ('Login'),
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
          ),
          OutlineButton(
            onPressed: (){},
            child: Text ('Register'),
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),

          ),
        ],
      ),
      ),
    );
  }



}
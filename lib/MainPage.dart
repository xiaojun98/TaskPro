import 'package:flutter/material.dart';
import 'Login.dart';

void main() => runApp(MaterialApp(
  home : MainPage(),
)
)
;

class MainPage extends StatefulWidget{
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<MainPage> {
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
            child: CircleAvatar (backgroundImage : AssetImage('assets/rocket.jpg'),radius: 30,),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0,10,0,20) ,
            child: Text('TaskPro', style: TextStyle(fontSize: 48,color: Colors.amberAccent[400]),fontFamily: 'OpenSansR'),
          ),
          OutlineButton(
            onPressed: (){
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Login()));
            },
            child: Text ('Login',style: TextStyle(fontSize: 18,color: Colors.amberAccent[400],fontFamily: 'OpenSansR')),
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
          ),
          OutlineButton(
            onPressed: (){},
            child: Text ('Register', style: TextStyle(fontSize: 18,color: Colors.amberAccent[400],fontFamily: 'OpenSansR')),
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),

          ),
        ],
      ),
      ),
    );
  }



}
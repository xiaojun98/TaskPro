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
  int num =0;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title : Text('Hello App'),
        centerTitle: true ,
        elevation: 0.0,
        backgroundColor: Colors.amberAccent[400],),
//      body: Center(
////        child: Text('This is center child', style: TextStyle(fontStyle: FontStyle.italic,fontFamily: 'FontEx'),),
////        child: Image.asset('assets/rocket.jpg')
////        child: RaisedButton.icon(
////          onPressed: () {print('Wow!');},
////          icon : Icon( Icons.bookmark,color : Colors.white),
////          label : Text ('Bookmark'),
////          color :Colors.amberAccent[400]
////        )
//        child : IconButton(onPressed: (){print('Wow 2');},
//          icon : Icon(Icons.bookmark_border),
//          color: Colors.amberAccent[400],
//        )
//      ),
      body : Column(
        children : <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 30.0) ,
              child: CircleAvatar (backgroundImage : AssetImage('assets/rocket.jpg'))),
          Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Container(
              child: Text('$num'),
              padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
              color: Colors.deepOrange,
            ),
            Expanded(
              child: Container(
                child: Text('Two'),
                  color: Colors.tealAccent
              ),
            ),
            RaisedButton(onPressed: (){},child: Text('Button'),),
          ]),
          IconButton(onPressed:(){},icon : Icon(Icons.timeline)),
          IconButton(onPressed:(){},icon : Icon(Icons.insert_drive_file)),
          FloatingActionButton  (
            child: Icon(Icons.add),
            onPressed: () {
              setState(() {
                num+=1;
              });
            },),
          IconButton(onPressed:(){},icon : Icon(Icons.calendar_today)),
          IconButton(onPressed:(){},icon : Icon(Icons.supervised_user_circle)),
        ],
      ),

    );
  }
}


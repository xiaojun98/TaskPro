import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Timeline extends StatefulWidget {
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Timeline> {
  @override
  Icon searchCon = Icon(Icons.search);
  Widget title = Text('Timeline');

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title : title,
        leading: IconButton(icon : Icon(Icons.inbox), onPressed: (){},),
        elevation: 0.0,
        backgroundColor: Colors.amberAccent[400],
        actions: <Widget>[
          IconButton(
            icon : searchCon,
            onPressed: (){
              setState(() {
                if(this.searchCon.icon == Icons.search){
                  this.searchCon = Icon(Icons.cancel);
                  this.title = TextField(
                    decoration: InputDecoration (hintText: "Search ... "),
                    textInputAction: TextInputAction.go,
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  );
                }
                else {
                  this.searchCon = Icon(Icons.search);
                  this.title = Text('Timeline');
                }
              });
          },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20,vertical: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text('Popular Categories', style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,fontFamily: 'OpenSans'),),
                  InkWell(
                      onTap: (){},
                      child: Text('View all', style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,fontFamily: 'OpenSans',),)),
                ],
              )
            ),
//            Container(
//              child: GridView(
//                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3,childAspectRatio: 3/2,),
//                children: <Widget>[
//
//                ],
//              ),
//            )
          ],
        ),

      ),
    );
  }
}
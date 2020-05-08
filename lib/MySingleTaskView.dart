import 'package:flutter/material.dart';

class MySingleTaskView extends StatefulWidget {
  _HomeState createState() => _HomeState();

}


class _HomeState extends State<MySingleTaskView> {
  TextStyle _style = TextStyle(fontFamily: 'OpenSans-R',fontSize: 16,);
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title : Text('MyTask'),
        centerTitle: true ,
        elevation: 0.0,
        backgroundColor: Colors.amberAccent[400],
      ),
      body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text('Lorem ipsum dolor sit', style : TextStyle(fontFamily: 'OpenSans-R',fontSize: 18,)),
                SizedBox(height: 20,),
                Text('Posted At : ',style: _style),
                Text('2020-05-07',style: _style,),
                SizedBox(height: 20,),
                Text('Status : ',style: _style),
                Text('Receiving offers/In Progress',style: _style,),
                SizedBox(height: 20,),
                Text('Task Description : ',style: _style),
                Text('Lorem ipsum dolor sit amet, utinam eligendi complectitur vel ut, nam fugit saperet an. Duo quod sapientem principes id, fastidii di',style: _style,),
                SizedBox(height: 20,),
                Text('Requirements : ',style: _style),
                Text('Agam rebum est ne. Sonet everti eligendi has ad, pro labore concludaturque eu, at mucius periculis consequuntur pri.',style: _style,),
                SizedBox(height: 20,),
                Text('Note to service provider : ',style: _style),
                Text('Ut fugit dicit antiopam vix, mei causae impetus ea, summo deterruisset at has.',style: _style,),
                SizedBox(height: 20,),
                Text('Tag(s) : ',style: _style),
                Text('Household , Cleaning',style: _style,),
                SizedBox(height: 20,),
                Text('Deadline : ',style: _style),
                Text('2020-12-31',style: _style,),
                SizedBox(height: 20,),
                Text('Commission : ',style: _style),
                Text('RM123',style: _style,),
                SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    FlatButton(
                      onPressed: (){

                      },
                      child: Text ('View Offer',
                        style: TextStyle(fontSize: 16,color: Colors.black,fontFamily: 'OpenSansR'),),
                      shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                      color: Colors.amber[100],
                    ),
                    FlatButton(
                      onPressed: (){

                      },
                      child: Text ('Delete',
                        style: TextStyle(fontSize: 16,color: Colors.black,fontFamily: 'OpenSansR'),),
                      shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                      color: Colors.amber[100],
                    ),
                    FlatButton(
                      onPressed: (){

                      },
                      child: Text ('Edit',
                        style: TextStyle(fontSize: 16,color: Colors.black,fontFamily: 'OpenSansR'),),
                      shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                      color: Colors.amber[100],
                    ),
                  ],
                ),
              FlatButton(
                onPressed: (){

                },
                child: Text ('Mark Complete',
                  style: TextStyle(fontSize: 16,color: Colors.black,fontFamily: 'OpenSansR'),),
                shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                color: Colors.grey[350],)
            ]),
          )
      ),
    );
  }
}

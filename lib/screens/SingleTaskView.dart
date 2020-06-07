import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SingleTaskView extends StatefulWidget {
  _HomeState createState() => _HomeState();

}


class _HomeState extends State<SingleTaskView> {
  TextStyle _style = TextStyle(fontFamily: 'OpenSans-R',fontSize: 16,);
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title : Text('Task Details'),
        centerTitle: true ,
        elevation: 0.0,
        backgroundColor: Colors.amberAccent[400],
      ),
      body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(30),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                          padding: EdgeInsets.fromLTRB(0,20,20,20),
                          child: CircleAvatar (backgroundImage : AssetImage('assets/sampleProfile.jpg'),radius: 25)),
                      Text('Shou Yue',style: TextStyle(color : Colors.lightBlue[900]),),
                    ],
                  ),
                  Text('Cake Delivery', style : TextStyle(fontFamily: 'OpenSans-R',fontSize: 18,)),
                  SizedBox(height: 20,),
                  Text('Posted At : ',style: _style),
                  Text('2020-05-07',style: _style,),
                  SizedBox(height: 20,),
                  Text('Status : ',style: _style),
                  Text('Receiving offers',style: _style,),
                  SizedBox(height: 20,),
                  Text('Task Description : ',style: _style),
                  Text('Purchase strawberry cake from ChangAn bakery, insert an angpao of RM200 and send to address below.',style: _style,),
                  SizedBox(height: 20,),
                  Text('Requirements : ',style: _style),
                  Text('Delivery date : 2020-05-08 8.00pm. AngPao is a must. Plese write happy birthday on cake',style: _style,),
                  SizedBox(height: 20,),
                  Text('Note to service provider : ',style: _style),
                  Text('Address is 145, Chang Road, ZhongAn District',style: _style,),
                  SizedBox(height: 20,),
                  Text('Tag(s) : ',style: _style),
                  Text('Delivery',style: _style,),
                  SizedBox(height: 20,),
                  Text('Deadline : ',style: _style),
                  Text('2020-05-08',style: _style,),
                  SizedBox(height: 20,),
                  Text('Commission : ',style: _style),
                  Text('RM300',style: _style,),
                  SizedBox(height: 20,),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      FloatingActionButton(
                        heroTag: 'Btn1',
                        backgroundColor: Colors.amber,
                        child: IconButton(
                          icon: Icon(Icons.bookmark),
                        ),
                        onPressed: () {},
                      ),
                      FloatingActionButton(
                        heroTag: 'Btn2',
                        backgroundColor: Colors.amber,
                        child: IconButton(
                          icon: Icon(Icons.send),
                        ),
                        onPressed: () {},
                      )
                    ],
                  )
                ]),
          )
      ),
    );
  }
}

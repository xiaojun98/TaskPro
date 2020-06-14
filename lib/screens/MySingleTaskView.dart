import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:testapp/screens/CreateTask.dart';
import '../models/Task.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MySingleTaskView extends StatefulWidget {
  FirebaseUser user;
  Task task;
  MySingleTaskView({this.user, this.task});
  _HomeState createState() => _HomeState(user, task);

}

class _HomeState extends State<MySingleTaskView> {
  FirebaseUser user;
  Task task;
  _HomeState(this.user, this.task);
  TextStyle _style = TextStyle(fontFamily: 'OpenSans-R',fontSize: 16,);
  bool ownTask = false;
  Widget build(BuildContext context) {
    ownTask = task.createdBy.documentID == user.uid;
    return Scaffold(
      appBar: AppBar(
        title : Text('Task Details'),
        centerTitle: true ,
        elevation: 0.0,
        backgroundColor: Colors.amberAccent[400],
        actions: ownTask ? <Widget>[
          PopupMenuButton(
            onSelected: (result) {
              if(result == 0) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => CreateTask(user: user, task: task,)));
              } else {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Confirm cancel task?'),
                      actions: <Widget>[
                        FlatButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          textColor: Colors.grey,
                          child: const Text('No'),
                        ),
                        FlatButton(
                          onPressed: () {
                            Firestore.instance.collection('task').document(task.id).updateData({
                              'updated_by': Firestore.instance.document('users/'+user.uid),
                              'updated_at': DateTime.now(),
                              'status': 'Cancelled',
                            });
                            Navigator.of(context).pop();
                          },
                          textColor: Theme.of(context).primaryColor,
                          child: const Text('Yes, Cancel'),
                        ),
                      ],
                    );
                  },
                );
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  child: Text('Edit Task'),
                  value: 0,
                ),
                PopupMenuItem(
                  child: Text('Cancel Task'),
                  value: 1,
                ),
              ];
            },
          ),
        ] : [],
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
                Text(task.title, style: TextStyle(fontFamily: 'OpenSans-R', fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 5,),
                Text('ID: '+task.id,style: TextStyle(fontFamily: 'OpenSans-R', fontSize: 12, color: Colors.grey)),
                SizedBox(height: 20,),
                Text('Posted At : ',style: _style),
                Text(DateFormat('yyyy-MM-dd  h:mm a').format(task.createdAt).toString(),style: _style,),
                SizedBox(height: 20,),
                Text('Status : ',style: _style),
                Text('Receiving offers/In Progress',style: _style,),
                SizedBox(height: 20,),
                Text('Task Description : ',style: _style),
                Text(task.description,style: _style,),
                SizedBox(height: 20,),
                Text('Additional Instruction : ',style: _style),
                Text(task.additionalInstruction ?? '-',style: _style,),
                SizedBox(height: 20,),
                Text('Tag(s) : ',style: _style),
                Text(task.tags ?? '-',style: _style,),
                SizedBox(height: 20,),
                Text('Date & Time : ',style: _style),
                Text(DateFormat('yyyy-MM-dd  h:mm a').format(task.dateTime).toString(),style: _style,),
                SizedBox(height: 20,),
                Text('Location : ',style: _style),
                Text(task.location ?? '-',style: _style,),
                SizedBox(height: 20,),
                Text('Fee : ',style: _style),
                Text('RM'+task.fee.toStringAsFixed(2),style: _style,),
                SizedBox(height: 20,),
                buildActionButtons(context, user, task, ownTask),
            ]),
          )
      ),
    );
  }
}

Widget buildActionButtons(BuildContext context, FirebaseUser user, Task task, bool ownTask){
  if(ownTask) {
    if(task.status=='Open') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          FlatButton(
            onPressed: (){

            },
            child: Text ('View Offer',
              style: TextStyle(fontSize: 16,color: Colors.black,fontFamily: 'OpenSansR'),),
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.amber[100],
          ),
        ],
      );
    } else if(task.status=='Ongoing') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          FlatButton(
            onPressed: (){

            },
            child: Text ('Mark Complete',
              style: TextStyle(fontSize: 16,color: Colors.black,fontFamily: 'OpenSansR'),),
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.grey[350],
          ),
        ],
      );
    }
    return null;
  } else {
    return Row(
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
    );
  }
}
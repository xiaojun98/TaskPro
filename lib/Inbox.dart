import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Inbox extends StatefulWidget {
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Inbox> {
  List <Message> msg = [
    Message('Alicia Ong','Ok. No problem.','2020-05-03 08:23:31'),
    Message('Tan Win Yin','see you later.','2020-05-04 10:12:21'),
    Message('Mohd Syafiq','boleh sir.','2020-05-04 13:56:44'),
  ];

  List <Notification> notifation = [
    Notification('Stay at home Covid-19','Stay home and we will do your work for you. TaskPro make it easy for you'),
    Notification('Report ID83759','Your task #1292849 is cancelled successfully.'),
    Notification('Task Completed','You have received RM23 from task #24679'),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(title : Text('Inbox'),
          centerTitle: true ,
          elevation: 0.0,
          actions: <Widget>[
            IconButton(
              icon : Icon(Icons.delete),
              tooltip: 'Delete Message',
              onPressed: () {},),
            IconButton(
              icon : Icon(Icons.add_circle_outline),
              tooltip: 'New Message',
              onPressed: () {},),
          ],
          backgroundColor: Colors.amberAccent[400],
          bottom: TabBar(
            indicatorColor: Colors.white,
            tabs: <Widget>[
              Tab(text: 'Message',),
              Tab(text: 'Notification',),
            ],

          ),
        ),

        body: TabBarView(
          children: <Widget>[
            ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                itemCount: msg.length,
                itemBuilder: (context,index){
                  return Card(
                    child: ListTile(
                      onTap: (){

                      },
                      leading: CircleAvatar (
                      backgroundImage : AssetImage('assets/profile-icon.png'),radius: 30,),
                      title: Text(msg[index].sender),
                      subtitle:Text(msg[index].latestMsg,overflow: TextOverflow.ellipsis),
                      trailing: Text(msg[index].datetime,),
                    ),
                  );
                }
            ),
            ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                itemCount: notifation.length,
                itemBuilder: (context,index){
                  return Card(
                    child: ListTile(
                      onTap: (){},
                      leading: Icon(Icons.notifications,color: Colors.amberAccent,),
                      title: Text(notifation[index].title),
                      subtitle: Text(notifation[index].nortiMsg,overflow: TextOverflow.ellipsis),
                    ),
                  );
                }
            ),
          ],
        ),
      ),
    );
  }
}

class Message {
  String sender;
  String latestMsg;
  String datetime;

  Message (String sender,String latestMsg, String datetime ) {
    this.sender = sender;
    this.latestMsg = latestMsg;
    this.datetime = datetime;
  }
}

class Notification {
  String title;
  String nortiMsg;

  Notification (String title,String nortiMsg){
    this.title = title;
    this.nortiMsg = nortiMsg;

  }
}





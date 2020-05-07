import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyTask extends StatefulWidget {
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<MyTask> {
  List <Task> taskPub = [
    Task('Help for translation','SampleMe',0,false),
    Task('Urgent child care','SampleMe',1,false),
    Task('Logo Design','SampleMe',3,false),
    Task('Game account training','SampleMe',0,false),
  ];
  List <Task> taskOff = [
    Task('Cheque Deposit Runner','Alicia Ong',5,false),
    Task('Item Delivery','Tan Win Yin',3,false),
    Task('Household Cleaner','Mohd Syafiq',5,false),
  ];
  List <Task> history = [
    Task('Shopper needed','Lim Mei Li',2,false),
    Task('House tuition teacher','Vincent Tan',4,false),
    Task('Beauty lesson 1 on 1','Chiew YanKee',6,false),
  ];
  List <Task> bookmark = [
    Task('Photographer needed','Tan Kin Yen',0,true),
    Task('Help to edit this poster','Ivan Koov',1,true),
  ];

  Icon _getIcon(int status){
    switch(status){
      case 0: return Icon(Icons.check_circle);
      case 1: return Icon(Icons.check_circle,color: Colors.amber,);
      case 2: return Icon(Icons.check_circle,color: Colors.greenAccent[700],);
      case 3: return Icon(Icons.swap_horizontal_circle,color: Colors.amber,);
      case 4: return Icon(Icons.remove_circle,color: Colors.red,);
      case 5: return Icon(Icons.swap_horizontal_circle,);
      case 6: return Icon(Icons.timer_off,color: Colors.red,);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(title : Text('MyTask'),
          centerTitle: true ,
          elevation: 0.0,
          backgroundColor: Colors.amberAccent[400],
          bottom: TabBar(
            indicatorColor: Colors.white,
            tabs: <Widget>[
              Tab(text: 'Published',),
              Tab(text: 'Offered',),
              Tab(text: 'Bookmark',),
              Tab(text: 'History',),
            ],
          ),
        ),

        body: TabBarView(
          children: <Widget>[
            ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
              itemCount: taskPub.length,
              itemBuilder: (context,index){
                return Card(
                  child: ListTile(
                    onTap: (){},
                    leading: _getIcon(taskPub[index].status),
                    title: Text(taskPub[index].taskTitle),
                    trailing: Text(taskPub[index].getStatus(),style: TextStyle(fontSize: 12),),
                  ),
                );
              }
            ),
            ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
              itemCount: taskOff.length,
              itemBuilder: (context,index){
                return Card(
                  child: ListTile(
                    onTap: (){},
                    leading: _getIcon(taskOff[index].status),
                    title: Text(taskOff[index].taskTitle),
//                      subtitle: Text(taskOff[index].getPublisher(),style: TextStyle(fontSize: 12)),
                    trailing: Text(taskOff[index].getStatus(),style: TextStyle(fontSize: 12),),
                  ),
                );
              }
            ),
            ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
              itemCount: bookmark.length,
              itemBuilder: (context,index){
                return Card(
                  child: ListTile(
                    onTap: (){},
                    leading: Icon(Icons.bookmark),
                    title: Text(bookmark[index].taskTitle),
                    trailing: Text(bookmark[index].getStatus(),style: TextStyle(fontSize: 12),),
                  ),
                );
              }
          ),
            ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
              itemCount: history.length,
              itemBuilder: (context,index){
                return Card(
                  child: ListTile(
                    onTap: (){},
                    leading: _getIcon(history[index].status),
                    title: Text(history[index].taskTitle),
                    trailing: Text(history[index].getStatus(),style: TextStyle(fontSize: 12),),
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

class Task{
  int status;
  String taskTitle;
  bool bookmark;
  String publisher;

  Task (String taskTitle,String publisher,int status,bool bm){
    this.taskTitle=taskTitle;
    this.publisher=publisher;
    this.status=status;
    this.bookmark=bm;
  }

  String getStatus(){
    switch(status){
      case 0 : return 'Published' ;
      case 1 : return 'Received Offer' ;
      case 2 : return 'Completed' ;
      case 3 : return 'In progress' ;
      case 4 : return 'Cancelled' ;
      case 5 : return 'Pending' ;
      case 6 : return 'Expired' ;
    }
  }
  String getPublisher(){
    return publisher;
    }
  }



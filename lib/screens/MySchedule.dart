import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:table_calendar/table_calendar.dart';

class MySchedule extends StatefulWidget {
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<MySchedule> {
  @override
  List <Task> deadlines = [
    Task('Help for translation','2020-05-18',0),
    Task('Urgent child care','2020-05-20',1),
    Task('Logo Design','2020-05-21',3),
    Task('Game account training','2020-05-28',0),
  ];

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title : Text('Schedule'),
        elevation: 0.0,
        backgroundColor: Colors.amberAccent[400],

      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            TableCalendar(
              calendarController: CalendarController(),

            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text('Upcoming deadlines',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,fontFamily: 'OpenSans'),),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 5,horizontal: 15),
              height: 300,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                itemCount: deadlines.length,
                itemBuilder: (context,index){
                  return Card(
                    child: ListTile(
                      onTap: (){},
                      leading:  Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children : <Widget>[
                          Text('${deadlines[index].getDaysLeft()}',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                          Text('Days Left',style: TextStyle(fontSize: 7),),
                        ],
                      ),
                      title: Text(deadlines[index].taskTitle),
                      trailing: Text(deadlines[index].getDeadline(),style: TextStyle(fontSize: 12),),
                    ),
                  );
                }
              ),
            ),
          ],
        )
      ),
    );
  }
}

class Task{
  int status;
  String taskTitle;
  String deadline;

  Task (String taskTitle,String deadline,int status){
    this.taskTitle=taskTitle;
    this.deadline=deadline;
    this.status=status;
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
  String getDeadline(){
    return deadline;
  }

  int getDaysLeft(){
    DateTime end = DateTime.parse(deadline);
    DateTime now = DateTime.now();
    return end.difference(now).inDays;
  }
}
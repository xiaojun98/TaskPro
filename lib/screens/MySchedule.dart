import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/Task.dart';
import 'MySingleTaskView.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MySchedule extends StatefulWidget {
  FirebaseUser user;
  MySchedule({this.user});
  _HomeState createState() => _HomeState(user);

}

class _HomeState extends State<MySchedule> {
  FirebaseUser user;
  _HomeState(this.user);
  Map<DateTime, List> eventList;
  CalendarController _calendarController;


  void initState() {
    super.initState();
    _calendarController = CalendarController();
    eventList = {};
  }

  @override
  void dispose() {
    super.dispose();
  }
  @override
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
              calendarController: _calendarController,
              events: eventList,
              calendarStyle: CalendarStyle(
                selectedColor: Colors.deepOrange[400],
                todayColor: Colors.deepOrange[200],
                markersColor: Colors.blue,
                outsideDaysVisible: false,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text('Upcoming deadlines',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,fontFamily: 'OpenSans'),),
            ),

            StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection('task')
                  .where('created_by', isEqualTo: Firestore.instance.collection('users').document(user.uid))
                  .where('status', whereIn: ['Open','Ongoing'])
                  .orderBy('date_time', ).snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if(!snapshot.hasData) {
                  return Center(child: Text('No task found.', style: TextStyle(color: Colors.grey),),);
                } else {
                  List<Task> taskList = [];
                  for (DocumentSnapshot doc in snapshot.data.documents) {
                    Task task = new Task();
                    task.id = doc.data['id'];
                    task.createdBy = doc.data['created_by'];
                    task.createdAt = doc.data['created_at']?.toDate();
                    task.updatedBy = doc.data['updated_by'];
                    task.updatedAt = doc.data['updated_at']?.toDate();
                    task.author = doc.data['author'];
                    task.serviceProvider = doc.data['service_provider'];
                    task.category = doc.data['category'];
                    task.title = doc.data['title'];
                    task.description = doc.data['description'];
                    task.additionalInstruction = doc.data['additional_instruction'];
                    task.tags = doc.data['tags'];
                    task.dateTime = doc.data['date_time']?.toDate();
                    task.location = doc.data['location'];
                    task.fee = double.parse(doc.data['fee'].toString());
                    task.payment = doc.data['payment'];
                    task.status = doc.data['status'];
                    task.offeredBy = doc.data['offered_by'];
                    task.isCompleteByAuthor = doc.data['is_complete_by_author'];
                    task.isCompleteByProvider = doc.data['is_complete_by_provider'];
                    task.offerNum = doc.data['offer_num'];
                    task.rating = doc.data['rating'];
                    if(task.dateTime.difference(DateTime.now()).inDays > 0){
                      taskList.add(task);
                      eventList[task.dateTime] = [task.title];
                    }
                  }
                  return SizedBox (height : 200,child: MyListView(user: user, tab: 'Published', taskList: taskList,));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class MyListView extends StatefulWidget {
  FirebaseUser user;
  final String tab;
  final List<Task> taskList;
  MyListView({Key key, this.user, this.tab, this.taskList});
  _MyListViewState createState() => _MyListViewState(user, tab, taskList);
}

class _MyListViewState extends State<MyListView> {
  FirebaseUser user;
  final String tab;
  final List<Task> taskList;
  _MyListViewState(this.user, this.tab, this.taskList);

  @override
  Widget build(BuildContext context) {

    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
      itemCount: taskList.length,
      itemBuilder: (context,index){

          return Card(
            child: ListTile(
              onTap: ()async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MySingleTaskView(user: user, task: taskList[index],))
                );
                setState(() {});
              },
              leading:  Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children : <Widget>[
                  Text('${taskList[index].dateTime.difference(DateTime.now()).inDays}',style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold),),
                  Text('Days Left',style: TextStyle(fontSize: 7),),
                ],
              ),
              title: Text('${taskList[index].title}'),
              trailing: Text('${taskList[index].dateTime.toIso8601String().substring(0,10)}',style: TextStyle(fontSize: 12),),
            ),
          );
        }
    );
  }
}
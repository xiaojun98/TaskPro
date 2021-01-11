import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/Task.dart';
import 'package:intl/intl.dart';
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
    FirebaseAnalytics().setCurrentScreen(screenName: "ScheduleScreen");
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
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                      decoration: BoxDecoration(color: Colors.blueGrey[50], borderRadius: BorderRadius.circular(5)),
                      child: Text( 'My Posted Task',style: TextStyle(fontWeight: FontWeight.bold, ),),
                    ),
                  ),
                  SizedBox(width: 10,),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                      decoration: BoxDecoration(color : Colors.blueGrey, borderRadius: BorderRadius.circular(5)),
                      child: Text('Service Offered',style: TextStyle(fontWeight: FontWeight.bold, color : Colors.white),),
                    ),
                  ),
                ],
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection('task')
                  .where('created_by', isEqualTo: Firestore.instance.collection('users').document(user.uid))
                  .where('status', whereIn: ['Open','Ongoing'])
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> myTask) {
                List<Task> taskList = [];
                if(!myTask.hasData) {
                  return Center(child: Text('No task found.', style: TextStyle(color: Colors.grey),),);
                } else {
                  for (DocumentSnapshot doc in myTask.data.documents) {
                    Task task = new Task();
                    task.id = doc.data['id'];
                    task.createdBy = doc.data['created_by'];
                    task.createdAt = doc.data['created_at']?.toDate();
                    task.updatedBy = doc.data['updated_by'];
                    task.updatedAt = doc.data['updated_at']?.toDate();
                    task.author = doc.data['author'];
                    task.category = doc.data['category'];
                    task.title = doc.data['title'];
                    task.description = doc.data['description'];
                    task.additionalInstruction = doc.data['additional_instruction'];
                    task.tags = doc.data['tags'];
                    task.offerDeadline = doc.data['offer_deadline']?.toDate();
                    task.taskDeadline = doc.data['task_deadline']?.toDate();
                    task.location = doc.data['location'];
                    task.fee = double.parse(doc.data['fee'].toString());
                    task.payment = doc.data['payment'];
                    task.status = doc.data['status'];
                    task.offeredBy = doc.data['offered_by'];
                    task.isCompleteByAuthor = doc.data['is_complete_by_author'];
                    task.isCompleteByProvider = doc.data['is_complete_by_provider'];
                    task.offerNum = doc.data['offer_num'];
                    if(task.taskDeadline.difference(DateTime.now()).inMilliseconds > 0){
                      if(task.status!= 'Completed' && task.status!= 'Expired' && task.status!= 'Cancelled'){
                        taskList.add(task);
                      }
                      if(task.offeredBy == null){
                        eventList[task.offerDeadline] = [task.title];
                        task.upcomingDeadline=task.offerDeadline;
                      }
                      else{
                        eventList[task.taskDeadline] = [task.title];
                        task.upcomingDeadline=task.taskDeadline;
                      }
                    }
                  }
                }
                return StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance.collection('offer').where('user_id', isEqualTo: user.uid).snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    List<dynamic> taskIdList = new List();
                    if(!snapshot.hasData) {
                      return Center(child: Text('No task found.', style: TextStyle(color: Colors.grey),),);
                    } else {
                      taskIdList = snapshot.data.documents.map((DocumentSnapshot docSnapshot){
                        return docSnapshot.data['task_id'];
                      }).toList();
                      return StreamBuilder<QuerySnapshot>(
                        stream: Firestore.instance.collection('task').where('id', whereIn: taskIdList).snapshots(),
                        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if(!snapshot.hasData) {
                            return Center(child: Text('No task found.', style: TextStyle(color: Colors.grey),),);
                          }
                          for (DocumentSnapshot doc in snapshot.data.documents) {
                            Task task = new Task();
                            task.id = doc.data['id'];
                            task.createdBy = doc.data['created_by'];
                            task.createdAt = doc.data['created_at']?.toDate();
                            task.updatedBy = doc.data['updated_by'];
                            task.updatedAt = doc.data['updated_at']?.toDate();
                            task.author = doc.data['author'];
                            task.category = doc.data['category'];
                            task.title = doc.data['title'];
                            task.description = doc.data['description'];
                            task.additionalInstruction = doc.data['additional_instruction'];
                            task.tags = doc.data['tags'];
                            task.offerDeadline = doc.data['offer_deadline']?.toDate();
                            task.taskDeadline = doc.data['task_deadline']?.toDate();
                            task.location = doc.data['location'];
                            task.fee = double.parse(doc.data['fee'].toString());
                            task.payment = doc.data['payment'];
                            task.status = doc.data['status'];
                            task.offeredBy = doc.data['offered_by'];
                            task.isCompleteByAuthor = doc.data['is_complete_by_author'];
                            task.isCompleteByProvider = doc.data['is_complete_by_provider'];
                            task.offerNum = doc.data['offer_num'];
                            if(task.offerDeadline.difference(DateTime.now()).inMilliseconds > 0 || task.taskDeadline.difference(DateTime.now()).inMilliseconds > 0){
                              //redundant
                              if(task.status!= 'Completed' && task.status!= 'Expired' && task.status!= 'Cancelled'){
                                taskList.add(task);
                              }
                              if(task.status=='Ongoing'){
                                eventList[task.taskDeadline] = [task.title];
                                task.upcomingDeadline=task.taskDeadline;
                              }
                              else{
                                eventList[task.offerDeadline] = [task.title];
                                task.upcomingDeadline=task.offerDeadline;
                              }
                            }
                          }
                          taskList.sort((a,b) => a.upcomingDeadline.compareTo(b.upcomingDeadline));
                          return SizedBox (height : 400,child: MyListView(user: user, tab: 'Published', taskList: taskList,));
                        },
                      );
                    }
                  },
                );
              }),
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

  TextStyle white1 = TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color : Colors.white);
  TextStyle white2 = TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color : Colors.white);
  TextStyle white3 = TextStyle(fontSize: 7,color : Colors.white);
  TextStyle white4 = TextStyle(color : Colors.white);

  @override
  Widget build(BuildContext context) {

    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
      itemCount: taskList.length,
      itemBuilder: (context,index){
          bool ownTask = taskList[index].createdBy.documentID == user.uid;
          return Card(
            elevation: 1,
            color: (ownTask) ? Colors.blueGrey[50] : Colors.blueGrey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            child: ListTile(
              onTap: ()async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MySingleTaskView(user: user, task: taskList[index],), settings: RouteSettings(name: "TaskDetailView"))
                );
                setState(() {});
              },
              leading:  Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children : <Widget>[
                  Text(
                    DateFormat.MMMM().format(taskList[index].upcomingDeadline).substring(0,3)
                    ,style: (ownTask) ? TextStyle(fontSize: 20,fontWeight: FontWeight.bold) : white1),

                  Text(
                    DateFormat.d().format(taskList[index].upcomingDeadline)
                    ,style: (ownTask) ? TextStyle(fontSize: 15,fontWeight: FontWeight.bold) :white2),
                  Text(taskList[index].upcomingDeadline.difference(DateTime.now()).inDays.toString() + ' Days Left',style: (ownTask) ? TextStyle(fontSize: 7): white3 ,),
                ],
              ),
              title: Text('${taskList[index].title}', style: (ownTask) ? TextStyle() : white4,),
              subtitle: getStatus(taskList[index]),
              // trailing: ,
            ),
          );
        }
    );
  }

  Widget getStatus(Task task){
    final STATUS = [
      {'id': 0, 'text': Text('Waiting Offer',style:TextStyle(fontWeight: FontWeight.bold,fontSize:13,color: Colors.blue[400]),),},
      {'id': 1, 'text': Text('Waiting Response',style:TextStyle(fontWeight: FontWeight.bold,fontSize:13,color: Colors.blue[400]),),},
      {'id': 2, 'text': Text('In Progress',style:TextStyle(fontWeight: FontWeight.bold,fontSize:13,color: Colors.amber[400]),),},
    ];
    if(task.offeredBy != null){

      return Container(
        height: 30,
        alignment: Alignment.centerLeft,
        child: STATUS[2]['text'],
      );

    }
    else {
      if(task.createdBy.documentID == user.uid){
        return Container(
          height: 30,
          alignment: Alignment.centerLeft,
          child: STATUS[0]['text'],
        );

      }
      else{
        return Container(
          height: 30,
          alignment: Alignment.centerLeft,
          child: STATUS[1]['text'],
        );
      }
    }
  }

}
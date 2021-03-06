import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'MySingleTaskView.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/Task.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyTask extends StatefulWidget {
  FirebaseUser user;
  MyTask({this.user});
  _HomeState createState() => _HomeState(user);
}

class _HomeState extends State<MyTask> {
  FirebaseUser user;
  _HomeState(this.user);

  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics().setCurrentScreen(screenName: "MyTaskScreen");
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(title : Text('My Task'),
          centerTitle: true ,
          elevation: 0.0,
          backgroundColor: Colors.amberAccent[400],
          automaticallyImplyLeading: false,
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
            // published tab
            StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection('task')
                  .where('created_by', isEqualTo: Firestore.instance.collection('users').document(user.uid))
                  .where('status', whereIn: ['Open','Ongoing'])
                  .orderBy('created_at', descending: true).snapshots(),
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
                    taskList.add(task);
                  }
                  return TaskListView(user: user, tab: 'Published', taskList: taskList,);
                }
              },
            ),
            // offered tab
            StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection('offer')
                  .where('user_id', isEqualTo: user.uid).snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if(!snapshot.hasData) {
                  return Center(child: Text('No offered task found.', style: TextStyle(color: Colors.grey),),);
                } else {
                  List<dynamic> taskIdList = new List();
                  taskIdList = snapshot.data.documents.map((DocumentSnapshot docSnapshot){
                    return docSnapshot.data['task_id'];
                  }).toList();
                  if(taskIdList.length==0){
                    return Center(child: Text('No offered task found.', style: TextStyle(color: Colors.grey),),);
                  }
                  else{
                    print("LENGTH : " + taskIdList.length.toString());
                    return StreamBuilder<QuerySnapshot>(
                      stream: Firestore.instance.collection('task').
                      where('id', whereIn: taskIdList).snapshots(),
                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if(!snapshot.hasData) {
                          return Center(child: Text('No offered found.', style: TextStyle(color: Colors.grey),),);
                        }
                        List<Task> taskList = [];
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
                          if(task.status!= 'Completed' && task.status!= 'Expired' && task.status!= 'Cancelled'){
                            taskList.add(task);
                          }
                        }
                        return TaskListView(user: user, tab: 'Offered', taskList: taskList,);
                      },
                    );
                  }
                }
              },
            ),
            // bookmark tab
            StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection('bookmark').where('user_id', isEqualTo: user.uid).snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {

                if(!snapshot.hasData) {
                  return Center(child: Text('No bookmark found.', style: TextStyle(color: Colors.grey),),);
                } else {
                  List<dynamic> taskIdList = new List();
                  taskIdList = snapshot.data.documents.map((DocumentSnapshot docSnapshot){
                    return docSnapshot.data['task_id'];
                  }).toList();
                  if(taskIdList.length==0){
                    return Center(child: Text('No bookmark found.', style: TextStyle(color: Colors.grey),),);
                  }
                  else{
                    return StreamBuilder<QuerySnapshot>(
                      stream: Firestore.instance.collection('task').where('id', whereIn: taskIdList).snapshots(),
                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if(!snapshot.hasData) {
                          return Center(child: Text('No bookmark found.', style: TextStyle(color: Colors.grey),),);
                        }
                        List<Task> taskList = [];
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
                          if(task.status == 'Open'){
                            taskList.add(task);
                          }
                        }
                        return TaskListView(user: user, tab: 'Bookmark', taskList: taskList,);
                      },
                    );
                  }
                }
              },
            ),
            // history tab
            StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection('task')
                  //.orderBy('created_at', descending: true)
                  .where('created_by', isEqualTo: Firestore.instance.collection('users').document(user.uid))
                  .where('status', whereIn: ['Completed','Cancelled','Expired']).snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if(!snapshot.hasData) {
                  return Center(child: Text('No task history found.', style: TextStyle(color: Colors.grey),),);
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
                    taskList.add(task);
                  }
                  // return TaskListView(user: user, tab: 'History', taskList: taskList,);
                  return StreamBuilder<QuerySnapshot>(
                    stream: Firestore.instance.collection('offer')
                        .where('user_id', isEqualTo: user.uid).snapshots(),
                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if(!snapshot.hasData) {
                        return Center(child: Text('No history found.', style: TextStyle(color: Colors.grey),),);
                      } else {
                        List<dynamic> taskIdList = new List();
                        taskIdList = snapshot.data.documents.map((DocumentSnapshot docSnapshot){
                          return docSnapshot.data['task_id'];
                        }).toList();
                        if(taskIdList.length==0 && taskList.length>0){
                          return TaskListView(user: user, tab: 'History', taskList: taskList,);
                        }
                        else{
                          return StreamBuilder<QuerySnapshot>(
                            stream: Firestore.instance.collection('task').
                            where('id', whereIn: taskIdList).snapshots(),
                            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                              if(!snapshot.hasData) {
                                return Center(child: Text('No history'
                                    ' found.', style: TextStyle(color: Colors.grey),),);
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
                                if(task.status== 'Completed' || task.status== 'Expired' || task.status== 'Cancelled'){
                                  taskList.add(task);
                                }
                              }
                              return TaskListView(user: user, tab: 'History', taskList: taskList,);
                            },
                          );
                        }
                      }
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class TaskListView extends StatefulWidget {
  FirebaseUser user;
  final String tab;
  final List<Task> taskList;
  TaskListView({Key key, this.user, this.tab, this.taskList});
  _TaskListViewState createState() => _TaskListViewState(user, tab, taskList);
}

class _TaskListViewState extends State<TaskListView> {
  FirebaseUser user;
  final String tab;
  final List<Task> taskList;
  _TaskListViewState(this.user, this.tab, this.taskList);
  final STATUS = [
    {'id': 0, 'text': Text('Waiting Offer',style:TextStyle(fontWeight: FontWeight.bold,fontSize:13,color: Colors.blueAccent),), 'icon': Icon(Icons.check_circle,color: Colors.blueAccent,size: 32,)},
    {'id': 1, 'text': Text('Open',style:TextStyle(fontWeight: FontWeight.bold,fontSize:13,color: Colors.blueAccent),), 'icon': Icon(Icons.check_circle,color: Colors.blueAccent,size: 32,)},
    {'id': 2, 'text': Text('Received offer',style:TextStyle(fontWeight: FontWeight.bold,fontSize:13,color: Colors.amber),), 'icon': Icon(Icons.check_circle,color: Colors.amber,size: 32,)},
    {'id': 3, 'text': Text('Pending',style:TextStyle(fontWeight: FontWeight.bold,fontSize:13,color: Colors.blueAccent),), 'icon': Icon(Icons.swap_horizontal_circle,color: Colors.blueAccent,size: 32,)},
    {'id': 4, 'text': Text('In progress',style:TextStyle(fontWeight: FontWeight.bold,fontSize:13,color: Colors.amber),), 'icon': Icon(Icons.swap_horizontal_circle,color: Colors.amber,size: 32,)},
    {'id': 5, 'text': Text('Completed',style:TextStyle(fontWeight: FontWeight.bold,fontSize:13,color: Colors.greenAccent[700]),), 'icon': Icon(Icons.check_circle,color: Colors.greenAccent[700],)},
    {'id': 6, 'text': Text('Cancelled',style:TextStyle(fontWeight: FontWeight.bold,fontSize:13,color: Colors.red),), 'icon': Icon(Icons.remove_circle,color: Colors.red,)},
    {'id': 7, 'text': Text('Expired',style:TextStyle(fontWeight: FontWeight.bold,fontSize:13,color: Colors.red),), 'icon': Icon(Icons.timer_off,color: Colors.red,)},
    {'id': 8, 'text': Text('Overdue',style:TextStyle(fontWeight: FontWeight.bold,fontSize:13,color: Colors.red),), 'icon': Icon(Icons.timer_off,color: Colors.red,)},
  ];

  @override
  Widget build(BuildContext context) {
    String statusIdCond;
    int statusId1, statusId2;
    switch(tab) {
      case 'Published':
        statusIdCond = 'Open';
        statusId1 = 0;
        statusId2 = 4;
        break;
      case 'Offered':
        statusIdCond = 'Open';
        statusId1 = 3;
        statusId2 = 4;
        break;
      case 'Bookmark':
        statusIdCond = 'Open';
        statusId1 = 1;
        statusId2 = 4;
        break;
      case 'History':
        break;
    }

    if(tab!='History'){
      return ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
          itemExtent: 100.0,
          itemCount: taskList.length,
          itemBuilder: (context,index){
            int statusId = taskList[index].status == statusIdCond ? statusId1 : statusId2;
            return Card(
              child: ListTile(
                onTap: () async {
                  await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MySingleTaskView(user: user, task: taskList[index],), settings: RouteSettings(name: "TaskDetailView"))
                  );
                },
                isThreeLine: true,
                leading: Container(
                  width: 66,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      tab != 'Bookmark' ? STATUS[statusId]['icon'] : Icon(Icons.bookmark),
                      SizedBox(height: 5,),
                      STATUS[statusId]['text'],
                    ],
                  ),
                ),
                title: Container(
                  padding: EdgeInsets.symmetric(vertical: 5,),
                  child: Text(taskList[index].title, style: TextStyle(fontWeight: FontWeight.bold), maxLines: 1,  overflow: TextOverflow.ellipsis,),
                ),
                subtitle: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [

                    (statusId == 0 || statusId == 1 || statusId == 2 || statusId == 3 ) ? Row(
                      children: [
                        Icon(Icons.date_range, color: Colors.grey, size: 16,),
                        SizedBox(width: 5,),
                        Text(taskList[index].offerDeadline!=null ? DateFormat('yyyy-MM-dd  h:mm a').format(taskList[index].offerDeadline).toString(): '-',),
                      ],
                    ) : Container(),

                    (statusId == 4) ? Row(
                      children: [
                        Icon(Icons.date_range, color: Colors.grey, size: 16,),
                        SizedBox(width: 5,),
                        Text(taskList[index].taskDeadline!=null ? DateFormat('yyyy-MM-dd  h:mm a').format(taskList[index].taskDeadline).toString(): '-',),
                      ],
                    ) : Container(),

                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.grey, size: 16,),
                        SizedBox(width: 5,),
                        SizedBox(
                          width: 135,
                            child: Text((taskList[index].location!=null && taskList[index].location!='') ? taskList[index].location : '-',overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.attach_money, color: Colors.grey, size: 16,),
                        SizedBox(width: 5,),
                        Text(taskList[index].fee!=null ? 'RM'+taskList[index].fee.toStringAsFixed(2) : '-',),
                      ],
                    ),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 45,
                      child:
                      statusId==statusId1 ?
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(taskList[index].offerNum.toString(),style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                          SizedBox(width: 2,),
                          Icon(Icons.people_outline, size: 18, color: Colors.black,),
                        ],
                      ): Container(
                        alignment: Alignment.centerRight,
                        child: Stack(
                          children: <Widget>[
                            Padding(padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12)),
                            new Icon(Icons.person_outline, size: 20.0, color: Colors.amber),
                            new Positioned(
                              left: 11,
                              top: 11,
                              child: new Icon(Icons.check_circle, size: 13.0, color:Colors.amber),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
      );
    }
    return ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
        itemCount: taskList.length,
        itemBuilder: (context,index){
          int statusId = 0;
          switch(taskList[index].status) {
            case 'Completed':
              statusId = 5;
              break;
            case 'Cancelled':
              statusId = 6;
              break;
            case 'Expired':
              statusId = 7;
              break;
            case 'Overdue':
              statusId = 7;
              break;
          }
          return Card(
            child: ListTile(
              onTap: ()  {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MySingleTaskView(user: user, task: taskList[index],), settings: RouteSettings(name: "TaskDetailView"))
                );
              },
              leading: STATUS[statusId]['icon'],
              title: Text(taskList[index].title, maxLines: 1,  overflow: TextOverflow.ellipsis,),
              trailing: STATUS[statusId]['text'],
            ),
          );
        }
    );
  }
}
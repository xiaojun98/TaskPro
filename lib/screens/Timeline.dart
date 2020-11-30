import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'Inbox.dart';
import 'MySingleTaskView.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/Task.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';


class Timeline extends StatefulWidget {
  FirebaseUser user;
  Timeline({this.user});
  _HomeState createState() => _HomeState(user);
}

class _HomeState extends State<Timeline> {
  FirebaseUser user;
  _HomeState(this.user);
  @override
  Icon searchCon = Icon(Icons.search);
  Widget title = Text('Timeline');

  String dropdownValue = 'Order by';
  bool searching = false;
  String searchTerm = '';

  RefreshController _refreshController = RefreshController(initialRefresh: false);

  void _onRefresh() async{
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async{
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    if(mounted)
      setState(() {

      });
    _refreshController.loadComplete();
  }

  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title : title,
        leading: IconButton(icon : Icon(Icons.inbox), onPressed: (){
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Inbox(user : user)));
        },),
        elevation: 0.0,
        backgroundColor: Colors.amberAccent[400],
        actions: <Widget>[
          IconButton(
            icon : searchCon,
            onPressed: (){
              setState(() {
                if(this.searchCon.icon == Icons.search){
                  setState(() {
                    searching = true;
                  });
                  this.searchCon = Icon(Icons.cancel);
                  this.title = Container(
                    height: 40,
                    child: TextField(
                      decoration: InputDecoration(hintText: "Search ... ",),
                      textInputAction: TextInputAction.go,

                      style: TextStyle(color: Colors.black, fontSize: 18),
                      cursorColor: Colors.grey,
                      onChanged:(keyword) {
                        setState(() {
                        searchTerm = keyword;});
                        },
                    ),
                  );
                }
                else {
                  setState(() {
                    searching = false;
                    searchTerm = '';
                  });
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
              padding: EdgeInsets.symmetric(horizontal: 20,),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text('Tasks Feed', style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,fontFamily: 'OpenSans'),),
                  DropdownButton<String>(
                    value: dropdownValue,
                    icon : Icon(Icons.filter_list),
                    onChanged: (String newValue) {
                      setState(() {
                        dropdownValue = newValue;
                      });
                    },
                    items: <String>['Order by','Date', 'Commission', 'Title'].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection('task')
                  .where('status', isEqualTo: 'Open').snapshots(),
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
                    task.rating = doc.data['rating'];
                    if(task.status=='Ongoing'){
                      task.upcomingDeadline=task.taskDeadline;
                    }
                    else{
                      task.upcomingDeadline=task.offerDeadline;
                    }
                    if(task.createdBy.documentID != user.uid) {
                      if(searching) {
                        if(task.title.contains(searchTerm)||task.description.contains(searchTerm)||task.category.contains(searchTerm)||(task.tags!=null && task.tags.contains(searchTerm)))
                          taskList.add(task);
                        else{
                          String capTerm = searchTerm.substring(0,1).toUpperCase() + searchTerm.substring(1);
                          if(task.title.contains(capTerm)||task.description.contains(capTerm)||task.category.contains(capTerm)||(task.tags!=null && task.tags.contains(capTerm)))
                            taskList.add(task);
                          else{
                            String decapTerm = searchTerm.substring(0,1) + searchTerm.substring(1).toLowerCase();
                            if(task.title.contains(decapTerm)||task.description.contains(decapTerm)||task.category.contains(decapTerm)||(task.tags!=null && task.tags.contains(decapTerm)))
                              taskList.add(task);
                          }
                        }
                       } else {
                        taskList.add(task);
                      }
                    }
                  }
                  if (dropdownValue != 'Order By'){
                    if (dropdownValue == 'Date'){
                      taskList.sort((a,b) => a.upcomingDeadline.compareTo(b.upcomingDeadline));
                    }
                    else if (dropdownValue == 'Commission'){
                      taskList.sort((a,b) => a.fee.compareTo(b.fee));
                    }
                    else if(dropdownValue == 'Title'){
                      taskList.sort((a,b) => a.title.compareTo(b.title));
                    }
                  }
                  return Container(
                      height: 560,
                      child: SmartRefresher(
                        enablePullDown: true,
                        enablePullUp: true,
                        header: WaterDropHeader(),
                        footer: CustomFooter(
                          loadStyle: LoadStyle.HideAlways,
                          builder: (BuildContext context, LoadStatus mode){
                            Widget body ;
                            if(mode==LoadStatus.idle){
                              body =  Text("pull up load");
                            }
                            else if(mode==LoadStatus.loading){
                            body =  CupertinoActivityIndicator();
                            }
                            else if(mode == LoadStatus.failed){
                            body = Text("Load Failed!Click retry!");
                            }
                            else if(mode == LoadStatus.canLoading){
                            body = Text("Release to load more");
                            }
                            else{
                            body = Text("No more Data");
                            }
                          return Container(
                            height: 55.0,
                            child: Center(child:body),
                            );},
                        ),
                        controller: _refreshController,
                        onRefresh: _onRefresh,
                        onLoading: _onLoading,
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                          itemCount: taskList.length,
                          itemBuilder: (context,index){
                            return StreamBuilder<DocumentSnapshot>(
                              stream: Firestore.instance.collection('profile').document(taskList[index].createdBy.documentID).snapshots(),
                              builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                                String username, profilePic;
                                if (snapshot.hasData && snapshot.data.exists) {
                                  username = snapshot.data.data['name'];
                                  profilePic = snapshot.data.data['profile_pic'];
                                }
                                return Container(
                                  width: 390,
                                  height: 180,
                                  child: Card(
                                      elevation: 5,
                                      child : ListTile(
                                        onTap: () async {
                                          await Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => MySingleTaskView(user: user, task: taskList[index],))
                                          );
                                          setState(() {});
                                        },
                                        leading : Column(
                                          children: <Widget>[
                                            CircleAvatar (
                                              backgroundColor: Colors.white,
                                              radius: 25,
                                              child: ClipOval(
                                                child: new SizedBox(
                                                  width: 50.0,
                                                  height: 50.0,
                                                  child: (profilePic!=null && profilePic!='') ? Image.network(
                                                    profilePic,
                                                    fit: BoxFit.cover,
                                                  ) : Image.asset(
                                                    "assets/profile-icon.png",
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],),
                                        subtitle : Container(
                                          margin: EdgeInsets.symmetric(vertical: 10),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: <Widget>[
                                              Text((username!=null && username!='') ? username : 'User Name',style: TextStyle(color : Colors.lightBlue[900]),),
                                              Divider(color: Colors.blueGrey, thickness: 1.0,),
                                              Text(taskList[index].title,style: TextStyle(fontSize: 16,color: Colors.black),),
                                              Container(height: 48, child: Text(taskList[index].description, maxLines: 3, overflow: TextOverflow.ellipsis,),),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: <Widget>[
                                                  Text (taskList[index].fee!=null ? 'RM'+taskList[index].fee.toStringAsFixed(2):'-'),
                                                  StreamBuilder<QuerySnapshot>(
                                                    stream: Firestore.instance.collection('bookmark')
                                                        .where('user_id', isEqualTo: user.uid)
                                                        .where('task_id',isEqualTo: taskList[index].id).snapshots(),
                                                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                                      bool bookmarkAdded = false;
                                                      if(snapshot.hasData){
                                                        bookmarkAdded = snapshot.data.documents.length != 0;
                                                      }
                                                      return IconButton(
                                                        icon: bookmarkAdded ? Icon(Icons.bookmark, color: Colors.amber,) : Icon(Icons.bookmark_border, color: Colors.grey,),
                                                        onPressed: bookmarkAdded? (){
                                                          String bookmarkId;
                                                          for (DocumentSnapshot doc in snapshot.data.documents) {
                                                            bookmarkId = doc.documentID;
                                                          }
                                                          Firestore.instance.collection('bookmark').document(bookmarkId).delete();
                                                        } : (){
                                                          Firestore.instance.collection('bookmark').document().setData({
                                                            'user_id': user.uid,
                                                            'task_id': taskList[index].id,
                                                          });
                                                        },
                                                      );
                                                    },
                                                  ),
                                                  StreamBuilder<QuerySnapshot>(
                                                    stream: Firestore.instance.collection('offer')
                                                        .where('user_id', isEqualTo: user.uid)
                                                        .where('task_id',isEqualTo: taskList[index].id).snapshots(),
                                                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                                      bool offerSent = false;
                                                      if(snapshot.hasData){
                                                        offerSent = snapshot.data.documents.length != 0;
                                                      }
                                                      return !offerSent ? IconButton(
                                                        icon: Icon(Icons.send),
                                                        onPressed: (){
                                                          Firestore.instance.collection('offer').document().setData({
                                                            'user_id': user.uid,
                                                            'task_id': taskList[index].id,
                                                          });
                                                          Firestore.instance.collection('task').document(taskList[index].id).updateData({'offer_num': FieldValue.increment(1)});
                                                        },
                                                        color: Colors.amber,
                                                      ) : Text('Offer Sent', style: TextStyle(color: Colors.amber, fontSize: 12),);
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                  ),
                                );
                              });
                          }
                    ),
                      ),
                  );
                }
              },
            ),
          ]
        ),
      ),
    );
  }
}
class Tags{
  String tagName;
  int tagCount;
  Tags(String tagName, int tagCount){
    this.tagName=tagName;
    this.tagCount=tagCount;

  }

}
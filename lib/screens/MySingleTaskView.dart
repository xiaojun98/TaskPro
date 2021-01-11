import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:testapp/screens/CreateTask.dart';
import '../models/Task.dart';
import '../models/Profile.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ViewProfile.dart';
import 'CreateReport.dart';
import 'package:testapp/services/stripeService.dart';
import 'package:testapp/models/Review.dart';
import 'WriteReview.dart';

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

  void initState(){
    super.initState();
    StripeService.init();
  }

  Widget build(BuildContext context) {
    List<String> tagList = [];
    ownTask = task.createdBy.documentID == user.uid;
    if(task.tags!=null && task.tags.length>0)
      tagList = task.tags.split(',').map((tag) => tag.trim()).toList();
    tagList.insert(0, task.category);
    return Scaffold(
      appBar: AppBar(
        title : Text('Task Details'),
        centerTitle: true ,
        elevation: 0.0,
        backgroundColor: Colors.amberAccent[400],
        actions: (ownTask && (task.status=='Open' || task.status=='Ongoing')) ? <Widget>[
          PopupMenuButton(
            onSelected: (result) async {
              if(result == 0) {
                await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CreateTask(user: user, task: task,))
                );
                setState(() {});
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
                            if(task.offeredBy == null){
                              Firestore.instance.collection('task').document(task.id).updateData({
                                'updated_by': Firestore.instance.document('users/'+user.uid),
                                'updated_at': DateTime.now(),
                                'status': 'Cancelled',
                              });
                              Navigator.of(context).pop(true);
                            }
                            else{
                              Navigator.of(context).pop(true);
                              showDialog(
                                  context: context,
                                  barrierDismissible: true,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text('Error Cancel Task'),
                                      content: Text('You cannot cancel a task which accepted an offer. To proceed for refund, please make a Report under Category [Refund].'),
                                    );
                                  });
                            }},
                          textColor: Theme.of(context).primaryColor,
                          child: const Text('Yes, Cancel'),
                        ),
                      ],
                    );
                  },
                ).then((value) => Navigator.pop(context));
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
        ] : [ IconButton(
                icon : Icon(Icons.report_gmailerrorred_outlined),
                onPressed: () => showDialog<bool>(
                  context: context,
                  builder: (c) => AlertDialog(
                    title: Text('Alert'),
                    content: Text('Report this task?'),
                    actions: [
                      FlatButton(
                          child: Text('Yes'),
                          onPressed: () {
                            Navigator.pop(c,true);
                            Navigator.push(context, MaterialPageRoute(builder: (context) => CreateReport(user: user, category: 'Task Related Issues', taskId: task.id, profileId: null,)));
                          }
                      ),
                      FlatButton(
                        child: Text('No'),
                        onPressed: () => Navigator.pop(c, false),
                      ),
                    ],
                  ),
                )
            )
          ],
      ),
      body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    StreamBuilder<DocumentSnapshot>(
                      stream: Firestore.instance.collection('profile').document(task.createdBy.documentID).snapshots(),
                      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                        String username, profilePic ;
                        Profile profile;
                        if (snapshot.hasData && snapshot.data.exists) {
                          username = snapshot.data.data['name'];
                          profilePic = snapshot.data.data['profile_pic'];
                          profile = new Profile.AsyncDs(snapshot);
                        }
                        return InkWell(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(
                                builder: (context) => ViewProfile(user : user , profile : profile)));
                          },
                          child: Row(
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.fromLTRB(0,0,20,0),
                                child: CircleAvatar (
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
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text((username!=null && username!='') ? username : 'User Name',style: TextStyle(color : Colors.lightBlue[900], fontWeight: FontWeight.bold, fontSize: 16),),
                                  Text(DateFormat('yyyy-MM-dd  h:mm a').format(task.createdAt).toString(),style: TextStyle(color : Colors.lightBlue[900]),),
                                ],
                              ),
                            ],
                          ),
                        );
                      }
                    ),
                    ownTask ? Container() : StreamBuilder<QuerySnapshot>(
                      stream: Firestore.instance.collection('bookmark')
                          .where('user_id', isEqualTo: user.uid)
                          .where('task_id',isEqualTo: task.id).snapshots(),
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
                              'task_id': task.id,
                            });
                          },
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 230,
                      child: Text(task.title, style: TextStyle(fontFamily: 'OpenSans-R', fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 4),
                      decoration: BoxDecoration(border: Border.all(color: Colors.amber), borderRadius: BorderRadius.circular(5)),
                      child: Text(task.status,style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),),
                    ),
                  ],
                ),
                SizedBox(height: 5,),
                Row(
                    children: [
                      Text('ID: '+task.id,style: TextStyle(fontFamily: 'OpenSans-R', fontSize: 12, color: Colors.grey)),
                      IconButton(
                        icon: Icon(Icons.copy,color: Colors.grey,size: 12,),
                        onPressed: (){
                          Clipboard.setData(ClipboardData(text: task.id));
                          Fluttertoast.showToast(
                              msg: "Task ID Copied",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.black54,
                              textColor: Colors.white,
                              fontSize: 16.0
                          );
                        }
                      ),
                    ]
                ),
                SizedBox(height: 20,),
                Container(
                  decoration: BoxDecoration(border: Border.all(color: Colors.blueGrey), borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(9), topRight: Radius.circular(9)), color: Colors.blueGrey,),
                        height: 25,
                        child: Center(child: Text('Task Description',style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        child: Text(task.description,style: _style,),
                      ),
                      SizedBox(height: 10,),
                      Container(
                        height: 25,
                        color: Colors.blueGrey,
                        child: Center(child: Text('Additional Instruction',style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        child: Text((task.additionalInstruction!=null && task.additionalInstruction!='') ? task.additionalInstruction : '-',style: _style,),
                      ),
                      SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              height: 80,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 25,
                                    color: Colors.blueGrey,
                                    child: Center(child: Text('Accepting Offers Until : ',style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),),
                                  ),
                                  Container(
                                    height: 55,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(DateFormat('yyyy-MM-dd').format(task.offerDeadline).toString(),style: _style,),
                                        Text(DateFormat('h:mm a').format(task.offerDeadline).toString(),style: _style,),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(color: Colors.blueGrey, width: 1, height: 80,),
                          Expanded(
                            child: Container(
                              height: 80,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 25,
                                    color: Colors.blueGrey,
                                    child: Center(child: Text('Task Deadline : ',style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),),
                                  ),
                                  Container(
                                    height: 55,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(DateFormat('yyyy-MM-dd').format(task.taskDeadline).toString(),style: _style,),
                                        Text(DateFormat('h:mm a').format(task.taskDeadline).toString(),style: _style,),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              height: 80,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 25,
                                    color: Colors.blueGrey,
                                    child: Center(child: Text('Location',style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),),
                                  ),
                                  Container(
                                    height: 55,
                                    child: Center(child: Text((task.location!=null && task.location!='') ? task.location : '-',style: _style,),),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(color: Colors.blueGrey, width: 1, height: 80,),
                          //Container(height: 50, child: VerticalDivider(color: Colors.amber, thickness: 1,),),
                          Expanded(
                            child: Container(
                              height: 80,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 25,
                                    color: Colors.blueGrey,
                                    child: Center(child: Text('Fee',style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),),
                                  ),
                                  Container(
                                    height: 55,
                                    child: Center(child: Text('RM'+task.fee.toStringAsFixed(2),style: _style,),),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    ]
                  ),
                ),
                SizedBox(height: 20,),
                Text('Tags :',style: TextStyle(fontFamily: 'OpenSans-R', fontSize: 12, color: Colors.grey)),
                SizedBox(height: 10,),
                Container(height: 26, child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: tagList.length,
                  itemBuilder: (context,index){
                    return Container(
                      margin: EdgeInsets.only(right: 10),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(color: Colors.blueGrey, borderRadius: BorderRadius.circular(5)),
                      child: Text(tagList[index], style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                    );
                  },
                ),),

                task.offeredBy== null ? Container() :
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20,),
                        Text('Service Provider :',style: TextStyle(fontFamily: 'OpenSans-R', fontSize: 12, color: Colors.grey)),
                        SizedBox(height: 10,),
                        StreamBuilder<DocumentSnapshot>(
                            stream: Firestore.instance.collection('profile').document(task.offeredBy.documentID).snapshots(),
                            builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                              String username;
                              Profile profile;
                              if (snapshot.hasData && snapshot.data.exists) {
                                print(username);
                                username = snapshot.data.data['name'];
                                profile = new Profile.AsyncDs(snapshot);
                              }
                              return InkWell(
                                onTap: (){
                                  if(profile!=null){
                                    Navigator.push(context, MaterialPageRoute(
                                        builder: (context) => ViewProfile(user : user , profile : profile)));
                                  }
                                },
                                child: Text((username!=null && username!='') ? username : 'User does not exist.',style: TextStyle(color : Colors.blueGrey, fontWeight: FontWeight.bold, fontSize: 16),),
                              );
                            }
                        ),
                      ],
                    ),

                SizedBox(height: 30,),
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
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return StreamBuilder<QuerySnapshot>(
                        stream: Firestore.instance.collection('offer')
                            .where('task_id', isEqualTo: task.id).snapshots(),
                        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (!snapshot.hasData) {
                            return SimpleDialog(
                                backgroundColor: Colors.white,
                                children: <Widget>[
                                  Center(
                                    child: Column(children: [
                                      CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.amber[800]),),
                                    ]),
                                  )
                                ]);
                          } else {
                            if(snapshot.data.documents.length == 0) {
                              return SimpleDialog(
                                children: [
                                  Center(child: Text('No offer received yet.'),),
                                ],
                              );
                            }
                            List<String> offerUsers = [];
                            for (DocumentSnapshot doc in snapshot.data.documents) {
                              offerUsers.add(doc.data['user_id']);
                            }
                            return StreamBuilder<QuerySnapshot>(
                              stream: Firestore.instance.collection('profile')
                                  .where('id', whereIn: offerUsers).snapshots(),
                              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (!snapshot.hasData) {
                                  return SimpleDialog(
                                      backgroundColor: Colors.white,
                                      children: <Widget>[
                                        Center(
                                          child: Column(children: [
                                            CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.amber[800]),),
                                          ]),
                                        )
                                      ]);
                                } else {
                                  if(snapshot.data.documents.length == 0) {
                                    return SimpleDialog(
                                      children: [
                                        Center(child: Text('No offer received yet.'),),
                                      ],
                                    );
                                  }
                                  List<Profile> offerProfiles = [];
                                  for (DocumentSnapshot doc in snapshot.data
                                      .documents) {
                                    Profile profile = new Profile.empty();
                                    profile.id = doc.data["id"];
                                    profile.name = doc.data["name"];
                                    profile.email = doc.data["email"];
                                    profile.about = doc.data["about"];
                                    profile.achievement = doc.data["achievement"];
                                    profile.services = doc.data["services"];
                                    profile.profilepic = doc.data["profile_pic"];
                                    Timestamp j = doc.data["joined"];
                                    profile.joined = j.toDate().toString().substring(0, 10);
                                    profile.posted = doc.data["task_posted"];
                                    profile.completed = doc.data["task_completed"];
                                    profile.reviewNum = doc.data["review_num"];
                                    profile.rating = double.parse(doc.data["rating"].toString());
                                    profile.gallery = doc.data["gallery"];
                                    offerProfiles.add(profile);
                                  }
                                  return SimpleDialog(
                                    title: const Text('Offer(s) Received:'),
                                    children: [
                                      Container(
                                        height: 160,
                                        width: 300,
                                        padding: EdgeInsets.symmetric(horizontal: 15),
                                        child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: offerProfiles.length,
                                            itemBuilder: (context, index) {
                                              return Container(
                                                padding: EdgeInsets.all(10),
                                                child: Column(
                                                    children: [
                                                      GestureDetector(
                                                        onTap: (){
                                                          Navigator.push(context, MaterialPageRoute(builder: (context) => ViewProfile(user : user, profile : offerProfiles[index])));
                                                        },
                                                        child: CircleAvatar(
                                                          backgroundImage: (offerProfiles[index]
                                                              .profilepic != '')
                                                              ? NetworkImage(
                                                              offerProfiles[index]
                                                                  .profilepic)
                                                              : AssetImage(
                                                              "assets/profile-icon.png"),
                                                          radius: 30,
                                                        ),
                                                      ),
                                                      SizedBox(height: 5,),
                                                      Text(offerProfiles[index].name, textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
                                                      ButtonTheme(
                                                        height: 25,
                                                        child: FlatButton(
                                                          onPressed: (){
                                                            showDialog(
                                                                context: context,
                                                                child: AlertDialog(
                                                                  title: const Text('Confirm accept?'),
                                                                  content: new Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: <Widget>[
                                                                      Text('You will be redirected to transaction site to proceed.'),
                                                                    ],
                                                                  ),
                                                                  actions: <Widget>[
                                                                    FlatButton(
                                                                      onPressed: () {
                                                                        Navigator.of(context).pop();
                                                                      },
                                                                      textColor: Colors.grey,
                                                                      child: const Text('Cancel'),
                                                                    ),
                                                                    FlatButton(
                                                                      onPressed: () async {
                                                                        ProgressDialog dialog = new ProgressDialog(context);
                                                                        dialog.style(
                                                                            message: 'Please wait...'
                                                                        );
                                                                        await dialog.show();
                                                                        var response = await StripeService.payWithNewCard(
                                                                            amount: (task.fee * 100).toInt().toString(),
                                                                            currency: 'myr'
                                                                        );

                                                                        if (response.success){
                                                                          Firestore.instance.collection('wallet').document(user.uid).collection('credit').add({
                                                                            'amount' : task.fee,
                                                                            'createdAt' : DateTime.now(),
                                                                            'status' : 'Hold',
                                                                            'taskRef' : Firestore.instance.document('task/'+ task.id),
                                                                            'creditTarget' : Firestore.instance.document('users/'+offerProfiles[index].id),
                                                                          }).then((value) => {
                                                                            Firestore.instance.collection('task').document(task.id).updateData({
                                                                            'offered_by': Firestore.instance.document('users/'+offerProfiles[index].id),
                                                                            'status': 'Ongoing',
                                                                            'updated_by': Firestore.instance.document('users/'+user.uid),
                                                                            'updated_at': DateTime.now(),
                                                                            'payment' : Firestore.instance.document('wallet/' + user.uid+ '/credit/' + value.documentID),
                                                                            'creditId' : value.documentID,
                                                                            })
                                                                          });
                                                                        }

                                                                        await dialog.hide().then((value) {
                                                                          Navigator.pop(context);
                                                                          Navigator.pop(context);
                                                                          String msg = response.message;
                                                                          showDialog(
                                                                              context: context,
                                                                              barrierDismissible: true,
                                                                              builder: (context) {
                                                                                return AlertDialog(
                                                                                  title: Text('Error Payment'),
                                                                                  content: Text('$msg Please check your card balance and try again.'),
                                                                                );
                                                                              });
                                                                        });
                                                                      },
                                                                      textColor: Theme.of(context).primaryColor,
                                                                      child: const Text('Yes, Accept'),
                                                                    ),
                                                                  ],
                                                                ),
                                                            );
                                                          },
                                                          child: Text ('Accept',style: TextStyle(fontSize: 14,color: Colors.black,fontFamily: 'OpenSansR'),),
                                                          shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                                                          color: Colors.amber,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                              );
                                            }
                                        ),
                                      ),
                                    ],
                                  );
                                }
                              }
                            );
                          }
                        }
                    );
                  }
              );
            },
            child: Text ('View Offer',
              style: TextStyle(fontSize: 16,color: Colors.black,fontFamily: 'OpenSansR'),),
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.amber[100],
          ),
        ],
      );
    } else if(task.status=='Ongoing') {
      return Column(
        children: [
          task.isCompleteByProvider ? Column(
            children: [
              SizedBox(height: 20,),
              Text('Service provider has marked complete.'),
              SizedBox(height: 10,),
            ],
          ): Container(),
          task.isCompleteByAuthor ? Column(
            children: [
              SizedBox(height: 20,),
              Text('You have marked complete.'),
              SizedBox(height: 10,),
            ],
          ): Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FlatButton(
                onPressed: (){
                  Firestore.instance.collection('task').document(task.id).updateData({
                    'is_complete_by_author': true,
                    'status': task.isCompleteByProvider ? 'Completed' : 'Ongoing',
                  }).then((value) {
                    checkTaskCompleted(task.id);
                  });
                  Navigator.pop(context);
                },
                child: Text ('Mark Complete',
                  style: TextStyle(fontSize: 16,color: Colors.black,fontFamily: 'OpenSansR'),),
                shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                color: Colors.amber,
              ),
            ],
          ),
        ],
      );
    }
    //service consumer write review
    else if (task.status== 'Completed' || task.status== 'Expired' || task.status== 'Cancelled'){
      bool reviewed = checkReviewed(Firestore.instance.collection('task').document(task.id), Firestore.instance.collection('users').document(user.uid)) as bool;
      if(task.offeredBy== null){
        return Text("The task is " + task.status.toString());
      }
      else if(reviewed){
        return Text("You have wrote a review.");
      }
      else if (!reviewed){
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("The task is " + task.status.toString()),
            SizedBox(height: 10,),
            FlatButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => WriteReview(user: user, ownTask : ownTask, task: task,)));
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Write Review',  textAlign: TextAlign.center, style: TextStyle(fontSize: 16,
                      color: Colors.black,
                      fontFamily: 'OpenSansR'),),
                ],
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0)),
              color: Colors.amber,
            ),
          ],
        );
      }
    }
    return Container();
  } else {
    if(task.status=='Open') {
      return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('offer')
            .where('user_id', isEqualTo: user.uid)
            .where('task_id', isEqualTo: task.id).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          bool offerSent = false;
          if (snapshot.hasData) {
            offerSent = snapshot.data.documents.length != 0;
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              offerSent ?
              OutlineButton(
                onPressed: () {
                  String offerId;
                  for (DocumentSnapshot doc in snapshot.data.documents) {
                    offerId = doc.documentID;
                  }
                  Firestore.instance.collection('offer')
                      .document(offerId)
                      .delete();
                  Firestore.instance.collection('task')
                      .document(task.id)
                      .updateData({'offer_num': FieldValue.increment(-1)});
                },
                child: Text('Cancel Offer', style: TextStyle(fontSize: 16,
                    color: Colors.amber,
                    fontFamily: 'OpenSansR'),),
                shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0)),
                borderSide: BorderSide(color: Colors.amber),
              ) :
              FlatButton(
                onPressed: () {
                  Firestore.instance.collection('offer').document().setData({
                    'user_id': user.uid,
                    'task_id': task.id,
                  });
                  Firestore.instance.collection('task')
                      .document(task.id)
                      .updateData({'offer_num': FieldValue.increment(1)});
                },
                child: Row(
                  children: [
                    Text('Send Offer', style: TextStyle(fontSize: 16,
                        color: Colors.black,
                        fontFamily: 'OpenSansR'),),
                    SizedBox(width: 10,),
                    Icon(Icons.send),
                  ],
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0)),
                color: Colors.amber,
              ),
            ],
          );
        },
      );
    } else if(task.status=='Ongoing') {
      return
      Column(
        children: [
          task.isCompleteByProvider ? Column(
            children: [
              SizedBox(height: 20,),
              Text('You has marked complete.'),
              SizedBox(height: 10,),
            ],
          ): Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FlatButton(
                onPressed: () {
                  Firestore.instance.collection('task').document(task.id).updateData({
                    'is_complete_by_provider': true,
                    'status': task.isCompleteByAuthor ? 'Completed' : 'Ongoing',
                  }).then((value) {
                    checkTaskCompleted(task.id);
                    Navigator.pop(context);
                  });
                },
                child: Row(
                  children: [
                    Text('Mark Complete', style: TextStyle(fontSize: 16,
                        color: Colors.black,
                        fontFamily: 'OpenSansR'),),
                  ],
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0)),
                color: Colors.amber,
              ),
            ],
          ),
          task.isCompleteByAuthor ? Column(
            children: [
              SizedBox(height: 20,),
              Text('Author has marked complete.'),
              SizedBox(height: 10,),
            ],
          ): Container(),
        ],
      );
    }
    //service provider write review
    else if (task.status== 'Completed' || task.status== 'Expired' || task.status== 'Cancelled'){
      bool reviewed = checkReviewed(Firestore.instance.collection('task').document(task.id), task.offeredBy) as bool;
      if(reviewed){
        return Text("You have wrote a review.");
      }
      if(!reviewed){
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("The task is " + task.status.toString()),
            SizedBox(height: 10,),
            FlatButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => WriteReview(user: user, ownTask : ownTask, task: task,)));
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Write Review', textAlign: TextAlign.center, style: TextStyle(fontSize: 16,
                    color: Colors.black,
                    fontFamily: 'OpenSansR',
                  ),),
                ],
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0)),
              color: Colors.amber,
            ),
          ],
        );
      }
    }
    return Container();
  }
}

checkTaskCompleted(String taskId) async {
  Task checkTask = new Task();
  Firestore.instance.collection("task").document(taskId).get().then((doc) {
    checkTask.id = doc.data['id'];
    checkTask.createdBy = doc.data['created_by'];
    checkTask.createdAt = doc.data['created_at']?.toDate();
    checkTask.updatedBy = doc.data['updated_by'];
    checkTask.updatedAt = doc.data['updated_at']?.toDate();
    checkTask.author = doc.data['author'];
    checkTask.category = doc.data['category'];
    checkTask.title = doc.data['title'];
    checkTask.description = doc.data['description'];
    checkTask.additionalInstruction = doc.data['additional_instruction'];
    checkTask.tags = doc.data['tags'];
    checkTask.offerDeadline = doc.data['offer_deadline']?.toDate();
    checkTask.taskDeadline = doc.data['task_deadline']?.toDate();
    checkTask.location = doc.data['location'];
    checkTask.fee = double.parse(doc.data['fee'].toString());
    checkTask.payment = doc.data['payment'];
    checkTask.status = doc.data['status'];
    checkTask.offeredBy = doc.data['offered_by'];
    checkTask.isCompleteByAuthor = doc.data['is_complete_by_author'];
    checkTask.isCompleteByProvider = doc.data['is_complete_by_provider'];
    checkTask.offerNum = doc.data['offer_num'];
    checkTask.creditId = doc.data['creditId'];
    if (checkTask.isCompleteByAuthor && checkTask.isCompleteByProvider){
      Firestore.instance.collection('wallet').document(checkTask.offeredBy.documentID).collection("debit").add({
        'amount' : checkTask.fee,
        'category' : 'Debit',
        'createdAt' : DateTime.now(),
        'payout' : false,
        'status' : 'Success',
        'taskRef' : '/task/$taskId',
      }).then((value) {
        Firestore.instance.collection('task').document(taskId).updateData({
          'debitId' : value.documentID,
        });
      }).then((value) {
        int task_completed;
        Firestore.instance.collection('profile').document(checkTask.offeredBy.documentID).get().then((profile) {
          task_completed = profile.data['task_completed'];
        });
        DocumentReference ref = Firestore.instance.collection('profile').document(checkTask.offeredBy.documentID);
        ref.updateData({
          'task_completed' : task_completed += 1,
        });
      });
    }
  }).then((value) {
    Firestore.instance.collection('wallet').document(checkTask.createdBy.documentID).collection('credit').document(checkTask.creditId).updateData({
        'status' : 'Success',
    });
  });
}
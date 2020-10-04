import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:testapp/models/Message.dart';
import 'package:intl/intl.dart';
import 'package:testapp/models/Profile.dart';
import 'ChatWindow.dart';

class Inbox extends StatefulWidget {
  FirebaseUser user;
  Inbox({this.user});
  _HomeState createState() => _HomeState(user);
}

class _HomeState extends State<Inbox> {
  FirebaseUser user;
  _HomeState(this.user);


//  List <Message> msg = [
//    Message('Alicia Ong','Ok. No problem.','2020-05-03 08:23:31'),
//    Message('Tan Win Yin','see you later.','2020-05-04 10:12:21'),
//    Message('Mohd Syafiq','boleh sir.','2020-05-04 13:56:44'),
//  ];

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
//          actions: <Widget>[
//            IconButton(
//              icon : Icon(Icons.delete),
//              tooltip: 'Delete Message',
//              onPressed: () {},),
//            IconButton(
//              icon : Icon(Icons.add_circle_outline),
//              tooltip: 'New Message',
//              onPressed: () {},),
//          ],
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
            buildListChat(),
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

  buildListChat(){
    return Container(
      child: StreamBuilder(
        stream: Firestore.instance
            .collection('message')
            .where('myId', isEqualTo: user.uid)
            .orderBy('lastTimestamp' , descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {

          if(!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)));
          } else {
            List<AssociatedChat> chatList = [];
            for (DocumentSnapshot doc in snapshot.data.documents) {
              AssociatedChat associatedChat = new AssociatedChat();
              associatedChat.peerId = doc.data['peerId'];
              associatedChat.peerName = doc.data['peerName'];
              associatedChat.peerAvatarUrl = doc.data['peerAvatarUrl'];
              associatedChat.lastMessage = doc.data['lastMessage'];
              associatedChat.lastTimestamp = doc.data['lastTimestamp'];
              if(associatedChat.lastMessage!='' && associatedChat.lastMessage!=null){
                chatList.add(associatedChat);
              }
            }
            return ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.all(10.0),
              itemBuilder: (context, index) => buildItem(chatList[index],chatList[index].peerId),
              itemCount: snapshot.data.documents.length,
//              controller: listScrollController,
            );
          }
        },
      ),
    );

  }

  Widget buildItem(AssociatedChat associatedChat, String peerId) {
    return Card(
        child: ListTile(
          onTap: (){
              fetchProfile(peerId);
            },
          leading : CachedNetworkImage(
            placeholder: (context, url) => Container(
              child: CircularProgressIndicator(
                valueColor:
                AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
              ),
              width: 200.0,
              height: 200.0,
              padding: EdgeInsets.all(70.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(8.0),
                ),
              ),
            ),
            errorWidget: (context, url, error) => Material(
              child: Image.asset(
                'assets/profile-icon.png',
                width: 50.0,
                height: 50.0,
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(8.0),
              ),
              clipBehavior: Clip.hardEdge,
            ),
            imageUrl: associatedChat.peerAvatarUrl,
            width: 50.0,
            height: 50.0,
            fit: BoxFit.cover,
          ),
          title: Text(associatedChat.peerName),
          subtitle:Text(associatedChat.lastMessage,overflow: TextOverflow.ellipsis),
          trailing: Text(DateFormat('dd MMM kk:mm').format(
              DateTime.fromMillisecondsSinceEpoch(
                  int.parse(associatedChat.lastTimestamp))),),
        ),
      );

  }

  fetchProfile(String peerId) async{
    Profile profile = new Profile.empty();
    await Firestore.instance.collection('profile').document(peerId).get().then((doc) {
      profile.id = doc.data["id"];
      profile.name = doc.data["name"];
      profile.email = doc.data["email"];
      profile.about = doc.data["about"];
      profile.achievement = doc.data["achievement"];
      profile.services = doc.data["services"];
      profile.profilepic = doc.data["profile_pic"];
      Timestamp j = doc.data["joined"];
      profile.joined = j.toDate().toString().substring(0, 10);
      profile.posted = doc.data["task_posted"].toString();
      profile.completed = doc.data["task_completed"].toString();
      profile.reviewNum = doc.data["review_num"].toString();
      profile.rating = doc.data["rating"].toString();
      profile.gallery = doc.data["gallery"];
    }).then((val){
      Navigator.push(context, MaterialPageRoute(
          builder: (context) =>
              ChatWindow(user: user, profile: profile)));
    });
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





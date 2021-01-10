import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:testapp/models/Message.dart';
import 'package:intl/intl.dart';
import 'package:testapp/models/Notification.dart';
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



  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics().setCurrentScreen(screenName: "InboxScreen");
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(title : Text('Inbox'),
          centerTitle: true ,
          elevation: 0.0,
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
            buildListNotification(),
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
              itemBuilder: (context, index) => buildChatItem(chatList[index],chatList[index].peerId),
              itemCount: snapshot.data.documents.length,
//              controller: listScrollController,
            );
          }
        },
      ),
    );

  }

  Widget buildChatItem(AssociatedChat associatedChat, String peerId) {
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
              ChatWindow(user: user, profile: profile), settings: RouteSettings(name: "ChatWindowView")));
    });
  }

  buildListNotification(){

    return Container(
      child: StreamBuilder(
        stream: Firestore.instance
            .collection('notification')
            .where('sentTo', whereIn: [user.uid,'ALL'])
            .orderBy('sentAt' , descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {

          if(!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)));
          } else {
            List<NotificationItem> notiList = [];
            for (DocumentSnapshot doc in snapshot.data.documents) {
              NotificationItem notification = new NotificationItem();
              notification.title = doc.data['title'];
              notification.id = doc.data['id'];
              notification.sentAt = doc.data['sentAt']?.toDate();;
              notification.sentTo = doc.data['sentTo'] == user.displayName ? 'Me' : 'All';
              notification.imgHeader = doc.data['imageHeader'];
              notification.content = doc.data['content'];
              notiList.add(notification);
            }
            return ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.all(10.0),
              itemBuilder: (context, index) => buildNotiItem(notiList[index]),
              itemCount: snapshot.data.documents.length,
            );
          }
        },
      ),
    );
  }

  Widget buildNotiItem(NotificationItem notiItem) {
    return Card(

      child: ListTile(
        onTap: (){
          Navigator.push(context, MaterialPageRoute(
              builder: (context) =>
                  ViewNotification(user: user, notificationItem: notiItem), settings: RouteSettings(name: "NotificationView")));
        },
        leading : Icon(Icons.notifications),
        title: Text(notiItem.title),
        subtitle:Text(notiItem.content.replaceAll("\\n", " "),overflow: TextOverflow.ellipsis),
        trailing: Text(DateFormat.yMMMd().format(notiItem.sentAt)),
      ),
    );

  }
}


class ViewNotification extends StatefulWidget {
  FirebaseUser user;
  NotificationItem notificationItem;
  ViewNotification({this.user , this.notificationItem});
  _NotificationState createState() => _NotificationState(user , notificationItem);
}

class _NotificationState extends State<ViewNotification> {
  FirebaseUser user;
  NotificationItem notificationItem;

  _NotificationState(this.user, this.notificationItem);

  @override
  Widget build(BuildContext context) {

    TextStyle _style1 = TextStyle(fontFamily: 'OpenSans-R',fontSize: 20);
    TextStyle _style2 = TextStyle(fontFamily: 'OpenSans-R',fontSize: 12,color: Colors.black26,);

    return Scaffold(
        appBar : AppBar(
          centerTitle: true,
          title : Text("View Notification"),
          elevation: 0.0,
          backgroundColor: Colors.amberAccent[400],
    ),
    body: SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notificationItem.title, style: _style1,),
            SizedBox(height: 5,),
            Text('id : ' + notificationItem.id, style: _style2,),
            SizedBox(height: 5,),
            Text(DateFormat.yMMMMEEEEd().format((notificationItem.sentAt)) + ' at ' + DateFormat.Hms().format(notificationItem.sentAt)),
            SizedBox(height: 10,),
            Container(color: Colors.blueGrey, height: 1,),
            SizedBox(height: 10,),
            (notificationItem.imgHeader == '' ) ? Container() : Image.network(notificationItem.imgHeader),
            SizedBox(height: 10,),
            Text(notificationItem.content.replaceAll("\\n", " \n")),
          ],
        ),
      ),
    ));
  }
}




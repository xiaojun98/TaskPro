import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';
import 'package:testapp/models/Profile.dart';
import 'package:testapp/models/Review.dart';
import 'package:testapp/services/analytics_service.dart';
import 'ChatWindow.dart';
import 'CreateReport.dart';


class ViewProfile extends StatefulWidget {

  final FirebaseUser user;
  final Profile profile;
  ViewProfile({this.user,this.profile});
  _HomeState createState() => new _HomeState(user,profile);

}

class _HomeState extends State<ViewProfile> {

  FirebaseUser user;
  Profile profile;
  _HomeState(this.user,this.profile);
  bool ownProfile = false;
  final _analyticsService = AnalyticsServices();

  Future<bool> createChatWindow() async{
    String groupChatId;
    groupChatId = user.uid + profile.id;

    DocumentReference ref = Firestore.instance.collection('message').document(groupChatId);
    DocumentReference ref2 = Firestore.instance.collection('message').document(groupChatId.substring(28)+groupChatId.substring(0,28));

    Firestore.instance.runTransaction((Transaction tx) async {
      tx.set(ref.collection('msg').document('last seen'), {'time created' : DateTime.now().toString()});
    });
    
    await ref.updateData({
      'myId' : user.uid,
      'peerId' : profile.id,
      'peerName' : profile.name,
      'peerAvatarUrl' : profile.profilepic,
    }).catchError((e) {
      ref.setData({
        'myId' : user.uid,
        'peerId' : profile.id,
        'peerName' : profile.name,
        'peerAvatarUrl' : profile.profilepic,
      });
    });

    await ref2.updateData({
        'myId' : profile.id,
        'peerId' : user.uid,
        'peerName' : user.displayName,
        'peerAvatarUrl' : user.photoUrl,
    }).catchError((e) {
      ref2.setData({
        'myId' : profile.id,
        'peerId' : user.uid,
        'peerName' : user.displayName,
        'peerAvatarUrl' : user.photoUrl,
      });
    });

    Navigator.push(context, MaterialPageRoute(
        builder: (context) =>
            ChatWindow(user: user, profile: profile), settings: RouteSettings(name: "ChatWindowView")));
  }

  Widget build(BuildContext context) {
    FirebaseAnalytics().setCurrentScreen(screenName: "ProfileScreen");
    ownProfile = user.uid == profile.id;
    _analyticsService.logProfileViewed();
    return Scaffold(
      appBar: AppBar(title : Text('Profile'),
        centerTitle: true ,
        elevation: 0.0,
        backgroundColor: Colors.amberAccent[400],
        actions: <Widget>[
          (!ownProfile) ? IconButton(
            icon : Icon(Icons.report_gmailerrorred_outlined),
            onPressed: () => showDialog<bool>(
              context: context,
              builder: (c) => AlertDialog(
                title: Text('Alert'),
                content: Text('Report this user?'),
                actions: [
                  FlatButton(
                    child: Text('Yes'),
                    onPressed: () {
                      Navigator.pop(c,true);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => CreateReport(user: user, category: 'Report an User', taskId: null, profileId: profile.id,), settings: RouteSettings(name: "ReportFormView")));
                    }
                  ),
                  FlatButton(
                    child: Text('No'),
                    onPressed: () => Navigator.pop(c, false),
                  ),
                ],
              ),
            )
          ) : Container ()
        ],
      ),
      floatingActionButton: Builder(builder: (context){
          if(!ownProfile){
            return Padding(
              padding: EdgeInsets.all(15),
              child: FloatingActionButton(
                child: Icon(Icons.mail,size: 30,color: Colors.white,),
                onPressed: () async {
                  await createChatWindow().catchError((e){
                    print("$e,#error creating chatwindow");
                  }).then((value){
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) =>
                        ChatWindow(user: user, profile: profile), settings: RouteSettings(name: "ChatWindowView")));
                  });
                }),
            );
          }
          else return Container();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[

            Column(
                children : <Widget>[
                  Container(
                    decoration: BoxDecoration(color : Colors.amberAccent[400], border: Border.all(color : Colors.amberAccent[400]),borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30),bottomRight: Radius.circular(30)), ),
                    height: 250,
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.all(10),
                                child: CircleAvatar (
                                  backgroundColor: Colors.white,
                                  radius: 60,
                                  child: ClipOval(
                                    child: new SizedBox(
                                      width: 180.0,
                                      height: 180.0,
                                      child: (profile.profilepic!='')?Image.network(
                                        profile.profilepic,
                                        fit: BoxFit.cover,
                                      ):Image.asset(
                                        "assets/profile-icon.png",
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                )
                            ),
                            SizedBox(width: 10),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(profile.name, style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold
                                ),),
                                Container(
                                  height: 35,
                                  child: Row(
                                      children: [
                                        Container(
                                          child: Text('ID:'+profile.id,style: TextStyle(fontFamily: 'OpenSans-R', fontSize: 10, color: Colors.black26,), overflow: TextOverflow.ellipsis),
                                          width: 120,
                                        ),
                                        IconButton(
                                            icon: Icon(Icons.copy,color: Colors.black26,size: 12,),
                                            onPressed: (){
                                              Clipboard.setData(ClipboardData(text: profile.id));
                                              Fluttertoast.showToast(
                                                  msg: "Profile ID Copied",
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
                                ),
                                Row(
                                  children: <Widget>[
                                    Icon(Icons.location_on,size: 15,),
                                    SizedBox(width: 10),
                                    Text('Joined at ',style: TextStyle(
                                      fontSize: 12,),),
                                    Text(profile.joined,style: TextStyle(
                                      fontSize: 12,),)
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  children: <Widget>[
                                    Icon(Icons.alternate_email,size: 15,),
                                    SizedBox(width: 10),
                                    Text(profile.email,style: TextStyle(
                                      fontSize: 12,),)
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 25,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                Text(profile.posted.toString(), style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold
                                ),),
                                Text("Posted", style: TextStyle(
                                  fontSize: 12,
                                ),),
                              ],
                            ),
                            Column(
                              children: <Widget>[
                                Text(profile.completed.toString(), style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold
                                ),),
                                Text("Completed", style: TextStyle(
                                  fontSize: 12,
                                ),),
                              ],
                            ),
                            Column(
                              children: <Widget>[
                                Text(profile.rating.toString(), style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold
                                ),),
                                Text("Rating", style: TextStyle(
                                  fontSize: 12,
                                ),),
                              ],
                            ),
                            Column(
                              children: <Widget>[
                                Text(profile.reviewNum.toString(), style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold
                                ),),
                                Text("Review", style: TextStyle(
                                  fontSize: 12,
                                ),),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ]
            ),
            SizedBox(height : 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Column(
                children: <Widget>[
                  Container(
                    child: Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      child: ListTile(
                        title: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Text('About', style : TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(profile.about == '' ? 'No information' : profile.about ,style : TextStyle(fontSize: 13)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 5,),
                  Container(
                    child: Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      child: ListTile(
                        title: Text('Achievement', style : TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),),
                        subtitle: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(profile.achievement == '' ? 'No information' : profile.achievement, style : TextStyle(fontSize: 13)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 5,),
                  Container(
                    child: Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      child: ListTile(
                        title: Text('Services', style : TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),),
                        subtitle: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(profile.services == '' ? 'No information' : profile.services,style : TextStyle(fontSize: 13)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Divider(indent : 15 , endIndent: 15 , height: 60 , color: Colors.amber, thickness: 1.5,),

            // Padding(
            //   padding: EdgeInsets.symmetric(horizontal: 20),
            //   child: Text('Gallery', style : TextStyle(
            //     fontSize: 20,
            //     fontWeight: FontWeight.bold,
            //   ),),
            // ),
            // SizedBox(height : 20),
            // Container(
            //   height: 120,
            //   padding: EdgeInsets.symmetric(horizontal: 20),
            //   //            child: ListView.builder(
            //   child: ListView(
            //     scrollDirection: Axis.horizontal,
            //     children: <Widget>[
            //       //Image.file(file)
            //       Container(
            //         margin: EdgeInsets.only(right: 10),
            //         height: 120,
            //         width: 120,
            //         decoration: BoxDecoration(
            //           image: DecorationImage(
            //               image: AssetImage('assets/images_1.png'),
            //               fit: BoxFit.cover
            //           ),
            //         ),
            //       ),
            //       Container(
            //         margin: EdgeInsets.only(right: 10),
            //         height: 120,
            //         width: 120,
            //         decoration: BoxDecoration(
            //           image: DecorationImage(
            //               image: AssetImage('assets/images_2.png'),
            //               fit: BoxFit.cover
            //           ),
            //         ),
            //       ),
            //       Container(
            //         margin: EdgeInsets.only(right: 10),
            //         height: 120,
            //         width: 120,
            //         decoration: BoxDecoration(
            //           image: DecorationImage(
            //               image: AssetImage('assets/images_3.jpg'),
            //               fit: BoxFit.cover
            //           ),
            //         ),
            //       ),
            //       Container(
            //         margin: EdgeInsets.only(right: 10),
            //         height: 120,
            //         width: 120,
            //         decoration: BoxDecoration(
            //           image: DecorationImage(
            //               image: AssetImage('assets/images_4.jpg'),
            //               fit: BoxFit.cover
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            // Divider(indent : 15 , endIndent: 15 , height: 60 , color: Colors.amber, thickness: 1.5,),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('Reviews', style : TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),),
            ),

            StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance.collection('review')
                    .where('reviewTarget', isEqualTo: Firestore.instance.collection('users').document(profile.id))
                    .snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> myTask) {
                  List<Review> reviewList = [];
                  if(!myTask.hasData) {
                    return Center(child: Text('No task found.', style: TextStyle(color: Colors.grey),),);
                  } else {
                    for (DocumentSnapshot doc in myTask.data.documents) {
                      Review rev = new Review();
                      rev.id = doc.data['id'];
                      rev.createdAt = doc.data['createdAt']?.toDate();
                      rev.reviewBy = doc.data['reviewBy'];
                      rev.reviewTarget = doc.data['reviewTarget'];
                      rev.content = doc.data['content'];
                      rev.rating = double.parse(doc.data['rating'].toString());
                      rev.taskAssociated = doc.data['taskAssociated'];
                      rev.authorName = doc.data['authorName'];
                      rev.authorPicUrl = doc.data['authorPicUrl'];
                      rev.taskTitle = doc.data['taskTitle'];
                      reviewList.add(rev);
                    }
                  }
                  return SizedBox (height : 400,child: MyListView(revs : reviewList));
                }),
            SizedBox(height: 100,),
          ],
        ),
      )
    );
  }
}

class MyListView extends StatefulWidget {
  final List<Review> revs;
  MyListView({ this.revs});
  _MyListViewState createState() => _MyListViewState(revs);
}

class _MyListViewState extends State<MyListView> {
  final List<Review> revs;
  _MyListViewState(this.revs);


  @override
  Widget build(BuildContext context) {

    return ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
        itemCount: revs.length,
        itemBuilder: (context,index){
          return Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            child: ListTile(
              onTap: () {
                showDialog(
                  context: context,
                  child: AlertDialog(
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Container(
                              alignment: Alignment.center,
                                  padding: EdgeInsets.all(10),
                                  child: CircleAvatar (
                                    backgroundColor: Colors.white,
                                    radius: 20,
                                    child: ClipOval(
                                      child: new SizedBox(
                                        width: 180.0,
                                        height: 180.0,
                                        child: (revs[index].authorPicUrl!='')?Image.network(
                                          revs[index].authorPicUrl,
                                          fit: BoxFit.cover,
                                        ):Image.asset(
                                          "assets/profile-icon.png",
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  )
                              ),
                              SizedBox(width: 10),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(revs[index].authorName, style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold
                                  ),),
                                  Text(revs[index].createdAt.toString() ,style: TextStyle(fontFamily: 'OpenSans-R', fontSize: 10, color: Colors.black26,), overflow: TextOverflow.ellipsis),
                                  ]
                              )
                            ],
                          ),
                          RatingBarIndicator(
                            rating: revs[index].rating,
                            itemBuilder: (context, index) => Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            itemCount: 5,
                            itemSize: 40.0,
                            direction: Axis.horizontal,
                          ),
                          Text(revs[index].rating.toString() + ' out of 5.0' , style: TextStyle( fontStyle : FontStyle.italic, color: Colors.black54),),
                          SizedBox(height: 20,),
                          Text(' For Task ' , style: TextStyle(color : Colors.black54, fontSize: 11)),
                          SizedBox(height: 5,),
                          Text(" \" " + revs[index].taskTitle.toString() + " \" " , style: TextStyle(fontWeight: FontWeight.bold , fontSize: 16 , color: Colors.blueGrey) , textAlign: TextAlign.center,),
                          SizedBox(height: 20,),
                          Container(
                            decoration: BoxDecoration(border: Border.all(color: Colors.blueGrey), borderRadius: BorderRadius.circular(10)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                    decoration: BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(9), topRight: Radius.circular(9)), color: Colors.blueGrey,),
                                    height: 25,
                                    child: Center(child: Text("Comment" , style : TextStyle(color: Colors.white)))),
                                SizedBox(height: 10,),
                                Container(
                                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                    child: Text(revs[index].content.toString())),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              leading:  Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children : <Widget>[
                  CircleAvatar (
                    backgroundColor: Colors.white,
                    radius: 25,
                    child: ClipOval(
                      child: new SizedBox(
                        width: 50.0,
                        height: 50.0,
                        child: (revs[index].authorPicUrl!=null && revs[index].authorPicUrl!='') ? Image.network(
                          revs[index].authorPicUrl,
                          fit: BoxFit.cover,
                        ) : Image.asset(
                          "assets/profile-icon.png",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  ],
              ),
              title: Text(revs[index].authorName.toString(), style: TextStyle(color : Colors.lightBlue[900]),),
              subtitle: Text(revs[index].content.toString(),overflow: TextOverflow.ellipsis),
              trailing: RatingBarIndicator(
                rating: revs[index].rating,
                itemBuilder: (context, index) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                itemCount: 5,
                itemSize: 10.0,
                direction: Axis.horizontal,
              ),
            ),
          );
        }
    );
  }
}
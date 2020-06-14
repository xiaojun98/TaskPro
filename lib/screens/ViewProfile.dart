import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:testapp/models/Profile.dart';


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

  Widget build(BuildContext context) {


    return Scaffold(
        appBar: AppBar(title : Text('Profile'),
          centerTitle: true ,
          elevation: 0.0,
          backgroundColor: Colors.amberAccent[400],),
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
                                  SizedBox(height: 10),
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
                                  Text(profile.posted, style: TextStyle(
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
                                  Text(profile.completed, style: TextStyle(
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
                                  Text(profile.rating, style: TextStyle(
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
                                  Text(profile.reviewNum, style: TextStyle(
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
              Column(
                children: <Widget>[
                  Container(
                    height: 180,
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      child: ListTile(
                        title: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Text('About', style : TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),),
                        ),
                        subtitle: Text(profile.about,style : TextStyle(fontSize: 13)),
                      ),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    //achievement
                    children: <Widget>[
                      Container(
                        height: 150,
                        width: 180,
                        child: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                          child: ListTile(
                            title: Text('Achievement', style : TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),),
                            subtitle: Text(profile.achievement, style : TextStyle(fontSize: 13)),
                          ),
                        ),
                      ),
                      SizedBox(height: 5,),
                      Container(
                        height: 150,
                        width: 180,
                        child: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                          child: ListTile(
                            title: Text('Services', style : TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),),
                            subtitle: Text(profile.services,style : TextStyle(fontSize: 13)),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),

              Divider(indent : 15 , endIndent: 15 , height: 60 , color: Colors.amber, thickness: 1.5,),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('Gallery', style : TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),),
              ),
              SizedBox(height : 20),
              Container(
                height: 120,
                padding: EdgeInsets.symmetric(horizontal: 20),
                //            child: ListView.builder(
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[
                    //Image.file(file)
                    Container(
                      margin: EdgeInsets.only(right: 10),
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('assets/images_1.png'),
                            fit: BoxFit.cover
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(right: 10),
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('assets/images_2.png'),
                            fit: BoxFit.cover
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(right: 10),
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('assets/images_3.jpg'),
                            fit: BoxFit.cover
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(right: 10),
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('assets/images_4.jpg'),
                            fit: BoxFit.cover
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(indent : 15 , endIndent: 15 , height: 60 , color: Colors.amber, thickness: 1.5,),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('Reviews', style : TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),),
              ),
              SizedBox(height: 100,),
            ],
          ),
        )
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:testapp/models/Profile.dart';

import 'ViewProfile.dart';


class SearchProfile extends StatefulWidget {
  FirebaseUser user;
  String searchTerm;
  SearchProfile({this.user, this.searchTerm});
  _HomeState createState() => _HomeState(user, searchTerm);
}

class _HomeState extends State<SearchProfile> {
  FirebaseUser user;
  String searchTerm;
  _HomeState(this.user,this.searchTerm);
  @override
  Icon searchCon = Icon(Icons.search);
  Widget title = Text('Search Profile');

  String dropdownValue = 'Order by';
  bool searching = true;


  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title : title,
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
                  this.title = Text('Search Profile');
                }
              });
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance.collection('profile').snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if(!snapshot.hasData) {
                    return Center(child: Text('No profile matched.', style: TextStyle(color: Colors.grey),),);
                  } else {
                    List<Profile> profileList = [];
                    for (DocumentSnapshot doc in snapshot.data.documents) {
                      Profile profile = new Profile.Ds(doc);
                      if(profile.status!= 0) break;
                      if(searching) {
                        if(profile.name.contains(searchTerm)||profile.email.contains(searchTerm)||profile.services.contains(searchTerm)||profile.achievement.contains(searchTerm)||profile.about.contains(searchTerm))
                          profileList.add(profile);
                        else{
                          String capTerm = searchTerm.substring(0,1).toUpperCase() + searchTerm.substring(1);
                          if(profile.name.contains(capTerm)||profile.email.contains(capTerm)||profile.services.contains(capTerm)||profile.achievement.contains(capTerm)||profile.about.contains(capTerm))
                            profileList.add(profile);
                          else{
                            String decapTerm = searchTerm.substring(0,1) + searchTerm.substring(1).toLowerCase();
                            if(profile.name.contains(decapTerm)||profile.email.contains(decapTerm)||profile.services.contains(decapTerm)||profile.achievement.contains(decapTerm)||profile.about.contains(decapTerm))
                              profileList.add(profile);
                          }
                        }
                      } else {
                        profileList.add(profile);
                      }
                    }
                    return ListView.builder(
                      padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                      itemCount: profileList.length,
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemBuilder: (context,index){
                        return Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: ListTile(
                            onTap: () {
                               Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => ViewProfile(user: user, profile: profileList[index],))
                              );
                            },
                            leading: CircleAvatar (
                              backgroundColor: Colors.white,
                              radius: 25,
                              child: ClipOval(
                                child: new SizedBox(
                                  width: 50.0,
                                  height: 50.0,
                                  child: (profileList[index].profilepic != null && profileList[index].profilepic!='') ? Image.network(
                                    profileList[index].profilepic,
                                    fit: BoxFit.cover,
                                  ) : Image.asset(
                                    "assets/profile-icon.png",
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(profileList[index].name),
                          ),
                        );
                      }
                    );
                  }
                }),
            ])
      )
    );
  }
}
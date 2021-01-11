import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Review.dart';

class Profile{
  String id = '';
  String name = '';
  String email = '';
  String about = '';
  String achievement = '';
  String services = '';
  String profilepic = '';
  String joined = '';
  int posted = 0;
  int completed = 0;
  int reviewNum = 0;
  double rating = 0;
  bool isActive = true;
  int status = 0;
  List chatWindowID = [];
  List gallery = [];
  bool notiEnaled = false;

  Profile.empty() {}

  Profile.AsyncDs(AsyncSnapshot<DocumentSnapshot> ds){
    this.id = ds.data["id"];
    this.name = ds.data["name"];
    this.email = ds.data["email"];
    this.about = ds.data["about"];
    this.achievement = ds.data["achievement"];
    this.services = ds.data["services"];
    this.profilepic = ds.data["profile_pic"];
    Timestamp j = ds.data["joined"];
    this.joined = j.toDate().toString().substring(0,10);
    this.posted = ds.data["task_posted"];
    this.completed = ds.data["task_completed"];
    this.reviewNum = ds.data["review_num"];
    this.rating = double.parse(ds.data["rating"].toString());
    this.isActive = ds.data["isActive"];
    this.status = ds.data["status"];
    this.chatWindowID = ds.data["chatWindowID"];
    this.gallery = ds.data["gallery"];
    this.notiEnaled = ds.data["notificationEnabled"];
    updates();
  }

  Profile.Ds(DocumentSnapshot ds){
    this.id = ds.data["id"];
    this.name = ds.data["name"];
    this.email = ds.data["email"];
    this.about = ds.data["about"];
    this.achievement = ds.data["achievement"];
    this.services = ds.data["services"];
    this.profilepic = ds.data["profile_pic"];
    Timestamp j = ds.data["joined"];
    this.joined = j.toDate().toString().substring(0,10);
    this.posted = ds.data["task_posted"];
    this.completed = ds.data["task_completed"];
    this.reviewNum = ds.data["review_num"];
    this.rating = double.parse(ds.data["rating"].toString());
    this.isActive = ds.data["isActive"];
    this.status = ds.data["status"];
    this.chatWindowID = ds.data["chatWindowID"];
    this.gallery = ds.data["gallery"];
    this.notiEnaled = ds.data["notificationEnabled"];
    updates();
  }

  updates() {
    Stream<QuerySnapshot> stream = Firestore.instance.collection('review')
        .where('reviewTarget', isEqualTo: Firestore.instance.collection('users').document(id))
        .snapshots();

    stream.forEach((QuerySnapshot element) {
      if(element == null){
        return;
      }


      else{
        element.documents.forEach((doc) {
          rating = rating + double.parse(doc.data['rating'].toString());
          reviewNum +=1;
        }
        );
        rating = rating / element.documents.length;
      }
    });
    Stream<QuerySnapshot> stream2 = Firestore.instance.collection('task')
        .where('created_by', isEqualTo: Firestore.instance.collection('users').document(id))
        .snapshots();

    stream2.forEach((QuerySnapshot element) {
      if(element == null){
        return;
      }


      else{
        element.documents.forEach((doc) {
          posted +=1;
          if(doc.data['status'] == "Completed"){
            completed+=1;
          }
        }
        );
      }
    });
    Stream<QuerySnapshot> stream3 = Firestore.instance.collection('task')
        .where('offered_by', isEqualTo: Firestore.instance.collection('users').document(id))
        .snapshots();

    stream3.forEach((QuerySnapshot element) {
      if(element == null){
        return;
      }


      else{
        element.documents.forEach((doc) {
          if(doc.data['status'] == "Completed"){
            completed+=1;
          }
        }
        );
      }
    });
  }

}
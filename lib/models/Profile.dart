import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class Profile{
  String id = '';
  String name = '';
  String email = '';
  String about = '';
  String achievement = '';
  String services = '';
  String profilepic = '';
  String joined = '';
  String posted = '';
  String completed = '';
  String reviewNum = '';
  String rating = '';
  List gallery = [];

  Profile.empty() {}

  Profile(AsyncSnapshot<DocumentSnapshot> ds){
    this.name = ds.data["name"];
    this.email = ds.data["email"];
    this.about = ds.data["about"];
    this.achievement = ds.data["achievement"];
    this.services = ds.data["services"];
    this.profilepic = ds.data["profile_pic"];
    Timestamp j = ds.data["joined"];
    this.joined = j.toDate().toString().substring(0,10);
    this.posted = ds.data["task_posted"].toString();
    this.completed = ds.data["task_completed"].toString();
    this.reviewNum = ds.data["review_num"].toString();
    this.rating = ds.data["rating"].toString();
    this.gallery = ds.data["gallery"];
  }

}
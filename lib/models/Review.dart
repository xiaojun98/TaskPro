import 'package:cloud_firestore/cloud_firestore.dart';

class Review{
  String id;
  String content;
  double rating;
  DocumentReference reviewBy;
  DocumentReference reviewTarget;
  DocumentReference taskAssociated;
  DateTime createdAt;
  String authorName;
  String authorPicUrl;
  String taskTitle;
}



import 'package:cloud_firestore/cloud_firestore.dart';

class Report {

  String id;
  DocumentReference createdBy;
  DateTime createdAt;
  Object author;
  String category;
  String subCategory;
  String title;
  String description;
  String suggestion;
  String status;
  String taskId;  //for category "Task Related Issue"
  DocumentReference taskRef;
  String profileId; //for category "Report an User"
  DocumentReference profileRef;

}
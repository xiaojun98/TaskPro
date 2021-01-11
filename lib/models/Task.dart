import 'dart:ffi';
import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  String id;
  DocumentReference createdBy;
  DateTime createdAt;
  DocumentReference updatedBy;
  DateTime updatedAt;
  Object author;
  String category;
  String title;
  String description;
  String additionalInstruction;
  String tags;
  DateTime offerDeadline;
  DateTime taskDeadline;
  String location;
  double fee;
  DocumentReference payment;
  String status;
  DocumentReference offeredBy;
  bool isCompleteByAuthor = false;
  bool isCompleteByProvider = false;
  int offerNum;

  DocumentReference reviewedByAuthor ;
  DocumentReference reviewByProvider ;

  DateTime upcomingDeadline;
  String creditId;
  String debitId;
}
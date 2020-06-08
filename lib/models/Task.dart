import 'dart:ffi';
import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  DocumentReference createdBy;
  DateTime createdAt;
  DocumentReference updatedBy;
  DateTime updatedAt;
  Object author;
  Object serviceProvider;
  String category;
  String title;
  String description;
  String additionalInstruction;
  String tags;
  DateTime dateTime;
  String location;
  double fee;
  DocumentReference payment;
  String status;
  DocumentReference offeredBy;
  bool isCompleteByAuthor = false;
  bool isCompleteByProvider = false;
}
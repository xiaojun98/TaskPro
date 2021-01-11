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

 Future<bool> checkReviewed(DocumentReference task, DocumentReference author) async{
   QuerySnapshot result = await Firestore.instance.collection('review')
       .where('taskAssociated', isEqualTo: task)
       .where('reviewBy', isEqualTo: author)
       .limit(1).getDocuments();
   List <DocumentSnapshot> documents = result.documents;
   if (documents.length == 1) {
     //reviewed
     return Future<bool>.value(true);
   }
   else {
     //not reviewed
      return Future<bool>.value(false);
   }
 }


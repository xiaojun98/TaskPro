import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService{

  static NotificationService get instance => NotificationService();


  String createNotiContent(int type, var obj){
    switch(type){
      case 1: {
        return "Your Report (ID: " + obj.id + ") is successfully submitted.";
      }
      break;

      case 2 : {
        return "Your Task [" + obj.title + "] (ID: " + obj.id + ") has been marked completed by " + obj.offeredBy.documentID;
      }
      break;

      case 3 : {
        return "Task [" + obj.title + "] (ID: " + obj.id + ") offered by you has been marked completed by " + obj.author.name;
      }
      break;

      case 4 : {
      return "Your Task [" + obj.title + "] (ID: " + obj.id + ") has expired.";
      }
      break;

      case 5 : {
        return "Your Task [" + obj.title + "] (ID: " + obj.id + ") has been reviewed by your service provider : " + obj.offeredBy.documentID;
      }
      break;

      case 6 : {
        return "You have receive an reviewed for Task [" + obj.title + "] (ID: " + obj.id + ") from the author : " + obj.author.name;
      }
      break;

      case 7 : {
        return "Your Task [" + obj.title + "] (ID: " + obj.id + ") was cancelled by service provider. Check your balance to view refund.";
      }
      break;

      default : {
        return "";
      }
      break;
    }
  }
  
  Future<bool> generateNotification (int type, var obj, String targetId) async{
    final TITLE = [
      {'id': 0, 'title' : 'Empty Notification'},
      {'id': 1, 'title' : 'Report Created'},
      {'id': 2, 'title' : 'Task Marked Completed'},
      {'id': 3, 'title' : 'Task Marked Completed'},
      {'id': 4, 'title' : 'Expired Task'},
      {'id': 5, 'title' : 'Task Reviewed'},
      {'id': 6, 'title' : 'Task Reviewed'},
      {'id': 7, 'title' : 'Task Cancelled'},
    ];

    String content = createNotiContent(type, obj);
    DocumentReference ref = Firestore.instance.collection("notification").document();
    await ref.setData({
      'id' : ref.documentID,
      'title' : TITLE[type]['title'],
      'content' : content,
      'sentAt' : DateTime.now(),
      'sentTo' : targetId
    }).catchError((e){
      print("Notification Generation Failed : " + e);
      return false; });
    return true;
  }
}
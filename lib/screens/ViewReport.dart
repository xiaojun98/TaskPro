import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:testapp/models/Profile.dart';
import 'package:testapp/models/Report.dart';
import 'package:testapp/models/Task.dart';
import 'package:testapp/screens/ViewProfile.dart';

import 'MySingleTaskView.dart';


class ViewReport extends StatefulWidget {
  Report report;
  ViewReport({this.report});
  _HomeState createState() => _HomeState(report);
}

class _HomeState extends State<ViewReport> {
  Report report;
  _HomeState(this.report);
  TextStyle _style = TextStyle(fontWeight: FontWeight.bold,color: Colors.white);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar : AppBar(
        centerTitle: true,
        title : Text("View Report"),
        elevation: 0.0,
        backgroundColor: Colors.amberAccent[400],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.blueGrey), borderRadius: BorderRadius.circular(5),),
            child: Column(
             children : [
               Row(
                 children: [
                   Container(
                     padding: EdgeInsets.only(left: 5),
                     color: Colors.blueGrey,
                     width: 90,
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         SizedBox(height: 5,),
                         Text('Title' , style: _style,),
                         SizedBox(height: 15,),
                         Text('Report ID' , style: _style,),
                         SizedBox(height: 15,),
                         Text('Created At' , style: _style,),
                         SizedBox(height: 15,),
                         Text('Status' , style: _style,),
                         SizedBox(height: 15,),
                         Text('Category' , style: _style,),
                         SizedBox(height: 15,),
                         Text('Sub Category' , style: _style,),
                         SizedBox(height: 15,),
                         (report.taskId !='') ? Text('Task ID' , style: _style,) : Container(),
                         (report.profileId != '') ? Text('Profile ID' , style: _style,) : Container(),
                         (report.taskId !='' ||report.profileId != '') ?SizedBox(height: 15,) : Container(),
                       ],
                     ),
                   ),
                   SizedBox(width: 15),
                   Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       SizedBox(height: 5,),
                       Text(report.title),
                       SizedBox(height: 15,),
                       // Container(color: Colors.amber, width: 180, height: 1,),
                       Text(report.id),
                       SizedBox(height: 15,),
                       Text(report.createdAt.toString()),
                       SizedBox(height: 15,),
                       Text(report.status),
                       SizedBox(height: 15,),
                       Text(report.category),
                       SizedBox(height: 15,),
                       Text(report.subCategory),
                       SizedBox(height: 15,),
                       (report.taskId !='') ? InkWell(
                         child: Text(report.taskId),
                         onTap: () async {
                           await Firestore.instance.collection('task').document(report.taskId).get().then((doc) async {
                             Task task = new Task();
                             task.id = doc.data['id'];
                             task.createdBy = doc.data['created_by'];
                             task.createdAt = doc.data['created_at']?.toDate();
                             task.updatedBy = doc.data['updated_by'];
                             task.updatedAt = doc.data['updated_at']?.toDate();
                             task.author = doc.data['author'];
                             task.category = doc.data['category'];
                             task.title = doc.data['title'];
                             task.description = doc.data['description'];
                             task.additionalInstruction = doc.data['additional_instruction'];
                             task.tags = doc.data['tags'];
                             task.offerDeadline = doc.data['offer_deadline']?.toDate();
                             task.taskDeadline = doc.data['task_deadline']?.toDate();
                             task.location = doc.data['location'];
                             task.fee = double.parse(doc.data['fee'].toString());
                             task.payment = doc.data['payment'];
                             task.status = doc.data['status'];
                             task.offeredBy = doc.data['offered_by'];
                             task.isCompleteByAuthor = doc.data['is_complete_by_author'];
                             task.isCompleteByProvider = doc.data['is_complete_by_provider'];
                             task.offerNum = doc.data['offer_num'];
                             task.rating = doc.data['rating'];
                             await FirebaseAuth.instance.currentUser().then((user) => {
                               Navigator.push(context, MaterialPageRoute(builder: (context) => MySingleTaskView(user: user, task: task,)))
                             });
                           });
                         },
                       ) : Container(),
                       (report.profileId != '') ? InkWell(
                         child: Text(report.profileId),
                         onTap: () async {
                           await Firestore.instance.collection('profile').document(report.profileId).get().then((doc) async {
                             Profile profile = new Profile.empty();
                             profile.id = doc.data["id"];
                             profile.name = doc.data["name"];
                             profile.email = doc.data["email"];
                             profile.about = doc.data["about"];
                             profile.achievement = doc.data["achievement"];
                             profile.services = doc.data["services"];
                             profile.profilepic = doc.data["profile_pic"];
                             Timestamp j = doc.data["joined"];
                             profile.joined = j.toDate().toString().substring(0, 10);
                             profile.posted = doc.data["task_posted"].toString();
                             profile.completed = doc.data["task_completed"].toString();
                             profile.reviewNum = doc.data["review_num"].toString();
                             profile.rating = doc.data["rating"].toString();
                             profile.gallery = doc.data["gallery"];
                             await FirebaseAuth.instance.currentUser().then((user) => {
                               Navigator.push(context, MaterialPageRoute(builder: (context) => ViewProfile(user: user, profile : profile)))
                             });
                           });

                         },
                       ) : Container(),
                       (report.taskId !='' ||report.profileId != '') ?SizedBox(height: 15,) : Container(),
                     ],
                   ),
                 ],
               ),
               Column(
                 crossAxisAlignment: CrossAxisAlignment.stretch,
                 children: [
                   Container(
                     padding: EdgeInsets.only(left: 5),
                     color: Colors.blueGrey,
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         SizedBox(height: 5,),
                         Text('Description' , style: _style, textAlign: TextAlign.center,) ,
                         SizedBox(height: 15,),
                       ],
                     ),
                   ),
                   Container(
                     padding: EdgeInsets.symmetric(horizontal: 10),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         SizedBox(height: 15,),
                         Text(report.description , textAlign: TextAlign.justify,),
                         SizedBox(height: 15,),
                       ],
                     ),
                   ),
                   (report.suggestion != '') ? Container(
                     padding: EdgeInsets.only(left: 5),
                     color: Colors.blueGrey,
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         SizedBox(height: 5,),
                         Text('Improvement' , style: _style,textAlign: TextAlign.center,) ,
                         SizedBox(height: 15,),
                       ],
                     ),
                   ) : Container() ,
                   (report.suggestion != '') ? Container(
                     padding: EdgeInsets.symmetric(horizontal: 10),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         SizedBox(height: 15,),
                         Text(report.suggestion, textAlign: TextAlign.justify),
                         SizedBox(height: 15,),
                       ],
                     ),
                   ) : Container(),
                 ],
               ),
             ],
         ),
          ),
        )
      ),
    );
  }
}















import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:testapp/models/Task.dart';
import 'package:testapp/services/NotificationService.dart';
import 'package:testapp/services/loadingDialog.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class WriteReview extends StatefulWidget {
  Task task;
  FirebaseUser user;
  bool ownTask;
  WriteReview({this.task, this.user, this.ownTask});
  _HomeState createState() => _HomeState(task,user,ownTask);
}

class _HomeState extends State<WriteReview> {
  Task task;
  FirebaseUser user;
  bool ownTask;

  _HomeState(this.task, this.user, this.ownTask);

  TextStyle _style = TextStyle(fontWeight: FontWeight.bold, color: Colors.white);
  final _formKey = GlobalKey<FormState>();
  final _keyLoader = GlobalKey<State>();
  double rating;

  TextEditingController _ratingInputController = new TextEditingController();
  TextEditingController _commentInputController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Text("Write Review"),
          elevation: 0.0,
          backgroundColor: Colors.amberAccent[400],
      ),
      body: WillPopScope(
        onWillPop: () =>
            showDialog<bool>(
              context: context,
              builder: (c) =>
                  AlertDialog(
                    title: Text('Warning'),
                    content: Text(
                        'Any changes made cannot be save. Exit "Review" ?'),
                    actions: [
                      FlatButton(
                        child: Text('Yes'),
                        onPressed: () =>
                        {
                          Navigator.pop(c, true),
                          Navigator.pop(context, true),
                        },
                      ),
                      FlatButton(
                        child: Text('No'),
                        onPressed: () => Navigator.pop(c, false),
                      ),
                    ],
                  ),
            ),
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 30, horizontal: 25),
            child: Column(
              children: <Widget>[
                Text("You are writing review for task : " , ),
                SizedBox(height: 20,),
                Text(" \" " + task.title + " \" " , style: TextStyle(fontWeight: FontWeight.bold , fontSize: 24 , color: Colors.blueGrey),),
                SizedBox(height: 5,),
                Text("[ id : " + task.id + " ]" , style: TextStyle(fontStyle: FontStyle.italic , fontSize: 12 , color: Colors.black54),),
                SizedBox(height: 20,),
                Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.disabled,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      RatingBar.builder(
                        initialRating: 0,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                        itemBuilder: (context, _) => Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {
                          this.rating = rating;
                          _ratingInputController.text = rating.toString() + ' out of 5.0';
                        },
                      ),
                      TextField(
                        controller: _ratingInputController,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontStyle : FontStyle.italic,
                          color: Colors.black54,
                        ),
                        decoration: new InputDecoration(
                          border: InputBorder.none,),
                        enabled: false,
                      ),
                      SizedBox(height: 20),
                      Text('Comment', ),
                      SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                        child: TextFormField(
                          textAlign: TextAlign.left,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: "Tell us more about your experience.",
                              hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14
                              )),
                          maxLength: 1000,
                          maxLines: null,
                          controller: _commentInputController,
                          textCapitalization: TextCapitalization.sentences,
                          validator: (value) =>
                          value.isEmpty
                              ? 'Please enter a comment'
                              : null,
                        ),
                      ),

                      SizedBox(width: 20),
                      FlatButton(
                        onPressed: () {
                          bool isValid = _formKey.currentState.validate();
                          if (isValid) {
                            showDialog<bool>(
                              context: context,
                              builder: (c) =>
                                  AlertDialog(
                                    title: Text('Alert'),
                                    content: Text(
                                        'Submit review? Changes cannot be made after submission.'),
                                    actions: [
                                      FlatButton(
                                        child: Text('Yes'),
                                        onPressed: () async =>
                                        {
                                          LoadingDialog.showLoadingDialog(context, _keyLoader, "Submitting"),
                                          await Firestore.instance.collection('review').add({
                                            'rating' : rating,
                                            'content' : _commentInputController.text,
                                            'reviewBy' : ownTask ? task.createdBy : task.offeredBy,
                                            'reviewTarget' : ownTask ? task.offeredBy : task.createdBy,
                                            'authorName' : user.displayName,
                                            'authorPicUrl' : user.photoUrl,
                                            'taskAssociated' : Firestore.instance.document('task/'+ task.id),
                                            'taskTitle' : task.title,
                                            'createdAt' : DateTime.now()
                                          }).then((value) async{
                                            if (ownTask){
                                              await Firestore.instance.collection('task').document(task.id).updateData({
                                                'reviewedByAuthor' : Firestore.instance.document('review/'+ value.documentID),
                                              });
                                              NotificationService.instance.generateNotification(6,task,task.offeredBy.documentID);
                                            }
                                            else{
                                              await Firestore.instance.collection('task').document(task.id).updateData({
                                                'reviewedByProvider' : Firestore.instance.document('review/'+ value.documentID),
                                              });
                                              NotificationService.instance.generateNotification(6,task,task.createdBy.documentID);
                                            }
                                          }).then((value) {
                                            Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
                                            Navigator.pop(context, true);
                                          })
                                        },
                                      ),
                                      FlatButton(
                                        child: Text('No'),
                                        onPressed: () =>
                                            Navigator.pop(c, false),
                                      ),
                                    ],
                                  ),
                            ).then((value) => Navigator.pop(context, true));
                          }
                        },
                        child: Text('Submit',
                          style: TextStyle(fontSize: 16,
                              color: Colors.black,
                              fontFamily: 'OpenSansR'),),
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0)),
                        color: Colors.amber,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


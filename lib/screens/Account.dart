import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_scaffold.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:testapp/models/Profile.dart';
import 'package:testapp/screens/BalanceAndPayout.dart';
import 'package:testapp/screens/TransactionHistory.dart';
import 'package:testapp/services/NotificationService.dart';
import 'CreateReport.dart';
import 'EditProfile.dart';
import 'Setup Stripe.dart';
import 'StartUp.dart';
import 'ViewProfile.dart';
import 'package:testapp/models/Task.dart';

class Account extends StatefulWidget {
  final FirebaseUser user;
  Account({this.user});
  _HomeState createState() => new _HomeState(user);
}

class _HomeState extends State<Account> {

  FirebaseUser user;
  _HomeState(this.user);
  Profile profile;
  String profilePic = '';
  TextStyle _style1 = TextStyle(fontFamily: 'OpenSans-R',fontWeight:FontWeight.bold,fontSize: 18);
  TextStyle _style2 = TextStyle(fontFamily: 'OpenSans-R',fontSize: 16);

  final _codeController = TextEditingController();
  String _code = '';

  Widget build(BuildContext context) {
    FirebaseAnalytics().setCurrentScreen(screenName: "AccountScreen");

    return Scaffold(
      appBar: AppBar(title : Text('Account'),
        centerTitle: true ,
        elevation: 0.0,
        backgroundColor: Colors.amberAccent[400],),
      body: SingleChildScrollView(
        child : StreamBuilder<DocumentSnapshot>(
            stream: Firestore.instance.collection('profile').document(user.uid).snapshots(),
            builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if(snapshot.hasData){
                profile = new Profile.AsyncDs(snapshot);
                profilePic = profile.profilepic;
                return getProfile(context);
              }
              else{
                return Container();
              }
            }
        ),
      )
    );
  }

  Widget getProfile(context){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(20),
          child: CircleAvatar (
            backgroundImage : (profile.profilepic!='') ? NetworkImage(profile.profilepic) : AssetImage("assets/profile-icon.png")
            ,radius: 70,
          ),
        ),
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text('Profile Settings',style : _style1,textAlign: TextAlign.left,)),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 5,
          margin: EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              ListTile(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => ViewProfile(user : user, profile : profile), settings: RouteSettings(name: "ProfileView")));
                },
                leading: Icon(Icons.contacts),
                title: Text("View Profile", style : _style2),
                trailing:Icon(Icons.arrow_forward),
              ),
              ListTile(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => EditProfile(user : user, profile : profile), settings: RouteSettings(name: "ProfileFormView")));
                },
                leading: Icon(Icons.settings),
                title: Text("Edit Profile", style : _style2),
                trailing: Icon(Icons.arrow_forward),
              ),
            ],
          ),
        ),
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text('Wallet',style : _style1,textAlign: TextAlign.left,)),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 5,
          margin: EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              ListTile(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => BalanceAndPayout(user : user), settings: RouteSettings(name: "BalanceAndPayoutView")));
                },
                leading: Icon(Icons.monetization_on),
                title: Text("Balance and Payout", style : _style2),
                trailing: Icon(Icons.arrow_forward),
              ),
              ListTile(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SetupStripe(user : user), settings: RouteSettings(name: "SetupStripeView")));
                },
                leading: Icon(Icons.account_balance_wallet),
                title: Text("Set Up Stripe", style : _style2),
                trailing: Icon(Icons.arrow_forward),
              ),
              // ListTile(
              //   onTap: (){
              //     Navigator.push(context, MaterialPageRoute(builder: (context) => SetupCard(user: user,)));
              //   },
              //   leading: Icon(Icons.credit_card),
              //   title: Text("Set Up Card", style : _style2),
              //   trailing: Icon(Icons.arrow_forward),
              // ),
              ListTile(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => TransactionHistory(user : user), settings: RouteSettings(name: "TransactionHistoryView")));
                },
                leading: Icon(Icons.history),
                title: Text("Transaction History", style : _style2),
                trailing: Icon(Icons.arrow_forward),
              ),
              // ListTile(
              //   onTap: (){
              //
              //   },
              //   leading: Icon(Icons.monetization_on),
              //   title: Text("Request a refund", style : _style2),
              //   trailing: Icon(Icons.arrow_forward),
              // ),
            ],
          ),
        ),
        SizedBox(height:10),
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text('Support',style : _style1,textAlign: TextAlign.left,)),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 5,
          margin: EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              ListTile(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CreateReport(user: user, category: null, taskId: null, profileId: null,), settings: RouteSettings(name: "ReportFormView")));
                },
                leading: Icon(Icons.report_problem),
                title: Text("Report an issue", style : _style2),
                trailing: Icon(Icons.arrow_forward),
              ),
              ListTile(
                onTap: () async {
                  String pdf = await loadFile('https://firebasestorage.googleapis.com/v0/b/taskpro-47370.appspot.com/o/Terms%20and%20Condition%2FTerms%20and%20Condition%20draft%20(1).pdf?alt=media&token=80fdb31d-dc18-43ff-b1d9-f2a2c8eff064');
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => viewPdf(pdf), settings: RouteSettings(name: "PDFView"))
                      );
                },
                leading: Icon(Icons.verified_user),
                title: Text("Terms and Conditions", style : _style2),
                trailing: Icon(Icons.arrow_forward),
              ),
            ],
          ),
        ),
        SizedBox(height:10),
        // Padding(
        //     padding: EdgeInsets.symmetric(horizontal: 20),
        //     child: Text('Notification Settings',style : _style1,textAlign: TextAlign.left,)),
        // SwitchListTile(
        //   activeColor: Colors.amberAccent[400],
        //   contentPadding: EdgeInsets.all(20),
        //   value: profile.notiEnaled,
        //   title: Text('Receive notification',style: TextStyle(color: Colors.grey[850])),
        //   onChanged: (val){
        //     profile.notiEnaled = val;
        //     Firestore.instance.collection("profile").document(user.uid).updateData({
        //       'notificationEnabled' : val,
        //     });
        //     if(val){
        //       Fluttertoast.showToast(
        //           msg: "Notification is Enabled",
        //           toastLength: Toast.LENGTH_SHORT,
        //           gravity: ToastGravity.BOTTOM,
        //           timeInSecForIosWeb: 1,
        //           backgroundColor: Colors.black54,
        //           textColor: Colors.white,
        //           fontSize: 16.0
        //       );
        //     }
        //     else{
        //       Fluttertoast.showToast(
        //           msg: "Notification is Disabled",
        //           toastLength: Toast.LENGTH_SHORT,
        //           gravity: ToastGravity.BOTTOM,
        //           timeInSecForIosWeb: 1,
        //           backgroundColor: Colors.black54,
        //           textColor: Colors.white,
        //           fontSize: 16.0
        //       );
        //     }
        //   },
        // ),
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text('Account Settings',style : _style1,textAlign: TextAlign.left,)),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 5,
          margin: EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              ListTile(
                onTap: (){
                  showDialog<bool>(
                    context: context,
                    useRootNavigator: false,
                    builder: (c) =>
                        AlertDialog(
                          title: Text('Alert'),
                          content: Text(
                              'Delete account? Action cannot be undone'),
                          actions: [
                            FlatButton(
                                child: Text('Cancel'),
                                onPressed: () {
                                  Navigator.of(c).pop();
                                }),
                            FlatButton(
                                child: Text('Delete'),
                                color: Colors.redAccent,
                                onPressed: () async{
                                  Navigator.of(c).pop();
                                  deleteUser();
                                })
                          ],
                        ),
                  );
                },
                leading: Icon(Icons.block),
                title: Text("Delete Account", style : _style2),
                trailing: Icon(Icons.arrow_forward),
              ),
              ListTile(
                onTap: () async{
                  await FirebaseAuth.instance.signOut().then((val){
                    Navigator.of(context).pop();
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => StartUp(), settings: RouteSettings(name: "StartUpView")),(route)=>false);
                  }).catchError((e){
                    print(e.toString());
                  });
                },
                leading: Icon(Icons.exit_to_app),
                title: Text("Log out", style : _style2),
                trailing: Icon(Icons.arrow_forward),
              ),
            ],
          ),
        )
      ],
    );
  }

  Future<String> loadFile(String url) async {
    final filename = 'taskpro.pdf';
    var request = await HttpClient().getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = new File('$dir/$filename');
    await file.writeAsBytes(bytes);
    print(file.path);
    return file.path;
  }

  Widget viewPdf (String pdfPath) {
    return PDFViewerScaffold(
        appBar: AppBar(
          title: Text("Terms and Condition"),
        ),
        path: pdfPath);
  }

  void deleteUser() async{

        //cancel all published task
        QuerySnapshot result = await Firestore.instance.collection('task')
            .where('created_by',
            isEqualTo: Firestore.instance.collection('users').document(user.uid))
            .where('status', whereIn: ['Ongoing', 'Open'])
            .getDocuments();
        result.documents.forEach((doc) {
          Firestore.instance.collection('task')
              .document(doc.documentID)
              .updateData({
            'status': 'Cancelled'
          });
        });

        //cancel ongoing tasks that is service provider
        QuerySnapshot spResult = await Firestore.instance.collection('task')
            .where('offered_by',
            isEqualTo: Firestore.instance.collection('users').document(user.uid))
            .where('status', whereIn: ['Ongoing', 'Open'])
            .getDocuments();
        spResult.documents.forEach((doc) {
          Task task = new Task();
          task.id = doc.documentID;
          task.offeredBy = doc.data['offered_by'];
          task.createdBy = doc.data['created_by'];
          Firestore.instance.collection('task')
              .document(doc.documentID)
              .updateData({
            'status': 'Cancelled'
          });

          Firestore.instance.collection('wallet').document(task.createdBy.documentID).collection('debit').document().setData(
            {
              'amount' : doc.data['fee'],
              'category' : 'Refund',
              'createdAt' : DateTime.now(),
              'payout' : false,
              'status' : 'Success',
              'taskRef' : Firestore.instance.collection('task').document(doc.documentID)
            }
          );

          NotificationService.instance.generateNotification(7, task, task.offeredBy.documentID);
        });

        //delete all offer
        QuerySnapshot offerResult = await Firestore.instance.collection('offer')
            .where('user_id', isEqualTo: user.uid)
            .getDocuments();
        offerResult.documents.forEach((doc) {
          Firestore.instance.document(doc.documentID).delete();
        });

        //delete all bookmark
        QuerySnapshot bmResult = await Firestore.instance.collection('bookmark')
            .where('user_id', isEqualTo: user.uid)
            .getDocuments();
        bmResult.documents.forEach((doc) {
          Firestore.instance.document(doc.documentID).delete();
        });

        Firestore.instance.collection('users').document(user.uid).delete().then((value) {
        user.delete();
        Firestore.instance.collection('profile').document(user.uid).delete();
      }).then((value) {
        Fluttertoast.showToast(
            msg: "Account Deleted.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black54,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }).whenComplete(() {
        Navigator.of(context).pop();
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => StartUp(), settings: RouteSettings(name: "StartUpView")));
      });
    // });
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_scaffold.dart';
import 'package:testapp/models/Profile.dart';
import 'package:testapp/screens/BalanceAndPayout.dart';
import 'CreateReport.dart';
import 'EditProfile.dart';
import 'Setup Stripe.dart';
import 'SetupCard.dart';
import 'StartUp.dart';
import 'ViewProfile.dart';

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


  Widget build(BuildContext context) {

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
                profile = new Profile(snapshot);
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
                      builder: (context) => ViewProfile(user : user, profile : profile)));
                },
                leading: Icon(Icons.contacts),
                title: Text("View Profile", style : _style2),
                trailing:Icon(Icons.arrow_forward),
              ),
              ListTile(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => EditProfile(user : user, profile : profile)));
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
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SetupStripe(user : user)));
                },
                leading: Icon(Icons.account_balance_wallet),
                title: Text("Set Up Stripe", style : _style2),
                trailing: Icon(Icons.arrow_forward),
              ),
              ListTile(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SetupCard(user: user,)));
                },
                leading: Icon(Icons.credit_card),
                title: Text("Set Up Card", style : _style2),
                trailing: Icon(Icons.arrow_forward),
              ),
              ListTile(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => BalanceAndPayout(user : user)));
                },
                leading: Icon(Icons.monetization_on),
                title: Text("Balance and Payout", style : _style2),
                trailing: Icon(Icons.arrow_forward),
              ),
              ListTile(
                onTap: (){

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
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CreateReport(user: user, category: null, taskId: null, profileId: null,)));
                },
                leading: Icon(Icons.report_problem),
                title: Text("Report an issue", style : _style2),
                trailing: Icon(Icons.arrow_forward),
              ),
              ListTile(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => viewTnc('https://firebasestorage.googleapis.com/v0/b/taskpro-47370.appspot.com/o/Terms%20and%20Condition%2FTerms%20and%20Condition%20draft.pdf?alt=media&token=a212132e-bac1-442c-b677-ff7e0f8807d1')));
                },
                leading: Icon(Icons.verified_user),
                title: Text("Terms and Conditions", style : _style2),
                trailing: Icon(Icons.arrow_forward),
              ),
            ],
          ),
        ),
        SizedBox(height:10),
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text('Notification Settings',style : _style1,textAlign: TextAlign.left,)),
        SwitchListTile(
          activeColor: Colors.amberAccent[400],
          contentPadding: EdgeInsets.all(20),
          value: true,
          title: Text('Receive notification',style: TextStyle(color: Colors.grey[850])),
          onChanged: (val){

          },
        ),
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

                },
                leading: Icon(Icons.phone_android),
                title: Text("Change Phone Number", style : _style2),
                trailing:Icon(Icons.arrow_forward),
              ),
              ListTile(
                onTap: (){

                },
                leading: Icon(Icons.block),
                title: Text("Delete Account", style : _style2),
                trailing: Icon(Icons.arrow_forward),
              ),
              ListTile(
                onTap: () async{
                  await FirebaseAuth.instance.signOut().then((val){
                    Navigator.of(context).pop();
                    Navigator.push(context, MaterialPageRoute(builder: (context) => StartUp()));
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
  Widget viewTnc (String pdfPath) {
    return PDFViewerScaffold(
        appBar: AppBar(
          title: Text("Terms and Condition"),
        ),
        path: pdfPath);
  }
}
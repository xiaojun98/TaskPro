import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SetupStripe extends StatefulWidget {
  FirebaseUser user;
  SetupStripe({this.user});
  _HomeState createState() => _HomeState(user);

}

class _HomeState extends State<SetupStripe> {
  FirebaseUser user;
  _HomeState(this.user);

  int balance = 0;
  TextStyle _style1 = TextStyle(fontFamily: 'OpenSans-R',fontWeight:FontWeight.bold,fontSize: 18);
  TextStyle _style2 = TextStyle(fontFamily: 'OpenSans-R',fontSize: 18,color: Colors.white);
  bool hasStripeAcc;
  bool linkedStripeOnboard;
  String stripeAccId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar : AppBar(
          centerTitle: true,
          title : Text("Setup Stripe"),
          elevation: 0.0,
          backgroundColor: Colors.amberAccent[400],
        ),
        body: SingleChildScrollView(
          child: StreamBuilder(
            stream: Firestore.instance
                .collection('wallet')
                .document(user.uid)
                .snapshots(),
            builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if(!snapshot.hasData) {
                return Text("No Data");
              } else {
                hasStripeAcc = snapshot.data['stripe_account'] == null ? false : true ;
                linkedStripeOnboard = snapshot.data['stripe_onboard'] == null ? false : true ;
                stripeAccId = snapshot.data['stripe_acc_id'];
              }
              return buildContext(context);
            },
          ),
        )
    );
  }

  Widget buildContext(context){
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children : [
          Center(
            child: Container(
              height: 100,
                child: Image.asset("assets/stripe.png")),
          ),
          Container(color: Colors.blueGrey, height: 1.5,),
          SizedBox(height: 15,),
          Text("Follow the following steps to set up an Stripe account to become a service provider! You can only provide service and check out your task fees only if you have a Stripe Account." , textAlign: TextAlign.justify,),
          SizedBox(height: 15,),
          Container(color: Colors.blueGrey, height: 1.5,),
          SizedBox(height: 15,),
          Text("Step 1", style : _style1),
          SizedBox(height: 5,),
          Text("Initiate a Stripe account for your current TaskPro account." , textAlign: TextAlign.justify, ),
          SizedBox(height: 15,),
          hasStripeAcc ?
          Container(
            height: 50,
            decoration: BoxDecoration(color : Colors.teal, borderRadius: BorderRadius.circular(5),boxShadow: [
              BoxShadow(
              color: Colors.grey,
              spreadRadius: 0.1,
              blurRadius: 1,
              offset: Offset(0, 1), // changes position of shadow
            ),]),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 Row(
                   children: [
                     SizedBox(width: 20,),
                     Icon(Icons.check_circle, color: Colors.white,),
                     SizedBox(width: 20,),
                     Text("Stripe Account Created.", style: _style2),
                   ],
                 )
               ],
            ),
          ) :
          Container(
            child: FlatButton(
              child: Text("Create Stripe Account", style: TextStyle(color: Colors.white),),
              color: Colors.blueGrey,
              onPressed: (){
                // var callable = CloudFunctions.instance.getHttpsCallable(functionName: 'createStripeAcc');
                // callable.call(<String, dynamic>{
                //   'userId': user.uid,
                // },).catchError((e){
                //   print(e.toString());
                // });
              },
          ),),
          SizedBox(height: 15,),
          Text("Step 2", style : _style1),
          SizedBox(height: 5,),
          Text("Connect your account to our TaskPro merchant to enable receiving payouts or refund. Fill up the form and you will be ready to go.", textAlign: TextAlign.justify,),
          SizedBox(height: 15,),
          linkedStripeOnboard ?
          Container(
            height: 50,
            decoration: BoxDecoration(color : Colors.teal, borderRadius: BorderRadius.circular(5),boxShadow: [
              BoxShadow(
                color: Colors.grey,
                spreadRadius: 0.1,
                blurRadius: 1,
                offset: Offset(0, 1), // changes position of shadow
              ),]),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    SizedBox(width: 20,),
                    Icon(Icons.check_circle, color: Colors.white,),
                    SizedBox(width: 20,),
                    Text("Connect-Onboard is Linked.", style: _style2),
                  ],
                )
              ],
            ),
          ) :
          Container(
            child: FlatButton(
              child: Text("Link Connect-Onboard" ,style: TextStyle(color: Colors.white)),
              color: Colors.blueGrey,
              onPressed: (){
                // var callable = CloudFunctions.instance.getHttpsCallable(functionName: 'createOnboardLink');
                // callable.call(<String, dynamic>{
                //   'userId': user.uid,
                // },).catchError((e){
                //   print(e.toString());
                // });
              },
            ),),
        ],
      ),
    );
  }
}















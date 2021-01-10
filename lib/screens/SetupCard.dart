import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:testapp/services/stripeService.dart';

class SetupCard extends StatefulWidget {
  final FirebaseUser user;
  SetupCard({this.user});
  _HomeState createState() => new _HomeState(user);
}

class _HomeState extends State<SetupCard> {
  FirebaseUser user;
  _HomeState(this.user);
  String profilePic = '';
  TextStyle _style = TextStyle(fontFamily: 'OpenSans-R',fontSize: 16);

  void initState(){
    super.initState();
    StripeService.init();
  }

  Widget build(BuildContext context) {
    FirebaseAnalytics().setCurrentScreen(screenName: "SetupCardScreen");

    return Scaffold(
        appBar: AppBar(title : Text('Set Up Card'),
          centerTitle: true ,
          elevation: 0.0,
          backgroundColor: Colors.amberAccent[400],),
        body: SingleChildScrollView(
          child : ListTile(
            onTap: (){
              //
            },
            leading: Icon(Icons.credit_card),
            title: Text("Add a new card", style : _style),
          ),
        )
    );
  }

  // Widget build(BuildContext context) {
  //
  //   return Scaffold(
  //       appBar: AppBar(title : Text('Set Up Card'),
  //         centerTitle: true ,
  //         elevation: 0.0,
  //         backgroundColor: Colors.amberAccent[400],),
  //       body: SingleChildScrollView(
  //         child : StreamBuilder<DocumentSnapshot>(
  //             stream: Firestore.instance.collection('cards').document(user.uid).snapshots(),
  //             builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
  //               if(snapshot.hasData){
  //
  //                 return getCard(context);
  //               }
  //               else{
  //                 return ListTile(
  //                   onTap: (){
  //                     StripePayment.paymentRequestWithCardForm(CardFormPaymentRequest()).then((paymentMethod) {
  //                       // _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Received ${paymentMethod.id}')));
  //                       // setState(() {
  //                       //   _paymentMethod = paymentMethod;
  //                       // });
  //                       print('Payment Method ************ ' + paymentMethod.id);
  //                     });
  //                   },
  //                   leading: Icon(Icons.contacts),
  //                   title: Text("Add a new card", style : _style),
  //                   trailing:Icon(Icons.arrow_forward),
  //                 );
  //               }
  //             }
  //         ),
  //       )
  //   );
  // }
  //
  // Widget getCard(context){
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: <Widget>[
  //
  //       Card(
  //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  //         elevation: 5,
  //         margin: EdgeInsets.all(20),
  //         child: Column(
  //           children: <Widget>[
  //             ListTile(
  //               onTap: (){
  //                 StripePayment.paymentRequestWithCardForm(CardFormPaymentRequest()).then((paymentMethod) {
  //                   // _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Received ${paymentMethod.id}')));
  //                   // setState(() {
  //                   //   _paymentMethod = paymentMethod;
  //                   // });
  //                   print('Payment Method ************ ' + paymentMethod.id);
  //                 });
  //               },
  //               leading: Icon(Icons.contacts),
  //               title: Text("Add a new card", style : _style),
  //               trailing:Icon(Icons.arrow_forward),
  //             ),
  //
  //             ListView.builder(
  //                 itemBuilder: null)
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }
}
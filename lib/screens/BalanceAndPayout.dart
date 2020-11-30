import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:testapp/models/transaction.dart';
import 'package:testapp/screens/Setup%20Stripe.dart';
import 'package:testapp/services/loadingDialog.dart';

class BalanceAndPayout extends StatefulWidget {
  FirebaseUser user;
  BalanceAndPayout({this.user});
  _HomeState createState() => _HomeState(user);

}

class _HomeState extends State<BalanceAndPayout> {
  FirebaseUser user;
  _HomeState(this.user);

  final _keyLoader = GlobalKey<State>();
  List<Payout> debitList = [];
  List<Payout> historyList = [];
  double balance = 0.00;
  TextStyle _style1 = TextStyle(fontFamily: 'OpenSans-R',fontWeight:FontWeight.bold,fontSize: 18);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar : AppBar(
        centerTitle: true,
        title : Text("Balance And Payout"),
        elevation: 0.0,
        backgroundColor: Colors.amberAccent[400],
      ),
      body: SingleChildScrollView(
          child: StreamBuilder<DocumentSnapshot>(
              stream: Firestore.instance.collection('wallet').document(user.uid).snapshots(),
              builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                if(snapshot.data['stripe_onboard']==true){
                  return StreamBuilder(
                  stream: Firestore.instance
                      .collection('wallet')
                      .document(user.uid)
                      .collection('debit')
                      .where('category', isEqualTo: "Debit")
                      .snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if(!snapshot.hasData) {
                    return Text("No Data");
                  } else {
                    for (DocumentSnapshot doc in snapshot.data.documents) {
                      Payout debit = new Payout();
                      debit.id = doc.documentID;
                      debit.amount = double.parse(doc.data['amount'].toString());
                      debit.createdAt = doc.data['createdAt']?.toDate();
                      debit.payout = doc.data['payout'];
                      debit.taskRef = doc.data['taskRef'];
                      debitList.add(debit);
                      balance += debit.amount;
                    }
                  }
                  return StreamBuilder(
                    stream: Firestore.instance
                        .collection('wallet')
                        .document(user.uid)
                        .collection('debit')
                        .where('category', isEqualTo: "Payout")
                        .snapshots(),
                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {

                      if(!snapshot.hasData) {
                        return Center(
                            child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)));
                      } else {
                        for (DocumentSnapshot doc in snapshot.data.documents) {
                          Payout history = new Payout();
                          history.id = doc.documentID;
                          history.amount = double.parse(doc.data['amount'].toString())* -1.0;
                          history.createdAt = doc.data['createdAt']?.toDate();
                          history.status = doc.data['status'];
                          historyList.add(history);
                          balance -= history.amount;
                        }
                        return buildContext(context);
                      }
                    },
                  );
                  // return buildContext(context);
                  },);
                }
                else{
                  return Container(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('You have not set up your Stripe. Go to set up Stripe to enable payouts.'),
                        SizedBox(height: 20,),
                        FlatButton(
                          child: Text("Setup Stripe", style: TextStyle(color: Colors.white),),
                          color: Colors.blueGrey,
                          onPressed: (){
                            Navigator.pop(context);
                            Navigator.push(context, MaterialPageRoute(builder: (context) => SetupStripe(user : user)));
                          },
                        ),
                      ],
                    ),
                  );
                }
              }
          )
      ));
  }

  Widget buildContext(context){
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children : [
          Text("My Debit Balance", style: _style1,),
          SizedBox(height: 10,),
          Container(
              height: 100,
              width: 300,
              alignment: Alignment.center,
              decoration: BoxDecoration(border: Border.all(color: Colors.white), borderRadius: BorderRadius.circular(5), color: Colors.white,boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  spreadRadius: 0.1,
                  blurRadius: 1,
                  offset: Offset(0, 1), // changes position of shadow
                ),
              ],),
              child: Text('RM ' + balance.toString(), style: TextStyle(fontFamily: 'OpenSans-R',fontWeight:FontWeight.w100,fontSize: 35),)
          ),
          SizedBox(height: 30,),
          balance == 0 ? RaisedButton(
              child: Text("Payout Now"),
              color: Colors.amber,
              onPressed: (){
                Fluttertoast.showToast(
                    msg: "RM0.00 : No payouts available.",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.black54,
                    textColor: Colors.white,
                    fontSize: 16.0
                );
              }
          ) :RaisedButton(
              child: Text("Payout Now"),
              color: Colors.amber,
              onPressed: (){
                LoadingDialog.showLoadingDialog(context, _keyLoader, "Payout to Stripe..");
                withdraw();
              }
          ),
          SizedBox(height: 30,),
          Text("Payout History" , style: _style1,),
          ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.all(10.0),
            itemBuilder: (context, index) => buildItem(historyList[index]),
            itemCount: historyList.length,
            reverse: true,
          ),
        ],
      ),
    );
  }

  void withdraw() async{
    await Firestore.instance.collection('wallet').document(user.uid).get().then((stripeAcc) {
      var callable = CloudFunctions.instance.getHttpsCallable(functionName: 'createTransfer');
      callable.call(<String, dynamic>{
        'userId' : user.uid,
        'stripe_acc_id': stripeAcc.data['stripe_acc_id'],
        'amount' : (balance*100).toInt().toString(),
      },).then((value) {
        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
      }).catchError((e){
        print(e.toString());
      });
      // acc.stripeAcc = value.data['stripe_acc_id'];
    });

  }

  Widget buildItem(Payout item){
    return Card(
    child: ListTile(
      title: Text('Withdrew RM' + item.amount.toString()),
      subtitle: Text('Status : ' + item.status),
      trailing: Text(DateFormat.MMMMd().format(item.createdAt)),
    ),
    );
  }
}

















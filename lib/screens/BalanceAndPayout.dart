import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BalanceAndPayout extends StatefulWidget {
  FirebaseUser user;
  BalanceAndPayout({this.user});
  _HomeState createState() => _HomeState(user);

}

class _HomeState extends State<BalanceAndPayout> {
  FirebaseUser user;
  _HomeState(this.user);

  List<Payout> debitList = [];
  int balance = 0;
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
          child: StreamBuilder(
              stream: Firestore.instance
                  .collection('wallet')
                  .document(user.uid)
                  .collection('debit')
                  .where('category', isEqualTo: "debit")
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if(!snapshot.hasData) {
                  return Text("No Data");
                } else {
                  for (DocumentSnapshot doc in snapshot.data.documents) {
                    Payout debit = new Payout();
                    debit.id = doc.documentID;
                    debit.amount = doc.data['amount'];
                    debit.debitCreatedAt = doc.data['debitCreatedAt']?.toDate();
                    debit.payout = doc.data['payout'];
                    debit.taskRef = doc.data['taskRef'];
                    debitList.add(debit);
                    balance += debit.amount;
                  }
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
        children : [
          Text("Debit Balance", style: _style1,),
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
          RaisedButton(
              child: Text("Withdraw Now"),
              color: Colors.amber,
              onPressed: (){

              }
          ),
          SizedBox(height: 30,),
          Text("Payout History" , style: _style1,),
          StreamBuilder(
            stream: Firestore.instance
                .collection('wallet')
                .document(user.uid)
                .collection('debit')
                .where('category', isEqualTo: "payout")
                .snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {

              if(!snapshot.hasData) {
                return Center(
                    child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)));
              } else {
                List<Payout> historyList = [];
                for (DocumentSnapshot doc in snapshot.data.documents) {
                  Payout history = new Payout();
                  history.id = doc.documentID;
                  history.amount = doc.data['amount']*-1;
                  history.payoutCreatedAt = doc.data['payoutCreatedAt']?.toDate();
                  history.status = doc.data['status'];
                  historyList.add(history);
                }
                return ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.all(10.0),
                  itemBuilder: (context, index) => buildItem(historyList[index]),
                  itemCount: snapshot.data.documents.length,
                  reverse: true,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget buildItem(Payout item){
    return Card(
    child: ListTile(
      title: Text('Withdrew RM' + item.amount.toString()),
      subtitle: Text('Status : ' + item.status),
      trailing: Text(DateFormat.MMMMd().format(item.payoutCreatedAt)),
    ),
    );
  }
}

class Payout{
  String id;
  int amount;
  DateTime debitCreatedAt;
  DateTime payoutCreatedAt;
  Object taskRef;
  bool payout;
  String status;
}















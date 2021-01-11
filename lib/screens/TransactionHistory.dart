import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:testapp/models/transaction.dart';

class TransactionHistory extends StatefulWidget {
  FirebaseUser user;
  TransactionHistory({this.user});
  _HomeState createState() => _HomeState(user);

}

class _HomeState extends State<TransactionHistory> {
  FirebaseUser user;
  _HomeState(this.user);

  List<HistoryItem> historyList = [];

  TextStyle _style1 = TextStyle(fontFamily: 'OpenSans-R',fontWeight:FontWeight.bold,fontSize: 18);
  TextStyle _style2 = TextStyle(fontFamily: 'OpenSans-R',fontSize: 18,color: Colors.white);


  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics().setCurrentScreen(screenName: "TransactionHistoryScreen");
    return Scaffold(
        appBar : AppBar(
          centerTitle: true,
          title : Text("Transaction History"),
          elevation: 0.0,
          backgroundColor: Colors.amberAccent[400],
        ),
        body: SingleChildScrollView(
          child: StreamBuilder(
            stream: Firestore.instance
                .collection('wallet')
                .document(user.uid)
                .collection('credit')
                .where('status', whereIn: ['Hold','Success'])
                .snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if(!snapshot.hasData) {
                return Text("No Data");
              } else {
                for (DocumentSnapshot doc in snapshot.data.documents) {
                  HistoryItem item = new HistoryItem();
                  item.category = 'Credit';
                  item.amount = double.parse(doc.data['amount'].toString());
                  item.dateTime = doc.data['createdAt']?.toDate();
                  item.status = doc.data['status'];
                  historyList.add(item);
                }
              }
              return StreamBuilder(
                stream: Firestore.instance
                    .collection('wallet')
                    .document(user.uid)
                    .collection('debit')
                    .where('category', whereIn: ['Debit','Payout','Refund'] )
                    .snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if(!snapshot.hasData) {
                      return Text("No Data");
                    } else {
                      for (DocumentSnapshot doc in snapshot.data.documents) {
                        HistoryItem item = new HistoryItem();
                        item.category = doc.data['category'];
                        item.amount = double.parse(doc.data['amount'].toString());
                        item.dateTime = doc.data['createdAt']?.toDate();
                        item.status = doc.data['status'];
                        historyList.add(item);
                      }
                    }
                    historyList.sort((a,b) => b.dateTime.compareTo(a.dateTime));
                    return buildContext(context);});
              // return buildContext(context);
            },
          ),
        )
    );
  }

  Widget buildContext(context){
    return Container(
      height: 700,
      child: ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
          itemCount: historyList.length,
          itemBuilder: (context,index){
            return Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              child: ListTile(
                onTap: () {


                },
                title: Text('${historyList[index].category}' + ' : RM ' + '${historyList[index].amount}',),
                subtitle: Text('${historyList[index].status}',),
                trailing: Text(DateFormat.MMMMd().format(historyList[index].dateTime),),
                // trailing: ,
              ),
            );
          }
      ),
    );
  }


}















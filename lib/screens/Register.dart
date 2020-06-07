import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'MainPage.dart';
import 'MainNavigation.dart';

void main() => runApp(MaterialApp(
  home : Register(),
)
)
;

class Register extends StatefulWidget{
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Register> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title : Text('TaskPro'),
        centerTitle: true ,
        elevation: 0.0,
        backgroundColor: Colors.amberAccent[400],),
      body: Center(
        child : Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.fromLTRB(30,50,30,10),
              child: Column(
                children: <Widget>[
                  Text("Register an Account",
                    style: TextStyle(fontSize: 25,fontWeight:FontWeight.bold,fontFamily: 'OpenSansR'),
                    textAlign: TextAlign.center,
                  ),
                  Text("Don't have an account? Register now.",
                    style: TextStyle(fontSize: 16,fontFamily: 'OpenSans-R'),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Expanded(
              flex : 4,
              child: Container(
                margin: EdgeInsets.symmetric(vertical : 10,horizontal: 30),
                padding : EdgeInsets.symmetric(vertical : 20,horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    TextField(
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                          prefixIcon : Icon(Icons.account_box),
                          border: OutlineInputBorder(),
                          hintText: "Enter your full name",
                          hintStyle: TextStyle(
                            color :Colors.grey,
                            fontSize: 12
                            )
                        ) ,
                    ),
                    TextField(
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                          prefixIcon : Icon(Icons.phone_android),
                          border: OutlineInputBorder(),
                          hintText: "Enter your mobile Number",
                          hintStyle: TextStyle(
                              color :Colors.grey,
                              fontSize: 12
                          )
                      ),
                    ),
                    TextField(
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                          prefixIcon : Icon(Icons.email),
                          border: OutlineInputBorder(),
                          hintText: "Enter your email",
                          hintStyle: TextStyle(
                              color :Colors.grey,
                              fontSize: 12
                          )
                      ),
                    ),
                    TextField(
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                          prefixIcon : Icon(Icons.card_membership),
                          border: OutlineInputBorder(),
                          hintText: "Enter your IC / Passport number",
                          hintStyle: TextStyle(
                              color :Colors.grey,
                              fontSize: 12
                          )
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        OutlineButton(
                          onPressed: (){
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => MainNavigation()));
                          },
                          child: Text ('Register',
                            style: TextStyle(fontSize: 18,color: Colors.amberAccent[400],fontFamily: 'OpenSansR'),),
                          shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                        ),
                        OutlineButton(
                          onPressed: (){
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => MainPage()));
                          },
                          child: Text ('Cancel',
                            style: TextStyle(fontSize: 18,color: Colors.amberAccent[400],fontFamily: 'OpenSansR'),),
                          shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
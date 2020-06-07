import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:testapp/screens/MainNavigation.dart';

void main() => runApp(MaterialApp(
  home : Login(),
)
)
;

class Login extends StatefulWidget{
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title : Text('TaskPro'),
          centerTitle: true ,
          elevation: 0.0,
          backgroundColor: Colors.amberAccent[400],),
        body: Center(
          child : Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top : 50, bottom: 20) ,
                child: CircleAvatar (backgroundImage : AssetImage('assets/Mobile-Phone-icon.png'),radius: 80,),
              ),
              Container(
                  margin: EdgeInsets.fromLTRB(50, 20, 50, 10),
                  child: Text("Login with Mobile Number",
                    style: TextStyle(fontSize: 25,fontWeight:FontWeight.bold,fontFamily: 'OpenSansR'),
                    textAlign: TextAlign.center,
                  )
              ),
              Container(
                  margin: EdgeInsets.fromLTRB(50, 5, 50, 10),
                  child: Text("Enter your mobile number to receive an OTP for login.",
                    style: TextStyle(fontSize: 16,fontFamily: 'OpenSans-R'),
                    textAlign: TextAlign.center,
                  )
              ),
              Container(
                  margin: EdgeInsets.fromLTRB( 50, 5, 50, 10),
                  child : TextField(
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                        hintText: "Mobile number",
                        hintStyle: TextStyle(
                            color :Colors.grey,
                            fontSize: 12
                        )
                    ),
                  )
              ),
              OutlineButton(
                onPressed: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MainNavigation()));
                },
                child: Text ('Login',
                  style: TextStyle(fontSize: 18,color: Colors.amberAccent[400],fontFamily: 'OpenSansR'),),
                shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
              ),
            ],
          ),
        ),
    );
  }

}
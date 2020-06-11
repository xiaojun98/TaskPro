import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:testapp/screens/MainNavigation.dart';
import 'package:testapp/screens/Register.dart';
import 'package:testapp/services/loadingDialog.dart';


class Login extends StatefulWidget{
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Login> {
  final _codeController = TextEditingController();
  final _phnumController = TextEditingController();
  String _code = '';
  final _keyLoader = GlobalKey<State>();
  final db = Firestore.instance;
  final _formKey = GlobalKey<FormState>();

  Future <bool> loginUser(String phnum, BuildContext context) async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    _auth.verifyPhoneNumber(
        phoneNumber: phnum,
        timeout: Duration(seconds: 0),
        //0 to disable auto-retrieval of code
        //verificationCompleted only occure if auto-retrieval
        verificationCompleted: null,
        verificationFailed: (AuthException exp) {
          print("verification failed : " + exp.message);
        },
        codeSent: (String verfId, [int forceResend]) {
          print("code sent : $verfId");
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
                  title: Text("Please enter the verification code : "),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextField(
                        controller: _codeController,
                        keyboardType: TextInputType.number,
                        onChanged: (val) {
                          setState(() => _code = val);
                        },
                      )
                    ],
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('Confirm'),
                      color: Colors.amber[400],
                      onPressed: () async {
                        AuthCredential credential = PhoneAuthProvider
                            .getCredential(
                            verificationId: verfId, smsCode: _code);
                        FirebaseUser user;
                        AuthResult result = await _auth.signInWithCredential(credential).catchError((e){
                          showDialog(child: Text(e.toString()));
                        });
                        user = result.user;

                        if (user != null) {
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => MainNavigation(user: user)
                          ));
                        }
                        else {
                          print("User null");
                        }
                      },
                    )
                  ],
                );
              }
          );
        },
        codeAutoRetrievalTimeout: null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('TaskPro'),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Colors.amberAccent[400],),
      body: SingleChildScrollView(
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 50, bottom: 20),
                  child: CircleAvatar(
                    backgroundImage: AssetImage('assets/Mobile-Phone-icon.png'),
                    radius: 80,),
                ),
                Container(
                    margin: EdgeInsets.fromLTRB(50, 20, 50, 10),
                    child: Text("Login with Mobile Number",
                      style: TextStyle(fontSize: 25,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'OpenSansR'),
                      textAlign: TextAlign.center,
                    )
                ),
                Container(
                    margin: EdgeInsets.fromLTRB(50, 5, 50, 10),
                    child: Text(
                      "Enter your mobile number to receive an OTP for login.",
                      style: TextStyle(fontSize: 16, fontFamily: 'OpenSans-R'),
                      textAlign: TextAlign.center,
                    )
                ),
                Container(
                    margin: EdgeInsets.fromLTRB(50, 5, 50, 10),
                    child: TextFormField(
                      controller: _phnumController,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                          hintText: "Mobile number",
                          hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 12
                          )
                      ),
                    )
                ),
                OutlineButton(
                  onPressed: () async {
                    final _phnum = _phnumController.text.trim();
                    QuerySnapshot result = await Firestore.instance
                        .collection('users')
                        .where('ph_num', isEqualTo: _phnum)
                        .limit(1)
                        .getDocuments();
                    List <DocumentSnapshot> documents = result.documents;
                    if (documents.length == 1) {
                      loginUser(_phnum, context);
                      print('login user complete. $_phnum');
                    }
                    else {
                      print('user not found.');
                      showDialog(context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text(
                                  "The number is not registered. Please proceed to register."),
                              actions: <Widget>[
                                FlatButton(
                                    child: Text('Register'),
                                    color: Colors.amber[400],
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Register()));
                                    })
                              ],
                            );
                          });
                    }
                  },
                  child: Text('Login',
                    style: TextStyle(fontSize: 18,
                        color: Colors.amberAccent[400],
                        fontFamily: 'OpenSansR'),),
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
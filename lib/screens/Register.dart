import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'Login.dart';
import 'MainPage.dart';
import 'MainNavigation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class Register extends StatefulWidget{
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Register> {

  final _codeController = TextEditingController();
  final db = Firestore.instance;
  String _code = '';
  String _uid = '';


  Future <bool> registerUser(String name, String phnum, String email,
      String idnum, BuildContext context) async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    _auth.verifyPhoneNumber(
        phoneNumber: phnum,
        timeout: Duration(seconds: 0),
        //0 to disable auto-retrieval of code
        verificationCompleted: (AuthCredential credential) async {
          Navigator.of(context).pop();
          AuthResult result = await _auth.signInWithCredential(credential);
          FirebaseUser user = result.user;
          _uid = user.uid;
          if (user != null) {
            Navigator.push(context, MaterialPageRoute(
                builder: (context) => MainNavigation(user: user)
            ));
          }
        },
        verificationFailed: (AuthException exp) {
          print(exp);
        },
        codeSent: (String verfId, [int forceResend]) {
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
                        AuthResult result = await _auth.signInWithCredential(
                            credential);
                        FirebaseUser user = result.user;
                        _uid = user.uid;
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

  final _nameController = TextEditingController();
  final _phnumController = TextEditingController();
  final _emailController = TextEditingController();
  final _idnumController = TextEditingController();

  String _name = '';
  String _phnum = '';
  String _email = '';
  String _idnum = '';

  final _formKey = GlobalKey<FormState>();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('TaskPro'),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Colors.amberAccent[400],),
      body: Center(
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.fromLTRB(30, 50, 30, 10),
              child: Column(
                children: <Widget>[
                  Text("Register an Account",
                    style: TextStyle(fontSize: 25,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'OpenSansR'),
                    textAlign: TextAlign.center,
                  ),
                  Text("Don't have an account? Register now.",
                    style: TextStyle(fontSize: 16, fontFamily: 'OpenSans-R'),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      TextFormField(
                        controller: _nameController,
                        //validate input in client side
                        validator: (val) =>
                        val.isEmpty
                            ? 'Enter your full name'
                            : null,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                            prefixIcon: Icon(Icons.account_box),
                            border: OutlineInputBorder(),
                            hintText: "Enter your full name",
                            hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 12
                            )
                        ),
                        onChanged: (val) {
                          setState(() => _name = val);
                        },
                      ),
                      TextFormField(
                        controller: _phnumController,
                        //validate input in client side
                        validator: (val) =>
                        !(val.length > 11)
                            ? 'Enter valid mobile number (eg : +60101234567)'
                            : null,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                            prefixIcon: Icon(Icons.phone_android),
                            border: OutlineInputBorder(),
                            hintText: "Enter your mobile number",
                            hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 12
                            )
                        ),
                        onChanged: (val) {
                          setState(() => _phnum = val);
                        },
                      ),
                      TextFormField(
                        controller: _emailController,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) {
                          Pattern pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                          RegExp regex = new RegExp(pattern);
                          if (!regex.hasMatch(val))
                            return 'Enter a valid email';
                          else
                            return null;
                        },
                        decoration: InputDecoration(
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(),
                            hintText: "Enter your email",
                            hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 12
                            )
                        ),
                        onChanged: (val) {
                          setState(() => _email = val);
                        },
                      ),
                      TextFormField(
                        controller: _idnumController,
                        textAlign: TextAlign.center,
                        validator: (val) =>
                        !(val.length == 9 || val.length <= 12)
                            ? 'Enter a valid IC/Passport number.'
                            : null,
                        decoration: InputDecoration(
                            prefixIcon: Icon(Icons.card_membership),
                            border: OutlineInputBorder(),
                            hintText: "Enter your IC / Passport number without '-' symbol.",
                            hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 12
                            )
                        ),
                        onChanged: (val) {
                          setState(() => _idnum = val);
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          OutlineButton(
                            onPressed: () async {
                              //validate all form text field
                              if (_formKey.currentState.validate()) {
                                //check if exists
                                final QuerySnapshot result = await Firestore
                                    .instance.collection('users').where(
                                    'ph_num', isEqualTo: _phnum)
                                    .limit(1)
                                    .getDocuments();
                                final List <DocumentSnapshot> documents = result.documents;
                                if (documents.length == 1) {
                                  print('user exists.');
                                  showDialog(context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text(
                                              "The number is registered. Please proceed to login."),
                                          actions: <Widget>[
                                            FlatButton(
                                                child: Text('Login'),
                                                color: Colors.amber[400],
                                                onPressed: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              Login()));
                                                })
                                          ],
                                        );
                                      });
                                }
                                else {
                                  registerUser(
                                      _name, _phnum, _email, _idnum, context);
                                  await db.collection("users")
                                      .document('$_uid')
                                      .setData(
                                      {
                                        'name': _name,
                                        'ph_num': _phnum,
                                        'email': _email,
                                        'idnum': _idnum
                                      });
                                  print('register user complete.');
                                }
                              }
                            },
                            child: Text('Register',
                              style: TextStyle(fontSize: 18,
                                  color: Colors.amberAccent[400],
                                  fontFamily: 'OpenSansR'),),
                            shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(30.0)),
                          ),
                          OutlineButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MainPage()));
                            },
                            child: Text('Cancel',
                              style: TextStyle(fontSize: 18,
                                  color: Colors.amberAccent[400],
                                  fontFamily: 'OpenSansR'),),
                            shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(30.0)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
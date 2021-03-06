import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:testapp/services/analytics_service.dart';
import 'Login.dart';
import 'StartUp.dart';
import 'MainNavigation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testapp/services/loadingDialog.dart';


class Register extends StatefulWidget{
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Register> {

  final _codeController = TextEditingController();
  final _keyLoader = GlobalKey<State>();
  final db = Firestore.instance;
  String _code = '';
  String _uid = '';
  String _name = '';
  String _phnum = '';
  String _email = '';
  String _idnum = '';
  final _nameController = TextEditingController();
  final _phnumController = TextEditingController();
  final _emailController = TextEditingController();
  final _idnumController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _analyticsService = AnalyticsServices();

  Future <bool> registerUser(String name, String phnum, String email, String idnum, BuildContext context) async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    _auth.verifyPhoneNumber(
        phoneNumber: phnum,
        timeout: Duration(seconds: 0),
        //0 to disable auto-retrieval of code
        //verificationCompleted only occure if auto-retrieval
        verificationCompleted: null,
        verificationFailed: (AuthException exp) {
          print('Error ' + exp.message);
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
                        textAlign: TextAlign.center,
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
                        AuthResult result = await _auth.signInWithCredential(credential).catchError((e){
                          Navigator.of(context).pop();
                          showDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('Error'),
                                  content: Text('Check your verification code and try again.'),
                                );
                              });
                        });
                        FirebaseUser user = result.user;
                        if (user != null) {
                          LoadingDialog.showLoadingDialog(context, _keyLoader, "Validating...");
                          _uid = user.uid;
                          await createUser(_uid,user).catchError((e){
                            print("$e, in confirm button $_uid");
                            Navigator.of(context).pop();
                            showDialog(
                                context: context,
                                barrierDismissible: true,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('Error Register'),
                                    content: Text('Error : $e. Please try again.'),
                                  );
                                });
                            // Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
                            }).then((value){
                              _analyticsService.logSignUp();
                              Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => MainNavigation(user: user),
                                  settings: RouteSettings(name: "MainView")
                              ));
                          });
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
    FirebaseAnalytics().setCurrentScreen(screenName: "RegisterScreen");
    return Scaffold(
      appBar: AppBar(title: Text('TaskPro'),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Colors.amberAccent[400],),
      body: SingleChildScrollView(
        child: Center(
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
              Container(
                height: 500,
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
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
                      SizedBox(height: 20,),
                      TextFormField(
                        controller: _phnumController,
                        //validate input in client side
                        validator: (val) =>
                        !(val.length > 11)
                            ? 'Enter valid mobile number with country code. (eg : +60101234567)'
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
                      SizedBox(height: 20,),
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
                      SizedBox(height: 20,),
                      TextFormField(
                        controller: _idnumController,
                        textAlign: TextAlign.center,
                        validator: (val) =>
                        !(val.length >= 9 && val.length <= 12)
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
                      SizedBox(height: 20,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          OutlineButton(
                            onPressed: () async {
                              //validate all form text field
                              if (_formKey.currentState.validate()) {
                                //check if exists
                                QuerySnapshot result = await Firestore
                                    .instance.collection('users').where(
                                    'ph_num', isEqualTo: _phnum)
                                    .limit(1)
                                    .getDocuments();
                                List <DocumentSnapshot> documents = result.documents;
                                if (documents.length == 1) {
                                  print('user exists.');
                                  showDialog(context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text(
                                              "The number is registered. Please proceed to login."),
                                          actions: <Widget>[
                                            FlatButton(
                                                child: Text('Cancel'),
                                                onPressed: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) => Register(), settings: RouteSettings(name: "RegisterView")));
                                                }),
                                            FlatButton(
                                                child: Text('Login'),
                                                color: Colors.amber[400],
                                                onPressed: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              Login(), settings: RouteSettings(name: "LoginView")));
                                                })
                                          ],
                                        );
                                      });
                                }
                                else {
                                  await registerUser(_name, _phnum, _email, _idnum, context);
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
                                      builder: (context) => StartUp(), settings: RouteSettings(name: "StartUpView")));
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
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> createUser(String _uid, FirebaseUser user) async{
    UserUpdateInfo userUpdateInfo = new UserUpdateInfo();
    userUpdateInfo.displayName = _name;
    userUpdateInfo.photoUrl = ' ';
    user.updateProfile(userUpdateInfo);
    print("REGISTER : MY NAME IS : " + user.displayName);
    await db.collection("users").document(_uid).setData({
      'id' : _uid,
      'name': _name,
      'ph_num': _phnum.replaceAll('-', ''),
      'email': _email,
      'idnum': _idnum,
      'joined' : new DateTime.now(),
      'role' : 'user',
      'status' : 0,
      'deleted_at' : null
    }).then((value) async {
      await db.collection("profile").document(_uid).setData({
        'id' : _uid,
        'name': _name,
        'ph_num': _phnum,
        'email' : _email,
        'task_completed': 0,
        'task_posted': 0,
        'rating' : 0,
        'review_num' : 0,
        'status' : 0,
        'gallery' : [],
        'profile_pic' : '',
        'services' : '',
        'joined' : new DateTime.now(),
        'achievement' : '',
        'about' : '-',
        'notificationEnabled' : false,
      });
    }).then((value) async {
      await db.collection("wallet").document(_uid).setData({
        'stripe_account' : false,
        'stripe_onboard' : false,
        'stripe_acc_id' : '',
      });
    });
  }
}
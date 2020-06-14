import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testapp/models/Profile.dart';

class EditProfile extends StatefulWidget {
  final FirebaseUser user;
  final Profile profile;
  EditProfile({this.user,this.profile});
  _HomeState createState() => new _HomeState(user,profile);
}

class _HomeState extends State<EditProfile> {

  FirebaseUser user;
  Profile profile;
  _HomeState(this.user,this.profile);

  final db = Firestore.instance;
  DocumentReference docRef;
  File _image;

  String _name;
  String _email;
  String _about;
  String _profilePicPath;
  String _achievement;
  String _services;

  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _aboutController = TextEditingController();
  TextEditingController _achievementController = TextEditingController();
  TextEditingController _servicesController = TextEditingController();

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();


  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
      print('Image Path $_image');
    });
  }

  Future uploadPic() async{
    String _profilepic = basename(_image.path);
    String folder = user.uid + '/profile';
    StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child('$folder/$_profilepic');
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(_image);
    StorageTaskSnapshot taskSnapshot=await uploadTask.onComplete.catchError((e){print(e.toString());});
    await firebaseStorageRef.getDownloadURL().then((val){
      _profilePicPath = val;
      print(_profilePicPath);
    }).catchError((e){print(e.toString());});
  }

  Future _updateProfile(BuildContext context,String uid,String name,String email, String profilePicPath, String about,String achievement,String services) async{
    await db.collection("profile").document(uid).updateData({
      'name': name,
      'email' : email,
      'profile_pic' : profilePicPath,
      'about' : about,
      'achievement' : achievement,
      'services' : services,
    }).catchError((e) {print(e.toString());});

//    setState(() {
//      print("Profile updated");
//      Scaffold.of(context).showSnackBar(SnackBar(content: Text('Profile Updated')));
//    });

  }

  void getValue(){
    _name = profile.name;
    _email = profile.email;
    _about = profile.about;
    _profilePicPath = profile.profilepic;
    _achievement = profile.achievement;
    _services = profile.services;

    _nameController.text = _name;
    _emailController.text = _email;
    _aboutController.text = _about;
    _achievementController.text = _achievement;
    _servicesController.text = _services;
  }

  Widget build(BuildContext context) {


    getValue();
    return Scaffold(
        appBar: AppBar(title : Text('Edit Profile'),
          centerTitle: true ,
          elevation: 0.0,
          backgroundColor: Colors.amberAccent[400],),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(15),
            child: Column(
              children: <Widget>[
                Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(5),
                    child: CircleAvatar (
                      backgroundColor: Colors.white,
                      radius: 90,
                      child: ClipOval(
                        child: new SizedBox(
                          width: 180.0, //2x radius
                          height: 180.0,
                          child: (_image!=null)?Image.file(
                            _image,
                            fit: BoxFit.cover,
                          ): (profile.profilepic!='')?Image.network(
                            profile.profilepic,
                            fit: BoxFit.cover,
                          ): Image.asset("assets/profile-icon.png"),
                        ),
                      ),
                    )
                ),
                Container(
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amberAccent[400],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: IconButton(
                      color: Colors.black,
                      onPressed: (){
                        getImage();
                      },
                      icon : Icon(Icons.file_upload,)),
                ),

                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Text('Name',style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12
                      ),),
                      TextFormField(
                        controller: _nameController,
                        //validate input in client side
                        validator: (val) =>
                        val.isEmpty
                            ? 'Enter your full name'
                            : null,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
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
                      Text('Email',style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14
                      ),),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        //validate input in client side
                        validator: (val) {
                          Pattern pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                          RegExp regex = new RegExp(pattern);
                          if (!regex.hasMatch(val))
                            return 'Enter a valid email';
                          else
                            return null;
                        },
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
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
                      Text('About',style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14
                      ),),
                      TextFormField(
                        maxLength: 300,
                        maxLines: null,
                        controller: _aboutController,
                        //validate input in client side
                        validator: (val) =>
                        (val.length > 300)
                            ? 'Exceeded 300 characters'
                            : null,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Tell us about yourself",
                            hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 12
                            )
                        ),
                        onChanged: (val) {
                          setState(() => _about = val);
                        },
                      ),
                      SizedBox(height: 20,),
                      Text('Achievement',style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14
                      ),),
                      TextFormField(
                        controller: _achievementController,
                        textAlign: TextAlign.center,
                        maxLength: 80,
                        maxLines: null,
                        validator: (val) =>
                        (val.length > 80)
                            ? 'Exceeded 80 characters'
                            : null,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Achievements / Area of Expertise",
                            hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 12
                            )
                        ),
                        onChanged: (val) {
                          setState(() => _achievement = val);
                        },
                      ),
                      SizedBox(height: 20,),
                      Text('Services',style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14
                      ),),
                      TextFormField(
                        controller: _servicesController,
                        textAlign: TextAlign.center,
                        maxLength: 80,
                        maxLines: null,
                        validator: (val) =>
                        (val.length > 80)
                            ? 'Exceeded 80 characters'
                            : null,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Services you would offer yourself to",
                            hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 12
                            )
                        ),
                        onChanged: (val) {
                          setState(() => _services = val);
                        },
                      ),
                      SizedBox(height: 20,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          OutlineButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Cancel',
                              style: TextStyle(fontSize: 18,
                                  color: Colors.amberAccent[400],
                                  fontFamily: 'OpenSansR'),),
                            shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(30.0)),
                          ),
                          OutlineButton(
                            onPressed: () {
                              if (_formKey.currentState.validate()) {
                                uploadPic();
                                _updateProfile(context,user.uid, _name, _email, _profilePicPath, _about, _achievement, _services);
                              }
                            },
                            child: Text('Save',
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
              ],
            ),
          )
        ));

  }
}
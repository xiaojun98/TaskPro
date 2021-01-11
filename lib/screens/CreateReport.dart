import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:testapp/models/Report.dart';
import 'package:testapp/services/NotificationService.dart';
import '../services/loadingDialog.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'ViewReport.dart';

class CreateReport extends StatefulWidget {
  FirebaseUser user;
  String category ;
  String taskId ;
  String profileId ;
  CreateReport({this.user,this.category,this.taskId,this.profileId});
  _HomeState createState() => _HomeState(user,category,taskId,profileId);
}

class _HomeState extends State<CreateReport> {
  FirebaseUser user;
  String category ;
  String subCategory ;
  String taskId ;
  String profileId ;
  _HomeState(this.user,this.category,this.taskId,this.profileId);
  TextStyle _style = TextStyle(fontFamily: 'OpenSans-R',fontSize: 16,);
  final _keyLoader = GlobalKey<State>();
  final _formKey = GlobalKey<FormState>();
  bool _validateCategory = false;
  bool _validateSubCategory = false;

  TextEditingController _taskIdInputController = new TextEditingController();
  TextEditingController _profileIdInputController = new TextEditingController();
  TextEditingController _titleInputController = new TextEditingController();
  TextEditingController _descriptionInputController = new TextEditingController();
  TextEditingController _suggestionInputController = new TextEditingController();


  void initState(){
    super.initState();
    if(taskId != null){
      category = 'Task Related Issues';
      _taskIdInputController.text = taskId;
    }
    else if(profileId != null){
      category = 'Report an User';
      _profileIdInputController.text = profileId;
    }
    else {
      category = null;
    }
    subCategory = null;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title : Text("Create Report"),
        elevation: 0.0,
        backgroundColor: Colors.amberAccent[400],
        actions: <Widget>[
          IconButton(
            icon : Icon(Icons.history),
            tooltip: 'Report Submitted',
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return StreamBuilder<QuerySnapshot>(
                        stream: Firestore.instance.collection('report')
                            .where('createdBy', isEqualTo: Firestore.instance.collection('users').document(user.uid)).snapshots(),
                        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (!snapshot.hasData) {
                            return SimpleDialog(
                              children: [
                                Center(child: Text('No history found.'),),
                              ],
                            );
                          } else {
                            List<SimpleDialogOption> historyItems = [];
                            for (DocumentSnapshot doc in snapshot.data.documents) {
                              Report history = new Report();
                              history.id = doc.data['id'];
                              history.createdBy = doc.data['createdBy'];
                              history.createdAt = doc.data['createdAt']?.toDate();
                              history.author = doc.data['author'];
                              history.category = doc.data['category'];
                              history.subCategory = doc.data['subCategory'];
                              history.title = doc.data['title'];
                              history.description = doc.data['description'];
                              history.suggestion = doc.data['suggestion'];
                              history.status = doc.data['status'];
                              history.taskId = doc.data['taskId'] == null ? '' : doc.data['taskId'];
                              history.taskRef = doc.data['taskRef'];
                              history.profileId = doc.data['profileId']== null ? '' : doc.data['profileId'];
                              history.profileRef = doc.data['profileRef'];
                              historyItems.add(
                                  SimpleDialogOption(
                                    child: Text(doc.data['title']),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => ViewReport(report: history,))
                                      );
                                    },
                                  )
                              );
                            }
                            return SimpleDialog(
                              title: Text('Select a history',style: _style),
                              children: historyItems,
                            );
                          }
                        }
                    );
                  }
              );
            },
          ),
        ]
      ),
      body: WillPopScope(
        onWillPop: () => showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
            title: Text('Warning'),
            content: Text('Any changes made cannot be save. Exit "Create Report" ?'),
            actions: [
              FlatButton(
                child: Text('Yes'),
                onPressed: () => {
                  Navigator.pop(c, true),
                  Navigator.pop(context, true),
                },
              ),
              FlatButton(
                child: Text('No'),
                onPressed: () => Navigator.pop(c, false),
              ),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.symmetric(vertical : 30,horizontal: 25),
            child: Column(
              children: <Widget>[
                Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.disabled,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text('Category',style: _style,),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0,5,0,15),
                        child: StreamBuilder<QuerySnapshot>(
                          stream: Firestore.instance.collection('category').document('reportCategory').collection('reportCategory').snapshots(),
                          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (!snapshot.hasData) {
                              return Text('Loading');
                            } else {
                              List<DropdownMenuItem> categoryItems = [];
                              for (DocumentSnapshot category in snapshot.data.documents) {
                                categoryItems.add(
                                    DropdownMenuItem(
                                      child: Text(category.documentID),
                                      value: category.documentID,
                                    )
                                );
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  FormField<String>(
                                    builder: (FormFieldState<String> state) {
                                      return InputDecorator(
                                        decoration: InputDecoration(
                                          errorText: _validateCategory ? state.errorText : null,
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.only(left: 0, bottom: 0, top: 0, right: 0),
                                        ),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton(
                                              items: categoryItems,
                                              onChanged: (item) {
                                                setState(() {
                                                  subCategory = null;
                                                  category = item;
                                                });
                                              },
                                              value: category,
                                              hint: Text(
                                                'Select a category',
                                                style: TextStyle(
                                                    color :Colors.grey,
                                                    fontSize: 14
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    validator: (value) {
                                      if(category == null) {
                                        _validateCategory = true;
                                        return 'Please select a category';
                                      } else {
                                        _validateCategory = false;
                                        return null;
                                      }
                                    },
                                  ),
                                ],
                              );
                            }
                          },
                        ),
                      ),
                      (category == null) ? Container () : Text('Sub-Category',style: _style,),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0,5,0,15),
                        child: (category == null) ?
                          InputDecorator(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.only(left: 0, bottom: 0, top: 0, right: 0),
                            ),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.0),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton(
                                  items: [],
                                  hint: Text(
                                    'Select a Category First',
                                    style: TextStyle(
                                        color :Colors.grey,
                                        fontSize: 14
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                          : StreamBuilder<QuerySnapshot>(
                          stream: Firestore.instance.collection('category').document('reportCategory').collection('reportCategory').document(category).collection('subCategory').snapshots(),
                          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (!snapshot.hasData) {
                              return Text('Please Select A Sub-category');
                            } else {
                              List<DropdownMenuItem> subCategoryItems = [];
                              for (DocumentSnapshot subcategory in snapshot.data.documents) {
                                subCategoryItems.add(
                                    DropdownMenuItem(
                                      child: Text(subcategory.documentID),
                                      value: subcategory.documentID,
                                    )
                                );
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  FormField<String>(
                                    builder: (FormFieldState<String> state) {
                                      return InputDecorator(
                                        decoration: InputDecoration(
                                          errorText: _validateSubCategory ? state.errorText : null,
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.only(left: 0, bottom: 0, top: 0, right: 0),
                                        ),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton(
                                              items: subCategoryItems,
                                              onChanged: (subItem) {
                                                setState(() {
                                                  subCategory = subItem;
                                                });
                                              },
                                              value: subCategory,
                                              hint: Text(
                                                'Select a sub-category',
                                                style: TextStyle(
                                                    color :Colors.grey,
                                                    fontSize: 14
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    validator: (value) {
                                      if(subCategory == null) {
                                        _validateSubCategory = true;
                                        return 'Please select a sub-category';
                                      } else {
                                        _validateSubCategory = false;
                                        return null;
                                      }
                                    },
                                  ),
                                ],
                              );
                            }
                          },
                        ),
                      ),
                      (taskId != null || category == 'Task Related Issues' || category == 'Refund') ? Text('Task ID',style: _style,) : Container(),
                      (taskId != null || category == 'Task Related Issues' || category == 'Refund') ?
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0,5,0,5),
                        child: TextFormField(
                          textAlign: TextAlign.left,
                          controller: _taskIdInputController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: "Task ID",
                              hintStyle: TextStyle(
                                  color :Colors.grey,
                                  fontSize: 14
                              )),
                          maxLength: 30,
                          // initialValue: taskId,
                          validator: (value) => (value == null || value.isEmpty) ? 'Please enter task ID' : null,
                          onSaved: (val) => taskId = val,
                        ),
                      ) : Container(),
                      (profileId != null || category == 'Report an User') ? Text('User Profile ID',style: _style,) : Container(),
                      (profileId != null || category == 'Report an User') ?
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0,5,0,5),
                        child: TextFormField(
                          textAlign: TextAlign.left,
                          controller: _profileIdInputController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: "User Profile ID",
                              hintStyle: TextStyle(
                                  color :Colors.grey,
                                  fontSize: 14
                              )),
                          maxLength: 30,
                          validator: (value) => (value == null || value.isEmpty)  ? 'Please enter ID of the user profile' : null,
                          // initialValue: profileId,
                          onSaved: (val) => profileId = val,
                        ),
                      ) : Container(),
                      Text('Title',style: _style,),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0,5,0,5),
                        child: TextFormField(
                          textAlign: TextAlign.left,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: "Title for the report",
                              hintStyle: TextStyle(
                                  color :Colors.grey,
                                  fontSize: 14
                              )),
                          maxLength: 60,
                          controller: _titleInputController,
                          textCapitalization: TextCapitalization.words,
                          validator: (value) => value.isEmpty ? 'Please enter title for the task' : null,
                        ),
                      ),
                      Text('Description',style: _style),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0,5,0,15),
                        child: TextFormField(
                          textAlign: TextAlign.left,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: "Please provide a detailed information about the issue.",
                              hintStyle: TextStyle(
                                  color :Colors.grey,
                                  fontSize: 14
                              )),
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          minLines: 3,
                          textCapitalization: TextCapitalization.sentences,
                          controller: _descriptionInputController,
                          validator: (value) => value.isEmpty ? 'Please provide a detailed information about the issue.' : null,
                        ),
                      ),
                      Text('Improvement',style: _style),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0,5,0,15),
                        child: TextFormField(
                          textAlign: TextAlign.left,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: "Help us improve by giving us some suggestions.",
                              hintStyle: TextStyle(
                                  color :Colors.grey,
                                  fontSize: 14
                              )),
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          minLines: 3,
                          textCapitalization: TextCapitalization.sentences,
                          controller: _suggestionInputController,
                        ),
                      ),
                      SizedBox(width: 20),
                      FlatButton(
                        onPressed: ()  {
                          taskId = _taskIdInputController.text;
                          profileId = _profileIdInputController.text;
                          bool isValid = _formKey.currentState.validate();
                          if (isValid) {
                            print(taskId.toString() + ' : ' + profileId.toString() + ' : ' + profileId.isEmpty.toString() + profileId.isNotEmpty.toString());
                            showDialog<bool>(
                              context: context,
                              builder: (c) => AlertDialog(
                                title: Text('Alert'),
                                content: Text('Submit report? Changes cannot be made after submission.'),
                                actions: [
                                  FlatButton(
                                    child: Text('Yes'),
                                    onPressed: () async => {
                                      LoadingDialog.showLoadingDialog(context, _keyLoader, "Submitting"),
                                      await Firestore.instance.collection('profile').document(user.uid).get().then((profile) {
                                        DocumentReference ref = Firestore.instance.collection('report').document();
                                        ref.setData({
                                          'id': ref.documentID,
                                          'createdBy': Firestore.instance.document('users/'+user.uid),
                                          'createdAt': DateTime.now(),
                                          'author': {'name':profile.data['name'], 'profile_pic': profile.data['profile_pic']},
                                          'category': category,
                                          'subCategory': subCategory,
                                          'taskId' : (taskId!=null && taskId!='') ? taskId : null,
                                          'taskRef' : (taskId!=null && taskId!='') ? Firestore.instance.document('task/'+ taskId) : null,
                                          'profileId' : (profileId!=null && profileId!='') ? profileId : null,
                                          'profileRef' : (profileId!=null && profileId!='') ? Firestore.instance.document('profile/'+ profileId) : null,
                                          'title': _titleInputController.text,
                                          'description': _descriptionInputController.text,
                                          'suggestion' : _suggestionInputController.text,
                                          'status': 'Pending',
                                        }).then((value) {
                                          Report report = new Report();
                                          report.id = ref.documentID;
                                          NotificationService.instance.generateNotification(1, report , user.uid);
                                          Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
                                          Navigator.pop(context, true);
                                        }).then((value) {
                                          Fluttertoast.showToast(
                                              msg: "Report submitted",
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.BOTTOM,
                                              timeInSecForIosWeb: 1,
                                              backgroundColor: Colors.black54,
                                              textColor: Colors.white,
                                              fontSize: 16.0
                                          );
                                        });
                                      })
                                    },
                                  ),
                                  FlatButton(
                                    child: Text('No'),
                                    onPressed: () => Navigator.pop(c, false),
                                  ),
                                ],
                              ),
                            ).then((value) =>  Navigator.pop(context, true));
                          }
                        },
                        child: Text ('Submit',
                          style: TextStyle(fontSize: 16,color: Colors.black,fontFamily: 'OpenSansR'),),
                        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                        color: Colors.amber,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

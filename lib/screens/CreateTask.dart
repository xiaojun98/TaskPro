import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moneytextformfield/moneytextformfield.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/Task.dart';
import '../services/loadingDialog.dart';
import 'package:firebase_auth/firebase_auth.dart';


class CreateTask extends StatefulWidget {
  FirebaseUser user;
  Task task;
  CreateTask({this.user, this.task});
  _HomeState createState() => _HomeState(user, task);
}

class _HomeState extends State<CreateTask> {
  FirebaseUser user;
  Task task;
  _HomeState(this.user, this.task);
  TextStyle _style = TextStyle(fontFamily: 'OpenSans-R',fontSize: 16,);
  DateTime now = DateTime.now();
  final _keyLoader = GlobalKey<State>();
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool _validateCategory = false;
  TextEditingController _titleInputController = new TextEditingController();
  TextEditingController _descriptionInputController = new TextEditingController();
  TextEditingController _additionalInstructionInputController = new TextEditingController();
  TextEditingController _tagsInputController = new TextEditingController();
  TextEditingController _locationInputController = new TextEditingController();
  TextEditingController _feeInputController = new TextEditingController();

  Widget _buildAboutDialog(BuildContext context){
    return new AlertDialog(
        title: const Text('Continue'),
        content: new Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Confirm publish? You will be redirected to transaction site to proceed.'),
          ],
        ),
        actions: <Widget>[
          new FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          textColor: Theme.of(context).primaryColor,
          child: const Text('Proceed to transaction'),
          ),
        ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if(task.dateTime == null) {
      task.dateTime = now;
    }
    if(task.status!=null) {
      _titleInputController.text = task.title;
      _descriptionInputController.text = task.description;
      _additionalInstructionInputController.text = task.additionalInstruction;
      _tagsInputController.text = task.tags;
      _locationInputController.text = task.location;
      _feeInputController.text = task.fee.toStringAsFixed(2);
      if(task.dateTime.isBefore(now))
        task.dateTime = now;
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title : Text(task.status==null||task.status=='Draft' ? 'Create A Task' : 'Edit Task Detail'),
        elevation: 0.0,
        backgroundColor: Colors.amberAccent[400],
        actions: task.status==null||task.status=='Draft' ? <Widget>[
          IconButton(
            icon : Icon(Icons.folder),
            tooltip: 'Drafts',
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return StreamBuilder<QuerySnapshot>(
                      stream: Firestore.instance.collection('task')
                          .where('created_by', isEqualTo: Firestore.instance.collection('users').document(user.uid))
                          .where('status', isEqualTo: 'Draft').snapshots(),
                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (!snapshot.hasData) {
                          return SimpleDialog(
                            children: [
                              Center(child: Text('No draft found.'),),
                            ],
                          );
                        } else {
                          List<SimpleDialogOption> draftItems = [];
                          for (DocumentSnapshot doc in snapshot.data.documents) {
                            Task draft = new Task();
                            draft.id = doc.data['id'];
                            draft.createdBy = doc.data['created_by'];
                            draft.createdAt = doc.data['created_at']?.toDate();
                            draft.updatedBy = doc.data['updated_by'];
                            draft.updatedAt = doc.data['updated_at']?.toDate();
                            draft.author = doc.data['author'];
                            draft.serviceProvider = doc.data['service_provider'];
                            draft.category = doc.data['category'];
                            draft.title = doc.data['title'];
                            draft.description = doc.data['description'];
                            draft.additionalInstruction = doc.data['additional_instruction'];
                            draft.tags = doc.data['tags'];
                            draft.dateTime = doc.data['date_time'].toDate();
                            draft.location = doc.data['location'];
                            draft.fee = doc.data['fee'];
                            draft.payment = doc.data['payment'];
                            draft.status = doc.data['status'];
                            draft.offeredBy = doc.data['offered_by'];
                            draft.isCompleteByAuthor = doc.data['is_complete_by_author'];
                            draft.isCompleteByProvider = doc.data['is_complete_by_provider'];
                            draft.offerNum = doc.data['offer_num'];
                            draft.rating = doc.data['rating'];
                            draftItems.add(
                                SimpleDialogOption(
                                  child: Text(doc.data['title']),
                                  onPressed: () {
                                    setState(() {
                                      task = draft;
                                    });
                                    Navigator.of(context).pop();
                                  },
                                )
                            );
                          }
                          return SimpleDialog(
                            title: const Text('Select a draft'),
                            children: draftItems,
                          );
                        }
                      }
                  );
                }
              );
            },),
        ] : [],
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(vertical : 30,horizontal: 25),
          child: Column(
            children: <Widget>[
              Form(
                key: _formKey,
                autovalidate: _autoValidate,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text('Category',style: _style,),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0,5,0,15),
                      child: StreamBuilder<QuerySnapshot>(
                        stream: Firestore.instance.collection('category').snapshots(),
                        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (!snapshot.hasData) {
                            return Text('Loading');
                          } else {
                            List<DropdownMenuItem> catrgoryItems = [];
                            for (DocumentSnapshot category in snapshot.data.documents) {
                              catrgoryItems.add(
                                  DropdownMenuItem(
                                    child: Text(category.data['name']),
                                    value: category.data['name'],
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
                                            items: catrgoryItems,
                                            onChanged: (category) {
                                              setState(() {
                                                task.category = category;
                                                state.didChange(category);
                                              });
                                            },
                                            value: task.category,
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
                                    if(task.category == null) {
                                      _validateCategory = true;
                                      return '    Please select a category';
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
                    Text('Title',style: _style,),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0,5,0,15),
                      child: TextFormField(
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Title for the task",
                            hintStyle: TextStyle(
                                color :Colors.grey,
                                fontSize: 14
                            )),
                        controller: _titleInputController,
                        validator: (value) => value.isEmpty ? 'Please enter title for the task' : null,
                        onSaved: (value) => task.title = value,
                      ),
                    ),
                    Text('Description',style: _style),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0,5,0,15),
                      child: TextFormField(
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Detail description for the task",
                            hintStyle: TextStyle(
                                color :Colors.grey,
                                fontSize: 14
                            )),
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        minLines: 3,
                        controller: _descriptionInputController,
                        validator: (value) => value.isEmpty ? 'Please enter description for the task' : null,
                        onSaved: (value) => task.description = value,
                      ),
                    ),
                    Text('Additional Instructions',style: _style),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0,5,0,15),
                      child: TextFormField(
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Additional instructions to service provider",
                            hintStyle: TextStyle(
                                color :Colors.grey,
                                fontSize: 14
                            )),
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        minLines: 3,
                        controller: _additionalInstructionInputController,
                        onSaved: (value) => value.isEmpty ? null : task.additionalInstruction = value,
                      ),
                    ),
                    Text('Tag(s)',style: _style),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0,5,0,15),
                      child: TextFormField(
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Seperate keywords using ',' ",
                            hintStyle: TextStyle(
                                color :Colors.grey,
                                fontSize: 14
                            )),
                        controller: _tagsInputController,
                        onSaved: (value) => value.isEmpty ? null : task.tags = value,
                      ),
                    ),
                    Text('Date & Time',style: _style),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children : <Widget>[
                          Container(
                            padding: const EdgeInsets.fromLTRB(0,5,0,15),
                            child: OutlineButton(
                              borderSide: BorderSide(
                                color: Colors.grey,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Container(
                                alignment: Alignment.center,
                                height: 50.0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Icon(
                                      Icons.date_range,
                                      size: 18.0,
                                      color: Colors.amberAccent[400],
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      DateFormat('yyyy-MM-dd').format(task.dateTime),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.0),
                                    ),
                                  ],
                                ),
                              ),
                              onPressed: (){
                                showDatePicker(
                                  context: context,
                                  initialDate: task.dateTime,
                                  firstDate: now,
                                  lastDate: now.add(new Duration(days: 365)),
                                ).then((date){
                                  setState(() {
                                    task.dateTime = date;
                                  });
                                });
                              },
                            ),
                          ),
                          SizedBox(width: 20),
                          Container(
                            padding: const EdgeInsets.fromLTRB(0,5,0,15),
                            child: OutlineButton(
                              borderSide: BorderSide(
                                color: Colors.grey,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Container(
                                alignment: Alignment.center,
                                height: 50.0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Icon(
                                      Icons.access_time,
                                      size: 18.0,
                                      color: Colors.amberAccent[400],
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      DateFormat.jm().format(task.dateTime),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.0),
                                    ),
                                  ],
                                ),
                              ),
                              onPressed: (){
                                showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.fromDateTime(task.dateTime),
                                ).then((time){
                                  setState(() {
                                    task.dateTime = DateTime(task.dateTime.year, task.dateTime.month, task.dateTime.day, time.hour, time.minute);;
                                  });
                                });
                              },
                            ),
                          ),
                          //Text(chosenDate == null ? '- Days Left' : '${chosenDate.difference(DateTime.now()).inDays} Days Left' ,style: TextStyle(fontFamily: 'OpenSans-R',fontSize: 14,color: Colors.red)),
                        ]),
                    Text('Location',style: _style),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0,5,0,15),
                      child: TextFormField(
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Location for the task",
                            hintStyle: TextStyle(
                                color :Colors.grey,
                                fontSize: 14
                            )),
                        controller: _locationInputController,
                        onSaved: (value) => value.isEmpty ? null : task.location = value,
                      ),
                    ),
                    Text('Fee',style: _style),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0,5,0,15),
                      child: MoneyTextFormField(
                          settings: MoneyTextFormFieldSettings(
                            controller: _feeInputController,
                            moneyFormatSettings: MoneyFormatSettings(amount : task.status!=null ? double.parse(_feeInputController.text) : 0.00 ,currencySymbol: 'RM',thousandSeparator: ','),
                            inputFormatters: [WhitelistingTextInputFormatter(RegExp(r"^\d*\.?\d*"))],
                            validator: (value) {
                              if(value.isEmpty) {
                                return 'Enter a fee amount';
                              } else if(double.parse(value)<=0) {
                                return 'Amount should be more than RM0';
                              } else {
                                task.fee = double.parse(value);
                                return null;
                              }
                            },
                          ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: task.status==null||task.status=='Draft' ? <Widget>[
                  FlatButton(
                    onPressed: (){
                      if(_formKey.currentState.validate()) {
                        LoadingDialog.showLoadingDialog(context, _keyLoader, "Saving as draft...");
                        _formKey.currentState.save();
                        if(task.id!=null) {
                          Firestore.instance.collection('task').document(task.id).updateData({
                            'created_at': DateTime.now(),
                            'category': task.category,
                            'title': task.title,
                            'description': task.description,
                            'additional_instruction': task.additionalInstruction,
                            'tags': task.tags,
                            'date_time': task.dateTime,
                            'location': task.location,
                            'fee': task.fee,
                          }).then((value) {
                            Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
                            Navigator.pop(context);
                          });
                        } else {
                          DocumentReference ref = Firestore.instance.collection('task').document();
                          ref.setData({
                            'id': ref.documentID,
                            'created_by': Firestore.instance.document('users/'+user.uid),
                            'created_at': DateTime.now(),
                            'updated_by': task.updatedBy,
                            'updated_at': task.updatedAt,
                            'author': {'name':user.displayName, 'profile_pic': user.photoUrl},
                            'service_provider': task.serviceProvider,
                            'category': task.category,
                            'title': task.title,
                            'description': task.description,
                            'additional_instruction': task.additionalInstruction,
                            'tags': task.tags,
                            'date_time': task.dateTime,
                            'location': task.location,
                            'fee': task.fee,
                            'payment': task.payment,
                            'status': 'Draft',
                            'offered_by': task.offeredBy,
                            'is_complete_by_author': task.isCompleteByAuthor,
                            'is_complete_by_provider': task.isCompleteByProvider,
                            'offer_num': 0,
                            'rating': task.rating,
                          }).then((value) {
                            Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
                            Navigator.pop(context);
                          });
                        }

                      } else {
                        setState(() => _autoValidate = true);
                      }
                    },
                    child: Text ('Save as Draft',
                      style: TextStyle(fontSize: 16,color: Colors.black,fontFamily: 'OpenSansR'),),
                    shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                    color: Colors.amber[100],
                  ),
                  SizedBox(width: 20),
                  FlatButton(
                    onPressed: (){
//                      showDialog(
//                        context: context,
//                        builder: (BuildContext context) => _buildAboutDialog(context),
//                      );
                      if(_formKey.currentState.validate()) {
                        LoadingDialog.showLoadingDialog(context, _keyLoader, "Publishing task...");
                        _formKey.currentState.save();
                        if(task.id!=null) {
                          Firestore.instance.collection('task').document(task.id).updateData({
                            'created_at': DateTime.now(),
                            'category': task.category,
                            'title': task.title,
                            'description': task.description,
                            'additional_instruction': task.additionalInstruction,
                            'tags': task.tags,
                            'date_time': task.dateTime,
                            'location': task.location,
                            'fee': task.fee,
                            'status': 'Open',
                          }).then((value) {
                            Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
                            Navigator.pop(context);
                          });
                        } else {
                          DocumentReference ref = Firestore.instance.collection('task').document();
                          ref.setData({
                            'id': ref.documentID,
                            'created_by': Firestore.instance.document('users/'+user.uid),
                            'created_at': DateTime.now(),
                            'updated_by': task.updatedBy,
                            'updated_at': task.updatedAt,
                            'author': {'name':user.displayName, 'profile_pic': user.photoUrl},
                            'service_provider': task.serviceProvider,
                            'category': task.category,
                            'title': task.title,
                            'description': task.description,
                            'additional_instruction': task.additionalInstruction,
                            'tags': task.tags,
                            'date_time': task.dateTime,
                            'location': task.location,
                            'fee': task.fee,
                            'payment': task.payment,
                            'status': 'Open',
                            'offered_by': task.offeredBy,
                            'is_complete_by_author': task.isCompleteByAuthor,
                            'is_complete_by_provider': task.isCompleteByProvider,
                            'offer_num': 0,
                            'rating': task.rating,
                          }).then((value) {
                            Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
                            Navigator.pop(context);
                          });
                        }
                      } else {
                        setState(() => _autoValidate = true);
                      }
                    },
                    child: Text ('Publish',
                      style: TextStyle(fontSize: 16,color: Colors.black,fontFamily: 'OpenSansR'),),
                    shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                    color: Colors.amber,
                  ),
                ] : [
                  FlatButton(
                    onPressed: (){
                      if(_formKey.currentState.validate()) {
                        LoadingDialog.showLoadingDialog(context, _keyLoader, "Saving changes...");
                        _formKey.currentState.save();
                        Firestore.instance.collection('task').document(task.id).updateData({
                          'updated_by': Firestore.instance.document('users/'+user.uid),
                          'updated_at': DateTime.now(),
                          'category': task.category,
                          'title': task.title,
                          'description': task.description,
                          'additional_instruction': task.additionalInstruction,
                          'tags': task.tags,
                          'date_time': task.dateTime,
                          'location': task.location,
                          'fee': task.fee,
                        }).then((value) {
                          Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
                          Navigator.pop(context);
                        });
                      } else {
                        setState(() => _autoValidate = true);
                      }
                    },
                    child: Text ('Save Changes',
                      style: TextStyle(fontSize: 16,color: Colors.black,fontFamily: 'OpenSansR'),),
                    shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                    color: Colors.amber,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

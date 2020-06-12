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
  CreateTask({this.user});
  _HomeState createState() => _HomeState(user);
}

class _HomeState extends State<CreateTask> {
  FirebaseUser user;
  _HomeState(this.user);
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
  Task newTask = new Task();

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
    if(newTask.dateTime == null){
      newTask.dateTime = now;
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title : Text('Create A Task'),
        elevation: 0.0,
        backgroundColor: Colors.amberAccent[400],
        actions: <Widget>[
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
                            Task task = new Task();
                            task.id = doc.data['id'];
                            task.createdBy = doc.data['created_by'];
                            task.createdAt = doc.data['created_at']?.toDate();
                            task.updatedBy = doc.data['updated_by'];
                            task.updatedAt = doc.data['updated_at']?.toDate();
                            task.author = doc.data['author'];
                            task.serviceProvider = doc.data['service_provider'];
                            task.category = doc.data['category'];
                            task.title = doc.data['title'];
                            task.description = doc.data['description'];
                            task.additionalInstruction = doc.data['additional_instruction'];
                            task.tags = doc.data['tags'];
                            task.dateTime = doc.data['date_time'].toDate();
                            if(task.dateTime.isBefore(now))
                              task.dateTime = now;
                            task.location = doc.data['location'];
                            task.fee = doc.data['fee'];
                            task.payment = doc.data['payment'];
                            task.status = doc.data['status'];
                            task.offeredBy = doc.data['offered_by'];
                            task.isCompleteByAuthor = doc.data['is_complete_by_author'];
                            task.isCompleteByProvider = doc.data['is_complete_by_provider'];
                            task.offerNum = doc.data['offer_num'];
                            task.rating = doc.data['rating'];
                            draftItems.add(
                                SimpleDialogOption(
                                  child: Text(doc.data['title']),
                                  onPressed: () {
                                    setState(() {
                                      newTask = task;
                                      _titleInputController.text = task.title;
                                      _descriptionInputController.text = task.description;
                                      _additionalInstructionInputController.text = task.additionalInstruction;
                                      _tagsInputController.text = task.tags;
                                      _locationInputController.text = task.location;
                                      _feeInputController.text = task.fee.toStringAsFixed(2);
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
        ],
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
                                                newTask.category = category;
                                                state.didChange(category);
                                              });
                                            },
                                            value: newTask.category,
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
                                    if(newTask.category == null) {
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
                        onSaved: (value) => newTask.title = value,
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
                        onSaved: (value) => newTask.description = value,
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
                        onSaved: (value) => value.isEmpty ? null : newTask.additionalInstruction = value,
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
                        onSaved: (value) => value.isEmpty ? null : newTask.tags = value,
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
                                      DateFormat('yyyy-MM-dd').format(newTask.dateTime),
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
                                  initialDate: newTask.dateTime,
                                  firstDate: now,
                                  lastDate: now.add(new Duration(days: 365)),
                                ).then((date){
                                  setState(() {
                                    newTask.dateTime = date;
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
                                      DateFormat.jm().format(newTask.dateTime),
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
                                  initialTime: TimeOfDay.fromDateTime(newTask.dateTime),
                                ).then((time){
                                  setState(() {
                                    newTask.dateTime = DateTime(newTask.dateTime.year, newTask.dateTime.month, newTask.dateTime.day, time.hour, time.minute);;
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
                        onSaved: (value) => value.isEmpty ? null : newTask.location = value,
                      ),
                    ),
                    Text('Fee',style: _style),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0,5,0,15),
                      child: MoneyTextFormField(
                          settings: MoneyTextFormFieldSettings(
                            controller: _feeInputController,
                            moneyFormatSettings: MoneyFormatSettings(amount : 0.00 ,currencySymbol: 'RM',thousandSeparator: ','),
                            inputFormatters: [WhitelistingTextInputFormatter(RegExp(r"^\d*\.?\d*"))],
                            validator: (value) {
                              if(value.isEmpty) {
                                return 'Enter a fee amount';
                              } else if(double.parse(value)<=0) {
                                return 'Amount should be more than RM0';
                              } else {
                                newTask.fee = double.parse(value);
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
                children: <Widget>[
                  FlatButton(
                    onPressed: (){
                      if(_formKey.currentState.validate()) {
                        LoadingDialog.showLoadingDialog(context, _keyLoader, "Saving as draft...");
                        _formKey.currentState.save();
                        if(newTask.id!=null) {
                          Firestore.instance.collection('task').document(newTask.id).updateData({
                            'created_at': DateTime.now(),
                            'category': newTask.category,
                            'title': newTask.title,
                            'description': newTask.description,
                            'additional_instruction': newTask.additionalInstruction,
                            'tags': newTask.tags,
                            'date_time': newTask.dateTime,
                            'location': newTask.location,
                            'fee': newTask.fee,
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
                            'updated_by': newTask.updatedBy,
                            'updated_at': newTask.updatedAt,
                            'author': {'name':user.displayName, 'profile_pic': user.photoUrl},
                            'service_provider': newTask.serviceProvider,
                            'category': newTask.category,
                            'title': newTask.title,
                            'description': newTask.description,
                            'additional_instruction': newTask.additionalInstruction,
                            'tags': newTask.tags,
                            'date_time': newTask.dateTime,
                            'location': newTask.location,
                            'fee': newTask.fee,
                            'payment': newTask.payment,
                            'status': 'Draft',
                            'offered_by': newTask.offeredBy,
                            'is_complete_by_author': newTask.isCompleteByAuthor,
                            'is_complete_by_provider': newTask.isCompleteByProvider,
                            'offer_num': 0,
                            'rating': newTask.rating,
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
                        if(newTask.id!=null) {
                          Firestore.instance.collection('task').document(newTask.id).updateData({
                            'created_at': DateTime.now(),
                            'category': newTask.category,
                            'title': newTask.title,
                            'description': newTask.description,
                            'additional_instruction': newTask.additionalInstruction,
                            'tags': newTask.tags,
                            'date_time': newTask.dateTime,
                            'location': newTask.location,
                            'fee': newTask.fee,
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
                            'updated_by': newTask.updatedBy,
                            'updated_at': newTask.updatedAt,
                            'author': {'name':user.displayName, 'profile_pic': user.photoUrl},
                            'service_provider': newTask.serviceProvider,
                            'category': newTask.category,
                            'title': newTask.title,
                            'description': newTask.description,
                            'additional_instruction': newTask.additionalInstruction,
                            'tags': newTask.tags,
                            'date_time': newTask.dateTime,
                            'location': newTask.location,
                            'fee': newTask.fee,
                            'payment': newTask.payment,
                            'status': 'Open',
                            'offered_by': newTask.offeredBy,
                            'is_complete_by_author': newTask.isCompleteByAuthor,
                            'is_complete_by_provider': newTask.isCompleteByProvider,
                            'offer_num': 0,
                            'rating': newTask.rating,
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

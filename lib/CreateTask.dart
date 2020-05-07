import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moneytextformfield/moneytextformfield.dart';


class CreateTask extends StatefulWidget {
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<CreateTask> {
  @override
  TextStyle _style = TextStyle(fontFamily: 'OpenSans-R',fontSize: 16,);
  DateTime _date;

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

  Widget build(BuildContext context) {
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
            onPressed: () {},),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(vertical : 30,horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text('Title for the task',style: _style,),
              Padding(
                padding: const EdgeInsets.fromLTRB(0,5,0,15),
                child: TextField(
                  textAlign: TextAlign.left,
                  decoration: InputDecoration(
//                  prefixIcon : Icon(Icons.account_box),
                    border: OutlineInputBorder(),
                    hintText: "Title",
                    hintStyle: TextStyle(
                        color :Colors.grey,
                        fontSize: 14
                    )),
                ),
              ),
              Text('Task Description',style: _style),
              Padding(
                padding: const EdgeInsets.fromLTRB(0,5,0,15),
                child: TextField(
                  textAlign: TextAlign.left,
                  decoration: InputDecoration(
//                  prefixIcon : Icon(Icons.account_box),
                      border: OutlineInputBorder(),
                      hintText: "Detail description for the task",
                      hintStyle: TextStyle(
                          color :Colors.grey,
                          fontSize: 14
                      )),
                ),
              ),
              Text('Requirements',style: _style),
              Padding(
                padding: const EdgeInsets.fromLTRB(0,5,0,15),
                child: TextField(
                  textAlign: TextAlign.left,
                  decoration: InputDecoration(
//                  prefixIcon : Icon(Icons.account_box),
                      border: OutlineInputBorder(),
                      hintText: "Requirements / Additional instructions ",
                      hintStyle: TextStyle(
                          color :Colors.grey,
                          fontSize: 14
                      )),
                ),
              ),
              Text('Note to service provider',style: _style),
              Padding(
                padding: const EdgeInsets.fromLTRB(0,5,0,15),
                child: TextField(
                  textAlign: TextAlign.left,
                  decoration: InputDecoration(
//                  prefixIcon : Icon(Icons.account_box),
                      border: OutlineInputBorder(),
                      hintText: "Note / Message to service provider",
                      hintStyle: TextStyle(
                          color :Colors.grey,
                          fontSize: 14
                      )),
                ),
              ),
              Text('Tag(s)',style: _style),
              Padding(
                padding: const EdgeInsets.fromLTRB(0,5,0,15),
                child: TextField(
                  textAlign: TextAlign.left,
                  decoration: InputDecoration(
//                  prefixIcon : Icon(Icons.account_box),
                      border: OutlineInputBorder(),
                      hintText: "Seperate keywords using ',' ",
                      hintStyle: TextStyle(
                          color :Colors.grey,
                          fontSize: 14
                      )),
                ),
              ),
              Text('Deadline',style: _style),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children : <Widget>[
                  Container(
                    padding: const EdgeInsets.fromLTRB(0,5,0,15),
                    child: RaisedButton(
                      child: Text(_date == null ? 'Pick a date' : _date.toString().substring(0,10),),
                      onPressed: (){
                        showDatePicker(
                            context: context, initialDate: DateTime.now(),
                            firstDate: DateTime(2020), lastDate: DateTime(2030)).then((date){
                          setState(() {
                            _date = date;
                          });
                        });
                      },
                    ),
                  ),
                  Text(_date == null ? '- Days Left' : '${_date.difference(DateTime.now()).inDays} Days Left' ,style: TextStyle(fontFamily: 'OpenSans-R',fontSize: 14,color: Colors.red)),
                ]),

              Text('Commission',style: _style),
              Padding(
                padding: const EdgeInsets.fromLTRB(0,5,0,15),
                child: MoneyTextFormField(
                    settings: MoneyTextFormFieldSettings(
                      controller: TextEditingController(),
                      moneyFormatSettings: MoneyFormatSettings(amount : 0.00 ,currencySymbol: 'RM',thousandSeparator: ','),
                    )
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  FlatButton(
                    onPressed: (){

                    },
                    child: Text ('Save as Draft',
                      style: TextStyle(fontSize: 16,color: Colors.black,fontFamily: 'OpenSansR'),),
                    shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                    color: Colors.amber[100],
                  ),
                  FlatButton(
                    onPressed: (){

                    },
                    child: Text ('Cancel',
                      style: TextStyle(fontSize: 16,color: Colors.black,fontFamily: 'OpenSansR'),),
                    shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                    color: Colors.amber[100],
                  ),
                  FlatButton(
                    onPressed: (){
                            showDialog(
                        context: context,
                        builder: (BuildContext context) => _buildAboutDialog(context),
                      );
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

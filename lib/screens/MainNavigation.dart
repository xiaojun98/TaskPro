import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:testapp/services/analytics_service.dart';
import 'Timeline.dart';
import 'MyTask.dart';
import 'CreateTask.dart';
import 'MySchedule.dart';
import 'Account.dart';
import '../models/Task.dart';
import 'dart:io';

void main() => runApp(MaterialApp(
  home : MainNavigation(),
  navigatorObservers: [AnalyticsServices().getAnalyticsObserver()],
)
)
;

class MainNavigation extends StatefulWidget{
  @override

  final FirebaseUser user;
  MainNavigation({this.user});
  _HomeState createState() => new _HomeState(user);
}

class _HomeState extends State<MainNavigation> {
  int _currentIndex = 0;
  FirebaseUser user;
  Task newTask = new Task();
  _HomeState(this.user);
  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics().setCurrentScreen(screenName: "MainScreen");
    final tabs = [
      Timeline(user: user,),
      MyTask(user: user,),
      null,
      MySchedule(user: user,),
      Account(user: user),
    ];
    return WillPopScope(
      onWillPop: () => showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: Text('Warning'),
          content: Text('Do you really want to exit?'),
          actions: [
            FlatButton(
              child: Text('Yes'),
              onPressed: () => exit(0),
            ),
            FlatButton(
              child: Text('No'),
              onPressed: () => Navigator.pop(c, false),
            ),
          ],
        ),
      ),
      child: Scaffold(
          body : tabs[_currentIndex],
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          floatingActionButton: new FloatingActionButton(
            onPressed:() async {
              Task newTask = new Task();
              await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateTask(user: user, task: newTask,), settings: RouteSettings(name: "TaskFormView"))
              );
              setState(() {});
            },
            tooltip: 'Create Task',
            child: new Icon(Icons.add),
            backgroundColor: Colors.amber[800],
          ),
          bottomNavigationBar: BottomAppBar(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            shape: CircularNotchedRectangle(),
            child: Theme(
              data: ThemeData(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
              child: BottomNavigationBar(
                iconSize: 25,
                type: BottomNavigationBarType.fixed,
                items: <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.timeline),
                    title: Text('Timeline'),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.photo_filter),
                    title: Text('My Task'),
                  ),

                  BottomNavigationBarItem(
                    icon: Icon(Icons.add_circle_outline),
                    title: Text('Create Task'),

                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.calendar_today),
                    title: Text('Schedule'),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.account_circle),
                    title: Text('Account'),
                  ),
                ],
                currentIndex : _currentIndex,
                selectedItemColor: Colors.amber[800],
                onTap: (index){
                  if(index == 2) {
                    return;
                  } else {
                    setState(() {
                      _currentIndex = index;
                    });
                  }
                },
              ),
            ),
          ),
      ),
    );
  }
}

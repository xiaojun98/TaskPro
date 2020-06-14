import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'Timeline.dart';
import 'MyTask.dart';
import 'CreateTask.dart';
import 'MySchedule.dart';
import 'Account.dart';


class MainNavigation extends StatefulWidget{
  @override

  final FirebaseUser user;
  MainNavigation({this.user});
  _HomeState createState() => new _HomeState(user);
}

class _HomeState extends State<MainNavigation> {
  int _currentIndex = 0;
  FirebaseUser user;
  _HomeState(this.user);

  @override
  Widget build(BuildContext context) {

    final tabs = [
      Timeline(),
      MyTask(),
      null,
      MySchedule(),
      Account(user: user,),
    ];

    return Scaffold(
        body : tabs[_currentIndex],
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: new FloatingActionButton(
          onPressed:(){
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateTask()));
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
    );
  }
}

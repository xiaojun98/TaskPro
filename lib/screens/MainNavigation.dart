import 'package:flutter/material.dart';
import 'Timeline.dart';
import 'MyTask.dart';
import 'CreateTask.dart';
import 'MySchedule.dart';
import 'Account.dart';

void main() => runApp(MaterialApp(
  home : MainNavigation(),
)
)
;

class MainNavigation extends StatefulWidget{
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<MainNavigation> {
  int _currentIndex = 0;

  final tabs = [
    Timeline(),
    MyTask(),
    CreateTask(),
    MySchedule(),
    Account(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body : tabs[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
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
            setState ((){
              _currentIndex= index;
            });
          },
        ),
        );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Account extends StatefulWidget {
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Account> {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title : Text('Account'),
        centerTitle: true ,
        elevation: 0.0,
        backgroundColor: Colors.amberAccent[400],),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(20),
                child: CircleAvatar (
                  backgroundImage : AssetImage('assets/profile-icon.png'),radius: 70,
                  child :
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.amberAccent[400],
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: IconButton(
                        color: Colors.black,
                        onPressed: (){},
                        icon : Icon(Icons.file_upload,)),
                    ),
                ),)
            ),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 5,
              margin: EdgeInsets.all(20),
              child: Column(
                children: <Widget>[
                  ListTile(
                    onTap: (){

                    },
                    leading: Icon(Icons.contacts),
                    title: Text("Your Name Example", style : TextStyle(fontFamily: 'OpenSans-R',fontWeight:FontWeight.bold,fontSize: 18)),
                    subtitle: Text("View Profile",style : TextStyle(fontFamily: 'OpenSans-R',fontSize: 12)),
                    trailing:Icon(Icons.arrow_forward),
                  ),
                  ListTile(
                    onTap: (){

                    },
                    leading: Icon(Icons.settings),
                    title: Text("Edit Profile", style : TextStyle(fontFamily: 'OpenSans-R',fontWeight:FontWeight.bold,fontSize: 18)),
                    subtitle: Text("Profile settings",style : TextStyle(fontFamily: 'OpenSans-R',fontSize: 12)),
                    trailing: Icon(Icons.arrow_forward),
                  ),

                  ListTile(
                    onTap: (){

                    },
                    leading: Icon(Icons.report_problem),
                    title: Text("Report", style : TextStyle(fontFamily: 'OpenSans-R',fontWeight:FontWeight.bold,fontSize: 18)),
                    subtitle: Text("Report a problem",style : TextStyle(fontFamily: 'OpenSans-R',fontSize: 12)),
                    trailing: Icon(Icons.arrow_forward),
                  ),

                ],
              ),
            ),
            SizedBox(height:10),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('Notification Settings',style : TextStyle(fontFamily: 'OpenSans-R',fontWeight:FontWeight.bold,fontSize: 18),textAlign: TextAlign.left,)),
            SwitchListTile(
              activeColor: Colors.amberAccent[400],
              contentPadding: EdgeInsets.all(20),
              value: true,
              title: Text('Receive notification',style: TextStyle(color: Colors.grey[850])),
              onChanged: (val){

              },
            ),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('Account Settings',style : TextStyle(fontFamily: 'OpenSans-R',fontWeight:FontWeight.bold,fontSize: 18),textAlign: TextAlign.left,)),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 5,
              margin: EdgeInsets.all(20),
              child: Column(
                children: <Widget>[
                  ListTile(
                    onTap: (){

                    },
                    leading: Icon(Icons.phone_android),
                    title: Text("Change Phone Number", style : TextStyle(fontFamily: 'OpenSans-R',fontSize: 16)),
                    trailing:Icon(Icons.arrow_forward),
                  ),
                  ListTile(
                    onTap: (){

                    },
                    leading: Icon(Icons.credit_card),
                    title: Text("Update Bank Information", style : TextStyle(fontFamily: 'OpenSans-R',fontSize: 16)),
                    trailing: Icon(Icons.arrow_forward),
                  ),
                  ListTile(
                    onTap: (){

                    },
                    leading: Icon(Icons.block),
                    title: Text("Deactivate Account", style : TextStyle(fontFamily: 'OpenSans-R',fontSize: 16)),
                    trailing: Icon(Icons.arrow_forward),
                  ),
                  ListTile(
                    onTap: (){

                    },
                    leading: Icon(Icons.exit_to_app),
                    title: Text("Log out", style : TextStyle(fontFamily: 'OpenSans-R',fontSize: 16)),
                    trailing: Icon(Icons.arrow_forward),
                  ),
                ],
              ),
            )
          ],
        )
        ),
      );
  }
}
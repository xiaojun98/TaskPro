import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'Inbox.dart';
import 'SingleTaskView.dart';

class Timeline extends StatefulWidget {
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Timeline> {
  @override
  Icon searchCon = Icon(Icons.search);
  Widget title = Text('Timeline');

  List <Tags> popularTags
  = [Tags('Pet care',30),
    Tags('Shopper',28),
    Tags('Household',13),
    Tags('Gaming',5),
    Tags('Delivery',18),
    Tags('Tuition',12),
    Tags('Child Care',7),
    Tags('Designing',8),
    Tags('Personal Helper',16),
    Tags('Data Entry',18),
  ];
  String dropdownValue = 'Order by';

  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title : title,
        leading: IconButton(icon : Icon(Icons.inbox), onPressed: (){
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Inbox()));
        },),
        elevation: 0.0,
        backgroundColor: Colors.amberAccent[400],
        actions: <Widget>[
          IconButton(
            icon : searchCon,
            onPressed: (){
              setState(() {
                if(this.searchCon.icon == Icons.search){
                  this.searchCon = Icon(Icons.cancel);
                  this.title = TextField(
                    decoration: InputDecoration (hintText: "Search ... "),
                    textInputAction: TextInputAction.go,
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  );
                }
                else {
                  this.searchCon = Icon(Icons.search);
                  this.title = Text('Timeline');
                }
              });
          },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20,vertical: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text('Popular Tags', style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,fontFamily: 'OpenSans'),),
                  InkWell(
                      onTap: (){},
                      child: Text('View all', style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,fontFamily: 'OpenSans',),)),
                ],
              )
            ),
            Container(
              height: 55,
              padding: EdgeInsets.only(left : 5),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: popularTags.length,
                itemBuilder: (context,index){
                  return Container(
                    margin: EdgeInsets.only(left: 15,bottom: 15),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(color : Colors.amber[100], borderRadius: BorderRadius.circular(20)),
                    child: Text(popularTags[index].tagName + ' (${popularTags[index].tagCount})',textAlign: TextAlign.center,style : TextStyle(fontSize: 16)),);
                }
              ),
            ),
            Divider(color: Colors.amber, thickness: 1.5,),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20,),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text('Tasks Feed', style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,fontFamily: 'OpenSans'),),
                  DropdownButton<String>(
                    value: dropdownValue,
                    icon : Icon(Icons.filter_list),
                    onChanged: (String newValue) {
                      setState(() {
                        dropdownValue = newValue;
                      });
                    },
                    items: <String>['Order by','Date', 'Commission', 'Title']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],),
            ),
            Container(
              width: 390,
              height: 180,
              child: Card(
                elevation: 5,
                child : ListTile(
                  onTap: (){
                  Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SingleTaskView()));
                  },
                  leading : Column(
                    children: <Widget>[
                      CircleAvatar (backgroundImage : AssetImage('assets/sampleProfile.jpg'),radius: 25),
                    ],),
                  subtitle : Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Text('Shou Yue',style: TextStyle(color : Colors.lightBlue[900]),),
                        Divider(color: Colors.amber, thickness: 1.0,),
                        Text('Cake Delivery',style: TextStyle(fontSize: 16,color: Colors.black),),
                        Text('Purchase strawberry cake from ChangAn bakery, insert an angpao of RM200 and send to address below.'),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Text ('RM300'),
                            IconButton(icon :Icon(Icons.bookmark),onPressed: (){},color: Colors.amber,),
                            IconButton(icon :Icon(Icons.send),onPressed: (){},color: Colors.amber),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              ),
            ),
            Container(
              width: 390,
              height: 180,
              child: Card(
                  elevation: 5,
                  child : ListTile(
                    onTap: (){},
                    leading : Column(
                      children: <Widget>[
                        CircleAvatar (backgroundImage : AssetImage('assets/sampleProfile_2.jpg'),radius: 25),
                      ],),
                    subtitle : Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text('Kai',style: TextStyle(color : Colors.lightBlue[900]),),
                          Divider(color: Colors.amber, thickness: 1.0,),
                          Text('Nanny service',style: TextStyle(fontSize: 16,color: Colors.black),),
                          Text('Need a 4 hours to take care of 3 months baby. PM for date and location.'),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Text ('RM120'),
                              IconButton(icon :Icon(Icons.bookmark),onPressed: (){},color: Colors.amber,),
                              IconButton(icon :Icon(Icons.send),onPressed: (){},color: Colors.amber),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
              ),
            ),
            Container(
              width: 390,
              height: 180,
              child: Card(
                  elevation: 5,
                  child : ListTile(
                    onTap: (){},
                    leading : Column(
                      children: <Widget>[
                        CircleAvatar (backgroundImage : AssetImage('assets/sampleProfile_3.jpg'),radius: 25),
                      ],),
                    subtitle : Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text('Angeline',style: TextStyle(color : Colors.lightBlue[900]),),
                          Divider(color: Colors.amber, thickness: 1.0,),
                          Text('Document translator needed',style: TextStyle(fontSize: 16,color: Colors.black),),
                          Text('Translate english documents to chinese.'),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Text ('RM30'),
                              IconButton(icon :Icon(Icons.bookmark),onPressed: (){},color: Colors.amber,),
                              IconButton(icon :Icon(Icons.send),onPressed: (){},color: Colors.amber),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
              ),
            ),
          ]
        ),
      ),
    );
  }
}
class Tags{
  String tagName;
  int tagCount;
  Tags(String tagName, int tagCount){
    this.tagName=tagName;
    this.tagCount=tagCount;

  }

}
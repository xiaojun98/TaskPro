import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_scaffold.dart';
import 'package:testapp/models/Profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testapp/models/Message.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:testapp/services/FullPhoto.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as Path;

import 'ViewProfile.dart';

class ChatWindow extends StatefulWidget {
  FirebaseUser user;
  Profile profile;
  String chatWindowID;
  ChatWindow({this.user,this.profile});
  _HomeState createState() => _HomeState(user,profile);
}

class _HomeState extends State<ChatWindow> {
  FirebaseUser user;
  Profile profile;
  String chatWindowID;
  _HomeState(this.user,this.profile);
  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();

  File imageFile;
  String imageUrl;
  bool isLoading;

  @override
  void initState(){
    super.initState();
    isLoading = false;
    if (user.uid.hashCode <= profile.id.hashCode) {
      chatWindowID = user.uid + profile.id;
    } else {
      chatWindowID = profile.id + user.uid;
    }
  }

  BoxShadow boxShadow(){
    return BoxShadow(
    color: Colors.grey,
    blurRadius: 1,
    spreadRadius: 0,
    offset: Offset(0.2, 0.5),);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title : Text(profile.name),
          actions: <Widget>[
            IconButton (
              icon: Icon(Icons.arrow_forward_ios),
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => ViewProfile(user : user, profile : profile)));
              },
            )
          ],
          elevation: 0.0,
          backgroundColor: Colors.amberAccent[400],
        ),

        body: Column(
          children: <Widget>[
            Expanded(
              child: Stack(
                children: <Widget>[
                  Column(
                  children: <Widget>[
                    // List of messages
                    _buildListMessage(),
                  ],
                ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 5),
              height: 70,
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  IconButton(
                    padding: EdgeInsets.fromLTRB(4, 8, 0, 8),
                    icon: Icon(Icons.photo),
                    iconSize: 25,
                    color: Theme.of(context).primaryColor,
                    onPressed: () {getImage();},
                  ),
                  IconButton(
                    padding: EdgeInsets.fromLTRB(0, 8, 4, 8),
                    icon: Icon(Icons.picture_as_pdf),
                    iconSize: 25,
                    color: Theme.of(context).primaryColor,
                    onPressed: () {
                      getFile();
                      },
                  ),
                  Expanded(
                    child: TextField(

                      onSubmitted: (msg){ onSendMessage(msg, 0); },
                      decoration: InputDecoration.collapsed(
                      hintText: 'Send a message..',
                      ),
                      controller: textEditingController,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    iconSize: 25,
                    color: Theme.of(context).primaryColor,
                    onPressed: () => onSendMessage(textEditingController.text, 0),
                  ),
                ],
              ),
            ),
          ],
        ),
    );

  }

  _buildListMessage(){
    return Flexible(
      child: StreamBuilder(
        stream: Firestore.instance
            .collection('message')
            .document(chatWindowID)
            .collection('msg')
            .orderBy('timestamp', descending: true)
//          .limit(_limit)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {

//        var listMessage = snapshot.data.documents;
          if(!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)));
          } else {
            List<Message> messageList = [];
            for (DocumentSnapshot doc in snapshot.data.documents) {
              Message message = new Message();
              message.content = doc.data['content'];
              message.idFrom = doc.data['idFrom'];
              message.idTo = doc.data['idTo'];
              message.type = doc.data['type'];
              message.timestamp = doc.data['timestamp'];
              messageList.add(message);
            }
            return ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.all(10.0),
              itemBuilder: (context, index) => buildItem((index>0 && messageList!= null && messageList[index].idFrom == user.uid || index == 0), messageList[index]),
              itemCount: snapshot.data.documents.length,
              reverse: true,
              controller: listScrollController,
            );
          }
        },
      ),
    );
  }

  Widget buildItem(bool isMeLast, Message msg) {
    if (msg.idFrom == user.uid) {
      // Right (my message)
      return Row(
        children: <Widget>[
          msg.type == 0
          // Text
              ? Container(
            child: Text(
              msg.content,
              style: TextStyle(color: Colors.black),
            ),
            padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
            width: 200.0,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  boxShadow()
                ],),
            margin: EdgeInsets.only(
                bottom: isMeLast ? 20.0 : 10.0,
                right: 10.0),
          )
              : msg.type == 1
          // Image
              ? Container(
            child: FlatButton(
              child: Material(
                child: CachedNetworkImage(
                  placeholder: (context, url) => Container(
                    child: CircularProgressIndicator(
                      valueColor:
                      AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                    ),
                    width: 200.0,
                    height: 200.0,
                    padding: EdgeInsets.all(70.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(
                        Radius.circular(8.0),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Material(
                    child: Image.asset(
                      'assets/no-image-available.png',
                      width: 200.0,
                      height: 200.0,
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(8.0),
                    ),
                    clipBehavior: Clip.hardEdge,
                  ),
                  imageUrl: msg.content,
                  width: 200.0,
                  height: 200.0,
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                clipBehavior: Clip.hardEdge,
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FullPhoto(
                            url: msg.content)));
              },
              padding: EdgeInsets.all(0),
            ),
            margin: EdgeInsets.only(
                bottom: isMeLast ? 20.0 : 10.0,
                right: 10.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              boxShadow: [
                boxShadow()
            ],),
          )
          // File
          : Container(
            width: 210.0,
//            height: 80.0,
            margin: EdgeInsets.only(
                bottom: isMeLast ? 20.0 : 10.0,
                right: 5.0),
            child: Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                  leading: Image.asset(
                      'assets/pdf-icon.png',
                      width: 35.0,
                      height: 35.0,
                      fit: BoxFit.cover,
                  ),
                  title: Text(msg.content.substring(117,(msg.content.indexOf('.pdf')+1)).replaceAll('%20', ' '),style: TextStyle(fontSize: 16,),),
                  subtitle: Text('Click to view', style: TextStyle(fontSize: 13),),
                  onTap: (){
                    loadFile(msg.content).then((path) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => viewFile(path)));
                    });
                  },
                ),
              ),
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    } else {
      // Left (peer message)
      return Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                !isMeLast
                    ? Material(
                  child: InkWell(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ViewProfile(user : user, profile : profile)));
                    },
                    child: CachedNetworkImage(
                      placeholder: (context, url) => Container(
                        child: CircularProgressIndicator(
                          strokeWidth: 1.0,
                          valueColor:
                          AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                        ),
                        width: 35.0,
                        height: 35.0,
                        padding: EdgeInsets.all(10.0),
                      ),
                      imageUrl: profile.profilepic,
                      width: 35.0,
                      height: 35.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(18.0),
                  ),
                  clipBehavior: Clip.hardEdge,
                )
                    : Container(width: 35.0),
                msg.type == 0
                    ? Container(
                  child: Text(
                    msg.content,
                    style: TextStyle(color: Colors.white),
                  ),
                  padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  width: 200.0,
                  decoration: BoxDecoration(
                      color: Colors.indigo,
                      borderRadius: BorderRadius.circular(8.0)),
                  margin: EdgeInsets.only(left: 10.0),
                )
                    : msg.type == 1
                    ? Container(
                  child: FlatButton(
                    child: Material(
                      child: CachedNetworkImage(
                        placeholder: (context, url) => Container(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).primaryColor),
                          ),
                          width: 200.0,
                          height: 200.0,
                          padding: EdgeInsets.all(70.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(
                              Radius.circular(8.0),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            Material(
                              child: Image.asset(
                                'assets/no-image-available.png',
                                width: 200.0,
                                height: 200.0,
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              clipBehavior: Clip.hardEdge,
                            ),
                        imageUrl: msg.content,
                        width: 200.0,
                        height: 200.0,
                        fit: BoxFit.cover,
                      ),
                      borderRadius:
                      BorderRadius.all(Radius.circular(8.0)),
                      clipBehavior: Clip.hardEdge,
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FullPhoto(
                                  url: msg.content)));
                    },
                    padding: EdgeInsets.all(0),
                  ),
                  margin: EdgeInsets.only(left: 10.0),
                )
                    : Container(
                  width: 210.0,
                  margin: EdgeInsets.only(
                      left : 10 ),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    color: Colors.indigo,
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                      leading: Image.asset(
                        'assets/pdf-icon.png',
                        width: 35.0,
                        height: 35.0,
                        fit: BoxFit.cover,
                      ),
                      title: Text(msg.content.substring(117,(msg.content.indexOf('.pdf')+1)).replaceAll('%20', ' '),style: TextStyle(fontSize: 16,color: Colors.white),),
                      subtitle: Text('Click to view', style: TextStyle(fontSize: 13, color : Colors.white),),
                      onTap: (){
                        loadFile(msg.content).then((path) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => viewFile(path)));
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),

            // Time
            !isMeLast
                ? Container(
              child: Text(
                DateFormat('dd MMM kk:mm').format(
                    DateTime.fromMillisecondsSinceEpoch(
                        int.parse(msg.timestamp))),
                style: TextStyle(
                    color: Colors.black12,
                    fontSize: 12.0,
                    fontStyle: FontStyle.italic),
              ),
              margin: EdgeInsets.only(left: 50.0, top: 5.0, bottom: 5.0),
            )
                : Container()
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        margin: EdgeInsets.only(bottom: 10.0),
      );
    }
  }

  Future uploadPhoto() async {
    String fileName = user.uid + '/messageFile/' + DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(imageFile);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      imageUrl = downloadUrl;
      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, 1);
      });
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: 'This file is not an image');
    });
  }

  Future getImage() async {
    imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (imageFile != null) {
      setState(() {
        isLoading = true;
      });
      uploadPhoto();
  }}

  Future uploadFile(File pdfFile, String pdfUrl) async {
    String baseName = Path.basename(pdfFile.path);
    String fileName = user.uid + '/messageFile/' + baseName;
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putData(pdfFile.readAsBytesSync());
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      pdfUrl = downloadUrl;
      setState(() {
        isLoading = false;
        onSendMessage(pdfUrl, 2);
      });
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: 'This file is not a PDF');
    });
  }

  Future getFile() async {
    File pdfFile;
    String pdfUrl;
    FilePickerResult result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if(result != null) {
      setState(() {
        isLoading = true;
        pdfFile = File(result.files.first.path);
      });
      uploadFile(pdfFile,pdfUrl);
    }
  }

  Future<String> loadFile(String url) async {
    final filename = 'taskpro.pdf';
    var request = await HttpClient().getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = new File('$dir/$filename');
    await file.writeAsBytes(bytes);
    print(file.path);
    return file.path;
  }

  Widget viewFile (String pdfPath) {
    print (pdfPath);
    return PDFViewerScaffold(
        appBar: AppBar(
          title: Text("PDF View"),
        ),
        path: pdfPath);
  }

  void onSendMessage(String content, int type) {
    // type: 0 = text, 1 = image, 2 = pdf
    String lastMsg;
    if(type == 0 ) { lastMsg = content;}
    else if (type ==1) { lastMsg = 'sent an image' ;}
    else { lastMsg = 'sent an PDF';}
    if (content.trim() != '') {
      textEditingController.clear();
      String documentID = DateTime.now().millisecondsSinceEpoch.toString();
      var documentReference = Firestore.instance
          .collection('message')
          .document(chatWindowID)
          .collection('msg')
          .document(documentID);

      var documentReference2 = Firestore.instance
          .collection('message')
          .document(chatWindowID.substring(28) + chatWindowID.substring(0,28));


      var documentReference3 = Firestore.instance
          .collection('message')
          .document(chatWindowID.substring(28) + chatWindowID.substring(0,28))
          .collection('msg')
          .document(documentID);

      var documentReference4 = Firestore.instance
          .collection('message')
          .document(chatWindowID);

      Firestore.instance.runTransaction((transaction) async {
        transaction.set(
          documentReference,
          {
            'idFrom': user.uid,
            'idTo': profile.id,
            'timestamp': documentID,
            'content': content,
            'type': type
          },
        );
      });
      Firestore.instance.runTransaction((transaction) async {
        transaction.update(documentReference2,
            {
              'lastTimestamp': documentID,
              'lastMessage': lastMsg,
            });
      });

      Firestore.instance.runTransaction((transaction) async {
        transaction.set(
          documentReference3,
          {
            'idFrom': user.uid,
            'idTo': profile.id,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': content,
            'type': type
          },
        );
      });
      Firestore.instance.runTransaction((transaction) async {
        transaction.update(documentReference4,
            {
              'lastTimestamp': documentID,
              'lastMessage': lastMsg,
            });
      });
//      Firestore.instance.runTransaction((transaction) async {
//        transaction.set(
//          documentReference2,
//            {
//              'lastTimestamp': DateTime
//                  .now()
//                  .millisecondsSinceEpoch
//                  .toString(),
//              'lastMessage': lastMsg,
//            });
//      });


      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(
          msg: 'Nothing to send',
          backgroundColor: Colors.black,
          textColor: Colors.red);
    }
  }

}



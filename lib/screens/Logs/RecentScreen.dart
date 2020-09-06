import 'dart:async';

import 'package:firebase/firebase.dart';
import 'package:flutter/material.dart';
import 'package:girvihisab/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';

class RecordScreen extends StatefulWidget {
  @override
  _RecordScreenState createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {

  Database db = database();
  List recents=List();
  

  StreamController recentsController = StreamController<bool>.broadcast();
  @override
  void initState() {
    db.ref("logs/${Utils.userId}").limitToLast(50).once("value").then((event) {
      debugPrint(event.toString());
      if(event.snapshot.val()!=null){
        Map logs=event.snapshot.val();
        logs.keys.forEach((element) {
          recents.add(logs[element]);
        });
        this.recents=this.recents.reversed.toList();
        recentsController.sink.add(true);
      }
    });
    super.initState();
  }


  @override
  void dispose() {
    recentsController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: recentsController.stream.asBroadcastStream(),
      builder: (context, snapshot) {
        if(snapshot.hasData && snapshot.data){
          return ListView.builder(itemBuilder: (context,index){
            var time=DateTime.fromMillisecondsSinceEpoch(int.parse(recents[index]['timeStamp']));
            return ListTile(
              leading: Icon(Icons.history,color: Colors.orange,),
              title: Text(recents[index]['text']),
              subtitle: Text(Jiffy(time).yMMMEdjm),
            );
          },itemCount: recents.length,);
        }
        return Center(child: CircularProgressIndicator());
      }
    );
  }
}

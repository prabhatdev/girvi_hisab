import 'dart:convert';

import 'package:firebase/firebase.dart';
import 'package:flutter/material.dart';
import 'package:girvihisab/main.dart';
import 'package:girvihisab/screens/AddItem/AddItemScreen.dart';
import 'package:girvihisab/screens/SearchItem/SearchItemScreen.dart';
import 'package:girvihisab/utils/constants.dart';
import 'package:girvihisab/utils/utils.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex=0;
  Database db = database();


  static List<Widget> _widgetOptions = <Widget>[
    SearchItemScreen(),
    AddItemScreen(),
    Text(
      'Orders'
    ),
  ];



  @override
  void initState() {
    super.initState();
    Utils.getPrefs().then((prefs) {
      String userId=prefs.getString(USER_ID);
      db.ref("users/$userId").onValue.listen((event) {
          if(event.snapshot.val()!=null){
            String json=jsonEncode(event.snapshot.val());
            prefs.setString(ALL_DATA, json);
          }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text("Home"),
            actions: [
              IconButton(
                icon: Icon(Icons.settings_power),
                onPressed: (){
                  Utils.getPrefs().then((prefs){
                    prefs.clear();
                    Navigator.pushNamedAndRemoveUntil(context, Routes.LOGIN,(Route<dynamic> route) => false);
                  });
                },
              )
            ],
          ),
        body: Center(
          child: _widgetOptions.elementAt(selectedIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              title: Text('Search'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add),
              title: Text('Add New'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.keyboard_return),
              title: Text('Return'),
            ),
          ],
          currentIndex: selectedIndex,
          onTap: (index){
            setState(() {
              selectedIndex=index;
            });
          },
        ),
      ),
    );
  }
}

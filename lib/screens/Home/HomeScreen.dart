import 'dart:async';
import 'dart:convert';

import 'package:firebase/firebase.dart';
import 'package:flutter/material.dart';
import 'package:girvihisab/main.dart';
import 'package:girvihisab/screens/AddItem/AddItemScreen.dart';
import 'package:girvihisab/screens/SearchItem/SearchItemScreen.dart';
import 'package:girvihisab/utils/constants.dart';
import 'package:girvihisab/utils/utils.dart';
import 'package:rxdart/subjects.dart';



class HomeScreen extends StatefulWidget {

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex=0;
  Database db = database();
  StreamController loadingController=StreamController<bool>.broadcast();
  List<Widget> _widgetOptions = <Widget>[
    SearchItemScreen(),
    AddItemScreen(),
    Text(
      'Orders'
    ),
  ];


  @override
  void dispose() {
    super.dispose();
    loadingController.close();
  }

  @override
  void initState() {
    super.initState();
  }

  fetchAlldata(){
    Utils.getPrefs().then((prefs) {
      String userId=prefs.getString(USER_ID);
      db.ref("users/$userId").onValue.listen((event) {
        if(event.snapshot.val()!=null){
          Utils.setRates(event.snapshot.val());
          loadingController.sink.add(true);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    fetchAlldata();
    return StreamBuilder<bool>(
      stream: loadingController.stream.asBroadcastStream(),
      builder: (context, snapshot) {
        if(snapshot.hasData && snapshot.data)
        return Center(
          child: Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                title: Text("Home"),
                centerTitle: true,
                actions: [
                  IconButton(
                    icon: Icon(Icons.add_circle),
                    tooltip: "Add",
                    onPressed: (){
                      showDialog(context: context,builder: (context){
                        GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
                        TextEditingController goldRateController = TextEditingController();
                         TextEditingController goldTunchRateController = TextEditingController();
                         TextEditingController silverRateController = TextEditingController();
                         TextEditingController silverTunchRateController = TextEditingController();
                         goldRateController.text=Utils.goldRate;
                         goldTunchRateController.text=Utils.goldTunchRate;
                         silverRateController.text=Utils.silverRate;
                         silverTunchRateController.text=Utils.silverTunchRate;
                        return AlertDialog(
                          title: Text("Update Rates"),
                          content: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextFormField(
                                  controller: goldRateController,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Please enter rate of gold';
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.numberWithOptions(signed: false,decimal: true),
                                  decoration: InputDecoration(
                                      hintText: 'Rate in ₹/10g',
                                      labelText: 'Rate Of Gold', suffixText: "per 10g"),
                                ),
                                SizedBox(height: 20,),
                                TextFormField(
                                  controller: silverRateController,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Please enter rate of silver';
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.numberWithOptions(signed: false,decimal: true),
                                  decoration: InputDecoration(
                                      hintText: 'Rate in ₹/Kg',
                                      labelText: 'Rate Of Silver', suffixText: "per Kg"),
                                ),

                                SizedBox(height: 20,),
                                TextFormField(
                                  controller: goldTunchRateController,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Please enter gold tunch';
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.numberWithOptions(signed: false,decimal: true),
                                  decoration: InputDecoration(
                                      hintText: 'Tunch in %',
                                      labelText: 'Gold Tunch', suffixText: "%"),
                                ),

                                SizedBox(height: 20,),
                                TextFormField(
                                  controller: silverTunchRateController,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Please enter silver tunch';
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.numberWithOptions(signed: false,decimal: true),
                                  decoration: InputDecoration(
                                      hintText: 'Tunch in %',
                                      labelText: 'Silver Tunch', suffixText: "%"),
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            FlatButton(
                              child: Text("Cancel"),
                              onPressed: (){
                                Navigator.pop(context);
                              },
                            ),
                            FlatButton(
                              child: Text("Submit"),
                              onPressed: () async {
                                if(_formKey.currentState.validate()) {
                                  await db.ref("users/${Utils.userId}/rates").set({
                                    'gold_rate': goldRateController.text,
                                    'gold_tunch_rate': goldTunchRateController.text,
                                    'silver_rate': silverRateController.text,
                                    'silver_tunch_rate': silverTunchRateController.text,
                                  });
                                  Navigator.pop(context);
                                }
                              },
                            ),

                          ],
                        );
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.settings_power),
                    tooltip: 'Logout',
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
        else
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Loading data"),
                  CircularProgressIndicator()
                ],
              ),
            ),
          );
      }
    );
  }
}

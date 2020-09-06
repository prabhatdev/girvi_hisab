import 'dart:async';
import 'dart:convert';

import 'package:firebase/firebase.dart';
import 'package:flutter/material.dart';
import 'package:girvihisab/main.dart';
import 'package:girvihisab/screens/AddItem/AddItemScreen.dart';
import 'package:girvihisab/screens/Logs/RecentScreen.dart';
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
    RecordScreen(),
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

  fetchAlldata(BuildContext context){
    Utils.getPrefs().then((prefs) {
      String userId=prefs.getString(USER_ID);
      db.ref("users/$userId").onValue.listen((event) {
        if(event.snapshot.val()!=null){
          Utils.setRates(event.snapshot.val());
          if(Utils.goldRate.isEmpty || Utils.silverRate.isEmpty){
            updateRates(context);
          }
          loadingController.sink.add(true);
        }
      });
    });
  }

  updateRates(context){
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
                  'silver_rate': silverRateController.text,
                });
                Utils.goldRate=goldRateController.text;
                Utils.silverRate=silverRateController.text;
                Navigator.pop(context);
              }
            },
          ),
        ],
      );
    }).then((value) {
      if(Utils.silverRate.isEmpty || Utils.goldRate.isEmpty){
        Utils.showToast("Please enter the rates first.");
        updateRates(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    fetchAlldata(context);
    return StreamBuilder<bool>(
      stream: loadingController.stream.asBroadcastStream(),
      builder: (context, snapshot) {
        if(snapshot.hasData && snapshot.data)
        return Center(
          child: Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                title: Text("Girvi Hisab"),
                centerTitle: true,
                actions: [
                  IconButton(
                    icon: Icon(Icons.add_circle),
                    tooltip: "Update Rates",
                    onPressed: (){
                      updateRates(context);
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
            body: _widgetOptions.elementAt(selectedIndex),
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
                  icon: Icon(Icons.history),
                  title: Text('Recent'),
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

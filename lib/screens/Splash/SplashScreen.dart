import 'dart:convert';

import 'package:firebase/firebase.dart';
import 'package:flutter/material.dart';
import 'package:girvihisab/main.dart';
import 'package:girvihisab/utils/constants.dart';
import 'package:girvihisab/utils/utils.dart';

class SplashScreen extends StatelessWidget {

  Database db = database();


  checkIsLoggedIn(BuildContext context){
    Utils.getPrefs().then((prefs){
      if(prefs.getBool(IS_LOGGED_IN)==null || !prefs.getBool(IS_LOGGED_IN)){
        Navigator.pushReplacementNamed(context,Routes.LOGIN);
      }
      else{
        Utils.userId=prefs.getString(USER_ID);

        db.ref("users/${Utils.userId}").once("value").then((event) {
          debugPrint(event.toString());
          if(event.snapshot.val()!=null){
            Utils.setRates(event.snapshot.val());
            Navigator.pushReplacementNamed(context, Routes.HOME);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    checkIsLoggedIn(context);
    return Scaffold(
      body: Center(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text("Girvi Hisab",style: TextStyle(fontSize: 100,),),
              CircularProgressIndicator(),
              Text("Product of Amar Jewellers")
            ],
          ),
        ),
      ),
    );
  }
}

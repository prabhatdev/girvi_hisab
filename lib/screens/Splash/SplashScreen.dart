import 'package:flutter/material.dart';
import 'package:girvihisab/main.dart';
import 'package:girvihisab/utils/constants.dart';
import 'package:girvihisab/utils/utils.dart';

class SplashScreen extends StatelessWidget {

  checkIsLoggedIn(BuildContext context){
    Utils.getPrefs().then((prefs){
      if(prefs.getBool(IS_LOGGED_IN)!=null){
        Navigator.pushReplacementNamed(context,Routes.HOME);
      }
      else{
        Navigator.pushReplacementNamed(context, Routes.LOGIN);
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

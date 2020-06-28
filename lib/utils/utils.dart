
import 'dart:io';

import 'package:firebase/firebase.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum filters{
  NAME,
  DATE,
  VALUE,
  ITEM_TYPE,
  ITEM_NAME
}

class Utils {
  static bool isiOS = Platform.isIOS;


  static SnackBar getSnackBarTime(String message, int time) => SnackBar(
    content: Text(message),
    duration: Duration(seconds: time),

  );

  static final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

  static SnackBar getSnackBar(String message) => SnackBar(content: Text(message));

  static Future<SharedPreferences> getPrefs() async {
    SharedPreferences preferences=await SharedPreferences.getInstance();
    return preferences;
  }

  static bool isValidEmail(String email) {
    return RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$")
        .hasMatch(email);
  }

  static Color getColors(int pos) {
    List<Color> colors = [Color(0xFF9B2A1A), Color(0xFFE98120), Color(0xFF75542C)];
    return colors[pos];
  }

  static showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        webPosition:"center" ,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        webBgColor: "linear-gradient(to right, #607D8B, #607D8B)",
        backgroundColor: Colors.blueGrey,
        textColor: Colors.white,
        fontSize: 16.0);
  }



  static Widget errorWidget(Function stateFunction, {String msg, icon: Icons.error_outline}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ClipRRect(
            borderRadius: new BorderRadius.circular(15.0),
            child: Image.network(
              "https://hungerstay.s3.ap-south-1.amazonaws.com/appAssets/internalError.jpg",
            )),
        (msg != null)
            ? Text(
          msg,
          style: TextStyle(fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        )
            : SizedBox.shrink(),
        Text(
          "Looks like our overpaid engineers messed up!\n-Poor Inters",
          style: TextStyle(fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: 10,
        ),
        FlatButton(
          onPressed: () {
            stateFunction();
          },
          child: Text(
            "RETRY",
            style: TextStyle(color: Colors.white),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          color: Colors.orangeAccent,
        )
      ],
    );
  }



}
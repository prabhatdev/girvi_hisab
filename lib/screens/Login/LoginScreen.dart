import 'dart:convert';

import 'package:firebase/firebase.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:girvihisab/main.dart';
import 'package:girvihisab/utils/constants.dart';
import 'package:girvihisab/utils/utils.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final TextEditingController userNameController=TextEditingController();
  final TextEditingController passwordController=TextEditingController();

  Database db = database();


  Future<bool> isCorrect(){
    return db.ref("users/${userNameController.text}").once('value').then((value) async {
      if(value.snapshot.val()!=null){
        if(value.snapshot.val()['password']==passwordController.text){
          db.ref("users/${userNameController.text}/last_login").set(DateTime.now().millisecondsSinceEpoch.toString());
          return true;
        }
        return false;
      }
      return false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text("Login"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(15),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text("Login",style: TextStyle(fontSize: 30),),
                TextFormField(
                  validator: (value){
                    if(value.isEmpty){
                      return 'Enter username';
                    }
                    return null;
                  },
                  controller: userNameController,
                  decoration: InputDecoration(
                    hintText: 'Username',
                    labelText: 'Username'
                  ),
                ),
                TextFormField(
                  validator: (value){
                    if(value.isEmpty){
                      return 'Enter password';
                    }
                    return null;
                  },
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                      hintText: 'Password',
                      labelText: 'Password',
                  ),
                ),
                RaisedButton(
                  child: Text("Login",style: TextStyle(fontSize: 20,color: Colors.white),),
                  onPressed: (){

                    if(_formKey.currentState.validate()){
                      isCorrect().then((value) {
                        if(value){
                          Utils.getPrefs().then((prefs){
                            prefs.setBool(IS_LOGGED_IN, true);
                            prefs.setString(USER_ID,userNameController.text);
                                String userId=userNameController.text;
                                db.ref("users/$userId").once("value").then((event) {
                                  debugPrint(event.toString());
                                  if(event.snapshot.val()!=null){
                                    String json=jsonEncode(event.snapshot.val());
                                    Utils.allData=json;
                                    Navigator.pushReplacementNamed(context, Routes.HOME);
                                  }
                            });
                          });
                        }
                        else{
                          Utils.showToast("Invalid credentials");
                        }
                      });
                    }
                  },
                ),
                InkWell(
                    onTap: (){
                          Navigator.pushNamed(context, Routes.SIGN_UP);
                    },
                    child: Text("No Account? Sign Up",style: TextStyle(fontSize: 20),))
              ],
            ),
          ),
        ));
  }
}

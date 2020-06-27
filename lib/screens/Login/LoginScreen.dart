import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:girvihisab/main.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Login"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text("Login",style: TextStyle(fontSize: 30),),
              TextField(
                decoration: InputDecoration(
                  hintText: 'User Name'
                ),
              ),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                    hintText: 'Password'
                ),
              ),
              RaisedButton(
                child: Text("Login",style: TextStyle(fontSize: 20,color: Colors.white),),
                onPressed: (){},
              ),
              InkWell(
                  onTap: (){
                        Navigator.pushNamed(context, Routes.SIGN_UP);
                  },
                  child: Text("No Account? Sign Up",style: TextStyle(fontSize: 20),))
            ],
          ),
        ));
  }
}

import 'package:firebase/firebase.dart';
import 'package:flutter/material.dart';
import 'package:girvihisab/utils/utils.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final TextEditingController passwordController=TextEditingController();
  final TextEditingController userNameController=TextEditingController();
  final TextEditingController nameController=TextEditingController();
  final TextEditingController shopNameController=TextEditingController();
  bool isUserNameExist=false;

  Database db = database();

  Future<bool> checkIfUserIdExist(String userId){
    return db.ref("users/$userId").once('value').then((value){
      if(value.snapshot.val()!=null)
        return false;
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Sign Up"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(15),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text("Sign Up",style: TextStyle(fontSize: 30),),
                TextFormField(
                  controller: nameController,
                  validator: (value){
                    if(value.isEmpty){
                      return 'Please enter name';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      labelText: 'Name'
                  ),
                ),
                TextFormField(
                  controller: shopNameController,
                  validator: (value){
                    if(value.isEmpty){
                      return 'Please enter shop name';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      labelText: 'ABC Jewellers',
                      hintText: 'Shop Name'
                  ),
                ),
                TextFormField(
                    controller: userNameController,
                  validator: (value){
                    if(value.isEmpty){
                      return 'Please enter name';
                    }
                    if(!this.isUserNameExist){
                      return "UserName already exist";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      hintText: 'Unique name',
                      labelText: 'User Name',
                  ),
                ),
                TextFormField(
                  validator: (value){
                    if(value.isEmpty){
                      return 'Please enter password';
                    }
                    return null;
                  },
                  obscureText: true,
                  controller: passwordController,
                  decoration: InputDecoration(
                      hintText: 'Password'
                  ),
                ),
                TextFormField(
                  validator: (value){
                    if(value.isEmpty){
                      return 'Please enter confirm password';
                    }
                    else if(value!=passwordController.text){
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  obscureText: true,
                  decoration: InputDecoration(
                      hintText: 'Confirm Password'
                  ),
                ),
                RaisedButton(
                  child: Text("Sign Up",style: TextStyle(fontSize: 20,color: Colors.white),),
                  onPressed: () async {
                    this.isUserNameExist= await checkIfUserIdExist(userNameController.text);
                    if(_formKey.currentState.validate()){
                      db.ref("users/${userNameController.text}").set(({
                        'name':nameController.text,
                        'shop_name':shopNameController.text,
                        'time':DateTime.now().millisecondsSinceEpoch,
                        'password':passwordController.text
                      })).then((value) {
                        Utils.showToast("Registration successful");
                        Navigator.pop(context);
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ));
  }
}

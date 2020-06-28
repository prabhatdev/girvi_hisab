import 'package:flutter/material.dart';
import 'package:girvihisab/main.dart';
import 'package:girvihisab/utils/utils.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex=0;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Scaffold(
          appBar: AppBar(
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
          body: Column(
            children: [

            ],
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

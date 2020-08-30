import 'package:flutter/material.dart';
import 'package:girvihisab/main.dart';
import 'package:girvihisab/utils/utils.dart';
import 'package:intl/intl.dart';

class SearchResultScreen extends StatefulWidget {
  @override
  _SearchResultScreenState createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  List customers = List();
  final df = new DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context).settings.arguments as Map;
    customers = arguments['result'] as List;
    return Scaffold(
      appBar: AppBar(
        title: Text("Search Result"),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          var customer = customers[index];
          String items='';
          (customer['items'] as Map).keys.toList().forEach((element) {
            items+='$element, ';
          });
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              color: Colors.white,
              child: ListTile(
                onTap: (){
                    Navigator.pushNamed(context, Routes.ORDER,arguments: {"key":customer["key"],"name":customer['name']});
                },
                subtitle: Text(items),
                title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person),
                      Text(customers[index]['name']),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.calendar_today),
                      Text(df.format(DateTime.fromMillisecondsSinceEpoch(int.parse(customers[index]['date'])))),
                    ],
                  ),
                  Row(
                    children: [
                      Text("₹"+customers[index]['principle']),
                    ],
                  ),
                ],
              )),
            ),
          );
        },
        shrinkWrap: true,
        itemCount: customers.length,
      ),
    );
  }
}

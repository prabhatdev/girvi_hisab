import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SearchResultScreen extends StatefulWidget {
  @override
  _SearchResultScreenState createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  List customers=List();
  final df = new DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context).settings.arguments as Map;
    customers=arguments['result'] as List;
    return Scaffold(
      appBar: AppBar(
        title: Text("Search Result"),
      ),
      body: ListView.builder(itemBuilder: (context,index){
        return Padding(
          padding: const EdgeInsets.only(left: 20,right: 20),
          child: Card(
            elevation: 10,
            child: Container(
              height: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          children: [
                            Text('Name:',style: TextStyle(fontWeight: FontWeight.bold),),
                            Text(customers[index]['name']),
                          ],
                        ),
                        Row(
                          children: [
                            Text('Item Name:',style: TextStyle(fontWeight: FontWeight.bold),),
                            Text(customers[index]['item_name']),
                          ],
                        ),
                        Row(
                          children: [
                            Text('Date:',style: TextStyle(fontWeight: FontWeight.bold),),
                            Text(df.format(DateTime.fromMillisecondsSinceEpoch(int.parse(customers[index]['date'])))),
                          ],
                        )
                      ],
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        children: [
                          Text('Item Type:',style: TextStyle(fontWeight: FontWeight.bold),),
                          Text(customers[index]['item_types']),
                        ],
                      ),
                      Row(
                        children: [
                          Text('Price:',style: TextStyle(fontWeight: FontWeight.bold),),
                          Text(customers[index]['value']),
                        ],
                      ),
                      Row(
                        children: [
                          Text('Interest: ',style: TextStyle(fontWeight: FontWeight.bold),),
                          Text('${customers[index]['interest']}%/${customers[index]['interest_type']}'),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },shrinkWrap: true,itemCount: customers.length,),
    );
  }
}

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
        var customer=customers[index];
        DateTime then=DateTime.fromMillisecondsSinceEpoch(int.parse(customer['date']));
        int days=DateTime.now().difference(then).inDays;
        double totalInterest=0;
        double interestRate=double.parse(customer['interest']);
        double principle=double.parse(customer['value']);
        if(customer['interest_type']=='monthly'){
          totalInterest=(interestRate*principle*days)/(100*30);
        }
        else{
          totalInterest=(interestRate*principle*days)/(365*100);
        }
        double totalAmount=double.parse(customer['value'])+totalInterest;
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
                          Text('Principle:',style: TextStyle(fontWeight: FontWeight.bold),),
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
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        children: [
                          Text('Weight: ',style: TextStyle(fontWeight: FontWeight.bold),),
                          Text(customers[index]['weight']??''),
                        ],
                      ),
                      Row(
                        children: [
                          Text('Interest Amount: ',style: TextStyle(fontWeight: FontWeight.bold),),
                          Text(totalInterest.toStringAsFixed(3)),
                        ],
                      ),
                      Row(
                        children: [
                          Text('Return Amount: ',style: TextStyle(fontWeight: FontWeight.bold),),
                          Text(totalAmount.toStringAsFixed(3)),
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

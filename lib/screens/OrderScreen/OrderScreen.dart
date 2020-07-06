import 'dart:async';

import 'package:firebase/firebase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart';
import 'package:girvihisab/screens/AddItem/AddItemScreen.dart';
import 'package:girvihisab/utils/constants.dart';
import 'package:girvihisab/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart' as dp;
import 'package:string_validator/string_validator.dart';

class OrderScreen extends StatefulWidget {
  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  Map orderDetails = {};
  final df = new DateFormat('dd/MM/yyyy');
  List items = [];
  double interestAmount = 0;
  double principleAmount = 0;
  double totalAmount = 0;
  List<Settlement> settlement = List<Settlement>();

  StreamController settlementsController = StreamController.broadcast();

  Database db = database();
  double todayValue = 0;

  @override
  void dispose() {
    super.dispose();
    settlementsController.close();
  }

  DateTime tillDate = DateTime.now();

  double interest(DateTime d1, DateTime d2, double interestRate, double principle, bool isMonthly) {
    int days = d2.difference(d1).inDays;
    double totalInterest = 0;
    if (isMonthly) {
      totalInterest = (interestRate * principle * days) / (100 * 30);
    } else {
      totalInterest = (interestRate * principle * days) / (365 * 100);
    }
    return totalInterest;
  }

  initialiseAll(settlements) {
    settlement.add(
        Settlement(principle: double.parse(orderDetails['principle']), date: DateTime.fromMillisecondsSinceEpoch(int.parse(orderDetails['date']))));

    if (settlements != null) {
      var settlementList = [];
      (settlements as List).forEach((element) {
        settlementList.add(element);
      });

      settlementList.forEach((element) {
        settlement.add(Settlement(
            principle: double.parse(element['amount']),
            date: DateTime.fromMillisecondsSinceEpoch(int.parse(element['date'])),
            remark: element['remarks'] ?? ''));
      });
    }
    findSettlements(false);
  }

  updateData() {
    var dataToSet = {};
    for (int i = 1; i < settlement.length; i++) {
      dataToSet[(i - 1).toString()] = {
        'date': settlement[i].date.millisecondsSinceEpoch.toString(),
        'amount': settlement[i].principle.toString(),
        'remarks': settlement[i].remark ?? ''
      };
    }
    db.ref("users/${Utils.userId}/customers/${orderDetails['name']}/${orderDetails['key']}/settlements").set(dataToSet);
  }

  findSettlements(bool isUpdate) {
    settlement.sort((a, b) {
      return (a.date.millisecondsSinceEpoch < b.date.millisecondsSinceEpoch) ? -1 : 1;
    });
    if (isUpdate) updateData();
    for (int i = 0; i < settlement.length; i++) {
      settlement[i].interest = interest(
          settlement[i].date, tillDate, double.parse(orderDetails['interest']), settlement[i].principle, orderDetails['interest_type'] == 'monthly');
    }
    double totalInterest = settlement.first.interest;
    double totalPrinciple = settlement.first.principle;

    Settlement t = settlement.first;
    settlement.removeAt(0);
    settlement.forEach((element) {
      totalInterest = totalInterest - element.interest;
      totalPrinciple = totalPrinciple - element.principle;
    });

    interestAmount = totalInterest;
    principleAmount = totalPrinciple;

    settlement.insert(0, t);

    totalAmount = totalPrinciple + totalInterest;
    isProfitable();
    settlementsController.sink.add(null);
  }

  isProfitable() {
    var items = [];
    (orderDetails['items'] as Map).forEach((key, value) {
      items.add(value);
    });
    todayValue = 0;
    items.forEach((element) {
      if (element['item_type'] == 'silver') {
        double weight = double.parse(element['weight']);
        double tunch = double.parse(element['tunch']);
        double rate = double.parse(Utils.silverRate);
        if (element['weight_type'] == 'g') {
          rate = rate / 1000;
        } else if (element['weight_type'] == 'mg') {
          rate = rate / 1000000;
        }
        todayValue += weight * tunch * rate / 100;
      } else {
        double rate = double.parse(Utils.goldRate);
        double weight = double.parse(element['weight']);
        double tunch = double.parse(element['tunch']);
        if (element['weight_type'] == 'g') {
          rate = rate / 10;
        } else if (element['weight_type'] == 'mg') {
          rate = rate / 10000;
        }
        todayValue += weight * tunch * rate / 100;
      }
    });
  }

  Widget buildDatePicker(Function onSelected) {
    // add some colors to default settings
    DatePickerRangeStyles styles = DatePickerRangeStyles(
      selectedPeriodLastDecoration:
          BoxDecoration(color: Colors.red, borderRadius: BorderRadius.only(topRight: Radius.circular(10.0), bottomRight: Radius.circular(10.0))),
      selectedPeriodStartDecoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), bottomLeft: Radius.circular(10.0)),
      ),
      selectedPeriodMiddleDecoration: BoxDecoration(color: Colors.yellow, shape: BoxShape.rectangle),
    );

    return dp.DayPicker(
      firstDate: DateTime.fromMillisecondsSinceEpoch(0),
      lastDate: DateTime.now().add(Duration(
        days: 31,
      )),
      selectedDate: DateTime.now(),
      onChanged: onSelected,
      datePickerStyles: styles,
    );
  }

  addSettlement(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          final TextEditingController dateController = TextEditingController();
          final TextEditingController amountController = TextEditingController();
          final TextEditingController remarksController = TextEditingController();
          final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
          return AlertDialog(
            title: Text("Add Settlement"),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    keyboardType: TextInputType.datetime,
                    controller: dateController,
                    validator: (value) {
                      if (!RegExp(DATE_EXP).hasMatch(value)) {
                        return 'Invalid date format';
                      }
                      return null;
                    },
                    autofocus: false,
                    decoration: InputDecoration(
                        labelText: 'Date',
                        hintText: '25/05/2020',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.calendar_today),
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    contentPadding: EdgeInsets.all(0),
                                    title: Text("Select Date"),
                                    content: buildDatePicker((DateTime date) {
                                      dateController.text = df.format(date);
                                      Navigator.pop(context);
                                    }),
                                  );
                                });
                          },
                        )),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: amountController,
                    autofocus: false,
                    inputFormatters: [DecimalTextInputFormatter()],
                    keyboardType: TextInputType.numberWithOptions(signed: false, decimal: true),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter amount';
                      }

                      if (!isFloat(value) && !isInt(value)) {
                        return 'Enver valid amount';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Amount',
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: remarksController,
                    autofocus: false,
                    keyboardType: TextInputType.text,
                    maxLength: 25,
                    decoration: InputDecoration(labelText: 'Remarks', hintText: 'Max 25 chars allowed'),
                  )
                ],
              ),
            ),
            actions: [
              FlatButton(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text("Submit"),
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    Navigator.pop(context, {
                      'date': df.parse(dateController.text).millisecondsSinceEpoch.toString(),
                      'amount': amountController.text,
                      'remarks': remarksController.text
                    });
                  }
                },
              ),
            ],
          );
        }).then((value) {
      if (value != null) {
        DateTime date = DateTime.fromMillisecondsSinceEpoch(int.parse(value['date']));
        int doesExist = settlement.indexWhere((element) {
          return element.date.millisecondsSinceEpoch == date.millisecondsSinceEpoch;
        });
        if (doesExist == -1) {
          settlement.add(Settlement(principle: double.parse(value['amount']), date: date, remark: value['remarks']));
          findSettlements(true);
        } else {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Date already exist!"),
                  actions: [
                    FlatButton(
                      onPressed: () {
                        settlement[doesExist].principle += double.parse(value['amount']);
                        Navigator.pop(context);
                      },
                      child: Text("Add to current date"),
                    ),
                    FlatButton(
                      onPressed: () {
                        settlement[doesExist].principle = double.parse(value['amount']);
                        Navigator.pop(context);
                      },
                      child: Text("Set new Amount"),
                    ),
                  ],
                );
              }).then((value) {
            findSettlements(true);
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    orderDetails = ModalRoute.of(context).settings.arguments as Map;
    items = (orderDetails['items'] as Map).keys.toList();
    initialiseAll(orderDetails['settlements']);
    return Scaffold(
      appBar: AppBar(
        title: Text("Girvi Details"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: EdgeInsets.all(10),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Name: ",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "${Utils.capitalize(orderDetails['name'])}",
                          style: TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text("Date: ", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        Text("${df.format(DateTime.fromMillisecondsSinceEpoch(int.parse(orderDetails['date'].toString())))}",
                            style: TextStyle(fontSize: 15)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: EdgeInsets.all(10),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      children: [
                        Text("Principle: ", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        Text("₹${orderDetails['principle']}", style: TextStyle(fontSize: 15)),
                      ],
                    ),
                    Row(
                      children: [
                        Text("Interest: ", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        Text("${orderDetails['interest']}%${orderDetails['interest_type']}", style: TextStyle(fontSize: 15)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Items: ", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: EdgeInsets.all(10),
                color: Colors.white,
                child: DataTable(
                  horizontalMargin: 15,
                  columnSpacing: 30,
                  columns: [
                    DataColumn(label: Text("Name", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text("Type", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text("Weight", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text("Tunch", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
                  ],
                  rows: List.generate(items.length, (index) {
                    var item = orderDetails['items'][items[index]];
                    return DataRow(cells: <DataCell>[
                      DataCell(Text(Utils.capitalize(item['name']),
                          style: TextStyle(
                            fontSize: 15,
                          ))),
                      DataCell(Text(item['item_type'],
                          style: TextStyle(
                            fontSize: 15,
                          ))),
                      DataCell(Text('${item['weight']}${item['weight_type']}',
                          style: TextStyle(
                            fontSize: 15,
                          ))),
                      DataCell(Text('${item['tunch']}%',
                          style: TextStyle(
                            fontSize: 15,
                          ))),
                    ]);
                  }),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Settlements: ", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.all(10),
                child: StreamBuilder(
                    stream: settlementsController.stream.asBroadcastStream(),
                    builder: (context, snapshot) {
                      return DataTable(
                        horizontalMargin: 15,
                        columnSpacing: 30,
                        columns: [
                          DataColumn(label: Text("Date", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("Amount", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("Remarks", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("Delete", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
                        ],
                        rows: List.generate(settlement.length, (index) {
                          return DataRow(cells: [
                            DataCell(Text(df.format(settlement[index].date), style: TextStyle(fontSize: 15))),
                            DataCell(Text('₹${settlement[index].principle.toStringAsFixed(3)}',
                                style: TextStyle(fontSize: 15, color: (index != 0) ? Colors.green : Colors.red))),
                            DataCell(Container(
                                width: 80,
                                child: Flexible(
                                    fit: FlexFit.tight,
                                    child: Text(
                                      settlement[index].remark ?? '',
                                    )))),
                            (index == 0)
                                ? DataCell(SizedBox.shrink())
                                : DataCell(IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      settlement.removeAt(index);
                                      findSettlements(true);
                                    },
                                  ))
                          ]);
                        }),
                      );
                    }),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Click"),
                IconButton(
                  icon: Icon(Icons.add_circle),
                  onPressed: () {
                    addSettlement(context);
                  },
                ),
                Text("to add more settlements"),
              ],
            ),
            StreamBuilder(
                stream: settlementsController.stream.asBroadcastStream(),
                builder: (context, snapshot) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          padding: EdgeInsets.all(10),
                          color: Colors.white,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Row(
                                children: [
                                  Text("Interest: ", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                  Text('₹${interestAmount.toStringAsFixed(3)}', style: TextStyle(fontSize: 15)),
                                ],
                              ),
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Text("Amount: ", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                      Text('₹${totalAmount.toStringAsFixed(3)}', style: TextStyle(fontSize: 15)),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text("${df.format(tillDate)}"),
                                      FlatButton(
                                        child: Icon(Icons.calendar_today),
                                        onPressed: () {
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  contentPadding: EdgeInsets.all(0),
                                                  title: Text("Select Date"),
                                                  content: buildDatePicker((DateTime date) {
                                                    tillDate = date;
                                                    findSettlements(true);
                                                    Navigator.pop(context);
                                                  }),
                                                );
                                              });
                                        },
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          padding: EdgeInsets.all(10),
                          color: Colors.white,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Row(
                                children: [
                                  Text("Today's rate ", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                  Text('₹${todayValue.toStringAsFixed(3)}',
                                      style: TextStyle(fontSize: 15, color: (totalAmount > todayValue) ? Colors.green : Colors.red)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Final Hisaab: ", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ),
            StreamBuilder(
                stream: settlementsController.stream.asBroadcastStream(),
                builder: (context, snapshot) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      color: Colors.white,
                      padding: EdgeInsets.all(10.0),
                      child: DataTable(
                        horizontalMargin: 5,
                        columnSpacing: 10,
                        columns: [
                          DataColumn(label: Text('Date', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Interest', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Amount', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Todays Value', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
                        ],
                        rows: [
                          DataRow(cells: [
                            DataCell(Text(df.format(tillDate), style: TextStyle(fontSize: 15))),
                            DataCell(Text("₹${interestAmount.toStringAsFixed(3)}", style: TextStyle(fontSize: 15))),
                            DataCell(Text("₹${totalAmount.toStringAsFixed(3)}", style: TextStyle(fontSize: 15))),
                            DataCell(Text("₹${todayValue.toStringAsFixed(3)}", style: TextStyle(fontSize: 15))),
                          ])
                        ],
                      ),
                    ),
                  );
                })
          ],
        ),
      ),
    );
  }
}

class Settlement {
  double principle;
  double interest;
  String remark = '';
  DateTime date;

  Settlement({this.principle, this.interest, this.date, this.remark});
}

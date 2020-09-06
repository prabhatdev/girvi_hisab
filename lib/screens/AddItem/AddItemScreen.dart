import 'dart:async';
import 'dart:convert';

import 'package:firebase/firebase.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:girvihisab/utils/constants.dart';
import 'package:girvihisab/utils/utils.dart';

import 'package:flutter_date_pickers/flutter_date_pickers.dart' as dp;
import 'package:intl/intl.dart';
import 'dart:math' as math;

import 'package:string_validator/string_validator.dart';

class AddItemScreen extends StatefulWidget {
  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  Database db = database();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController itemValueController = TextEditingController();
  final TextEditingController rateController = TextEditingController();
  final df = new DateFormat('dd/MM/yyyy');

  List<String> name = List<String>();
  List<String> itemNames = List<String>();
  List<String> itemTypes = List<String>();
  String userId = '';
  String interestType = 'monthly';
  List allItems = [];
  List settlements = [];
  StreamController itemsController = StreamController.broadcast();
  StreamController settlementsController = StreamController.broadcast();
  StreamController itemTypeController = StreamController<String>.broadcast();
  StreamController weightTypeController = StreamController<String>.broadcast();
  @override
  void dispose() {
    super.dispose();
    itemsController.close();
    settlementsController.close();
    itemTypeController.close();
    weightTypeController.close();
  }

  fetchAllData() {
    userId = Utils.userId;
    Map userData = Utils.allData as Map;
    if (userData['customers'] != null) {
      name.clear();
      itemNames.clear();
      itemTypes.clear();
      Map customers = userData['customers'];
      Map itemType = userData['itemTypes'];
      Map itemName = userData['itemsNames'];
      customers.forEach((key, value) {
        name.add(key.toString().toLowerCase());
      });
      itemName.forEach((key, value) {
        itemNames.add(key.toString().toLowerCase());
      });
      itemType.forEach((key, value) {
        itemTypes.add(key.toString().toLowerCase());
      });
    }
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
      lastDate: DateTime.now().add(Duration(hours: 1)),
      selectedDate: DateTime.now(),
      onChanged: onSelected,
      datePickerStyles: styles,
    );
  }

  addItem(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          final TextEditingController itemNameController = TextEditingController();
          final TextEditingController itemWeightController = TextEditingController();
          final TextEditingController tunchController = TextEditingController();
          final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
           itemTypeController = StreamController<String>.broadcast();
           weightTypeController = StreamController<String>.broadcast();


          String weightType = 'g';
          String itemType = 'silver';
          return AlertDialog(
            title: Text("Add Item"),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: TypeAheadFormField(
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter item name';
                            }
                            return null;
                          },
                          suggestionsCallback: (pattern) {
                            return itemNames.where((element) => element.contains(pattern.toLowerCase())).toList();
                          },
                          textFieldConfiguration: TextFieldConfiguration(
                            autofocus: false,
                            controller: itemNameController,
                            decoration: InputDecoration(
                                labelText: 'Item Name',
                                hintText: 'Chain, Payal etc',
                            ),
                          ),
                          itemBuilder: (context, suggestion) {
                            return ListTile(
                              leading: Icon(Icons.person),
                              title: Text(suggestion),
                            );
                          },
                          noItemsFoundBuilder: (context) {
                            return SizedBox.shrink();
                          },
                          onSuggestionSelected: (suggestion) {
                            itemNameController.text = suggestion;
                          },
                        ),
                      ),
                      StreamBuilder<String>(
                          stream: itemTypeController.stream.asBroadcastStream(),
                          builder: (context, snapshot) {
                            return DropdownButton<String>(
                              items: <String>['gold', 'silver', 'other'].map((String value) {
                                return new DropdownMenuItem<String>(
                                  value: value,
                                  child: new Text(value),
                                );
                              }).toList(),
                              onChanged: (type) {
                                itemType = type;
                                itemTypeController.sink.add(itemType);
                              },
                              value: itemType,
                            );
                          }
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Flexible(
                        child: TextFormField(
                          keyboardType: TextInputType.numberWithOptions(signed: false,decimal: true),
                          autofocus: false,
                          controller: itemWeightController,
                          inputFormatters: [DecimalTextInputFormatter()],
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter weight';
                            }
                            if (!isFloat(value) && !isInt(value)) {
                              return 'Enter valid weight';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                              labelText: 'Weight',
                          ),
                        ),
                      ),
                      StreamBuilder<String>(
                          stream: weightTypeController.stream.asBroadcastStream(),
                          builder: (context, snapshot) {
                            return DropdownButton<String>(
                              items: <String>['g', 'mg'].map((String value) {
                                return new DropdownMenuItem<String>(
                                  value: value,
                                  child: new Text(value),
                                );
                              }).toList(),
                              onChanged: (type) {
                                weightType = type;
                                weightTypeController.sink.add(weightType);
                              },
                              value: weightType,
                            );
                          }
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: tunchController,
                    autofocus: false,
                    inputFormatters: [DecimalTextInputFormatter()],
                    keyboardType: TextInputType.numberWithOptions(signed: false, decimal: true),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter tunch value';
                      }

                      if (!isFloat(value) && !isInt(value)) {
                        return 'Enter valid tunch';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Tunch Percentage',
                      suffixText: "%",
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
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
                      'name': itemNameController.text,
                      'weight': itemWeightController.text,
                      'item_type': itemType,
                      'weight_type': weightType,
                      'tunch': tunchController.text
                    });
                  }
                },
              ),
            ],
          );
        }).then((value) {
      if (value != null) {
        allItems.add(value);
        itemsController.sink.add(null);
      }
    });
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
                        return 'Enter valid amount';
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
                    decoration: InputDecoration(
                      labelText: 'Remarks',
                      hintText: 'Max 25 chars allowed'
                    ),
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
                      'remarks':remarksController.text
                    });
                  }
                },
              ),
            ],
          );
        }).then((value) {
      if (value != null) {
        settlements.add(value);
        settlementsController.sink.add(null);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    fetchAllData();
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TypeAheadFormField(
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter name';
                  }
                  return null;
                },
                suggestionsCallback: (pattern) {
                  return name.where((element) => element.contains(pattern.toLowerCase())).toList();
                },
                textFieldConfiguration: TextFieldConfiguration(
                  controller: nameController,
                  autofocus: false,
                  decoration: InputDecoration(
                    labelText: 'Name',
                  ),
                ),
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    leading: Icon(Icons.person),
                    title: Text(suggestion),
                  );
                },
                noItemsFoundBuilder: (context) {
                  return SizedBox.shrink();
                },
                onSuggestionSelected: (suggestion) {
                  nameController.text = suggestion;
                },
              ),
              SizedBox(
                height: 10,
              ),
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
              StreamBuilder(
                  stream: itemsController.stream.asBroadcastStream(),
                  builder: (context, snapshot) {
                    if (allItems.isNotEmpty) {
                      return Column(
                        children: [
                          DataTable(
                            horizontalMargin: 15,
                            columnSpacing: 30,
                            columns: [
                              DataColumn(
                                label: Text(
                                  "Name",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "Type",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "Weight",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "Tunch",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "Delete",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                            rows: List.generate(allItems.length, (index) {
                              var item = allItems[index];
                              return DataRow(cells: [
                                DataCell(
                                  Text(
                                    item['name'],
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                                DataCell(Text(item['item_type'], style: TextStyle(fontSize: 18))),
                                DataCell(Text('${item['weight']}${item['weight_type']}', style: TextStyle(fontSize: 18))),
                                DataCell(Text('${item['tunch']}%', style: TextStyle(fontSize: 18))),
                                DataCell(
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      allItems.removeAt(index);
                                      itemsController.sink.add(null);
                                    },
                                  ),
                                )
                              ]);
                            }),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Click"),
                              IconButton(
                                icon: Icon(Icons.add_circle),
                                onPressed: () {
                                  addItem(context);
                                },
                              ),
                              Text("to add more items"),
                            ],
                          )
                        ],
                      );
                    }
                    return Column(
                      children: [
                        Text("No Items Added currently"),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Click"),
                            IconButton(
                              icon: Icon(Icons.add_circle),
                              onPressed: () {
                                addItem(context);
                              },
                            ),
                            Text("to add items"),
                          ],
                        )
                      ],
                    );
                  }),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Flexible(
                    child: TextFormField(
                      controller: itemValueController,
                      autofocus: false,
                      inputFormatters: [DecimalTextInputFormatter()],
                      keyboardType: TextInputType.numberWithOptions(signed: false, decimal: true),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter principle amount';
                        }

                        if (!isFloat(value) && !isInt(value)) {
                          return 'Enver valid amount';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Principle Amount',
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Flexible(
                    child: Row(
                      children: [
                        Flexible(
                          child: TextFormField(
                            autofocus: false,
                            controller: rateController,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter rate of interest';
                              }
                              if (!isFloat(value) && !isInt(value)) {
                                return 'Enter valid interest amount';
                              }
                              return null;
                            },
                            inputFormatters: [DecimalTextInputFormatter()],
                            keyboardType: TextInputType.numberWithOptions(signed: false, decimal: true),
                            decoration: InputDecoration(
                                hintText: 'Interest in %',
                                labelText: 'Rate Of Interest',
                                suffixText: "%"),
                          ),
                        ),
                        DropdownButton<String>(
                          items: <String>['monthly', 'yearly'].map((String value) {
                            return new DropdownMenuItem<String>(
                              value: value,
                              child: new Text(value),
                            );
                          }).toList(),
                          onChanged: (type) {
                            setState(() {
                              interestType = type;
                            });
                          },
                          value: interestType,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              StreamBuilder(
                  stream: settlementsController.stream.asBroadcastStream(),
                  builder: (context, snapshot) {
                    if (settlements.isNotEmpty) {
                      return Column(
                        children: [
                          DataTable(
                            columnSpacing: 20,
                            columns: [
                              DataColumn(label: Text("Date",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),)),
                              DataColumn(label: Text("Amount ",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),)),
                              DataColumn(label: Text("Remarks ",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),)),
                              DataColumn(label: Text("Delete ",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),)),
                            ],
                            rows: List.generate(settlements.length, (index) {
                              return DataRow(
                                  cells: [
                                DataCell(Text(df.format(DateTime.fromMillisecondsSinceEpoch(int.parse(settlements[index]['date']))),
                                  style: TextStyle(fontSize: 18))),
                                DataCell(Text(settlements[index]['amount'],
                                  style: TextStyle(fontSize: 18))),
                                DataCell(Container(width: 80,child: Flexible(child: Text(settlements[index]['remarks']),fit: FlexFit.tight,))),
                                DataCell(IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    settlements.removeAt(index);
                                    settlementsController.sink.add(null);
                                  },
                                ))
                              ]);
                            }),
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
                          )
                        ],
                      );
                    }
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Click"),
                        IconButton(
                          icon: Icon(Icons.add_circle),
                          onPressed: () {
                            addSettlement(context);
                          },
                        ),
                        Text("to add settlements"),
                      ],
                    );
                  }),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: RaisedButton(
                  child: Text(
                    "Add Order",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState.validate() && allItems.isNotEmpty) {
//                      Text(item['name'],style: TextStyle(fontSize: 18),),
//                    Text(item['item_type'],style: TextStyle(fontSize: 18)),
//                    Text('${item['weight']}${item['weight_type']}',style: TextStyle(fontSize: 18)),
//                    Text('${item['tunch']}%',style: TextStyle(fontSize: 18)),

                      String date = df.parse(dateController.text).millisecondsSinceEpoch.toString();
                      var itemName = {};
                      var dataToPush = {};
                      dataToPush['items'] = {};
                      dataToPush['name'] = nameController.text;
                      dataToPush['date'] = date;
                      dataToPush['principle'] = itemValueController.text;
                      dataToPush['interest'] = rateController.text;
                      dataToPush['interest_type'] = interestType;
                      allItems.forEach((element) {
                        dataToPush['items'][element['name']] = {
                          'name': element['name'],
                          'item_type': element['item_type'],
                          'weight': element['weight'],
                          'weight_type': element['weight_type'],
                          'tunch': element['tunch'],
                        };
                        itemName[element['name']] = '1';
                      });
                      var settlement={};
                      for(int i=0;i<settlements.length;i++){
                        settlement[i.toString()]=settlements[i];
                      }
                      dataToPush['settlements']=settlement;
                      await db.ref("users/${userId}/customers/${nameController.text.toLowerCase()}").push().set(dataToPush);

                      for (int i = 0; i < allItems.length; i++) {
                        await db.ref("users/${userId}/itemsNames/${allItems[i]['name']}").set('1');
                      }

                      Utils.showToast("Item Added");
                      allItems.clear();
                      settlements.clear();
                      settlementsController.sink.add(null);
                      itemsController.sink.add(null);
                      _formKey.currentState.reset();
                      fetchAllData();
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter({this.decimalRange}) : assert(decimalRange == null || decimalRange > 0);

  final int decimalRange;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue, // unused.
    TextEditingValue newValue,
  ) {
    TextSelection newSelection = newValue.selection;
    String truncated = newValue.text;

    if (decimalRange != null) {
      String value = newValue.text;

      if (value.contains(".") && value.substring(value.indexOf(".") + 1).length > decimalRange) {
        truncated = oldValue.text;
        newSelection = oldValue.selection;
      } else if (value == ".") {
        truncated = "0.";

        newSelection = newValue.selection.copyWith(
          baseOffset: math.min(truncated.length, truncated.length + 1),
          extentOffset: math.min(truncated.length, truncated.length + 1),
        );
      }

      return TextEditingValue(
        text: truncated,
        selection: newSelection,
        composing: TextRange.empty,
      );
    }
    return newValue;
  }
}

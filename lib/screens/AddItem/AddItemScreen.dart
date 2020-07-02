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

class AddItemScreen extends StatefulWidget {
  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  Database db = database();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController itemWeightController = TextEditingController();
  final TextEditingController itemValueController = TextEditingController();
  final TextEditingController rateController = TextEditingController();
  final df = new DateFormat('dd/MM/yyyy');
  String interestType='monthly';
  String weightType='g';
  String itemType='silver';
  List<String> name = List<String>();
  List<String> itemNames = List<String>();
  List<String> itemTypes = List<String>();
  String userId = '';

  fetchAllData() {
    Utils.getPrefs().then((prefs) {
      String allDataJson = Utils.allData;
      userId = prefs.getString(USER_ID);
      Map userData = jsonDecode(allDataJson);
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
      lastDate: DateTime.now().add(Duration(hours: 1)),
      selectedDate: DateTime.now(),
      onChanged: onSelected,
      datePickerStyles: styles,
    );
  }

  @override
  Widget build(BuildContext context) {
    fetchAllData();
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            TextFormField(
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
            TypeAheadFormField(
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
                    suffixIcon: DropdownButton<String>(
                      items: <String>['gold', 'silver','other'].map((String value) {
                        return new DropdownMenuItem<String>(
                          value: value,
                          child: new Text(value),
                        );
                      }).toList(),
                      onChanged: (type) {
                        setState(() {
                          itemType=type;
                        });
                      },
                      value: itemType,
                    )
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

            Row(
              children: [
                Flexible(
                  child: TextFormField(
                    controller: itemValueController,
                    keyboardType: TextInputType.numberWithOptions(signed: false,decimal: true),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter item value';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Item Value',
                    ),
                  ),
                ),
                SizedBox(width: 10,),
                Flexible(
                  child: TextFormField(
                    controller: itemWeightController,
                    inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter weight';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        labelText: 'Weight',
                        suffixIcon: DropdownButton<String>(
                          items: <String>['g', 'mg'].map((String value) {
                            return new DropdownMenuItem<String>(
                              value: value,
                              child: new Text(value),
                            );
                          }).toList(),
                          onChanged: (type) {
                            setState(() {
                              weightType=type;
                            });
                          },
                          value: weightType,
                        )
                    ),
                  ),
                ),

              ],
            ),

            TextFormField(
              controller: rateController,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter rate of interest';
                }
                return null;
              },
              keyboardType: TextInputType.numberWithOptions(signed: false,decimal: true),
              decoration: InputDecoration(
                  suffixIcon: DropdownButton<String>(
                    items: <String>['monthly', 'yearly'].map((String value) {
                      return new DropdownMenuItem<String>(
                        value: value,
                        child: new Text(value),
                      );
                    }).toList(),
                    onChanged: (type) {
                      setState(() {
                        interestType=type;
                      });
                    },
                    value: interestType,
                  ),
                  hintText: 'Interest in %',
                  labelText: 'Rate Of Interest', suffixText: "%"),
            ),


            RaisedButton(
              child: Text(
                "Add Item",
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              onPressed: () async {
                if (_formKey.currentState.validate()) {
                  String date = df.parse(dateController.text).millisecondsSinceEpoch.toString();

                  await db.ref("users/${userId}/customers/${nameController.text.toLowerCase()}").push().set({
                    'date': date,
                    'name': nameController.text,
                    'item_name': itemNameController.text,
                    'item_types': itemType,
                    'value': itemValueController.text,
                    'interest': rateController.text,
                    'interest_type': interestType,
                    'weight': itemWeightController.text+weightType,
                  });
                  await db.ref("users/${userId}/itemsNames/${itemNameController.text.toLowerCase()}").set(1);
                  Utils.showToast("Item Added");
                  _formKey.currentState.reset();
                  fetchAllData();
                }
              },
            )
          ],
        ),
      ),
    );
  }
}

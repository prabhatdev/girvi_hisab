import 'dart:async';
import 'dart:convert';

import 'package:firebase/firebase.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart';
import 'package:flutter_tagging/flutter_tagging.dart';

import 'package:girvihisab/main.dart';
import 'package:girvihisab/screens/Home/HomeScreen.dart';
import 'package:girvihisab/utils/constants.dart';
import 'package:girvihisab/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart' as dp;

class SearchItemScreen extends StatefulWidget {
  @override
  _SearchItemScreenState createState() => _SearchItemScreenState();
}

class _SearchItemScreenState extends State<SearchItemScreen> {
  Database db = database();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController itemTypeController = TextEditingController();
  final TextEditingController itemValueController = TextEditingController();
  final df = new DateFormat('dd/MM/yyyy');

  StreamController loaderController = StreamController<bool>.broadcast();

  List<String> name = List<String>();
  List<Item> allItemNames = List<Item>();
  List<Item> selectedItems = List<Item>();
  List<String> itemTypes = ['gold', 'silver', 'other'];
  String userId = '';
  List searchResult = List();
  Map customers = Map();

  @override
  void dispose() {
    super.dispose();
    loaderController.close();
  }

  fetchAllData() {
    userId = Utils.userId;
    Map<String, dynamic> userData = Utils.allData as Map;
    if (userData['customers'] != null) {
      name.clear();
      allItemNames.clear();
      Map<String, dynamic> customers = userData['customers'];
      Map<String, dynamic> itemName = userData['itemsNames'];
      customers.forEach((key, value) {
        name.add(key.toString().toLowerCase());
        (customers[key] as Map).keys.toList().forEach((element) {
          if (!this.customers.containsKey(key.toString().toLowerCase())) {
            this.customers[key.toString().toLowerCase()] = List();
          }
          customers[key][element]['key'] = element;
          this.customers[key.toString().toLowerCase()].add(customers[key][element]);
        });
      });
      itemName.forEach((key, value) {
        allItemNames.add(Item(name: key.toString().toLowerCase()));
      });
    }
  }

  searchAll(filter) async {
    if (filter != filters.NAME && searchResult.isEmpty) {
      Utils.showToast("No results found");
      loaderController.sink.add(false);
      return;
    }
    switch (filter) {
      case filters.NAME:
        if (nameController.text.isEmpty) {
          customers.forEach((key, value) {
            searchResult.addAll(value);
          });
        } else {
          name.where((element) => element.toString().toLowerCase().contains(nameController.text.toLowerCase())).toList().forEach((element) {
            searchResult.addAll(customers[element]);
          });
        }
        searchAll(filters.DATE);
        break;
      case filters.DATE:
        if (fromDateController.text.isNotEmpty) {
          if (fromDateController.text.isNotEmpty && toDateController.text.isEmpty) {
            searchResult =
                searchResult.where((element) => element['date'] == df.parse(fromDateController.text).millisecondsSinceEpoch.toString()).toList();
          } else {
            searchResult = searchResult
                .where((element) =>
                    int.parse(element['date']) >= df.parse(fromDateController.text).millisecondsSinceEpoch &&
                    int.parse(element['date']) <= df.parse(toDateController.text).millisecondsSinceEpoch)
                .toList();
          }
        }
        searchAll(filters.ITEM_NAME);
        break;
      case filters.ITEM_NAME:
        if (selectedItems.isNotEmpty) {
          searchResult = searchResult.where((element) {
            int foundCount = 0;
            (element['items'] as Map).keys.toList().forEach((itemName) {
              selectedItems.forEach((element) {
                if (element.name == itemName) {
                  foundCount++;
                }
              });
            });
            return foundCount == selectedItems.length;
          }).toList();
        }
        loaderController.sink.add(false);
        if (searchResult.isEmpty) {
          Utils.showToast("No results found");
        } else {
          Utils.showToast("${searchResult.length} results found");
          Navigator.pushNamed(context, Routes.SEARCH_RESULT, arguments: {'result': searchResult});
        }
        break;
    }
  }

  Widget buildDatePicker(DateTime firstDate, DateTime lastDate, Function onSelected) {
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
      firstDate: firstDate,
      lastDate: lastDate,
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
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TypeAheadFormField(
              suggestionsCallback: (pattern) {
                return name.where((element) => element.contains(pattern.toLowerCase())).toList();
              },
              textFieldConfiguration: TextFieldConfiguration(
                controller: nameController,
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
            Row(
              children: [
                Flexible(
                  child: TextFormField(
                    controller: fromDateController,
                    validator: (value) {
                      if (value.isEmpty) return null;
                      if (!RegExp(DATE_EXP).hasMatch(value)) {
                        return 'Invalid date format';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        labelText: 'From Date',
                        hintText: '25/05/2020',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.calendar_today),
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    contentPadding: EdgeInsets.all(0),
                                    title: Text("Select From Date"),
                                    content: buildDatePicker(DateTime.fromMillisecondsSinceEpoch(0), DateTime.now().add(Duration(hours: 1)),
                                        (DateTime date) {
                                      fromDateController.text = df.format(date);
                                      Navigator.pop(context);
                                    }),
                                  );
                                });
                          },
                        )),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Flexible(
                  child: TextFormField(
                    controller: toDateController,
                    validator: (value) {
                      if (value.isEmpty) return null;
                      if (!RegExp(DATE_EXP).hasMatch(value)) {
                        return 'Invalid date format';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        labelText: 'To Date',
                        hintText: '25/05/2020',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.calendar_today),
                          onPressed: () {
                            if (fromDateController.text.isNotEmpty) {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      contentPadding: EdgeInsets.all(0),
                                      title: Text("To Date"),
                                      content: buildDatePicker(
                                          df.parse(fromDateController.text).add(Duration(days: 1)), DateTime.now().add(Duration(hours: 1)),
                                          (DateTime date) {
                                        toDateController.text = df.format(date);
                                        Navigator.pop(context);
                                      }),
                                    );
                                  });
                            } else {
                              Utils.showToast("Please select from date first");
                            }
                          },
                        )),
                  ),
                ),
              ],
            ),
//            TypeAheadFormField(
//              suggestionsCallback: (pattern) {
//                return allItemNames.where((element) => element.contains(pattern.toLowerCase())).toList();
//              },
//              textFieldConfiguration: TextFieldConfiguration(
//                controller: itemNameController,
//                decoration: InputDecoration(
//                  labelText: 'Item Name',
//                  hintText: 'Chain, Payal etc',
//                ),
//              ),
//              itemBuilder: (context, suggestion) {
//                return ListTile(
//                  leading: Icon(Icons.person),
//                  title: Text(suggestion),
//                );
//              },
//              noItemsFoundBuilder: (context) {
//                return SizedBox.shrink();
//              },
//              onSuggestionSelected: (suggestion) {
//                itemNameController.text = suggestion;
//              },
//            ),

            FlutterTagging<Item>(
                initialItems: selectedItems,
                textFieldConfiguration: TextFieldConfiguration(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    filled: true,
                    hintText: 'Chain, Payal, etc',
                    labelText: 'Select Items',
                  ),
                ),
                findSuggestions: (value) {
                  if (value.isEmpty) {
                    return allItemNames;
                  }
                  return allItemNames.where((element) => element.name.contains(value.toLowerCase())).toList();
                },
                additionCallback: (value) {
                  return Item(
                    name: value,
                  );
                },
                onAdded: (item) {
                  return item;
                },
                configureSuggestion: (item) {
                  return SuggestionConfiguration(
                    title: Text(item.name),
                    additionWidget: Chip(
                      avatar: Icon(
                        Icons.add_circle,
                        color: Colors.white,
                      ),
                      label: Text('Select Item'),
                      labelStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  );
                },
                configureChip: (lang) {
                  return ChipConfiguration(
                    label: Text(lang.name),
                    backgroundColor: Colors.blue,
                    labelStyle: TextStyle(color: Colors.white),
                    deleteIconColor: Colors.white,
                  );
                },
                onChanged: () {
                  print(selectedItems);
                }),
            StreamBuilder<bool>(
                stream: loaderController.stream.asBroadcastStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data) {
                    return CircularProgressIndicator();
                  }
                  return RaisedButton(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search,
                            color: Colors.white,
                          ),
                          Text(
                            "Search",
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ],
                      ),
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          loaderController.sink.add(true);
                          this.searchResult.clear();
                          searchAll(filters.NAME);
                        }
                      });
                })
          ],
        ),
      ),
    );
  }
}

class Item extends Taggable {
  final String name;

  /// Creates Language
  Item({
    this.name,
  });

  @override
  List<Object> get props => [name];
}

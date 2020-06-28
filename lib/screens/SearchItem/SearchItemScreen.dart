import 'dart:async';
import 'dart:convert';

import 'package:firebase/firebase.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:girvihisab/main.dart';
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
  final TextEditingController dateController = TextEditingController();
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController itemTypeController = TextEditingController();
  final TextEditingController itemValueController = TextEditingController();
  final df = new DateFormat('dd/MM/yyyy');

  StreamController loaderController=StreamController<bool>.broadcast();

  List<String> name = List<String>();
  List<String> itemNames = List<String>();
  List<String> itemTypes = List<String>();
  String userId = '';
  List searchResult=List();
  Map customers=Map();


  @override
  void dispose() {
    super.dispose();
    loaderController.close();
  }

  fetchAllData() {
    Utils.getPrefs().then((prefs) {
      String allDataJson = prefs.getString(ALL_DATA);
      userId = prefs.getString(USER_ID);
      Map<String, dynamic> userData = jsonDecode(allDataJson);
      if (userData['customers'] != null) {
        name.clear();
        itemNames.clear();
        itemTypes.clear();
        Map<String, dynamic> customers = userData['customers'];
        Map<String, dynamic> itemType = userData['itemTypes'];
        Map<String, dynamic> itemName = userData['itemsNames'];
        customers.forEach((key, value) {
          name.add(key.toString().toLowerCase());
          (customers[key] as Map).keys.toList().forEach((element) {
            if(!this.customers.containsKey(key.toString().toLowerCase())){
              this.customers[key.toString().toLowerCase()]=List();
            }
            this.customers[key.toString().toLowerCase()].add(JsonDecoder().convert(JsonEncoder().convert(customers[key][element])));
          });
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

  searchAll(filter) async{
    if(filter!=filters.NAME && searchResult.isEmpty){
      Utils.showToast("No results found");
      loaderController.sink.add(false);
      return;
    }
      switch(filter){
        case filters.NAME:
          if(nameController.text.isEmpty){
            customers.forEach((key, value) {
              searchResult.addAll(value);
            });
          }
          else{
            name.where((element) => element.toString().toLowerCase().contains(nameController.text.toLowerCase())).toList().forEach((element) {
              searchResult.addAll(customers[element]);
            });
          }
          searchAll(filters.DATE);
          break;
        case filters.DATE:
          if(dateController.text.isNotEmpty){
            searchResult=searchResult.where((element) => element['date']==df.parse(dateController.text).millisecondsSinceEpoch.toString()).toList();
          }
          searchAll(filters.ITEM_NAME);
          break;
        case filters.ITEM_NAME:
          if(itemNameController.text.isNotEmpty){
            searchResult=searchResult.where((element) => element['item_name'].toString().toLowerCase().contains(itemNameController.text.toLowerCase())).toList();
          }
          searchAll(filters.ITEM_TYPE);
          break;
        case filters.ITEM_TYPE:
          if(itemTypeController.text.isNotEmpty){
            searchResult=searchResult.where((element) => element['item_types'].toString().toLowerCase().contains(itemTypeController.text.toLowerCase())).toList();
          }
          searchAll(filters.VALUE);
          break;
        case filters.VALUE:
          if(itemValueController.text.isNotEmpty){
            searchResult=searchResult.where((element) {
              return element['value'].toString().toLowerCase().contains(itemValueController.text.toLowerCase());
            }).toList();
          }
          loaderController.sink.add(false);
          if(searchResult.isEmpty){
            Utils.showToast("No results found");
          }
          else{
            Utils.showToast("${searchResult.length} results found");
            Navigator.pushNamed(context, Routes.SEARCH_RESULT,arguments: {'result':searchResult});
          }
          break;
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
                return ListTile(
                  title: Text("User not found! New User"),
                );
              },
              onSuggestionSelected: (suggestion) {
                nameController.text = suggestion;
              },
            ),
            TextFormField(
              controller: dateController,
              validator: (value) {
                if(value.isEmpty)
                  return null;
                if (!RegExp(DATE_EXP).hasMatch(value)) {
                  return 'Invalid date format';
                }
                return null;
              },
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
              suggestionsCallback: (pattern) {
                return itemNames.where((element) => element.contains(pattern.toLowerCase())).toList();
              },
              textFieldConfiguration: TextFieldConfiguration(
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
                return ListTile(
                  title: Text("New Item"),
                );
              },
              onSuggestionSelected: (suggestion) {
                itemNameController.text = suggestion;
              },
            ),
            TypeAheadFormField(
              suggestionsCallback: (pattern) {
                return itemTypes.where((element) => element.contains(pattern.toLowerCase())).toList();
              },
              textFieldConfiguration: TextFieldConfiguration(
                controller: itemTypeController,
                decoration: InputDecoration(
                  labelText: 'Item Type',
                  hintText: 'Gold, Silver, etc',
                ),
              ),
              itemBuilder: (context, suggestion) {
                return ListTile(
                  leading: Icon(Icons.person),
                  title: Text(suggestion),
                );
              },
              noItemsFoundBuilder: (context) {
                return ListTile(
                  title: Text("New Item Type"),
                );
              },
              onSuggestionSelected: (suggestion) {
                itemTypeController.text = suggestion;
              },
            ),
            TextFormField(
              controller: itemValueController,
              inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Item Value',
              ),
            ),
            StreamBuilder<bool>(
              stream: loaderController.stream.asBroadcastStream(),
              builder: (context, snapshot) {
                if(snapshot.hasData && snapshot.data){
                  return CircularProgressIndicator();
                }
                return RaisedButton(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search,color: Colors.white,),
                      Text(
                        "Search",
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ],
                  ),
                  onPressed: () {
                    if(_formKey.currentState.validate()){
                      loaderController.sink.add(true);
                      this.searchResult.clear();
                      searchAll(filters.NAME);
                    }
                  }
                );
              }
            )
          ],
        ),
      ),
    );
  }
}

//import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqlbrite/sqlbrite.dart';
import 'bill_screen.dart';
import 'history.dart';
import 'states.dart';

class InvoiceCubit extends Cubit<InvoiceStates> {
  InvoiceCubit() : super(InvoiceInitStates());

  static InvoiceCubit get(context) => BlocProvider.of(context);
  num sellsOrReturns = 1;

  //DATABASE SECTION //////////////////////////////////////////////////////////////

  static Database? database;

  String itemsTable =
      "CREATE TABLE items(items_id INTEGER PRIMARY KEY AUTOINCREMENT,unit_id INTEGER ,item_desc VARCHAR NOT NULL, item_no INTEGER NOT NULL,price INTEGER NOT NULL,tax INTEGER NOT NULL)";
  String clientsTable =
      "CREATE TABLE clients(client_id INTEGER PRIMARY KEY AUTOINCREMENT,client_name VARCHAR NOT NULL, phone_number VARCHAR NOT NULL )";
  String invoiceInfoTable =
      "CREATE TABLE invoice_info(info_id INTEGER PRIMARY KEY AUTOINCREMENT,client_id INTEGER,invoice_number INTEGER NOT NULL,invoice_type INTEGER NOT NULL, invoice_date VARCHAR NOT NULL,client_name VARCHAR NOT NULL,total INTEGER NOT NULL,notes VARCHAR )";
  String invoiceItemsTable =
      "CREATE TABLE invoice_items(items_id INTEGER PRIMARY KEY AUTOINCREMENT,info_id INTEGER NOT NULL,unit_id INTEGER ,invoice_num INTEGER NOT NULL,invoice_items VARCHAR NOT NULL,quentity INTEGER NOT NULL,price INTEGER NOT NULL,tax INTEGER NOT NULL)";
  String settingsTable =
      "CREATE TABLE settings(id INTEGER PRIMARY KEY AUTOINCREMENT,settings VARCHAR NOT NULL,settings_state INTEGER NOT NULL)";
  String unitsTable =
      "CREATE TABLE units(unit_id INTEGER PRIMARY KEY AUTOINCREMENT,unit VARCHAR NOT NULL)";
  void _createSubjectsTable(Batch batch) {
    batch.execute(itemsTable);
    debugPrint(' table 1 created ');
  }

  void _createClientsTable(Batch batch) {
    batch.execute(clientsTable);
    debugPrint(' table 2 created ');
  }

  void _createInvoiceInfoTable(Batch batch) {
    batch.execute(invoiceInfoTable);
    debugPrint(' table 3 created ');
  }

  void _createInvoiceItemsTable(Batch batch) {
    batch.execute(invoiceItemsTable);
    debugPrint(' table 4 created ');
  }

  void _createSettingsTable(Batch batch) {
    batch.execute(settingsTable);
    batch.rawInsert(
        'INSERT INTO settings(settings,settings_state) VALUES("insert items manually","0")');
    debugPrint(' table 5 created ');
    batch.rawInsert(
        'INSERT INTO settings(settings,settings_state) VALUES("edit sale price","0")');
  }

  void _createUnitsTable(Batch batch) {
    batch.execute(unitsTable);
    batch.rawInsert('INSERT INTO units(unit) VALUES("PCS")');
    debugPrint("done1");
    batch.rawInsert('INSERT INTO units(unit) VALUES("KG")');
    debugPrint("done2");
    debugPrint(' table 6 created ');
  }

  List<Map> items = [];
  List<Map> clients = [];
  List<Map> history = [];
  List<Map> returnsMax = [];
  List<Map> sellsMax = [];
  List<Map> savedItems = [];
  List<Map> settingsList = [];
  List totalOfItem = [];
  List quantity = [];
  List priceOfItem = [];
  List dropDownUnitsList = [];
  List<int> taxLIst = <int>[0, 4, 8, 16];
  List<Map> unitsList = [];
  late List<Map> allAddedItems = [];
  late List<Map> currentAddedItem = [];

  Future<Database> createDatabase() async {
    database = await openDatabase('invoice.db', version: 1,
        onCreate: (database, version) {
      print(' database created ');
      var batch = database.batch();
      _createSubjectsTable(batch);
      _createClientsTable(batch);
      _createInvoiceInfoTable(batch);
      _createInvoiceItemsTable(batch);
      _createSettingsTable(batch);
      _createUnitsTable(batch);
      batch.commit();
    }, onOpen: (database) async {
      print("database opend");
      getDataFromDatabase(database, "items").then((value) {
        items = filterdItems = value;
        emit(GetDatabase());
      });
      getDataFromDatabase(database, "clients").then((value) {
        clients = filteredClients = value;
        emit(GetDatabase());
      });
      getDataFromDatabase(database, "invoice_items").then((value) {
        savedItems = value;
        emit(GetDatabase());
      });
      getDataFromDatabase(database, "settings").then((value) {
        settingsList = value;
        emit(GetDatabase());
      });
      getDataFromDatabase(database, "units").then((value) {
        unitsList = value;
        for (var element in unitsList) {
          dropDownUnitsList
              .add(element["unit"] + (element["unit_id"]).toString());
          debugPrint(element["unit"]);
          debugPrint(dropDownUnitsList.toString());
        }

        emit(GetDatabase());
      });
      getDataFromInfoOrderdByDate(database, "invoice_info").then((value) {
        history = filterdHistory = value;
        emit(GetDatabase());
      }).then((value) {
        calculateDayTotal();
      });
      getReturnsMaxFromInfo(database).then((value) {
        returnsMax = value;
        emit(GetDatabase());
      }).then((value) {
        debugPrint("returns${returnsMax.toString()}");
      });
      getSellsMaxFromInfo(database).then((value) {
        sellsMax = value;
        emit(GetDatabase());
      }).then((value) {
        debugPrint("sells${sellsMax.toString()}");
      });
    });
    return Future.delayed(const Duration(microseconds: 0));
  }

  Future<List<Map>> insertToDatabase({
    required String name,
    required String number,
    required String price,
    int? unitId,
    int? tax,
  }) async {
    await database?.transaction((txn) {
      txn
          .rawInsert(
              'INSERT INTO items(item_desc,item_no,price,unit_id,tax) VALUES("$name","$number","$price","$unitId","$tax")')
          .then((value) {
        emit(InsertDatabase());
        getDataFromDatabase(database, "items").then((value) {
          items = filterdItems = value;
          emit(GetDatabase());
        });
      });

      return Future.delayed(const Duration(microseconds: 0));
    });
    return Future.delayed(const Duration(microseconds: 0));
  }

  Future<List<Map>> insertToClients({
    required String clientName,
    required String phoneNumber,
  }) async {
    await database?.transaction((txn) {
      txn
          .rawInsert(
              'INSERT INTO clients(client_name,phone_number) VALUES("$clientName","$phoneNumber")')
          .then((value) {
        emit(InsertDatabase());
        debugPrint("$clientName $phoneNumber inserted");
        getDataFromDatabase(database, "clients").then((value) {
          clients = filteredClients = value;
          emit(GetDatabase());
        });
      });

      return Future.delayed(const Duration(microseconds: 0));
    });
    debugPrint(database.toString());
    return Future.delayed(const Duration(microseconds: 0));
  }

  Future<List<Map>> insertToInvoiceInfo(
      {required int invoiceNumber,
      required String invoiceDate,
      required String clientName,
      required num total,
      required num type,
      int? clientId,
      required String notes}) async {
    await database?.transaction((txn) {
      txn
          .rawInsert(
              'INSERT INTO invoice_info(invoice_number,invoice_type,invoice_date,client_name,client_id,total,notes) VALUES("$invoiceNumber","$type","$invoiceDate","$clientName","$clientId","$total","$notes")')
          .then((value) {
        emit(InsertDatabase());
        // getDataFromDatabase(database, "invoice_info").then((value) {
        //   history = filterdHistory = value;
        //   emit(GetDatabase());
        // }).then((value) {
        //   calculateDayTotal();
        // });
        getSellsMaxFromInfo(database).then((value) {
          sellsMax = value;
          emit(GetDatabase());
        }).then((value) {
          debugPrint("hereeeee${sellsMax.toString()}");
        });
        getReturnsMaxFromInfo(database).then((value) {
          returnsMax = value;
          emit(GetDatabase());
        }).then((value) {
          debugPrint("hereeeee${returnsMax.toString()}");
        });
        getDataFromInfoOrderdByDate(database, "invoice_info").then((value) {
          history = filterdHistory = value;
          emit(GetDatabase());
        }).then((value) {
          calculateDayTotal();
        });
      });

      return Future.delayed(const Duration(microseconds: 0));
    });
    debugPrint(database.toString());
    return Future.delayed(const Duration(microseconds: 0));
  }

  Future<List<Map>> insertInvoiceItems({
    int? infoId,
    int? unitId,
    required String items,
    required int invoiceNumber,
    int? quentity,
    num? price,
    int? tax,
  }) async {
    await database?.transaction((txn) {
      txn
          .rawInsert(
              'INSERT INTO invoice_items(info_id,unit_id,invoice_num,invoice_items,quentity,price,tax) VALUES("$infoId","$unitId","$invoiceNumber","$items","$quentity","$price","$tax")')
          .then((value) {
        emit(InsertDatabase());

        getDataFromDatabase(database, "invoice_items").then((value) {
          savedItems = value;

          emit(GetDatabase());
        });
      });

      return Future.delayed(const Duration(microseconds: 0));
    });
    debugPrint(database.toString());
    return Future.delayed(const Duration(microseconds: 0));
  }

  Future<List<Map>> insertToSettings() async {
    //database=await createDatabase();
    await database?.transaction((txn) {
      print("doneeeeeeee");
      txn
          .rawInsert(
              'INSERT INTO settings(settings,settings_state) VALUES("insert items manually","false")')
          .then((value) {
        emit(InsertDatabase());

        getDataFromDatabase(database, "settings").then((value) {
          settingsList = value;

          emit(GetDatabase());
        });
      });

      return Future.delayed(const Duration(microseconds: 0));
    });
    await database?.transaction((txn) {
      print("doneeeeeeee2");
      txn
          .rawInsert(
              'INSERT INTO settings(settings,settings_state) VALUES("edit sale price","false")')
          .then((value) {
        emit(InsertDatabase());

        getDataFromDatabase(database, "settings").then((value) {
          settingsList = value;
          emit(GetDatabase());
        });
      });

      return Future.delayed(const Duration(microseconds: 0));
    });
    debugPrint(database.toString());
    return Future.delayed(const Duration(microseconds: 0));
  }

  Future<List<Map>> insertToUnits() async {
    await database?.transaction((txn) {
      txn.rawInsert('INSERT INTO units(unit) VALUES("pcs")');
      debugPrint("done1");
      txn.rawInsert('INSERT INTO units(unit) VALUES("pcs")');
      debugPrint("done2");
      txn.rawInsert('INSERT INTO units(unit) VALUES("pcs")');
      debugPrint("done3");
      txn.rawInsert('INSERT INTO units(unit) VALUES("pcs")');
      debugPrint("done4");
      return Future.delayed(const Duration(microseconds: 0));
    }).then((value) {
      emit(InsertDatabase());
      getDataFromDatabase(database, "units").then((value) {
        unitsList = value;
        emit(GetDatabase());
      });
    });
    return Future.delayed(const Duration(microseconds: 0));
  }

  Future<List<Map>> getDataFromDatabase(database, tableName) async {
    return database.rawQuery('SELECT * FROM $tableName ');
  }

  Future<List<Map>> getDataFromInfoOrderdByDate(database, tableName) async {
    return database
        .rawQuery('SELECT * FROM $tableName ORDER BY invoice_date DESC');
  }

  Future<List<Map>> getSellsMaxFromInfo(database) async {
    return database.rawQuery(
        'SELECT MAX (invoice_number) AS "sells_max" FROM invoice_info WHERE invoice_type =1');
  }

  Future<List<Map>> getReturnsMaxFromInfo(database) async {
    return database.rawQuery(
        'SELECT MAX (invoice_number) AS "return_max" FROM invoice_info WHERE invoice_type =-1');
  }

  void updateSettings({required int state, required String name}) {
    database?.rawUpdate(
      'UPDATE settings SET settings_state = ? WHERE settings = ?',
      [state, name],
    ).then((value) {
      getDataFromDatabase(database, "settings").then((value) {
        settingsList = value;
      });
      emit(UpdateFromDatabase());
      emit(ChangeCheckBox());
    });
  }

  void updateClients(
      {required String number, required String name, required int id}) {
    database?.rawUpdate(
      'UPDATE clients SET phone_number = ?,client_name = ? WHERE client_id = ?',
      [number, name, id],
    ).then((value) {
      getDataFromDatabase(database, "clients").then((value) {
        clients = filteredClients = value;
        emit(GetDatabase());
      });
      emit(UpdateFromDatabase());
    });
  }

  void updateSubjects(
      {required String price, required String name, required String number}) {
    database?.rawUpdate(
      'UPDATE subjects SET price = ?,name = ? WHERE number = ?',
      [price, name, number],
    ).then((value) {
      getDataFromDatabase(database, "subjects").then((value) {
        items = value;
        emit(GetDatabase());
      });
      emit(UpdateFromDatabase());
    });
  }

  void deleteFromDB({
    required int id,
    required String tableName,
    required String columnName,
  }) {
    database?.rawDelete(
        'DELETE FROM $tableName WHERE $columnName = ?', [id]).then((value) {
      getDataFromDatabase(database, "clients").then((value) {
        clients = filteredClients = value;
        calculateDayTotal();
        emit(GetDatabase());
      });
      getDataFromDatabase(database, "items").then((value) {
        items = filterdItems = value;
        calculateDayTotal();
        emit(GetDatabase());
      });
      getDataFromDatabase(database, "invoice_info").then((value) {
        history = filterdHistory = value;
        calculateDayTotal();
        emit(GetDatabase());
      });
      calculateDayTotal();
      emit(DeleteFromDatabase());
    });
  }

  del(index) {
    allAddedItems.removeAt(index);
    quantity.removeAt(index);
    totalOfItem.removeAt(index);
    calculateTotal();
    emit(RemoveItem());
  }

  //CHANGE SCREEN INDEX SECTION ///////////////////////////////////////////////////////////////

  int bottomBarIndx = 0;
  List<Widget> screens = [const BillScreen(), const History()];

  void changeScreenIndex(int index) {
    bottomBarIndx = index;
    emit(AppChangeBottomNavBarState());
  }

  //FIREBASE SECTION /////////////////////////////////////////////////////////////////
  bool valueOrPercntage = true;
  final itemsCollectionRef = FirebaseFirestore.instance.collection("items");
  final historyCollectionRef = FirebaseFirestore.instance.collection("history");
  List<Map> fireStoreData = [];
  List<Map> filterdFireStoreData = [];
  String? data;
  String? loadedData;
  List splitingList = [];
  List<dynamic>? itemsRecords;
  List<Map<String, dynamic>> uniqueItems = [];
//   void getDocuments() async {
//   QuerySnapshot querySnapshot =
//       await FirebaseFirestore.instance.collection("items").get();
//   List<DocumentSnapshot> documents = querySnapshot.docs;
//   List<Map<String, dynamic>> documentData =
//       documents.map((doc) => doc.data).toList();
//   print(documentData);
// }

// getData() async {
//   await collection1.get.then((value) {
//     for(var i in value.docs) {
//       fireStoreData.add(i.data());
//     }
//   });
// }

  void loadData() async {
    loadedData = await rootBundle.loadString('assets/Items.txt');
    itemsRecords = jsonDecode(loadedData!);
    addRecords3();
  }

  void addRecords3() {
    //itemsCollectionRef.add({"items": itemsRecords}).then((value) {
    itemsCollectionRef.get().then((value) {
      value.docs.asMap().forEach((indx, element) {
        element.data()["items"].forEach((item) {
          debugPrint(item.toString());
          fireStoreData.add(item);
          filterdFireStoreData = fireStoreData;
        });
      });
    });
    //});
  }

//void addRecords1(x) async {
//     itemsCollectionRef.get().then((value) {
//     value.docs.asMap().forEach((indx, doc) {
//       doc.data()["items"].forEach((item) {
//         itemsRecords!.forEach((element) {
//           if (item.toString() != element.toString() && !uniqueItems.contains(element)) {
//             debugPrint("work");
//             itemsCollectionRef.add({"items": element});
//             uniqueItems.add(element);
//           } else {
//             debugPrint("did not work");
//           }
//         });
//         debugPrint(item.toString());
//         fireStoreData.add(item);
//         filterdFireStoreData = fireStoreData;
//       });
//       debugPrint("first${fireStoreData.length.toString()}");
//       debugPrint("second${filterdFireStoreData.length.toString()}");
//     });
//   });
// }

  void addRecords2(x) async {
    List<Map<String, dynamic>> uniqueItems = [];

    itemsCollectionRef.get().then((value) {
      if (value.docs.isEmpty) {
        itemsCollectionRef.add({"items": itemsRecords});
        value.docs.asMap().forEach((index, doc) {
          doc.data()["items"].forEach((item) {
            debugPrint(item.toString());
            fireStoreData.add(item);
            filterdFireStoreData = fireStoreData;
          });
        });
      } else {
        value.docs.asMap().forEach((indx, doc) {
          doc.data()["items"].forEach((item) {
            itemsRecords!.forEach((element) {
              if (item.toString() != element.toString() &&
                  !uniqueItems.contains(element)) {
                debugPrint("work");
                itemsCollectionRef.add({"items": element});
                uniqueItems.add(element);
              } else {
                debugPrint("did not work");
              }
            });
            debugPrint(item.toString());
            fireStoreData.add(item);
            filterdFireStoreData = fireStoreData;
          });
          debugPrint("first${fireStoreData.length.toString()}");
          debugPrint("second${filterdFireStoreData.length.toString()}");
        });
      }
    });
  }

  void addRecords(x) async {
    itemsCollectionRef.get().then((value) {
      value.docs.asMap().forEach((indx, doc) {
        doc.data()["items"].forEach((item) {
          itemsRecords!.forEach((element) {
            if (item.toString() != element.toString()) {
              debugPrint("work");
              itemsCollectionRef.add({"items": element});
              // .then((value) {
              //   itemsCollectionRef.get().then((value) {
              //     value.docs.asMap().forEach((indx, element) {
              //       element.data()["items"].forEach((item) {
              //         fireStoreData.add(item);
              //       });
              //     });
              //   });
              // });
            } else {
              debugPrint("did not work");
            }
          });
          debugPrint(item.toString());
          fireStoreData.add(item);
          filterdFireStoreData = fireStoreData;
        });
        debugPrint("first${fireStoreData.length.toString()}");
        debugPrint("second${filterdFireStoreData.length.toString()}");
        //element.data()["items"][indx] //to access the element
      });
    });

    // itemsCollectionRef.add({"items": itemsRecords}).then((value) {
    //   itemsCollectionRef.get().then((value) {
    //     value.docs.asMap().forEach((indx, element) {
    //       element.data()["items"].forEach((item) {
    //         fireStoreData.add(item);
    //       });
    //       //debugPrint(element.data()["items"][indx].toString()); //to access the element
    //     });
    //   });
    // });
    //worked
    // x.forEach((element) {
    //   itemsCollectionRef.add(element).then((value) {
    //     itemsCollectionRef.get().then((snapshot) {
    //       snapshot.docs.forEach((doc) {
    //         //fireStoreData.add(doc.data());
    //         debugPrint(doc.data().toString());
    //       });
    //     });
    //   });
    // });

    //all in one field
    // await collection1.add({
    //   'maps': jsonEncode(records),
    // });

    //Collection
    //collection1.add({'items': records});

    //Document
    //FirebaseFirestore.instance.doc('items2/2').set({'some_key': records});

    //each record in a doc
    // records.forEach((element) {
    //   FirebaseFirestore.instance.collection("items3").doc().set(element);
    // });

    // CollectionReference collectionReference = fireStore.collection('items');
    // Start a batch write
    // WriteBatch batch = fireStore.batch();
    /// Add multiple records to the batch
    // batch.set(collectionReference.doc(), {
    //   'name': 'milk',
    //   'price': '1',
    // });
    // batch.set(collectionReference.doc(), {
    //   'name': 'oat',
    //   'price': '3',
    // });

    // Commit the batch write
    // await batch.commit();
  }

  //DATE & TIME SECTION ///////////////////////////////////////////

  DateTime selectedDate = DateTime.now();
  var formatOfDate = DateFormat("yyyy-MM-dd");
  var formatOfDate2 = DateFormat("dd");
  late String formattedDate = formatOfDate.format(selectedDate);
  DateTime now = DateTime.now();
  late String formattedTime = DateFormat('hh:mm:ss').format(now);
  void trueDate() {
    formattedDate = formatOfDate.format(DateTime.now()).toString();
  }
  //DROPDOWN SECTION //////////////////////////////////////////////////////////

  late String dropdownValue = (taxLIst.first).toString();
  void changeDropDownList(value) {
    dropdownValue = value;
    emit(ChangeCheckBox());
  }

  late String unitDropdownValue = (dropDownUnitsList.first).toString();
  void changeUnitDropDownList(value) {
    unitDropdownValue = value;
    emit(ChangeCheckBox());
  }

  //CHECKBOX SECTION /////////////////////////////////////////////////////////////////

  late List<int> cc = [
    (settingsList[0]["settings_state"]),
    (settingsList[1]["settings_state"])
  ];
  void change(value, index) {
    cc[index] = value == false ? 0 : 1;

    emit(ChangeCheckBox());
  }

  //CONTROLLERS SECTION /////////////////////////////////////////////////////////////
  TextEditingController discountCon = TextEditingController(text: "1");
  TextEditingController writeClientNameCon = TextEditingController();
  late TextEditingController priceEditingController = TextEditingController();
  TextEditingController quantityController = TextEditingController(text: "1");
  TextEditingController clientsFilteringController = TextEditingController();
  TextEditingController itemsFilteringController = TextEditingController();
  TextEditingController historyFilteringController = TextEditingController();
  //FILLTERING SECTION ///////////////////////////////////////////////////////////////

  List<Map> filterdHistory = [];
  List<Map> filterdItems = [];
  List<Map> filteredClients = [];
  void filtering(String enteredKeyword, list) {
    List<Map> results = [];
    if (enteredKeyword.isEmpty) {
      if (list == "clients") {
        results = clients;
        filteredClients = results;
        emit(Filtering());
      } else if (list == "items") {
        results = fireStoreData;
        filterdFireStoreData = results;
        emit(Filtering());
      } else {
        results = history;
        filterdHistory = results;
        emit(Filtering());
      }
    } else {
      if (list == "clients") {
        results = clients
            .where((user) => user["client_name"]
                .toLowerCase()
                .contains(enteredKeyword.toLowerCase()))
            .toList();
        filteredClients = results;
        emit(Filtering());
      } else if (list == "items") {
        results = fireStoreData
            .where((user) => user["item_desc"]
                .toLowerCase()
                .contains(enteredKeyword.toLowerCase()))
            .toList();

        filterdFireStoreData = results;
        emit(Filtering());
      } else {
        results = history
            .where((user) => (user["invoice_date"])
                .toString()
                .substring(8)
                .toLowerCase()
                .contains(enteredKeyword.toString().toLowerCase()))
            .toList();
        filterdHistory = results;

        emit(Filtering());
      }
    }
  }

  // INVOICE INFO SECTION /////////////////////////////////////////////
  String client_name = '';
  int client_id = 0;
  num dis = 0;
  num totalAfter = 0;
  num totalBefor = 0;
  num dayTotal = 0;
  var formkey = GlobalKey<FormState>();

  String clientName(index) {
    client_id = filteredClients[index]["client_id"];
    client_name = filteredClients[index]["client_name"];

    emit(AddClient(client_name, client_id));
    return client_name;
  }

  String writeClientName() {
    client_name = writeClientNameCon.text;
    emit(WriteClient(client_name));
    return client_name;
  }

  int getInvoiceNum() {
    debugPrint("length${history.length.toString()}");
    debugPrint("sells${sellsMax.toString()}");
    if (history.isEmpty) {
      return 1;
    } else {
      getSellsMaxFromInfo(database);
      if (sellsMax.isEmpty || sellsMax[0]["sells_max"] == null) {
        return 1;
      } else {
        return (sellsMax[0]["sells_max"]) + 1;
      }
    }
  }

  int getReturnNum() {
    getReturnsMaxFromInfo(database);
    debugPrint(returnsMax.toString());
    if (returnsMax.isEmpty || returnsMax[0]["return_max"] == null) {
      return 1;
    } else {
      return (returnsMax[0]["return_max"]) + 1;
    }
  }

  int getInfoId() {
    if (history.isEmpty) {
      return 1;
    } else {
      return history[history.length - 1]["info_id"] + 1;
    }
  }

  num calculateTotal() {
    totalAfter = totalBefor = 0;
    for (var element in totalOfItem) {
      totalBefor += element;
      totalAfter += element;
    }
    return totalBefor;
  }

  num calculateDayTotal() {
    dayTotal = 0;
    for (var element in history) {
      dayTotal += (element["total"]);
    }
    return dayTotal;
  }

  void afterSave() {
    debugPrint(sellsOrReturns.toString());
    debugPrint(history.toString());
    debugPrint(savedItems.toString());
    getInvoiceNum();
    getReturnNum();
    allAddedItems.clear();
    totalOfItem.clear();
    priceOfItem.clear();
    quantity.clear();
    client_name = "";
    client_id = 0;
    totalAfter = 0;
    totalBefor = 0;
    dis = 0;
    //savedItemsIndx = 0;
    writeClientNameCon.clear();
    sellsOrReturns = 1;
    debugPrint(sellsOrReturns.toString());
    emit(AfterSaveInvoice());
  }

  List saved = [];

  showSavedItems(index) {
    saved.clear();
    for (var element in savedItems) {
      if (element["invoice_num"].toString() ==
          filterdHistory[index]["invoice_number"].toString()) {
        saved.add(element);
      }
    }
    debugPrint(saved.toString());
  }

  isExist(controller, BuildContext context) {
    for (var element in items) {
      if (controller.text == element["item_num"]) {
        continue;
      }
    }
    return true;
  }

  void addToList() {
    quantity.add(sellsOrReturns == 1
        ? quantityController.text
        : (num.parse(quantityController.text) * (-1)).toString());

    totalOfItem.add(((cc[1] == 1 //.............
            ? sellsOrReturns == 1
                ? (num.parse(priceEditingController.text) +
                    ((currentAddedItem[0]["tax"] *
                            num.parse(priceEditingController.text)) /
                        100))
                : (num.parse(priceEditingController.text) +
                        ((currentAddedItem[0]["tax"] *
                                num.parse(priceEditingController.text)) /
                            100)) *
                    sellsOrReturns
            : sellsOrReturns == 1
                ? (currentAddedItem[0]['price'] +
                    ((currentAddedItem[0]["tax"] *
                            currentAddedItem[0]['price']) /
                        100))
                : (currentAddedItem[0]['price'] +
                        ((currentAddedItem[0]["tax"] *
                                currentAddedItem[0]['price']) /
                            100)) *
                    sellsOrReturns) *
        num.parse(quantityController.text))); //............

    priceOfItem.add(cc[1] == 1
        ? num.parse(priceEditingController.text)
        : currentAddedItem[0]['price']);
    calculateTotal(); //...............
    Future.delayed(const Duration(milliseconds: 100), () {
      currentAddedItem.clear();
      quantityController = TextEditingController(text: "1");
    });

    debugPrint("1111111111111111111111");
  }

  
}

// Future<void> insertAmount(context) async {
//   emit(OpenDialogForQuantity());
//   return await showDialog(
//     context: context,
//     builder: (context) {
//       return Wrap(children: <Widget>[
//         AlertDialog(
//           title: const Text('قم بإدخال الكمية'),
//           content: Form(
//             child: Column(children: []),
//           ),
//           actions: <Widget>[
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color.fromRGBO(120, 166, 200, 1)),
//               child: const Text('save'),
//               onPressed: () {
//                 emit(AddItemToInvoice());
//quantity = int.parse(quantityController.text);
//                 print(cardList1.length);
// print(cardList2.length);
// print(cardList3.length);
//                 cardList1[index]['quantity'].add(quantity.toString());
//                 print(cardList1.length);
// print(cardList2.length);
// print(cardList3.length);
//                 Navigator.pop(context);
//                 cardHeigt += 60;
//                 quantityController.clear();
// Navigator.push(
//   context,
//   MaterialPageRoute(builder: (context) => home()),//                 // );
//                 //Navigator.pop(context);
//               },
//             ),
//           ],
//         ),
//       ]);
//     },
//   );
// }

// Widget card() {
//   return Card(
//     elevation: 5,
//     child: Container(
//       margin: const EdgeInsets.only(left: 5, top: 3),
//       height: 40,
//       width: 300,
//       child: Center(
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               name,
//               style: const TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black),
//             ),
//             Text(
//               quantityController.text,
//               style: const TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black),
//             ),
//             Text(
//               price.toString(),
//               style: const TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black),
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// }

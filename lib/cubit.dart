//import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqlbrite/sqlbrite.dart';
import 'bill_screen.dart';
import 'history.dart';
import 'items_modle.dart';
import 'states.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class InvoiceCubit extends Cubit<InvoiceStates> {
  InvoiceCubit() : super(InvoiceInitStates());

  static InvoiceCubit get(context) => BlocProvider.of(context);
  bool sellsOrReturns = false;

  //HIVE SECTION

  // void put({required String name, required int num}) {
  //   final clients = AddClients()
  //     ..name = name
  //     ..num = num;

  //   final box = Boxes.get();
  //   box.add(clients);
  //   debugPrint(box.values.toList().cast<AddClients>().toString());
  // }
  //{"items_id":1,"unit_id":1,"item_desc":"milk","item_no":1,"price":1,"tax":4}

  //DATABASE SECTION //////////////////////////////////////////////////////////////

  static Database? database;
  Future<Database?> get getDb async {
    if (database == null) {
      database = await createDatabase().then((value) {});
      return database;
    } else {
      return database;
    }
  }

  //late Database database;

  String itemsTable =
      "CREATE TABLE items(items_id INTEGER PRIMARY KEY AUTOINCREMENT,unit_id INTEGER ,item_desc VARCHAR NOT NULL, item_no INTEGER NOT NULL,price INTEGER NOT NULL,tax INTEGER NOT NULL)";
  String clientsTable =
      "CREATE TABLE clients(client_id INTEGER PRIMARY KEY AUTOINCREMENT,client_name VARCHAR NOT NULL, phone_number VARCHAR NOT NULL )";
  String invoiceInfoTable =
      "CREATE TABLE invoice_info(info_id INTEGER PRIMARY KEY AUTOINCREMENT,client_id INTEGER,invoice_number INTEGER NOT NULL, invoice_date VARCHAR NOT NULL,client_name VARCHAR NOT NULL,total INTEGER NOT NULL,notes VARCHAR )";
  String invoiceItemsTable =
      "CREATE TABLE invoice_items(items_id INTEGER PRIMARY KEY AUTOINCREMENT,info_id INTEGER NOT NULL,unit_id INTEGER ,invoice_num INTEGER NOT NULL,invoice_items VARCHAR NOT NULL,quentity INTEGER NOT NULL,price INTEGER NOT NULL,tax INTEGER NOT NULL)";
  String settingsTable =
      "CREATE TABLE settings(id INTEGER PRIMARY KEY AUTOINCREMENT,settings VARCHAR NOT NULL,settings_state INTEGER NOT NULL)";
  String unitsTable =
      "CREATE TABLE units(unit_id INTEGER PRIMARY KEY AUTOINCREMENT,unit VARCHAR NOT NULL)";

  List<Map> items = [];
  List<Map> clients = [];
  List<Map> history = [];
  List<Map> history2 = [];
  List<Map> returns = [];
  List<Map> savedItems = [];
  List<Map> settingsList = [];
  List totalOfItem = [];
  List quantity = [];
  List returnsQuantity = [];
  List priceOfItem = [];
  List dropDownUnitsList = [];
  List<int> taxLIst = <int>[0, 4, 8, 16];
  List<Map> unitsList = [];
  late List<Map> allAddedItems = [];
  late List<Map> currentAddedItem = [];

  late List<Map> allReturnsItems = [];
  late List<Map> currentReturnsItem = [];
  List totalOfReturns = [];
  List priceOfReturns = [];

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
      getDataFromDatabase(database, "invoice_info").then((value) {
        history = filterdHistory = value;
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
    });
    // .then((value) {
    //   if (database == null) {
    //     getDb.then((value) {
    //       insertToUnits();
    //       insertToSettings();
    //     });
    //   } else {
    //     insertToUnits();
    //     insertToSettings();
    //   }
    //   return Future.delayed(const Duration(microseconds: 0));
    // });
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
      int? clientId,
      required String notes}) async {
    await database?.transaction((txn) {
      txn
          .rawInsert(
              'INSERT INTO invoice_info(invoice_number,invoice_date,client_name,client_id,total,notes) VALUES("$invoiceNumber","$invoiceDate","$clientName","$clientId","$total","$notes")')
          .then((value) {
        emit(InsertDatabase());
        // getDataFromDatabase(database, "invoice_info").then((value) {
        //   history = filterdHistory = value;
        //   emit(GetDatabase());
        // }).then((value) {
        //   calculateDayTotal();
        // });
        getDataFromInfo(database, "invoice_info").then((value) {
          history = filterdHistory = value;
          emit(GetDatabase());
        }).then((value) {
          calculateDayTotal();
          debugPrint("hereeeee${history2.toString()}");
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
    // await database.transaction((txn) {
    //   txn
    //       .rawInsert(
    //           'INSERT INTO units(unit) VALUES("pcs")')
    //       .then((value) {
    //     emit(InsertDatabase());
    //     getDataFromDatabase(database, "settings").then((value) {
    //       settingsList = value;
    //       emit(GetDatabase());
    //     });
    //   });
    //   return Future.delayed(const Duration(microseconds: 0));
    // }
    // );

    // await database.transaction((txn) {
    //   print("doneeeeeeee2");
    //   txn
    //       .rawInsert(
    //           'INSERT INTO settings(settings,settings_state) VALUES("edit sale price","false")')
    //       .then((value) {
    //     emit(InsertDatabase());
    //     getDataFromDatabase(database, "settings").then((value) {
    //       settingsList = value;
    //       emit(GetDatabase());
    //     });
    //   });
    //   return Future.delayed(const Duration(microseconds: 0));
    // }
    // );

    //database.batch().rawInsert('INSERT INTO units(unit) VALUES("pcs")');
    //database=await createDatabase();

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

  Future<List<Map>> getDataFromDatabase(database, tableName) async {
    return database.rawQuery('SELECT * FROM $tableName ');
  }

  Future<List<Map>> getDataFromInfo(database, tableName) async {
    return database
        .rawQuery('SELECT * FROM $tableName ORDER BY invoice_date DESC');
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

  // void updateToReturns({required int quantity, required int id}) {
  //   database?.rawUpdate(
  //     'UPDATE invoice_items SET quentity = ? WHERE info_id = ?',
  //     [quantity, id],
  //   ).then((value) {
  //     getDataFromDatabase(database, "invoice_items").then((value) {
  //       //history = filterdHistory = value;
  //       savedItems = value;
  //       emit(GetDatabase());
  //     });
  //     emit(UpdateFromDatabase());
  //   });
  // }

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
    if (sellsOrReturns == true) {
      allReturnsItems.removeAt(index);
      returnsQuantity.removeAt(index);
      totalOfReturns.removeAt(index);
    } else {
      allAddedItems.removeAt(index);
      quantity.removeAt(index);
      totalOfItem.removeAt(index);
    }
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

  final fireStore = FirebaseFirestore.instance;
  late var batch = fireStore.batch();

  final itemsCollectionRef = FirebaseFirestore.instance.collection("items");

  List<Map> fireStoreData = [];
  List<Map> filterdFireStoreData = [];

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
  String? data;
  String? loadedData;
  List splitingList = [];
  List<dynamic>? itemsRecords;
  List<Map<String, dynamic>> uniqueItems = [];
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
//   void addRecords1(x) async {
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
  /*
  int aa = 0;
  late var s = itemss.doc("1");
  
  late CollectionReference itemss =
      FirebaseFirestore.instance.collection('items');
  late QuerySnapshot querySnapshot = itemss.get() as QuerySnapshot<Object?>;
  late var docData = querySnapshot.docs.map((doc) => doc.data()).toList();

  Future<void> getData() async {
    debugPrint("doneeeeee");
    // Get docs from collection reference
    QuerySnapshot querySnapshot = await _fireStore.collection('items').get();

    // Get data from docs and convert map to List
    // allData = querySnapshot.docs.map((doc) => doc.data()).toList();

    //for a specific field
    //  allData =
    //         querySnapshot.docs.map((doc) => doc.get('fieldName')).toList();
    emit(GetDatabase());
    //print(allData[0]['subject_desc']);
  }
  
  
  List<ItemsModel> allData = [];
  ItemsModel? model;
  void getItems() {
    FirebaseFirestore.instance.collection("items").get().then((value) {
      value.docs.forEach((element)  {
        allData.add(ItemsModel.fromJson(element.data()));
        debugPrint(allData.toString());// list  هون انا بدي اعمل برنت لل 
      });
    }).catchError((e) {});
  }
  
  */
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
  //num dis = 0;
  num totalAfter = 0;
  num totalBefor = 0;
  num dayTotal = 0;
  num returnsTotalAfter = 0;
  num returnsTotalBefor = 0;
  //int savedItemsIndx = 0;
  var formkey = GlobalKey<FormState>();
  var returnsFormKey = GlobalKey<FormState>();

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
    if (history.isEmpty) {
      return 1;
    } else {
      return history[history.length - 1]["info_id"] + 1;
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
    num total;
    if (sellsOrReturns == true) {
      returnsTotalAfter = returnsTotalBefor = 0;
      for (var element in totalOfReturns) {
        returnsTotalBefor += element;
        returnsTotalAfter += element;
      }
      total = returnsTotalAfter = returnsTotalBefor;
    } else {
      totalAfter = totalBefor = 0;
      for (var element in totalOfItem) {
        totalBefor += element;
        totalAfter += element;
      }
      total = totalAfter = totalBefor;
    }

    return total;
  }

  //remove num parsing
  num calculateDayTotal() {
    dayTotal = 0;
    for (var element in history) {
      dayTotal += (element["total"]);
    }
    return dayTotal;
  }

  void afterSave() {
    debugPrint(history.toString());
    debugPrint(savedItems.toString());
    getInvoiceNum();
    allAddedItems.clear();
    allReturnsItems.clear();
    totalOfItem.clear();
    priceOfItem.clear();
    totalOfReturns.clear();
    priceOfReturns.clear();
    quantity.clear();
    returnsQuantity.clear();
    client_name = "";
    client_id = 0;
    totalAfter = 0;
    totalBefor = 0;
    dis = 0;
    //savedItemsIndx = 0;
    writeClientNameCon.clear();
    emit(AfterSaveInvoice());
  }

  TextEditingController businessName = TextEditingController();
  TextEditingController emailAddress = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController address = TextEditingController();
  List saved = [];

  showSavedItems(index) {
    saved.clear();
    for (var element in savedItems) {
      if (element["invoice_num"].toString() ==
          filterdHistory[index]["invoice_number"].toString()) {
        saved.add(element);
        //saved.add(element["quentity"]);
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
    if (sellsOrReturns == true) {
      returnsQuantity.add((num.parse(quantityController.text) * (-1)).toString());
      totalOfReturns.add(((cc[1] == 1 //هون
              ? (num.parse(priceEditingController.text) +
                  ((currentReturnsItem[0]["tax"] *
                          num.parse(priceEditingController.text)) /
                      100))
              : (currentReturnsItem[0]['price'] +
                  ((currentReturnsItem[0]["tax"] *
                          currentReturnsItem[0]['price']) /
                      100))) *
          num.parse(quantityController.text) *
          (-1))); //لهون
      priceOfReturns.add(cc[1] == 1
          ? num.parse(priceEditingController.text)
          : currentReturnsItem[0]['price']);
      calculateTotal();
      Future.delayed(const Duration(milliseconds: 100), () {
        currentReturnsItem.clear();
        quantityController.clear();
      });
    } else {
      quantity.add(quantityController.text);
      totalOfItem.add(((cc[1] == 1 //هون
              ? (num.parse(priceEditingController.text) +
                  ((currentAddedItem[0]["tax"] *
                          num.parse(priceEditingController.text)) /
                      100))
              : (currentAddedItem[0]['price'] +
                  ((currentAddedItem[0]["tax"] * currentAddedItem[0]['price']) /
                      100))) *
          num.parse(quantityController.text))); //لهون
      /* */
      priceOfItem.add(cc[1] == 1
          ? num.parse(priceEditingController.text)
          : currentAddedItem[0]['price']);
      calculateTotal();
      Future.delayed(const Duration(milliseconds: 100), () {
        currentAddedItem.clear();
        quantityController = TextEditingController(text: "1");
      });
    }
    debugPrint("1111111111111111111111");
  }

  // var records = [
  //   {
  //     "items_id": 2,
  //     "unit_id": 1,
  //     "item_desc": "مشحاف 3 انش ",
  //     "item_no": 1,
  //     "price": 0.45,
  //     "tax": 0
  //   },
  //   {
  //     "items_id": 3,
  //     "unit_id": 1,
  //     "item_desc": "مشحاف 4انش ",
  //     "item_no": 2,
  //     "price": 0.55,
  //     "tax": 0
  //   },
  //   {
  //     "items_id": 4,
  //     "unit_id": 1,
  //     "item_desc": "مالج يد خشب عادي",
  //     "item_no": 3,
  //     "price": 1.25,
  //     "tax": 0
  //   },
  //   {
  //     "items_id": 5,
  //     "unit_id": 1,
  //     "item_desc": "مالج يد خشب مشرنف",
  //     "item_no": 4,
  //     "price": 1.25,
  //     "tax": 0
  //   },
  //   {
  //     "items_id": 6,
  //     "unit_id": 1,
  //     "item_desc": "مالج يد فيبر عادي  + مشرنف",
  //     "item_no": 5,
  //     "price": 1.50,
  //     "tax": 0
  //   },
  //   // {
  //   //   "items_id": 8,
  //   //   "unit_id": 1,
  //   //   "item_desc": "لباده قصاره يد فيبر ",
  //   //   "item_no": 7,
  //   //   "price": 1.50,
  //   //   "tax": 0
  //   // },
  //   // {
  //   //   "items_id": 9,
  //   //   "unit_id": 1,
  //   //   "item_desc": "رول دهان حجم صغير",
  //   //   "item_no": 8,
  //   //   "price": 0.85,
  //   //   "tax": 0
  //   // },
  //   // {
  //   //   "items_id": 10,
  //   //   "unit_id": 1,
  //   //   "item_desc": "سكينه معجونه 8 انش ",
  //   //   "item_no": 9,
  //   //   "price": 0.50,
  //   //   "tax": 0
  //   // },
  //   // {
  //   //   "items_id": 11,
  //   //   "unit_id": 1,
  //   //   "item_desc": "سكينه معجونه 10انش ",
  //   //   "item_no": 10,
  //   //   "price": 0.50,
  //   //   "tax": 0
  //   // },
  //   // {
  //   //   "items_id": 12,
  //   //   "unit_id": 1,
  //   //   "item_desc": "مسطرين مربع 6انش ",
  //   //   "item_no": 11,
  //   //   "price": 0.65,
  //   //   "tax": 0
  //   // },
  //   // {
  //   //   "items_id": 13,
  //   //   "unit_id": 1,
  //   //   "item_desc": "مسطرين مربع 7انش ",
  //   //   "item_no": 12,
  //   //   "price": 0.75,
  //   //   "tax": 0
  //   // },
  //   // {
  //   //   "items_id": 14,
  //   //   "unit_id": 1,
  //   //   "item_desc": "مسطرين مربع 8انش ",
  //   //   "item_no": 13,
  //   //   "price": 0.85,
  //   //   "tax": 0
  //   // },
  //   // {
  //   //   "items_id": 15,
  //   //   "unit_id": 1,
  //   //   "item_desc": "مسطرين مدور 6 انش ",
  //   //   "item_no": 14,
  //   //   "price": 0.50,
  //   //   "tax": 0
  //   // },
  //   // {
  //   //   "items_id": 16,
  //   //   "unit_id": 1,
  //   //   "item_desc": "مسطرين مدور 7انش ",
  //   //   "item_no": 15,
  //   //   "price": 0.60,
  //   //   "tax": 0
  //   // },
  //   // {
  //   //   "items_id": 17,
  //   //   "unit_id": 1,
  //   //   "item_desc": "مسطرين مدور 8 انش ",
  //   //   "item_no": 16,
  //   //   "price": 0.75,
  //   //   "tax": 0
  //   // },
  //   // {
  //   //   "items_id": 18,
  //   //   "unit_id": 1,
  //   //   "item_desc": "فرد سلكون برتقالي",
  //   //   "item_no": 17,
  //   //   "price": 0.85,
  //   //   "tax": 0
  //   // },
  //   // {
  //   //   "items_id": 19,
  //   //   "unit_id": 1,
  //   //   "item_desc": "فرد سلكون اخضر",
  //   //   "item_no": 18,
  //   //   "price": 2.25,
  //   //   "tax": 0
  //   // },
  //   // {
  //   //   "items_id": 21,
  //   //   "unit_id": 1,
  //   //   "item_desc": "عجل ابيض مع بريك 2انش طقم",
  //   //   "item_no": 20,
  //   //   "price": 1.75,
  //   //   "tax": 0
  //   // },
  //   // {
  //   //   "items_id": 22,
  //   //   "unit_id": 1,
  //   //   "item_desc": "عجل ابيض مع بريك 3انش ",
  //   //   "item_no": 21,
  //   //   "price": 1.00,
  //   //   "tax": 0
  //   // },
  //   // {
  //   //   "items_id": 23,
  //   //   "unit_id": 1,
  //   //   "item_desc": "عجل احمرصغيرمع بريك1.5 انش",
  //   //   "item_no": 22,
  //   //   "price": 0.35,
  //   //   "tax": 0
  //   // },
  //   // {
  //   //   "items_id": 24,
  //   //   "unit_id": 1,
  //   //   "item_desc": "عجل احمرصغيرمع بريك2انش",
  //   //   "item_no": 23,
  //   //   "price": 0.37,
  //   //   "tax": 0
  //   // },
  //   // {
  //   //   "items_id": 25,
  //   //   "unit_id": 1,
  //   //   "item_desc": "عجل احمرصغيرمع بريك2.5انش",
  //   //   "item_no": 24,
  //   //   "price": 0.90,
  //   //   "tax": 0
  //   // },
  //   // {
  //   //   "items_id": 26,
  //   //   "unit_id": 1,
  //   //   "item_desc": "عجل احمر مع بريك3انش",
  //   //   "item_no": 25,
  //   //   "price": 1.25,
  //   //   "tax": 0
  //   // },
  //   // {
  //   //   "items_id": 27,
  //   //   "unit_id": 1,
  //   //   "item_desc": "عجل صوبه ",
  //   //   "item_no": 26,
  //   //   "price": 1.50,
  //   //   "tax": 0
  //   // },
  //   // {
  //   //   "items_id": 28,
  //   //   "unit_id": 1,
  //   //   "item_desc": "بوز شد هنجر10-48mm",
  //   //   "item_no": 27,
  //   //   "price": 1.75,
  //   //   "tax": 0
  //   // },
  //   // {
  //   //   "items_id": 29,
  //   //   "unit_id": 1,
  //   //   "item_desc": "بوزشد هنجر 8-10-12—48mm",
  //   //   "item_no": 28,
  //   //   "price": 1.75,
  //   //   "tax": 0
  //   // },
  //   // {
  //   //   "items_id": 30,
  //   //   "unit_id": 1,
  //   //   "item_desc": "بوز شد سلف درل عادي",
  //   //   "item_no": 29,
  //   //   "price": 2.50,
  //   //   "tax": 0
  //   // },
  //   // {
  //   //   "items_id": 31,
  //   //   "unit_id": 1,
  //   //   "item_desc": "بوزشدسلف دريل منحس",
  //   //   "item_no": 30,
  //   //   "price": 3.00,
  //   //   "tax": 0
  //   // },
  //   // {
  //   //   "items_id": 32,
  //   //   "unit_id": 1,
  //   //   "item_desc": "طقم فتاحات سبوت16pcs",
  //   //   "item_no": 31,
  //   //   "price": 3.50,
  //   //   "tax": 0
  //   // },
  //   // {
  //   //   "items_id": 33,
  //   //   "unit_id": 1,
  //   //   "item_desc": "رول دهان تقليد الماني",
  //   //   "item_no": 32,
  //   //   "price": 1.25,
  //   //   "tax": 0
  //   // },
  //   // {
  //   //   "items_id": 34,
  //   //   "unit_id": 1,
  //   //   "item_desc": "كفوف بني ثقيل",
  //   //   "item_no": 33,
  //   //   "price": 6.50,
  //   //   "tax": 0
  //   // },
  //   // {
  //   //   "items_id": 35,
  //   //   "unit_id": 1,
  //   //   "item_desc": "كفوف صوف خفيف + مغطس",
  //   //   "item_no": 34,
  //   //   "price": 0.20,
  //   //   "tax": 0
  //   // },
  //   // {
  //   //   "items_id": 36,
  //   //   "unit_id": 1,
  //   //   "item_desc": "مقص انبيب بلاستك احمر",
  //   //   "item_no": 35,
  //   //   "price": 2.50,
  //   //   "tax": 0
  //   // },
  //   // {
  //   //   "items_id": 37,
  //   //   "unit_id": 1,
  //   //   "item_desc": "وصله ملون تلفزيون اوديو3*3",
  //   //   "item_no": 36,
  //   //   "price": 0.50,
  //   //   "tax": 0
  //   // },
  //   // {
  //   //   "items_id": 38,
  //   //   "unit_id": 1,
  //   //   "item_desc": "وصلة 3*1",
  //   //   "item_no": 37,
  //   //   "price": 0.50,
  //   //   "tax": 0
  //   // },
  //   // {
  //   //   "items_id": 39,
  //   //   "unit_id": 1,
  //   //   "item_desc": "وصله   1.5m    HD  ",
  //   //   "item_no": 38,
  //   //   "price": 1.00,
  //   //   "tax": 0
  //   // },
  //   // {
  //   //   "items_id": 40,
  //   //   "unit_id": 1,
  //   //   "item_desc": "كاوي الحام 40w ",
  //   //   "item_no": 39,
  //   //   "price": 1.25,
  //   //   "tax": 0
  //   // },
  //   // {
  //   //   "items_id": 41,
  //   //   "unit_id": 1,
  //   //   "item_desc": "كاوي الحام 60w ",
  //   //   "item_no": 40,
  //   //   "price": 2.50,
  //   //   "tax": 0
  //   // },
  //   // {
  //   //   "items_id": 42,
  //   //   "unit_id": 1,
  //   //   "item_desc": "روسيه سلك ستلايت ابيض",
  //   //   "item_no": 41,
  //   //   "price": 3.50,
  //   //   "tax": 0
  //   // },
  //   // {
  //   //   "items_id": 43,
  //   //   "unit_id": 1,
  //   //   "item_desc": "وصلة .... ملغي",
  //   //   "item_no": 42,
  //   //   "price": 5.00,
  //   //   "tax": 0
  //   // },
  //   // {
  //   //   "items_id": 45,
  //   //   "unit_id": 1,
  //   //   "item_desc": "لفه قصدير الحام 50غرام",
  //   //   "item_no": 44,
  //   //   "price": 0.75,
  //   //   "tax": 0
  //   // },
  //   // {
  //   //   "items_id": 46,
  //   //   "unit_id": 1,
  //   //   "item_desc": "علبه براغي واسفين 5ملم",
  //   //   "item_no": 45,
  //   //   "price": 0.35,
  //   //   "tax": 0
  //   // },
  //   // {
  //   //   "items_id": 48,
  //   //   "unit_id": 1,
  //   //   "item_desc": "حبل غسيل 15m مكلفن",
  //   //   "item_no": 47,
  //   //   "price": 0.50,
  //   //   "tax": 0
  //   // },
  //   // {
  //   //   "items_id": 50,
  //   //   "unit_id": 1,
  //   //   "item_desc": "حبل غسيل 30m كبير",
  //   //   "item_no": 49,
  //   //   "price": 0.75,
  //   //   "tax": 0
  //   // },
  //   //   {
  //   //     "items_id": 51,
  //   //     "unit_id": 1,
  //   //     "item_desc": "حبل غسيل 20m ملون وسط",
  //   //     "item_no": 50,
  //   //     "price": 0.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 52,
  //   //     "unit_id": 1,
  //   //     "item_desc": "غراء خشب ابيض 100غرام",
  //   //     "item_no": 51,
  //   //     "price": 0.40,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 53,
  //   //     "unit_id": 1,
  //   //     "item_desc": "غراء خشب ابيض 250غرام",
  //   //     "item_no": 52,
  //   //     "price": 0.60,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 54,
  //   //     "unit_id": 1,
  //   //     "item_desc": "غراء خشب ابيض 500غرام",
  //   //     "item_no": 53,
  //   //     "price": 1.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 55,
  //   //     "unit_id": 1,
  //   //     "item_desc": "غراء خشب ابيض 1 كيلوا",
  //   //     "item_no": 54,
  //   //     "price": 1.25,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 57,
  //   //     "unit_id": 1,
  //   //     "item_desc": "سوبر جلو على كرت ",
  //   //     "item_no": 56,
  //   //     "price": 1.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 58,
  //   //     "unit_id": 1,
  //   //     "item_desc": "فرد سلكون حراري 100w",
  //   //     "item_no": 57,
  //   //     "price": 3.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 59,
  //   //     "unit_id": 1,
  //   //     "item_desc": "فرد سلكون عظم احمر",
  //   //     "item_no": 58,
  //   //     "price": 1.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 60,
  //   //     "unit_id": 1,
  //   //     "item_desc": "فرد سلكون عظم برتقالي ",
  //   //     "item_no": 59,
  //   //     "price": 1.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 61,
  //   //     "unit_id": 1,
  //   //     "item_desc": "مقص زينه شجره  خشب",
  //   //     "item_no": 60,
  //   //     "price": 5.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 62,
  //   //     "unit_id": 1,
  //   //     "item_desc": "ازميل ",
  //   //     "item_no": 61,
  //   //     "price": 1.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 63,
  //   //     "unit_id": 1,
  //   //     "item_desc": "مفك دق مصلب وعادي ",
  //   //     "item_no": 62,
  //   //     "price": 0.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 64,
  //   //     "unit_id": 1,
  //   //     "item_desc": "مفك طبه مشكل",
  //   //     "item_no": 63,
  //   //     "price": 0.42,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 65,
  //   //     "unit_id": 1,
  //   //     "item_desc": "مقص شجر صغير ",
  //   //     "item_no": 64,
  //   //     "price": 2.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 66,
  //   //     "unit_id": 1,
  //   //     "item_desc": "شاكوش خلع  كبير",
  //   //     "item_no": 65,
  //   //     "price": 2.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 68,
  //   //     "unit_id": 1,
  //   //     "item_desc": "مشرط عجل ",
  //   //     "item_no": 67,
  //   //     "price": 0.55,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 69,
  //   //     "unit_id": 1,
  //   //     "item_desc": "لاصق شفاف ",
  //   //     "item_no": 68,
  //   //     "price": 1.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 77,
  //   //     "unit_id": 1,
  //   //     "item_desc": "مربط حديدمشكل",
  //   //     "item_no": 76,
  //   //     "price": 3.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 78,
  //   //     "unit_id": 1,
  //   //     "item_desc": "مربط بطاريه سياره على كرت ",
  //   //     "item_no": 77,
  //   //     "price": 0.60,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 82,
  //   //     "unit_id": 1,
  //   //     "item_desc": "مربط بلاستك مشكل",
  //   //     "item_no": 81,
  //   //     "price": 0.75,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 83,
  //   //     "unit_id": 1,
  //   //     "item_desc": "مربط بلاستك كبير",
  //   //     "item_no": 82,
  //   //     "price": 3.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 87,
  //   //     "unit_id": 1,
  //   //     "item_desc": "مشرط على كرت ",
  //   //     "item_no": 86,
  //   //     "price": 1.75,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 88,
  //   //     "unit_id": 1,
  //   //     "item_desc": "درل شحن 12v ",
  //   //     "item_no": 87,
  //   //     "price": 18.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 89,
  //   //     "unit_id": 1,
  //   //     "item_desc": "درل شحن v 18",
  //   //     "item_no": 88,
  //   //     "price": 20.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 90,
  //   //     "unit_id": 0,
  //   //     "item_desc": "درل شحن 24v ",
  //   //     "item_no": 89,
  //   //     "price": 27.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 91,
  //   //     "unit_id": 1,
  //   //     "item_desc": "طقم طرطيقه",
  //   //     "item_no": 90,
  //   //     "price": 8.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 92,
  //   //     "unit_id": 1,
  //   //     "item_desc": "شاكوش خلع صغير",
  //   //     "item_no": 91,
  //   //     "price": 1.75,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 94,
  //   //     "unit_id": 1,
  //   //     "item_desc": "منشار شجر ساموراي",
  //   //     "item_no": 93,
  //   //     "price": 1.75,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 95,
  //   //     "unit_id": 1,
  //   //     "item_desc": "طقم مشحاف حديد وبلاستك ",
  //   //     "item_no": 94,
  //   //     "price": 0.25,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 96,
  //   //     "unit_id": 1,
  //   //     "item_desc": "زرديه لون اصفر",
  //   //     "item_no": 95,
  //   //     "price": 1.25,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 99,
  //   //     "unit_id": 0,
  //   //     "item_desc": "منشار حديد برتقالي بولاند",
  //   //     "item_no": 98,
  //   //     "price": 1.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 100,
  //   //     "unit_id": 1,
  //   //     "item_desc": "صندوق عده  اصفر3 قطع",
  //   //     "item_no": 99,
  //   //     "price": 18.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 101,
  //   //     "unit_id": 1,
  //   //     "item_desc": "صندوق عده سكني 3 قطع ",
  //   //     "item_no": 100,
  //   //     "price": 16.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 102,
  //   //     "unit_id": 1,
  //   //     "item_desc": "مفك تي + مفك تي طرطيقه",
  //   //     "item_no": 101,
  //   //     "price": 1.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 103,
  //   //     "unit_id": 1,
  //   //     "item_desc": "حنفيه كولر",
  //   //     "item_no": 102,
  //   //     "price": 0.45,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 105,
  //   //     "unit_id": 1,
  //   //     "item_desc": "رشاشه ماء 1.5 لتر",
  //   //     "item_no": 104,
  //   //     "price": 1.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 106,
  //   //     "unit_id": 1,
  //   //     "item_desc": "رشاشه ماء 2لتر شفاف",
  //   //     "item_no": 105,
  //   //     "price": 2.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 107,
  //   //     "unit_id": 1,
  //   //     "item_desc": "سيفون مغسله ",
  //   //     "item_no": 106,
  //   //     "price": 0.45,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 108,
  //   //     "unit_id": 1,
  //   //     "item_desc": "سيفون مجلى + مغسلة",
  //   //     "item_no": 107,
  //   //     "price": 0.75,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 109,
  //   //     "unit_id": 1,
  //   //     "item_desc": "سيفون مجلى دبل واي",
  //   //     "item_no": 108,
  //   //     "price": 1.20,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 110,
  //   //     "unit_id": 1,
  //   //     "item_desc": "حشوه فلتر مبريم",
  //   //     "item_no": 109,
  //   //     "price": 7.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 112,
  //   //     "unit_id": 1,
  //   //     "item_desc": "غطاء مرحاض ",
  //   //     "item_no": 111,
  //   //     "price": 2.30,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 113,
  //   //     "unit_id": 1,
  //   //     "item_desc": "غطاء مرحاض اطفال ",
  //   //     "item_no": 112,
  //   //     "price": 2.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 114,
  //   //     "unit_id": 1,
  //   //     "item_desc": "حشوه فلتر 3 قطع",
  //   //     "item_no": 113,
  //   //     "price": 1.80,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 115,
  //   //     "unit_id": 1,
  //   //     "item_desc": "صباب غاطس ",
  //   //     "item_no": 114,
  //   //     "price": 1.75,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 117,
  //   //     "unit_id": 1,
  //   //     "item_desc": "تي + مفة فلتر مشكل",
  //   //     "item_no": 116,
  //   //     "price": 0.25,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 118,
  //   //     "unit_id": 1,
  //   //     "item_desc": "مفتاح جره فلتر ",
  //   //     "item_no": 117,
  //   //     "price": 1.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 119,
  //   //     "unit_id": 1,
  //   //     "item_desc": "محبس فلتر  حديد ازرق",
  //   //     "item_no": 118,
  //   //     "price": 1.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 120,
  //   //     "unit_id": 1,
  //   //     "item_desc": " براغي غطاء مرحاض",
  //   //     "item_no": 119,
  //   //     "price": 0.45,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 121,
  //   //     "unit_id": 1,
  //   //     "item_desc": "بربيش تصريف غساله ",
  //   //     "item_no": 120,
  //   //     "price": 1.25,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 122,
  //   //     "unit_id": 1,
  //   //     "item_desc": "بربيش فلتر ابيض100متر",
  //   //     "item_no": 121,
  //   //     "price": 6.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 123,
  //   //     "unit_id": 1,
  //   //     "item_desc": "مفتاح حشوه فلتر ",
  //   //     "item_no": 122,
  //   //     "price": 0.60,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 124,
  //   //     "unit_id": 1,
  //   //     "item_desc": "عوامه نيجرا جنب برتغالي",
  //   //     "item_no": 123,
  //   //     "price": 3.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 125,
  //   //     "unit_id": 1,
  //   //     "item_desc": "عوامه نيجرا سفلي برتغالي",
  //   //     "item_no": 124,
  //   //     "price": 3.75,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 126,
  //   //     "unit_id": 1,
  //   //     "item_desc": "عوامه نيجرا مرحاض طابه",
  //   //     "item_no": 125,
  //   //     "price": 1.25,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 127,
  //   //     "unit_id": 1,
  //   //     "item_desc": "رول فاين",
  //   //     "item_no": 126,
  //   //     "price": 1.25,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 128,
  //   //     "unit_id": 1,
  //   //     "item_desc": "غطاء حمام عربي رداد",
  //   //     "item_no": 127,
  //   //     "price": 0.35,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 130,
  //   //     "unit_id": 0,
  //   //     "item_desc": "مضخه كاز",
  //   //     "item_no": 129,
  //   //     "price": 0.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 131,
  //   //     "unit_id": 1,
  //   //     "item_desc": "مقص مواسير بيكس ازرق",
  //   //     "item_no": 130,
  //   //     "price": 2.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 132,
  //   //     "unit_id": 1,
  //   //     "item_desc": "كف دش كعب الست",
  //   //     "item_no": 131,
  //   //     "price": 1.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 133,
  //   //     "unit_id": 1,
  //   //     "item_desc": "عوامه نيجرا سفلي على كرت ",
  //   //     "item_no": 132,
  //   //     "price": 1.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 134,
  //   //     "unit_id": 1,
  //   //     "item_desc": "قصبه مغسله مشكل عادي",
  //   //     "item_no": 133,
  //   //     "price": 0.60,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 135,
  //   //     "unit_id": 1,
  //   //     "item_desc": "طاسه دش مربع ومدور ",
  //   //     "item_no": 134,
  //   //     "price": 2.25,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 136,
  //   //     "unit_id": 1,
  //   //     "item_desc": "قصبه زنبرك مجلي ",
  //   //     "item_no": 135,
  //   //     "price": 1.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 137,
  //   //     "unit_id": 1,
  //   //     "item_desc": "قصبه ملونه بوز عريض",
  //   //     "item_no": 136,
  //   //     "price": 2.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 139,
  //   //     "unit_id": 1,
  //   //     "item_desc": "يد شطافه بلاستك  ",
  //   //     "item_no": 138,
  //   //     "price": 0.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 140,
  //   //     "unit_id": 1,
  //   //     "item_desc": "شطاف  علبه  أزرق ",
  //   //     "item_no": 139,
  //   //     "price": 1.35,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 141,
  //   //     "unit_id": 1,
  //   //     "item_desc": "بربيش كروم ثقيل نحاس",
  //   //     "item_no": 140,
  //   //     "price": 1.25,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 142,
  //   //     "unit_id": 1,
  //   //     "item_desc": "كف دش مع بربيش حركات ثقيل",
  //   //     "item_no": 141,
  //   //     "price": 2.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 143,
  //   //     "unit_id": 1,
  //   //     "item_desc": "بوز توفير مجلي قصير ",
  //   //     "item_no": 142,
  //   //     "price": 0.65,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 144,
  //   //     "unit_id": 1,
  //   //     "item_desc": "بوز توفر مجلي طويل ",
  //   //     "item_no": 143,
  //   //     "price": 0.75,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 145,
  //   //     "unit_id": 1,
  //   //     "item_desc": "شطافه كيس اصفر ",
  //   //     "item_no": 144,
  //   //     "price": 1.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 146,
  //   //     "unit_id": 1,
  //   //     "item_desc": "شطافه كروم",
  //   //     "item_no": 145,
  //   //     "price": 4.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 148,
  //   //     "unit_id": 1,
  //   //     "item_desc": "سيفون مجلي غاطس سكني",
  //   //     "item_no": 147,
  //   //     "price": 3.25,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 149,
  //   //     "unit_id": 1,
  //   //     "item_desc": "محبس غساله ازرق",
  //   //     "item_no": 148,
  //   //     "price": 1.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 150,
  //   //     "unit_id": 1,
  //   //     "item_desc": "حنفيه ستيم نحاس صيني",
  //   //     "item_no": 149,
  //   //     "price": 1.25,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 152,
  //   //     "unit_id": 1,
  //   //     "item_desc": "بربيش تغذيه 2 متر ",
  //   //     "item_no": 151,
  //   //     "price": 1.40,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 153,
  //   //     "unit_id": 1,
  //   //     "item_desc": "بربيش تغذيه 3 متر ",
  //   //     "item_no": 152,
  //   //     "price": 2.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 154,
  //   //     "unit_id": 1,
  //   //     "item_desc": "بربيش تغذيه  4متر ",
  //   //     "item_no": 153,
  //   //     "price": 2.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 155,
  //   //     "unit_id": 1,
  //   //     "item_desc": " صباب كبس مغسله ",
  //   //     "item_no": 154,
  //   //     "price": 1.75,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 156,
  //   //     "unit_id": 1,
  //   //     "item_desc": "مصفاة ستانلس 10*10 كبس",
  //   //     "item_no": 155,
  //   //     "price": 2.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 157,
  //   //     "unit_id": 1,
  //   //     "item_desc": "مصفاة ستانلس 10*10 مفتوح",
  //   //     "item_no": 156,
  //   //     "price": 1.75,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 158,
  //   //     "unit_id": 1,
  //   //     "item_desc": "اكسسوار حمام",
  //   //     "item_no": 157,
  //   //     "price": 7.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 159,
  //   //     "unit_id": 1,
  //   //     "item_desc": "مصفاه ارض 15×15 ايفان",
  //   //     "item_no": 158,
  //   //     "price": 2.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 160,
  //   //     "unit_id": 1,
  //   //     "item_desc": "مصفاه ارض 20×20 ايفان",
  //   //     "item_no": 159,
  //   //     "price": 2.75,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 163,
  //   //     "unit_id": 1,
  //   //     "item_desc": "شد وصل ذكر + انثى",
  //   //     "item_no": 162,
  //   //     "price": 0.80,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 164,
  //   //     "unit_id": 0,
  //   //     "item_desc": "شد وصل انثى",
  //   //     "item_no": 163,
  //   //     "price": 0.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 165,
  //   //     "unit_id": 1,
  //   //     "item_desc": "شد وصل دبل",
  //   //     "item_no": 164,
  //   //     "price": 1.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 166,
  //   //     "unit_id": 1,
  //   //     "item_desc": "فرشايه بولو",
  //   //     "item_no": 165,
  //   //     "price": 0.65,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 167,
  //   //     "unit_id": 1,
  //   //     "item_desc": "الينكيه مشرنف",
  //   //     "item_no": 166,
  //   //     "price": 1.25,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 168,
  //   //     "unit_id": 1,
  //   //     "item_desc": "طقم الينكيه عادي",
  //   //     "item_no": 167,
  //   //     "price": 1.25,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 169,
  //   //     "unit_id": 1,
  //   //     "item_desc": "فردتبشيم",
  //   //     "item_no": 168,
  //   //     "price": 2.75,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 170,
  //   //     "unit_id": 1,
  //   //     "item_desc": "مقص صاج",
  //   //     "item_no": 169,
  //   //     "price": 2.75,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 174,
  //   //     "unit_id": 1,
  //   //     "item_desc": "واي بكس قياس8—10—12  ",
  //   //     "item_no": 173,
  //   //     "price": 1.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 175,
  //   //     "unit_id": 1,
  //   //     "item_desc": "مصلب بكس قياس 8—10—12",
  //   //     "item_no": 174,
  //   //     "price": 1.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 176,
  //   //     "unit_id": 1,
  //   //     "item_desc": "فرشايه سلك فيبر عريض",
  //   //     "item_no": 175,
  //   //     "price": 0.75,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 177,
  //   //     "unit_id": 0,
  //   //     "item_desc": "فرشايه سلك فيبر رفيع",
  //   //     "item_no": 176,
  //   //     "price": 0.63,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 178,
  //   //     "unit_id": 1,
  //   //     "item_desc": "فرشايه سلك خشب عريض",
  //   //     "item_no": 177,
  //   //     "price": 0.75,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 179,
  //   //     "unit_id": 1,
  //   //     "item_desc": "فرشايه سلك خشب رفيع",
  //   //     "item_no": 178,
  //   //     "price": 0.63,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 180,
  //   //     "unit_id": 1,
  //   //     "item_desc": "طقم فراشي سلك6قطع",
  //   //     "item_no": 179,
  //   //     "price": 2.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 181,
  //   //     "unit_id": 1,
  //   //     "item_desc": "فرد تنظيف",
  //   //     "item_no": 180,
  //   //     "price": 5.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 182,
  //   //     "unit_id": 1,
  //   //     "item_desc": "فرد حرق دهان",
  //   //     "item_no": 181,
  //   //     "price": 1.75,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 183,
  //   //     "unit_id": 1,
  //   //     "item_desc": "سوبر جلو قطره",
  //   //     "item_no": 182,
  //   //     "price": 6.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 184,
  //   //     "unit_id": 1,
  //   //     "item_desc": "جرس باب لاسلكي  خفيف",
  //   //     "item_no": 183,
  //   //     "price": 2.25,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 185,
  //   //     "unit_id": 1,
  //   //     "item_desc": "يونيكا دبل مدور  ومربع",
  //   //     "item_no": 184,
  //   //     "price": 18.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 186,
  //   //     "unit_id": 1,
  //   //     "item_desc": "متر شفاف 3 متر ",
  //   //     "item_no": 185,
  //   //     "price": 0.85,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 187,
  //   //     "unit_id": 1,
  //   //     "item_desc": "متر شفاف 5 متر ",
  //   //     "item_no": 186,
  //   //     "price": 1.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 188,
  //   //     "unit_id": 1,
  //   //     "item_desc": "متر شفاف 7.5 متر ",
  //   //     "item_no": 187,
  //   //     "price": 1.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 189,
  //   //     "unit_id": 1,
  //   //     "item_desc": "متر اسود 3 متر ",
  //   //     "item_no": 188,
  //   //     "price": 1.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 190,
  //   //     "unit_id": 1,
  //   //     "item_desc": "متر اسود 5متر ",
  //   //     "item_no": 189,
  //   //     "price": 1.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 191,
  //   //     "unit_id": 1,
  //   //     "item_desc": "متر اسود 7.5 متر ",
  //   //     "item_no": 190,
  //   //     "price": 1.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 192,
  //   //     "unit_id": 1,
  //   //     "item_desc": "نسلات منشار حديد ",
  //   //     "item_no": 191,
  //   //     "price": 8.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 196,
  //   //     "unit_id": 1,
  //   //     "item_desc": "منشار خشب20 انش سماش",
  //   //     "item_no": 195,
  //   //     "price": 3.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 197,
  //   //     "unit_id": 1,
  //   //     "item_desc": "مقص بكس حجم كبير سماش",
  //   //     "item_no": 196,
  //   //     "price": 3.75,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 198,
  //   //     "unit_id": 1,
  //   //     "item_desc": "قطاعه طوبار 6 انش سماش",
  //   //     "item_no": 197,
  //   //     "price": 3.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 199,
  //   //     "unit_id": 1,
  //   //     "item_desc": "زرديه بوز رفيع 6 انش سماش",
  //   //     "item_no": 198,
  //   //     "price": 1.75,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 200,
  //   //     "unit_id": 1,
  //   //     "item_desc": "زرديه بوز عريض 6 انش سماش",
  //   //     "item_no": 199,
  //   //     "price": 1.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 201,
  //   //     "unit_id": 1,
  //   //     "item_desc": "قطاعه 6 انش سماش",
  //   //     "item_no": 200,
  //   //     "price": 1.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 208,
  //   //     "unit_id": 1,
  //   //     "item_desc": "لفه قصدير 100 غرام",
  //   //     "item_no": 19,
  //   //     "price": 1.25,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 209,
  //   //     "unit_id": 1,
  //   //     "item_desc": "حنفية فلتر جير خفيف",
  //   //     "item_no": 192,
  //   //     "price": 3.75,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 210,
  //   //     "unit_id": 1,
  //   //     "item_desc": "حنفية ستيم سن عادي",
  //   //     "item_no": 193,
  //   //     "price": 1.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 211,
  //   //     "unit_id": 1,
  //   //     "item_desc": "جرس لاسلكي ثقيل",
  //   //     "item_no": 194,
  //   //     "price": 4.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 215,
  //   //     "unit_id": 0,
  //   //     "item_desc": "سوبر جلو مع منشف",
  //   //     "item_no": 204,
  //   //     "price": 1.25,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 216,
  //   //     "unit_id": 1,
  //   //     "item_desc": "مزيل صدأ",
  //   //     "item_no": 205,
  //   //     "price": 0.83,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 217,
  //   //     "unit_id": 1,
  //   //     "item_desc": "منظف كربوريتر",
  //   //     "item_no": 2.6,
  //   //     "price": 0.75,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 219,
  //   //     "unit_id": 1,
  //   //     "item_desc": "بوز توفير مروحة",
  //   //     "item_no": 206,
  //   //     "price": 0.75,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 220,
  //   //     "unit_id": 1,
  //   //     "item_desc": "بوز توفير خرز",
  //   //     "item_no": 207,
  //   //     "price": 0.85,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 221,
  //   //     "unit_id": 1,
  //   //     "item_desc": "مضخة قارورة",
  //   //     "item_no": 208,
  //   //     "price": 8.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 222,
  //   //     "unit_id": 1,
  //   //     "item_desc": "غطاء مرحاض مربع تركي",
  //   //     "item_no": 209,
  //   //     "price": 9.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 223,
  //   //     "unit_id": 1,
  //   //     "item_desc": "سيفون مجلى دبل ثقيل",
  //   //     "item_no": 210,
  //   //     "price": 1.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 224,
  //   //     "unit_id": 1,
  //   //     "item_desc": "سيفون 3 انش برتقالي",
  //   //     "item_no": 211,
  //   //     "price": 2.75,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 225,
  //   //     "unit_id": 1,
  //   //     "item_desc": "جلدة برتقالي",
  //   //     "item_no": 212,
  //   //     "price": 0.01,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 226,
  //   //     "unit_id": 1,
  //   //     "item_desc": "فتاحات سبوت 12 قطعة",
  //   //     "item_no": 213,
  //   //     "price": 2.75,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 227,
  //   //     "unit_id": 1,
  //   //     "item_desc": "خراقة خشب",
  //   //     "item_no": 214,
  //   //     "price": 2.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 228,
  //   //     "unit_id": 1,
  //   //     "item_desc": "تب عزل",
  //   //     "item_no": 215,
  //   //     "price": 3.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 229,
  //   //     "unit_id": 1,
  //   //     "item_desc": "تب عزل كروم",
  //   //     "item_no": 216,
  //   //     "price": 0.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 230,
  //   //     "unit_id": 1,
  //   //     "item_desc": "مانع انزلاق",
  //   //     "item_no": 217,
  //   //     "price": 1.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 231,
  //   //     "unit_id": 1,
  //   //     "item_desc": "مشحاف 1 انش",
  //   //     "item_no": 218,
  //   //     "price": 0.41,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 232,
  //   //     "unit_id": 1,
  //   //     "item_desc": "مشحاف 2 انش",
  //   //     "item_no": 219,
  //   //     "price": 0.45,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 233,
  //   //     "unit_id": 1,
  //   //     "item_desc": "امشحاف 5 انش",
  //   //     "item_no": 220,
  //   //     "price": 0.54,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 234,
  //   //     "unit_id": 1,
  //   //     "item_desc": "مشحاف 6 انش",
  //   //     "item_no": 221,
  //   //     "price": 0.75,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 235,
  //   //     "unit_id": 1,
  //   //     "item_desc": "مشرط موكيت",
  //   //     "item_no": 222,
  //   //     "price": 1.75,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 236,
  //   //     "unit_id": 1,
  //   //     "item_desc": "زردية كبس",
  //   //     "item_no": 223,
  //   //     "price": 2.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 237,
  //   //     "unit_id": 1,
  //   //     "item_desc": "مكبس تنجيد",
  //   //     "item_no": 224,
  //   //     "price": 4.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 238,
  //   //     "unit_id": 1,
  //   //     "item_desc": "طقم زردية سماش",
  //   //     "item_no": 225,
  //   //     "price": 6.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 239,
  //   //     "unit_id": 1,
  //   //     "item_desc": "زردية بيبي",
  //   //     "item_no": 226,
  //   //     "price": 1.25,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 240,
  //   //     "unit_id": 1,
  //   //     "item_desc": "انجليزي 8 انش",
  //   //     "item_no": 227,
  //   //     "price": 2.25,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 241,
  //   //     "unit_id": 1,
  //   //     "item_desc": "انجليزي 10 انش",
  //   //     "item_no": 228,
  //   //     "price": 2.75,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 242,
  //   //     "unit_id": 1,
  //   //     "item_desc": "انجليزي 12 انش",
  //   //     "item_no": 229,
  //   //     "price": 3.25,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 243,
  //   //     "unit_id": 1,
  //   //     "item_desc": "انجليزي 14 انش",
  //   //     "item_no": 230,
  //   //     "price": 3.75,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 244,
  //   //     "unit_id": 1,
  //   //     "item_desc": "انجليزي 18 انش",
  //   //     "item_no": 231,
  //   //     "price": 6.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 245,
  //   //     "unit_id": 1,
  //   //     "item_desc": "تحويلة دش",
  //   //     "item_no": 232,
  //   //     "price": 1.85,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 246,
  //   //     "unit_id": 1,
  //   //     "item_desc": "واي مربع غاز",
  //   //     "item_no": 233,
  //   //     "price": 0.25,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 247,
  //   //     "unit_id": 1,
  //   //     "item_desc": "وصلة مربع غاز",
  //   //     "item_no": 234,
  //   //     "price": 3.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 248,
  //   //     "unit_id": 0,
  //   //     "item_desc": "بطارية ساخن",
  //   //     "item_no": 235,
  //   //     "price": 16.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 249,
  //   //     "unit_id": 1,
  //   //     "item_desc": "مقص زينة شجر تقصير وتطويل",
  //   //     "item_no": 236,
  //   //     "price": 5.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 250,
  //   //     "unit_id": 1,
  //   //     "item_desc": "فرد مرش اخضر",
  //   //     "item_no": 237,
  //   //     "price": 1.75,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 252,
  //   //     "unit_id": 1,
  //   //     "item_desc": "اصبع سيلكون تايوان",
  //   //     "item_no": 239,
  //   //     "price": 3.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 253,
  //   //     "unit_id": 1,
  //   //     "item_desc": "قصبة مغسلة عريض عكازة مدور ",
  //   //     "item_no": 240,
  //   //     "price": 1.75,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 254,
  //   //     "unit_id": 1,
  //   //     "item_desc": "حنفية بلاستيك سن نحاس ابيض",
  //   //     "item_no": 241,
  //   //     "price": 0.75,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 255,
  //   //     "unit_id": 1,
  //   //     "item_desc": "محبس هوا",
  //   //     "item_no": 242,
  //   //     "price": 0.90,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 256,
  //   //     "unit_id": 1,
  //   //     "item_desc": "علاقة دش متحرك مشكل",
  //   //     "item_no": 243,
  //   //     "price": 0.75,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 257,
  //   //     "unit_id": 1,
  //   //     "item_desc": "تحويلة دش بلاستيك",
  //   //     "item_no": 244,
  //   //     "price": 1.40,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 258,
  //   //     "unit_id": 1,
  //   //     "item_desc": "بوز قصبة سن داخلي وخارجي",
  //   //     "item_no": 245,
  //   //     "price": 1.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 259,
  //   //     "unit_id": 1,
  //   //     "item_desc": "قصبة ملونة بوز رفيع",
  //   //     "item_no": 246,
  //   //     "price": 2.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 260,
  //   //     "unit_id": 1,
  //   //     "item_desc": "مقبض لحام",
  //   //     "item_no": 247,
  //   //     "price": 2.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 261,
  //   //     "unit_id": 0,
  //   //     "item_desc": "لقاطة باب كبير",
  //   //     "item_no": 248,
  //   //     "price": 0.35,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 262,
  //   //     "unit_id": 1,
  //   //     "item_desc": "لقاطة باب صغير",
  //   //     "item_no": 249,
  //   //     "price": 0.25,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 263,
  //   //     "unit_id": 1,
  //   //     "item_desc": "زاوية حديد 3 سم",
  //   //     "item_no": 250,
  //   //     "price": 1.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 264,
  //   //     "unit_id": 1,
  //   //     "item_desc": "زاوية حديد 4 سم",
  //   //     "item_no": 251,
  //   //     "price": 1.75,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 265,
  //   //     "unit_id": 0,
  //   //     "item_desc": "زاوية حديد 5 سم",
  //   //     "item_no": 252,
  //   //     "price": 2.75,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 266,
  //   //     "unit_id": 0,
  //   //     "item_desc": "زاوية حديد 6 سم",
  //   //     "item_no": 253,
  //   //     "price": 2.25,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 267,
  //   //     "unit_id": 0,
  //   //     "item_desc": "زاوية حديد 7 سم",
  //   //     "item_no": 254,
  //   //     "price": 4.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 268,
  //   //     "unit_id": 1,
  //   //     "item_desc": "مفصلات باب صغير",
  //   //     "item_no": 255,
  //   //     "price": 1.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 269,
  //   //     "unit_id": 1,
  //   //     "item_desc": "مفصلات باب وسط",
  //   //     "item_no": 256,
  //   //     "price": 0.35,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 270,
  //   //     "unit_id": 1,
  //   //     "item_desc": "مفصلات باب كبير",
  //   //     "item_no": 257,
  //   //     "price": 0.40,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 271,
  //   //     "unit_id": 1,
  //   //     "item_desc": "حشوة فلتر خيط",
  //   //     "item_no": 258,
  //   //     "price": 0.80,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 272,
  //   //     "unit_id": 1,
  //   //     "item_desc": "حشوة فلتر 5 مراحل",
  //   //     "item_no": 259,
  //   //     "price": 10.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 274,
  //   //     "unit_id": 1,
  //   //     "item_desc": "نبل مفتوح 1/2 انش",
  //   //     "item_no": 261,
  //   //     "price": 1.25,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 275,
  //   //     "unit_id": 1,
  //   //     "item_desc": "حنفية فلتر مذهب",
  //   //     "item_no": 262,
  //   //     "price": 2.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 276,
  //   //     "unit_id": 1,
  //   //     "item_desc": "حنفية فلتر مذهب ثقيل",
  //   //     "item_no": 263,
  //   //     "price": 4.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 277,
  //   //     "unit_id": 1,
  //   //     "item_desc": "حنفية فلتر جير تركي",
  //   //     "item_no": 264,
  //   //     "price": 6.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 278,
  //   //     "unit_id": 1,
  //   //     "item_desc": "محبس جرة فلتر",
  //   //     "item_no": 265,
  //   //     "price": 0.90,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 279,
  //   //     "unit_id": 1,
  //   //     "item_desc": "وصلة ستلايت لون اسود",
  //   //     "item_no": 266,
  //   //     "price": 4.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 280,
  //   //     "unit_id": 1,
  //   //     "item_desc": "مشحاف 5 انش",
  //   //     "item_no": 267,
  //   //     "price": 0.66,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 281,
  //   //     "unit_id": 1,
  //   //     "item_desc": "فرد سيلكون حراري 20 واط",
  //   //     "item_no": 268,
  //   //     "price": 2.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 282,
  //   //     "unit_id": 1,
  //   //     "item_desc": "تي بكس مشكل",
  //   //     "item_no": 269,
  //   //     "price": 0.75,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 283,
  //   //     "unit_id": 1,
  //   //     "item_desc": "كف دش حبيبات",
  //   //     "item_no": 270,
  //   //     "price": 1.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 284,
  //   //     "unit_id": 1,
  //   //     "item_desc": "سيفون مجلى واي دبل تركي",
  //   //     "item_no": 271,
  //   //     "price": 1.75,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 285,
  //   //     "unit_id": 1,
  //   //     "item_desc": "سيفون مجلى ومغسلة تركي",
  //   //     "item_no": 272,
  //   //     "price": 0.90,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 286,
  //   //     "unit_id": 1,
  //   //     "item_desc": "كف دش مع بربيش خفيف",
  //   //     "item_no": 273,
  //   //     "price": 1.75,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 287,
  //   //     "unit_id": 1,
  //   //     "item_desc": "كف دش مفرد حركات",
  //   //     "item_no": 274,
  //   //     "price": 1.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 288,
  //   //     "unit_id": 1,
  //   //     "item_desc": "قصبة عريض طويل ",
  //   //     "item_no": 275,
  //   //     "price": 1.40,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 289,
  //   //     "unit_id": 1,
  //   //     "item_desc": "قصبة عريض قصير",
  //   //     "item_no": 276,
  //   //     "price": 1.30,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 290,
  //   //     "unit_id": 1,
  //   //     "item_desc": "عزقة تنك ايطالي",
  //   //     "item_no": 277,
  //   //     "price": 1.75,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 291,
  //   //     "unit_id": 1,
  //   //     "item_desc": "قلب بطارية ايطالي تركي",
  //   //     "item_no": 278,
  //   //     "price": 0.95,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 292,
  //   //     "unit_id": 1,
  //   //     "item_desc": "محبس دبل ايطالي",
  //   //     "item_no": 279,
  //   //     "price": 3.75,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 293,
  //   //     "unit_id": 1,
  //   //     "item_desc": "محبس غسالة ايطالي",
  //   //     "item_no": 280,
  //   //     "price": 2.25,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 294,
  //   //     "unit_id": 1,
  //   //     "item_desc": "تي كيزر مفتوح ايطالي",
  //   //     "item_no": 281,
  //   //     "price": 1.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 295,
  //   //     "unit_id": 1,
  //   //     "item_desc": "بطارية جير جوان طقم",
  //   //     "item_no": 282,
  //   //     "price": 32.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 296,
  //   //     "unit_id": 1,
  //   //     "item_desc": "ايزي برس",
  //   //     "item_no": 283,
  //   //     "price": 27.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 297,
  //   //     "unit_id": 1,
  //   //     "item_desc": "محبس 3/4 بوجاتي",
  //   //     "item_no": 284,
  //   //     "price": 2.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 298,
  //   //     "unit_id": 1,
  //   //     "item_desc": "محبس 3/4 ايطالي",
  //   //     "item_no": 285,
  //   //     "price": 2.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 299,
  //   //     "unit_id": 1,
  //   //     "item_desc": "محبس 1/2 ايطالي",
  //   //     "item_no": 286,
  //   //     "price": 1.85,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 300,
  //   //     "unit_id": 1,
  //   //     "item_desc": "محبس 1/2 بوجاتي",
  //   //     "item_no": 287,
  //   //     "price": 2.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 301,
  //   //     "unit_id": 1,
  //   //     "item_desc": "بربيش كيزر 20 سم",
  //   //     "item_no": 288,
  //   //     "price": 0.62,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 302,
  //   //     "unit_id": 1,
  //   //     "item_desc": "بربيش كيزر 30 سم",
  //   //     "item_no": 289,
  //   //     "price": 0.65,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 303,
  //   //     "unit_id": 1,
  //   //     "item_desc": "بربيش 40 سم",
  //   //     "item_no": 290,
  //   //     "price": 0.75,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 304,
  //   //     "unit_id": 1,
  //   //     "item_desc": "بربيش 50 سم",
  //   //     "item_no": 291,
  //   //     "price": 0.85,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 305,
  //   //     "unit_id": 1,
  //   //     "item_desc": "بربيش 60 سم",
  //   //     "item_no": 292,
  //   //     "price": 0.95,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 306,
  //   //     "unit_id": 1,
  //   //     "item_desc": "بربيش 70 سم",
  //   //     "item_no": 293,
  //   //     "price": 1.05,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 307,
  //   //     "unit_id": 1,
  //   //     "item_desc": "بربيش 80 سم",
  //   //     "item_no": 294,
  //   //     "price": 1.20,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 308,
  //   //     "unit_id": 1,
  //   //     "item_desc": "بربيش 1 متر",
  //   //     "item_no": 295,
  //   //     "price": 1.40,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 309,
  //   //     "unit_id": 1,
  //   //     "item_desc": "بربيش 120 سم",
  //   //     "item_no": 296,
  //   //     "price": 1.65,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 310,
  //   //     "unit_id": 1,
  //   //     "item_desc": "بربيش 150 سم",
  //   //     "item_no": 297,
  //   //     "price": 1.80,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 311,
  //   //     "unit_id": 1,
  //   //     "item_desc": "بربيش كيزر 2 متر",
  //   //     "item_no": 298,
  //   //     "price": 2.20,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 312,
  //   //     "unit_id": 1,
  //   //     "item_desc": "طقم ايادي جوان",
  //   //     "item_no": 299,
  //   //     "price": 28.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 313,
  //   //     "unit_id": 1,
  //   //     "item_desc": "خط بلدية حائط عمود جوان",
  //   //     "item_no": 300,
  //   //     "price": 6.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 314,
  //   //     "unit_id": 1,
  //   //     "item_desc": "مضخة ماء 1/2 حصان",
  //   //     "item_no": 301,
  //   //     "price": 25.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 315,
  //   //     "unit_id": 1,
  //   //     "item_desc": "خيط مصيص",
  //   //     "item_no": 302,
  //   //     "price": 4.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 316,
  //   //     "unit_id": 1,
  //   //     "item_desc": "زنبرك برادي",
  //   //     "item_no": 303,
  //   //     "price": 2.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 317,
  //   //     "unit_id": 1,
  //   //     "item_desc": "زرفيل طقة",
  //   //     "item_no": 304,
  //   //     "price": 4.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 318,
  //   //     "unit_id": 1,
  //   //     "item_desc": "حنفية 3/4 صيني",
  //   //     "item_no": 305,
  //   //     "price": 0.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 319,
  //   //     "unit_id": 1,
  //   //     "item_desc": "مصفاة رز",
  //   //     "item_no": 306,
  //   //     "price": 0.25,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 320,
  //   //     "unit_id": 1,
  //   //     "item_desc": "خيط كنب",
  //   //     "item_no": 307,
  //   //     "price": 6.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 321,
  //   //     "unit_id": 1,
  //   //     "item_desc": "جلدة ابيض 3/4",
  //   //     "item_no": 308,
  //   //     "price": 1.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 322,
  //   //     "unit_id": 1,
  //   //     "item_desc": "شفرة كوري",
  //   //     "item_no": 309,
  //   //     "price": 4.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 323,
  //   //     "unit_id": 1,
  //   //     "item_desc": "محبس زاوية صيني",
  //   //     "item_no": 310,
  //   //     "price": 0.75,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 324,
  //   //     "unit_id": 1,
  //   //     "item_desc": "قلب مع يد تركي",
  //   //     "item_no": 311,
  //   //     "price": 1.35,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 325,
  //   //     "unit_id": 1,
  //   //     "item_desc": "مشبك غاز",
  //   //     "item_no": 312,
  //   //     "price": 3.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 326,
  //   //     "unit_id": 1,
  //   //     "item_desc": "حنفية بلاستيك ابيض",
  //   //     "item_no": 313,
  //   //     "price": 0.30,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 327,
  //   //     "unit_id": 1,
  //   //     "item_desc": "مانع هوا",
  //   //     "item_no": 314,
  //   //     "price": 0.60,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 328,
  //   //     "unit_id": 1,
  //   //     "item_desc": "نبل فلتر 3/4",
  //   //     "item_no": 315,
  //   //     "price": 1.75,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 329,
  //   //     "unit_id": 1,
  //   //     "item_desc": "نبل فلتر 1/2",
  //   //     "item_no": 316,
  //   //     "price": 1.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 330,
  //   //     "unit_id": 1,
  //   //     "item_desc": "قلم علام",
  //   //     "item_no": 317,
  //   //     "price": 0.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 331,
  //   //     "unit_id": 0,
  //   //     "item_desc": "كوع انجاصة",
  //   //     "item_no": 318,
  //   //     "price": 1.75,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 332,
  //   //     "unit_id": 1,
  //   //     "item_desc": "مفك كهرباء الماني كبير",
  //   //     "item_no": 319,
  //   //     "price": 7.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 333,
  //   //     "unit_id": 1,
  //   //     "item_desc": "مفك كهرباء الماني صغير",
  //   //     "item_no": 320,
  //   //     "price": 6.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 334,
  //   //     "unit_id": 1,
  //   //     "item_desc": "مفك كهرباء صيني كبير",
  //   //     "item_no": 321,
  //   //     "price": 3.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 335,
  //   //     "unit_id": 1,
  //   //     "item_desc": "مفك كهرباء صيني صغير",
  //   //     "item_no": 322,
  //   //     "price": 2.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 336,
  //   //     "unit_id": 1,
  //   //     "item_desc": "معجونة تركي",
  //   //     "item_no": 323,
  //   //     "price": 14.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 337,
  //   //     "unit_id": 1,
  //   //     "item_desc": "سيلكون تركي",
  //   //     "item_no": 324,
  //   //     "price": 33.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 338,
  //   //     "unit_id": 1,
  //   //     "item_desc": "جلدة اسود 3/4",
  //   //     "item_no": 325,
  //   //     "price": 3.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 339,
  //   //     "unit_id": 1,
  //   //     "item_desc": "رول الماني",
  //   //     "item_no": 326,
  //   //     "price": 3.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 340,
  //   //     "unit_id": 1,
  //   //     "item_desc": "تب ورق عريض 2 انش",
  //   //     "item_no": 327,
  //   //     "price": 5.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 341,
  //   //     "unit_id": 1,
  //   //     "item_desc": "تب ورق رفيع 1 انش",
  //   //     "item_no": 328,
  //   //     "price": 4.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 342,
  //   //     "unit_id": 1,
  //   //     "item_desc": "كفوف احمر",
  //   //     "item_no": 329,
  //   //     "price": 2.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 343,
  //   //     "unit_id": 1,
  //   //     "item_desc": "كفوف اخضر",
  //   //     "item_no": 330,
  //   //     "price": 5.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 344,
  //   //     "unit_id": 1,
  //   //     "item_desc": "حنفية 1/2 ستيم اييطالي",
  //   //     "item_no": 331,
  //   //     "price": 2.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 345,
  //   //     "unit_id": 1,
  //   //     "item_desc": "حنفية 1/2 بوجاتي",
  //   //     "item_no": 332,
  //   //     "price": 2.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 346,
  //   //     "unit_id": 1,
  //   //     "item_desc": "يد شطافة ايطالي",
  //   //     "item_no": 333,
  //   //     "price": 0.90,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 347,
  //   //     "unit_id": 1,
  //   //     "item_desc": "يونيكا مفرد تركي",
  //   //     "item_no": 334,
  //   //     "price": 7.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 348,
  //   //     "unit_id": 1,
  //   //     "item_desc": "عوامة تركي",
  //   //     "item_no": 335,
  //   //     "price": 3.25,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 349,
  //   //     "unit_id": 0,
  //   //     "item_desc": "سيلكون 999",
  //   //     "item_no": 336,
  //   //     "price": 16.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 350,
  //   //     "unit_id": 0,
  //   //     "item_desc": "خلط ابرو",
  //   //     "item_no": 337,
  //   //     "price": 13.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 351,
  //   //     "unit_id": 0,
  //   //     "item_desc": "فحمات كرت",
  //   //     "item_no": 338,
  //   //     "price": 4.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 352,
  //   //     "unit_id": 0,
  //   //     "item_desc": "فرشاية سلك صف",
  //   //     "item_no": 339,
  //   //     "price": 1.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 353,
  //   //     "unit_id": 0,
  //   //     "item_desc": "سلندر ايزو 6 سم",
  //   //     "item_no": 340,
  //   //     "price": 2.25,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 354,
  //   //     "unit_id": 0,
  //   //     "item_desc": "سلندر ايزو 7 سم",
  //   //     "item_no": 341,
  //   //     "price": 2.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 355,
  //   //     "unit_id": 0,
  //   //     "item_desc": "مصفاة 10*10 عادي",
  //   //     "item_no": 342,
  //   //     "price": 1.35,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 356,
  //   //     "unit_id": 1,
  //   //     "item_desc": "مجلى ستانلس  حوضين",
  //   //     "item_no": 343,
  //   //     "price": 0.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 357,
  //   //     "unit_id": 1,
  //   //     "item_desc": "بطارية طقم جولدن ون",
  //   //     "item_no": 344,
  //   //     "price": 0.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 358,
  //   //     "unit_id": 1,
  //   //     "item_desc": "يونيكا + بطارية",
  //   //     "item_no": 345,
  //   //     "price": 0.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 359,
  //   //     "unit_id": 1,
  //   //     "item_desc": "مغسلة مدور + مربع ",
  //   //     "item_no": 346,
  //   //     "price": 0.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 360,
  //   //     "unit_id": 1,
  //   //     "item_desc": "مغسلة 120 سم حوضين",
  //   //     "item_no": 347,
  //   //     "price": 65.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 361,
  //   //     "unit_id": 1,
  //   //     "item_desc": "مغسلة 80 سم سليم",
  //   //     "item_no": 348,
  //   //     "price": 26.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 362,
  //   //     "unit_id": 1,
  //   //     "item_desc": "مغسلة 60 سم سليم",
  //   //     "item_no": 349,
  //   //     "price": 21.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 363,
  //   //     "unit_id": 1,
  //   //     "item_desc": "مغسلة 80 سم عادي",
  //   //     "item_no": 350,
  //   //     "price": 24.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 364,
  //   //     "unit_id": 1,
  //   //     "item_desc": "مغسلة 60 سم عادي",
  //   //     "item_no": 351,
  //   //     "price": 19.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 372,
  //   //     "unit_id": 1,
  //   //     "item_desc": "بطارية ديكور طويل",
  //   //     "item_no": 352,
  //   //     "price": 21.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 373,
  //   //     "unit_id": 1,
  //   //     "item_desc": "بطارية ديكور قصير",
  //   //     "item_no": 353,
  //   //     "price": 16.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 374,
  //   //     "unit_id": 1,
  //   //     "item_desc": "بطارية مجلى مربع + كروم",
  //   //     "item_no": 354,
  //   //     "price": 12.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 375,
  //   //     "unit_id": 1,
  //   //     "item_desc": "بطارية مجلى ستانلس ",
  //   //     "item_no": 355,
  //   //     "price": 12.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 376,
  //   //     "unit_id": 1,
  //   //     "item_desc": "ماكنة طباعة",
  //   //     "item_no": 356,
  //   //     "price": 0.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 377,
  //   //     "unit_id": 1,
  //   //     "item_desc": "عوامة تنك ايطالي",
  //   //     "item_no": 357,
  //   //     "price": 5.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 378,
  //   //     "unit_id": 1,
  //   //     "item_desc": "بطارية حائط جير",
  //   //     "item_no": 358,
  //   //     "price": 20.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 379,
  //   //     "unit_id": 1,
  //   //     "item_desc": "عزقة تنك صيني",
  //   //     "item_no": 359,
  //   //     "price": 1.25,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 380,
  //   //     "unit_id": 1,
  //   //     "item_desc": "قصبة مدور مربع عادي",
  //   //     "item_no": 360,
  //   //     "price": 1.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 381,
  //   //     "unit_id": 0,
  //   //     "item_desc": "بربيش كروم خفيف",
  //   //     "item_no": 361,
  //   //     "price": 1.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 382,
  //   //     "unit_id": 1,
  //   //     "item_desc": "محبس زاوية ايطالي",
  //   //     "item_no": 362,
  //   //     "price": 1.40,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 383,
  //   //     "unit_id": 1,
  //   //     "item_desc": "مصفاة بلاستك 20*20",
  //   //     "item_no": 363,
  //   //     "price": 0.60,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 384,
  //   //     "unit_id": 0,
  //   //     "item_desc": "مصفاة بلاستك 15*15",
  //   //     "item_no": 364,
  //   //     "price": 0.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 385,
  //   //     "unit_id": 1,
  //   //     "item_desc": "كفوف باكستاني",
  //   //     "item_no": 365,
  //   //     "price": 4.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 386,
  //   //     "unit_id": 0,
  //   //     "item_desc": "بوكس هيتر صغير",
  //   //     "item_no": 366,
  //   //     "price": 1.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 387,
  //   //     "unit_id": 1,
  //   //     "item_desc": "بوكس هيتر كبير",
  //   //     "item_no": 367,
  //   //     "price": 2.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 388,
  //   //     "unit_id": 0,
  //   //     "item_desc": "مرش نحاس",
  //   //     "item_no": 368,
  //   //     "price": 1.25,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 389,
  //   //     "unit_id": 0,
  //   //     "item_desc": "ساعة غاز عادي",
  //   //     "item_no": 369,
  //   //     "price": 2.50,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 390,
  //   //     "unit_id": 0,
  //   //     "item_desc": "توماتيك",
  //   //     "item_no": 370,
  //   //     "price": 3.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 392,
  //   //     "unit_id": 0,
  //   //     "item_desc": "خشب",
  //   //     "item_no": 371,
  //   //     "price": 0.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 393,
  //   //     "unit_id": 1,
  //   //     "item_desc": "مغسلة 1 متر",
  //   //     "item_no": 372,
  //   //     "price": 0.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 394,
  //   //     "unit_id": 1,
  //   //     "item_desc": "مرايا",
  //   //     "item_no": 373,
  //   //     "price": 0.00,
  //   //     "tax": 0
  //   //   },
  //   //   {
  //   //     "items_id": 395,
  //   //     "unit_id": 1,
  //   //     "item_desc": "قضيب تيوب",
  //   //     "item_no": 374,
  //   //     "price": 0.00,
  //   //     "tax": 0
  //   //   }
  // ];

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

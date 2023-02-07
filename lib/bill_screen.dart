//
// ignore_for_file: deprecated_member_use
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';
import 'package:test1/returns.dart';
import 'client.dart';
import 'cubit.dart';
import 'settings.dart';
import 'states.dart';
import 'items.dart';
import 'shared/components/components.dart';

List<Map<String, dynamic>>? maps;
Future<Database> initializeDB(String tableNAME) async {
  String path = await getDatabasesPath();
  final dataBase = openDatabase(
    join(path, 'database.db'),
    onCreate: (database, version) async {
      await database.execute(tableNAME);
    },
    version: 1,
  );
  return dataBase;
}

class Info {
  String? subjectNameS;
  String? subjectNumberS;
  String? priceS;

  Info({this.subjectNameS, this.subjectNumberS, this.priceS});

  Info.fromMap(Map<String, dynamic> item)
      : subjectNameS = item[" name"],
        subjectNumberS = item[" number"],
        priceS = item["price"];

  Map<String, Object> toMap() {
    return {
      ' name': subjectNameS!,
      ' number': subjectNumberS!,
      'price': priceS!
    };
  }
}

Future<void> insertPerson(Info infoo) async {
  // Get a reference to the database.
  var db = await initializeDB("");
  // Insert the Dog into the correct table. You might also specify the
  // `conflictAlgorithm` to use in case the same dog is inserted twice.
  // In this case, replace any previous data.
  await db.insert('subjects', infoo.toMap());
}

var person = Info(
    // subjectNameS: nameController.text,
    // subjectNumberS: subjectNumberController.text,
    // priceS: priceController.text,
    );
Future<List<Info>> dogs(String table) async {
  // Get a reference to the database.
  var db = await initializeDB(table);
// Query the table for all The Dogs.
  maps = await db
      .query(/*'SELECT number FROM "info" WHERE name LIKE"zaid"'*/ 'subjects');
  print(maps!.length);
  print(maps);
  print(maps![1]['name']);
// Convert the List<Map<String, dynamic> into a List<Dog>.
  return List.generate(maps!.length, (i) {
    return Info(
      priceS: maps![i]['price'],
      subjectNameS: maps![i]['subject name'],
      subjectNumberS: maps![i]['subject number'],
    );
  });
}

class BillScreen extends StatefulWidget {
  const BillScreen({Key? key}) : super(key: key);

  @override
  State<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  @override
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InvoiceCubit, InvoiceStates>(
      listener: (context, state) {},
      builder: (context, state) {
        var cubit = BlocProvider.of<InvoiceCubit>(context);

        var formatter = NumberFormat('0000');
        var totalFormatter = NumberFormat('###.##');
        TextEditingController nameController = TextEditingController();
        TextEditingController subjectNumberController = TextEditingController();
        TextEditingController priceController = TextEditingController();

        MediaQueryData mediaQueryData = MediaQuery.of(context);
        double screenWidth = mediaQueryData.size.width;
        double screenHeight = mediaQueryData.size.height;
        double blockSizeHorizontal = screenWidth / 100;
        double blockSizeVertical = screenHeight / 100;
        var appBar = AppBar(
            backgroundColor: const Color.fromRGBO(32, 67, 89, 1),
            title: Title(color: Colors.cyan, child: const Text('Bill maker')));

        return Scaffold(
          appBar: appBar,
          body: Column(
            children: [
              defaultCard(
                  fontSize: 20,
                  smallConHeigt: (MediaQuery.of(context).size.height -
                          appBar.preferredSize.height -
                          MediaQuery.of(context).padding.top) *
                      0.1,
                  smallConWedth: MediaQuery.of(context).size.width,
                  text: 'INVOICE #:${formatter.format(cubit.getInvoiceNum())}',
                  text1: cubit.formattedDate,
                  fontColor: Colors.grey,
                  onTap: () {}),
              InkWell(
                onLongPress: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Wrap(
                        children: [
                          AlertDialog(
                            title: const Text("ادخل اسم العميل "),
                            content: Form(
                                child: Form(
                              key: cubit.formkey,
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  defaultTextFormFeild(
                                    warning: " يرجى ادخال اسم العميل ",
                                    color: Colors.black,
                                    controller: cubit.writeClientNameCon,
                                    type: TextInputType.name,
                                    label: "اسم العميل",
                                    prefix: Icons.discount,
                                    textInputFormatter:
                                        FilteringTextInputFormatter.deny(
                                            RegExp('')),
                                    onChange: () {},
                                    onSubmit: () {},
                                  ),
                                ],
                              ),
                            )),
                            actions: [
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromRGBO(
                                          120, 166, 200, 1)),
                                  child: const Text('OK'),
                                  onPressed: () {
                                    if (cubit.formkey.currentState!
                                        .validate()) {
                                      cubit.writeClientName();

                                      Navigator.pop(context);
                                    }
                                  }),
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromRGBO(
                                          120, 166, 200, 1)),
                                  child: const Text('CANCEL'),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  }),
                            ],
                          )
                        ],
                      );
                    },
                  );
                },
                child: defaultCard(
                    fontSize: 15,
                    smallConHeigt: (MediaQuery.of(context).size.height -
                            appBar.preferredSize.height -
                            MediaQuery.of(context).padding.top) *
                        0.1, //MediaQuery.of(context).size.height / 10,
                    smallConWedth: blockSizeHorizontal *
                        100, //MediaQuery.of(context).size.width,
                    text: 'CLIENT',
                    text1: state is AddClient
                        ? state.clientName
                        : cubit.writeClientNameCon.text,
                    fontColor: Colors.grey,
                    onTap: () {
                      cubit.trueDate();

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Client()),
                      );
                    }),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        
                        
                        cubit.addRecords();
                        cubit.sellsOrReturns = false;
                        cubit.trueDate();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Items()),
                        );
                      },
                      child: Container(
                        width: blockSizeHorizontal * 25,
                        decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            border: Border.all(
                              width: 3,
                              color: const Color.fromRGBO(120, 166, 200, 1),
                            )),
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          child: const Center(
                            child: Text(
                              'ITEMS',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: blockSizeVertical * 6,
                      width: blockSizeHorizontal * 69,
                      child: InkWell(
                        onTap: cubit.totalAfter == 0
                            ? null
                            : () {
                                //cubit.trueDate();
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Wrap(
                                      children: [
                                        AlertDialog(
                                          title: const Text("اضف خصم"),
                                          content: Form(
                                              child: Form(
                                            key: cubit.formkey,
                                            child: Column(
                                              children: [
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                defaultTextFormFeild(
                                                  warning: "يرجى ادخال نسبة ",
                                                  color: Colors.black,
                                                  controller: cubit.discountCon,
                                                  type: TextInputType.number,
                                                  label: "الخصم",
                                                  prefix: Icons.discount,
                                                  textInputFormatter:
                                                      FilteringTextInputFormatter
                                                          .allow(RegExp(
                                                              r'[0-9 .]')),
                                                  onChange: () {},
                                                  onSubmit: () {},
                                                ),
                                                const SizedBox(height: 5),
                                              ],
                                            ),
                                          )),
                                          actions: [
                                            ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        const Color.fromRGBO(
                                                            120, 166, 200, 1)),
                                                child: const Text('نسبة'),
                                                onPressed: () {
                                                  if (cubit
                                                          .formkey.currentState!
                                                          .validate() &&
                                                      cubit.totalOfItem
                                                          .isNotEmpty &&
                                                      num.parse(cubit
                                                              .discountCon
                                                              .text) <=
                                                          100) {
                                                    setState(() {
                                                      cubit.dis = num.parse(
                                                          cubit.discountCon
                                                              .text);
                                                      debugPrint(
                                                          cubit.dis.toString());
                                                      cubit.totalAfter = cubit
                                                              .totalBefor -
                                                          ((cubit.dis / 100) *
                                                              cubit.totalBefor);
                                                    });

                                                    Navigator.pop(context);
                                                    cubit.discountCon.clear();
                                                    debugPrint(
                                                        cubit.dis.toString());
                                                  }
                                                }),
                                            ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        const Color.fromRGBO(
                                                            120, 166, 200, 1)),
                                                child: const Text('قيمة'),
                                                onPressed: () {
                                                  if (cubit
                                                          .formkey.currentState!
                                                          .validate() &&
                                                      cubit.totalOfItem
                                                          .isNotEmpty &&
                                                      num.parse(cubit
                                                              .discountCon
                                                              .text) <=
                                                          cubit.totalAfter) {
                                                    setState(() {
                                                      cubit.dis = num.parse(
                                                          cubit.discountCon
                                                              .text);

                                                      cubit.totalAfter =
                                                          cubit.totalBefor -
                                                              cubit.dis;
                                                    });

                                                    Navigator.pop(context);
                                                    cubit.discountCon.clear();
                                                    debugPrint(
                                                        cubit.dis.toString());
                                                  }
                                                }),
                                          ],
                                        )
                                      ],
                                    );
                                  },
                                );
                              },
                        child: Card(
                          color: const Color.fromRGBO(32, 67, 89, 1),
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "TOTAL : ${cubit.dis == 0 ? totalFormatter.format(cubit.totalBefor) : totalFormatter.format(cubit.totalAfter)} ",
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromRGBO(230, 92, 79, 1),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, bottom: 5),
                child: SizedBox(
                    width: double.infinity,
                    height: 240,
                    child: Card(
                      color: const Color.fromRGBO(233, 238, 244, 1),
                      child: Column(
                        children: [
                          Expanded(
                            child: cubit.allAddedItems.isEmpty &&
                                    cubit.quantity.isEmpty &&
                                    cubit.totalOfItem.isEmpty
                                ? const Center(
                                    child: Text(
                                    "NO ITEMS",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 30),
                                  ))
                                : Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 5, right: 5, top: 5),
                                        child: Card(
                                          color: const Color.fromRGBO(
                                              32, 67, 89, 1),
                                          child: Padding(
                                            padding: const EdgeInsets.all(3.0),
                                            child: SizedBox(
                                              width: blockSizeHorizontal * 93,
                                              height: 10,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: const [
                                                  Text(
                                                    "ITEM",
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.grey),
                                                  ),
                                                  Text("QUANTITY",
                                                      style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.grey)),
                                                  Text("PRICE",
                                                      style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.grey)),
                                                  Text("TOTAL PRICE",
                                                      style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.grey)),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: ListView.builder(
                                            itemCount:
                                                cubit.allAddedItems.length,
                                            itemBuilder: (context, index) {
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10,
                                                    right: 10,
                                                    top: 5),
                                                child: SizedBox(
                                                  height: 40,
                                                  child: Dismissible(
                                                    key: UniqueKey(),
                                                    onDismissed: (direction) {
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return Wrap(
                                                              children: <
                                                                  Widget>[
                                                                StatefulBuilder(
                                                                  builder: (BuildContext
                                                                          context,
                                                                      void Function(
                                                                              void Function())
                                                                          setState) {
                                                                    return AlertDialog(
                                                                      title: const Text(
                                                                          '  هل تريد حذف هذه المادة  '),
                                                                      content:
                                                                          Form(
                                                                        key: cubit
                                                                            .formkey,
                                                                        child: Column(
                                                                            children: []),
                                                                      ),
                                                                      actions: <
                                                                          Widget>[
                                                                        ElevatedButton(
                                                                          style:
                                                                              ElevatedButton.styleFrom(backgroundColor: const Color.fromRGBO(120, 166, 200, 1)),
                                                                          child:
                                                                              const Text('CANCEL'),
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.pop(context);
                                                                          },
                                                                        ),
                                                                        Builder(builder:
                                                                            (context) {
                                                                          return ElevatedButton(
                                                                              style: ElevatedButton.styleFrom(backgroundColor: const Color.fromRGBO(120, 166, 200, 1)),
                                                                              child: const Text('DELETE'),
                                                                              onPressed: () {
                                                                                Navigator.pop(context);
                                                                                cubit.del(index);
                                                                              });
                                                                        }),
                                                                      ],
                                                                    );
                                                                  },
                                                                ),
                                                              ]);
                                                        },
                                                      );
                                                    },
                                                    child: InkWell(
                                                      child: Card(
                                                        color: const Color
                                                                .fromRGBO(
                                                            120, 166, 200, 1),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      5),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Text(
                                                                cubit
                                                                    .allAddedItems[
                                                                        index][
                                                                        'item_desc']
                                                                    .toString(),
                                                                style: const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w900,
                                                                    fontSize:
                                                                        15),
                                                              ),
                                                              Text(
                                                                (cubit.quantity[
                                                                        index])
                                                                    .toString(),
                                                                style: const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w900,
                                                                    fontSize:
                                                                        15),
                                                              ),
                                                              Text(
                                                                "${cubit.priceOfItem[index].toString()}JD",
                                                                style: const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w900,
                                                                    fontSize:
                                                                        15),
                                                              ),
                                                              Text(
                                                                "${totalFormatter.format(cubit.totalOfItem[index]).toString()}JD",
                                                                style: const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w900,
                                                                    fontSize:
                                                                        15),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                              //}
                                            }),
                                      ),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    )),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: SizedBox(
                    width: blockSizeHorizontal * 100,
                    height: blockSizeVertical * 13,
                    child: Card(
                        color: const Color.fromRGBO(233, 238, 244, 1),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    "Befor discount: ${cubit.totalOfItem.isEmpty ? "0" : totalFormatter.format(cubit.totalBefor)}",
                                    style: TextStyle(
                                      decoration: cubit.dis == 0
                                          ? TextDecoration.none
                                          : TextDecoration.lineThrough,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    "Discount: ${cubit.dis == 0 ? "" : cubit.dis.toString()}%",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                      "Discount: ${cubit.dis == 0 ? "" : totalFormatter.format(((cubit.dis / 100) * cubit.totalBefor)).toString()}",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ))
                                ],
                              ),
                              defaultButon(
                                  height: blockSizeVertical * 4,
                                  fontSize: 13,
                                  width: (blockSizeHorizontal * 20),
                                  background:
                                      const Color.fromRGBO(32, 67, 89, 1),
                                  function: () {
                                    if (cubit.allAddedItems.isNotEmpty &&
                                        cubit.quantity.isNotEmpty &&
                                        cubit.totalOfItem.isNotEmpty) {
                                      cubit.insertToInvoiceInfo(
                                          clientId: cubit.client_id,
                                          notes: "",
                                          invoiceNumber: cubit.getInvoiceNum(),
                                          invoiceDate:
                                              cubit.formattedDate.toString(),
                                          clientName: cubit.client_name,
                                          total: cubit.totalAfter);

                                      // while (cubit.savedItemsIndx <
                                      //     cubit.allAddedItems.length) {
                                      //   cubit.insertInvoiceItems(
                                      //       infoId: cubit.getInfoId(),
                                      //       unitId: 0,
                                      //       quentity: int.parse(cubit.quantity[
                                      //               cubit.savedItemsIndx])
                                      //           ,
                                      //       price: int.parse(cubit.totalOfItem[
                                      //               cubit.savedItemsIndx])
                                      //           ,
                                      //       tax: 0,
                                      //       items: cubit.allAddedItems[cubit
                                      //               .savedItemsIndx]["item_desc"]
                                      //           .toString(),
                                      //       invoiceNumber: cubit
                                      //           .getInvoiceNum()
                                      //           );
                                      //   cubit.savedItemsIndx++;
                                      // }
                                      cubit.allAddedItems.forEach((element) {
                                        cubit.insertInvoiceItems(
                                          infoId: cubit.getInfoId(),
                                          unitId: 0,
                                          quentity: int.parse(cubit.quantity[
                                              cubit.allAddedItems
                                                  .indexOf(element)]),
                                          price: (cubit.totalOfItem[cubit
                                              .allAddedItems
                                              .indexOf(element)]),
                                          tax: int.parse(cubit.dropdownValue),
                                          invoiceNumber: cubit.getInvoiceNum(),
                                          items: element["item_desc"],
                                        );
                                      });
                                    }
                                    cubit.afterSave();
                                  },
                                  text: "save")
                            ],
                          ),
                        ))),
              ),
            ],
          ),
          drawer: Drawer(
            child: ListView(padding: EdgeInsets.zero, children: [
              InkWell(
                onDoubleTap: () {
                  debugPrint(cubit.settingsList.toString());
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingsScreen()),
                  );
                },
                child: const DrawerHeader(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/icons-settings.png"),
                        fit: BoxFit.none),
                    color: Color.fromRGBO(230, 92, 79, 1),
                  ),
                  child: null,
                ),
              ),
              Builder(builder: (context) {
                return Visibility(
                  visible: cubit.settingsList.isEmpty
                      ? false
                      : (cubit.cc[0] == 0 ? false : true),
                  //bool.fromEnvironment(cubit.settingsList[0]["settings_state"], defaultValue: false)

                  child: ListTile(
                      title: const Text(
                        ' اضافة مواد  ',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return Wrap(children: <Widget>[
                              StatefulBuilder(
                                builder: (BuildContext context,
                                    void Function(void Function()) setState) {
                                  return AlertDialog(
                                    title: const Text('قم بإدخال المواد'),
                                    content: Form(
                                      key: cubit.formkey,
                                      child: Column(children: [
                                        defaultTextFormFeild(
                                          warning: "قم بادخال الاسم",
                                          color: Colors.black,
                                          controller: nameController,
                                          type: TextInputType.name,
                                          label: "Name",
                                          prefix: Icons.abc,
                                          onChange: () {},
                                          onSubmit: () {},
                                          textInputFormatter:
                                              FilteringTextInputFormatter.deny(
                                                  r'[]'),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        defaultTextFormFeild(
                                          warning: "قم بادخال رقم المادة",
                                          color: Colors.black,
                                          controller: subjectNumberController,
                                          type: TextInputType.number,
                                          label: "Subject Number",
                                          prefix: Icons.numbers,
                                          textInputFormatter:
                                              FilteringTextInputFormatter.allow(
                                                  RegExp(r'[0-9]')),
                                          onChange: () {},
                                          onSubmit: () {},
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        defaultTextFormFeild(
                                          warning: "قم بادخال السعر",
                                          color: Colors.black,
                                          controller: priceController,
                                          type: TextInputType.number,
                                          label: "Price",
                                          prefix: Icons.monetization_on,
                                          textInputFormatter:
                                              FilteringTextInputFormatter.allow(
                                                  RegExp(r'[0-9 .]')),
                                          onChange: () {},
                                          onSubmit: () {},
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Text("Tax:"),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            DropdownButton<String>(
                                              value: cubit.dropdownValue,
                                              icon: const Icon(
                                                  Icons.arrow_downward),
                                              elevation: 16,
                                              style: const TextStyle(
                                                  color: Colors.black),
                                              underline: Container(
                                                height: 2,
                                                color: const Color.fromRGBO(
                                                    120, 166, 200, 1),
                                              ),
                                              onChanged: (String? value) {
                                                cubit.changeDropDownList(value);
                                                // This is called when the user selects an item.
                                                setState(() {});
                                              },
                                              items: cubit.taxLIst.map<
                                                      DropdownMenuItem<String>>(
                                                  (int value) {
                                                return DropdownMenuItem<String>(
                                                  value: value.toString(),
                                                  child: Text(value.toString()),
                                                );
                                              }).toList(),
                                            ),
                                            const SizedBox(
                                              width: 40,
                                            ),
                                            const Text("Unit:"),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            DropdownButton<String>(
                                              value: cubit.unitDropdownValue,
                                              icon: const Icon(
                                                  Icons.arrow_downward),
                                              elevation: 16,
                                              style: const TextStyle(
                                                  color: Colors.black),
                                              underline: Container(
                                                height: 2,
                                                color: const Color.fromRGBO(
                                                    120, 166, 200, 1),
                                              ),
                                              onChanged: (String? value) {
                                                cubit.changeUnitDropDownList(
                                                    value);
                                                // This is called when the user selects an item.

                                                setState(() {});
                                              },
                                              items: cubit.dropDownUnitsList
                                                  .map<
                                                      DropdownMenuItem<
                                                          String>>((value) {
                                                return DropdownMenuItem<String>(
                                                  value: value.toString(),
                                                  child: Text(value
                                                      .substring(
                                                          0, value.length - 1)
                                                      .toString()),
                                                );
                                              }).toList(),
                                            ),
                                          ],
                                        )
                                      ]),
                                    ),
                                    actions: <Widget>[
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color.fromRGBO(
                                                    120, 166, 200, 1)),
                                        child: const Text('CANCEL'),
                                        onPressed: () {
                                          Navigator.pop(context);
                                          nameController.clear();
                                          subjectNumberController.clear();
                                          priceController.clear();
                                        },
                                      ),
                                      Builder(builder: (context) {
                                        return ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color.fromRGBO(
                                                        120, 166, 200, 1)),
                                            child: const Text('SAVE'),
                                            onPressed: () {
                                              if (cubit.formkey.currentState!
                                                  .validate()) {
                                                cubit
                                                    .insertToDatabase(
                                                        tax: int.parse(cubit
                                                            .dropdownValue),
                                                        unitId: int.parse(cubit
                                                            .unitDropdownValue[(cubit
                                                                .unitDropdownValue
                                                                .length -
                                                            1)]),
                                                        name:
                                                            nameController.text,
                                                        number:
                                                            subjectNumberController
                                                                .text
                                                                .toString(),
                                                        price: priceController
                                                            .text
                                                            .toString())
                                                    .then((value) {
                                                  Navigator.pop(context);
                                                  nameController.clear();
                                                  subjectNumberController
                                                      .clear();
                                                  priceController.clear();
                                                  Fluttertoast.showToast(
                                                    msg: "تمت اضافة هذه المادة",
                                                    toastLength:
                                                        Toast.LENGTH_LONG,
                                                    gravity:
                                                        ToastGravity.CENTER,
                                                  );
                                                });
                                              }
                                            });
                                      }),
                                    ],
                                  );
                                },
                              ),
                            ]);
                          },
                        );
                      }),
                );
              }),
              Builder(builder: ((context) {
                return ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Returns()),
                    );
                  },
                  title: const Text(
                    'المرتجعات',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                );
              }))
            ]),
          ),
        );
      },
    );
  }
}

// return Align(
//   alignment: Alignment.topCenter,
//   child: InkWell(
//     child: Padding(
//       padding:
//           const EdgeInsets.symmetric(
//               horizontal: 20,
//               vertical: 5),
//       child: Card(
//         elevation: 5,
//         child: SizedBox(
//           height: 40,
//           width: MediaQuery.of(context)
//               .size
//               .width,
//           child: Padding(
//             padding: const EdgeInsets
//                     .symmetric(
//                 horizontal: 10),
//             child: Row(
//               crossAxisAlignment:
//                   CrossAxisAlignment
//                       .stretch,
//               mainAxisAlignment:
//                   MainAxisAlignment
//                       .spaceBetween,
//               children: const [
//                 Text(
//                   'q',
//                   //items[id]['name'],
//                   style: TextStyle(
//                       fontSize: 20,
//                       fontWeight:
//                           FontWeight
//                               .bold,
//                       color:
//                           Colors.black),
//                 ),
//                 Text(
//                   'q',
//                   // "${InvoiceProvider.get(context).amount}",
//                   style: TextStyle(
//                       fontSize: 20,
//                       fontWeight:
//                           FontWeight
//                               .bold,
//                       color:
//                           Colors.black),
//                 ),
//                 Text(
//                   "q",
//                   style: TextStyle(
//                       fontSize: 20,
//                       fontWeight:
//                           FontWeight
//                               .bold,
//                       color:
//                           Colors.black),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     ),
//     //  );
//     //},
//   ),
// );

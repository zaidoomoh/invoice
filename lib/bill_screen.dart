//
// ignore_for_file: deprecated_member_use
//import 'package:cloud_firestore/cloud_firestore.dart';

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';
import 'package:test1/returns.dart';
import 'package:xml/xml.dart';
import 'client.dart';
import 'cubit.dart';
import 'dio_helper.dart';
import 'settings.dart';
import 'states.dart';
import 'items.dart';
import 'shared/components/components.dart';

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
            title: Title(
                color: Colors.cyan,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Image.asset(
                      'assets/optimal.png',
                      width: 59,
                      height: 59,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Text('Optimal'),
                  ],
                )));

        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: appBar,
          body: Column(
            children: [
              defaultCard(
                  backgroundColor: const Color.fromRGBO(233, 238, 244, 1),
                  fontSize: 20,
                  smallConHeigt: (MediaQuery.of(context).size.height -
                          appBar.preferredSize.height -
                          MediaQuery.of(context).padding.top) *
                      0.07,
                  smallConWedth: MediaQuery.of(context).size.width,
                  text: cubit.sellsOrReturns == 1
                      ? 'INVOICE #: ${cubit.getInvoiceNum()}'
                      : 'RETURN #: ${cubit.getReturnNum()}',
                  text1: cubit.formattedDate,
                  fontColor: Colors.black,
                  onTap: () {}),
              InkWell(
                onLongPress: () {
                  cubit.checkBiometrics() == cubit.auth.isDeviceSupported()
                      ? cubit.authenticate()
                      : debugPrint(
                          "lengthhhhh: ${(cubit.savedItems).toString()}");
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
                    backgroundColor: const Color.fromRGBO(233, 238, 244, 1),
                    fontSize: 15,
                    smallConHeigt: (MediaQuery.of(context).size.height -
                            appBar.preferredSize.height -
                            MediaQuery.of(context).padding.top) *
                        0.08, //MediaQuery.of(context).size.height / 10,
                    smallConWedth: blockSizeHorizontal *
                        100, //MediaQuery.of(context).size.width,
                    text: 'CLIENT',
                    text1: state is AddClient
                        ? state.clientName
                        : cubit.writeClientNameCon.text,
                    fontColor: Colors.black,
                    onTap: () {
                      // DioHelper.getData(url: '/posts', query: {
                      // 'op':'getMax_id',
                      //  'password': 'OptimalPass',
                      //  'TableName': 'Table_Test',
                      // 'op':'GetDonation',
                      // 'ID':1
                      // }).then((value) {
                      //   debugPrint(value.data.toString());
                      // }).catchError((e) {
                      //   debugPrint(e.toString());
                      // });

                      // DioHelper.postData().then((value){
                      //   debugPrint(value.data.toString());
                      // }).catchError((e){debugPrint(e.toString());});

                      DioHelper.getMaxId();
                      // DioHelper.x().then((value) {
                      //   // Parse the XML response
                      //   final document =
                      //       XmlDocument.parse(value.data.toString());
                      //   final result = document
                      //       .findAllElements('getMax_idResult')
                      //       .single
                      //       .text;
                      //   // Do something with the result
                      //   print(result);
                      // }).catchError((e) {
                      //   print('Error: $e');
                      // });

                      // DioHelper.xx().then((value) {
                      //   String xmlResponse = value.data;
                      //   Map<String, dynamic> parsedResponse =
                      //       jsonDecode(jsonEncode(xmlResponse));
                      // }).catchError((e) {
                      //   debugPrint(e.toString());
                      // });

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
                      onTap: () async {
                        cubit.getReturnNum();
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
                                                  cubit.valueOrPercntage =
                                                      false;
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
                                                  cubit.valueOrPercntage = true;
                                                  if (cubit
                                                          .formkey.currentState!
                                                          .validate() &&
                                                      cubit.totalOfItem
                                                          .isNotEmpty &&
                                                      (num.parse(cubit
                                                                  .discountCon
                                                                  .text) <=
                                                              cubit
                                                                  .totalAfter ||
                                                          num.parse(cubit
                                                                      .discountCon
                                                                      .text) *
                                                                  -1 >=
                                                              cubit
                                                                  .totalAfter)) {
                                                    setState(() {
                                                      cubit.dis = num.parse(
                                                          cubit.discountCon
                                                              .text);
                                                      if (cubit
                                                              .sellsOrReturns ==
                                                          1) {
                                                        cubit.totalAfter =
                                                            cubit.totalBefor -
                                                                cubit.dis;
                                                      } else {
                                                        cubit.totalAfter =
                                                            cubit.totalBefor +
                                                                cubit.dis;
                                                      }
                                                    });

                                                    Navigator.pop(context);
                                                    // cubit.discountCon.clear();
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
                                        color: Colors.white,
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
                    height: 280,
                    child: Card(
                      color: const Color.fromRGBO(233, 238, 244, 1),
                      child: cubit.allAddedItems.isEmpty &&
                              cubit.quantity.isEmpty &&
                              cubit.totalOfItem.isEmpty
                          ? const Center(
                              child: Text(
                              "NO ITEMS",
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 30),
                            ))
                          : Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 5, right: 5, top: 5),
                                  child: Card(
                                    color: const Color.fromRGBO(32, 67, 89, 1),
                                    child: Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: SizedBox(
                                        width: blockSizeHorizontal * 93,
                                        height: 10,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: const [
                                            Text(
                                              "ITEM",
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey),
                                            ),
                                            Text("QUANTITY",
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.grey)),
                                            Text("PRICE",
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.grey)),
                                            Text("TOTAL PRICE",
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.grey)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: ListView.builder(
                                      physics: const BouncingScrollPhysics(),
                                      itemCount: cubit.allAddedItems.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10, right: 10, top: 5),
                                          child: SizedBox(
                                            height: 40,
                                            child: Dismissible(
                                              key: UniqueKey(),
                                              onDismissed: (direction) {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return Wrap(children: <
                                                        Widget>[
                                                      StatefulBuilder(
                                                        builder: (BuildContext
                                                                context,
                                                            void Function(
                                                                    void
                                                                        Function())
                                                                setState) {
                                                          return AlertDialog(
                                                            title: const Text(
                                                                '  هل تريد حذف هذه المادة  '),
                                                            content: Form(
                                                              key:
                                                                  cubit.formkey,
                                                              child: Column(
                                                                  children: []),
                                                            ),
                                                            actions: <Widget>[
                                                              ElevatedButton(
                                                                style: ElevatedButton.styleFrom(
                                                                    backgroundColor:
                                                                        const Color.fromRGBO(
                                                                            120,
                                                                            166,
                                                                            200,
                                                                            1)),
                                                                child: const Text(
                                                                    'CANCEL'),
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                              ),
                                                              Builder(builder:
                                                                  (context) {
                                                                return ElevatedButton(
                                                                    style: ElevatedButton.styleFrom(
                                                                        backgroundColor: const Color.fromRGBO(
                                                                            120,
                                                                            166,
                                                                            200,
                                                                            1)),
                                                                    child: const Text(
                                                                        'DELETE'),
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.pop(
                                                                          context);
                                                                      cubit.del(
                                                                          index);
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
                                                  color: const Color.fromRGBO(
                                                      120, 166, 200, 1),
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 5),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          cubit.allAddedItems[
                                                                  index]
                                                                  ['item_desc']
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w900,
                                                                  fontSize: 15),
                                                        ),
                                                        Text(
                                                          (cubit.quantity[
                                                                  index])
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w900,
                                                                  fontSize: 15),
                                                        ),
                                                        Text(
                                                          cubit.priceOfItem[
                                                                  index]
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w900,
                                                                  fontSize: 15),
                                                        ),
                                                        Text(
                                                          totalFormatter
                                                              .format(cubit
                                                                      .totalOfItem[
                                                                  index])
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w900,
                                                                  fontSize: 15),
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
                                    "Discount:${cubit.dis == 0 ? "" : cubit.valueOrPercntage == true ? ((num.parse(cubit.discountCon.text) / cubit.totalBefor) * 100).toStringAsFixed(2) : cubit.dis.toString()}%",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                      "Discount: ${cubit.dis == 0 ? "" : cubit.valueOrPercntage == true ? cubit.discountCon.text : totalFormatter.format(((cubit.dis / 100) * cubit.totalBefor)).toString()}",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ))
                                ],
                              ),
                              Row(
                                children: [
                                  FloatingActionButton(
                                    onPressed: () {
                                      cubit.afterSave();
                                    },
                                    backgroundColor:
                                        const Color.fromRGBO(230, 92, 79, 1),
                                    child: const Icon(
                                      Icons.clear_all,
                                      size: 40,
                                      color: Color.fromRGBO(233, 238, 244, 1),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  FloatingActionButton(
                                    onPressed: () {
                                      if (cubit.allAddedItems.isNotEmpty &&
                                          cubit.quantity.isNotEmpty &&
                                          cubit.totalOfItem.isNotEmpty) {
                                        cubit.insertToInvoiceInfo(
                                            type: cubit.sellsOrReturns,
                                            clientId: cubit.client_id,
                                            notes: "",
                                            invoiceNumber:
                                                cubit.sellsOrReturns == 1
                                                    ? cubit.getInvoiceNum()
                                                    : cubit.getReturnNum(),
                                            invoiceDate:
                                                cubit.formattedDate.toString(),
                                            clientName: cubit.client_name,
                                            total: cubit.totalAfter);
                                        cubit.allAddedItems.forEach((element) {
                                          cubit.insertInvoiceItems(
                                            infoId: cubit.getInfoId(),
                                            unitId: 0,
                                            quentity: int.parse(cubit.quantity[
                                                cubit.allAddedItems
                                                    .indexOf(element)]),
                                            price: cubit.dis == 0
                                                ? (cubit.totalOfItem[cubit
                                                    .allAddedItems
                                                    .indexOf(element)])
                                                : cubit.totalAfter,
                                            tax: int.parse(cubit.dropdownValue),
                                            invoiceNumber:
                                                cubit.sellsOrReturns == 1
                                                    ? cubit.getInvoiceNum()
                                                    : cubit.getReturnNum(),
                                            items: element["item_desc"],
                                          );
                                        });
                                      }
                                      setState(() {
                                        cubit.sellsOrReturns = 1;
                                      });
                                      cubit.afterSave();
                                    },
                                    backgroundColor:
                                        const Color.fromRGBO(32, 67, 89, 1),
                                    child: const Icon(
                                      Icons.save,
                                      size: 40,
                                      color: Color.fromRGBO(233, 238, 244, 1),
                                    ),
                                  ),
                                ],
                              ),
                              // defaultButon(
                              //     height: blockSizeVertical * 4,
                              //     fontSize: 13,
                              //     width: (blockSizeHorizontal * 20),
                              //     background:
                              //         const Color.fromRGBO(32, 67, 89, 1),
                              //     function: () {
                              //       if (cubit.allAddedItems.isNotEmpty &&
                              //           cubit.quantity.isNotEmpty &&
                              //           cubit.totalOfItem.isNotEmpty) {
                              //         cubit.insertToInvoiceInfo(
                              //             type: cubit.sellsOrReturns,
                              //             clientId: cubit.client_id,
                              //             notes: "",
                              //             invoiceNumber:
                              //                 cubit.sellsOrReturns == 1
                              //                     ? cubit.getInvoiceNum()
                              //                     : cubit.getReturnNum(),
                              //             invoiceDate:
                              //                 cubit.formattedDate.toString(),
                              //             clientName: cubit.client_name,
                              //             total: cubit.totalAfter);
                              //         // while (cubit.savedItemsIndx <
                              //         //     cubit.allAddedItems.length) {
                              //         //   cubit.insertInvoiceItems(
                              //         //       infoId: cubit.getInfoId(),
                              //         //       unitId: 0,
                              //         //       quentity: int.parse(cubit.quantity[
                              //         //               cubit.savedItemsIndx])
                              //         //           ,
                              //         //       price: int.parse(cubit.totalOfItem[
                              //         //               cubit.savedItemsIndx])
                              //         //           ,
                              //         //       tax: 0,
                              //         //       items: cubit.allAddedItems[cubit
                              //         //               .savedItemsIndx]["item_desc"]
                              //         //           .toString(),
                              //         //       invoiceNumber: cubit
                              //         //           .getInvoiceNum()
                              //         //           );
                              //         //   cubit.savedItemsIndx++;
                              //         // }
                              //         cubit.allAddedItems.forEach((element) {
                              //           cubit.insertInvoiceItems(
                              //             infoId: cubit.getInfoId(),
                              //             unitId: 0,
                              //             quentity: int.parse(cubit.quantity[
                              //                 cubit.allAddedItems
                              //                     .indexOf(element)]),
                              //             price: cubit.dis == 0
                              //                 ? (cubit.totalOfItem[cubit
                              //                     .allAddedItems
                              //                     .indexOf(element)])
                              //                 : cubit.totalAfter,
                              //             tax: int.parse(cubit.dropdownValue),
                              //             invoiceNumber:
                              //                 cubit.sellsOrReturns == 1
                              //                     ? cubit.getInvoiceNum()
                              //                     : cubit.getReturnNum(),
                              //             items: element["item_desc"],
                              //           );
                              //         });
                              //       }
                              //       setState(() {
                              //         cubit.sellsOrReturns = 1;
                              //       });
                              //       cubit.afterSave();
                              //     },
                              //     text: "save")
                            ],
                          ),
                        ))),
              ),
            ],
          ),
          drawer: Drawer(
            child: ListView(padding: EdgeInsets.zero, children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/icons-settings.png"),
                    fit: BoxFit.none,
                  ),
                  color: Color.fromRGBO(230, 92, 79, 1),
                ),
                child: InkWell(
                  onDoubleTap: () {
                    debugPrint(cubit.settingsList.toString());
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SettingsScreen()),
                    );
                  },
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
                    cubit.afterSave();
                    if (cubit.sellsOrReturns == -1) {
                      setState(
                        () {
                          debugPrint(cubit.sellsOrReturns.toString());
                          cubit.sellsOrReturns = 1;
                          Navigator.pop(context);
                          cubit.getInvoiceNum();
                          debugPrint(cubit.sellsOrReturns.toString());
                        },
                      );
                    } else {
                      setState(
                        () {
                          debugPrint(cubit.sellsOrReturns.toString());
                          cubit.sellsOrReturns = -1;
                          debugPrint(cubit.sellsOrReturns.toString());
                        },
                      );
                      cubit.getReturnNum();
                      Navigator.pop(context);
                      Fluttertoast.showToast(
                        backgroundColor: const Color.fromRGBO(32, 67, 89, 1),
                        fontSize: 25,
                        msg: "المرتجعات",
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.CENTER,
                      );
                    }
                  },
                  title: const Text(
                    'المرتجعات',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                );
              })),
              Builder(builder: ((context) {
                return ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    showBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                            height: 300,
                            decoration: const BoxDecoration(
                              color: Color.fromRGBO(220, 92, 79, 1),
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(10)),
                            ),
                            child: Column(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.all(5.0),
                                  child: Text(
                                    "المصاريف",
                                    style: TextStyle(
                                        fontSize: 30,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: TextFormField(
                                    controller: cubit.expenseDescController,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(
                                      hintText: "المصاريف",
                                      hintStyle: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color.fromRGBO(32, 67, 89, 1),
                                        ),
                                      ),
                                    ),
                                    keyboardType: TextInputType.text,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: TextFormField(
                                    controller: cubit.expensePriceController,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(
                                      hintText: "المجموع",
                                      hintStyle: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color.fromRGBO(32, 67, 89, 1),
                                        ),
                                      ),
                                    ),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'[0-9 .]')),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                ElevatedButton(
                                  style: ButtonStyle(
                                    shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30))),
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                      const Color.fromRGBO(32, 67, 89, 1),
                                    ),
                                  ),
                                  onPressed: () {
                                    cubit
                                        .insertToExpenses(
                                            expenseDesc: cubit
                                                .expenseDescController.text,
                                            expensePrice: int.parse(cubit
                                                .expensePriceController.text),
                                            expenseDate: cubit.formatOfDate
                                                .format(DateTime.now())
                                                .toString())
                                        .then((value) {
                                      cubit.calculateExpenses();
                                      cubit.calculateDayTotal();
                                    });
                                    Navigator.pop(context);
                                    cubit.expenseDescController.clear();
                                    cubit.expensePriceController.clear();
                                  },
                                  //elevation: 10,

                                  child: const Icon(Icons.add),
                                ),
                              ],
                            ),
                          );
                        });
                  },
                  title: const Text(
                    'المصاريف',
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

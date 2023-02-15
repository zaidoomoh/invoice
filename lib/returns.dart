import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:test1/shared/components/components.dart';
import 'client.dart';
import 'cubit.dart';
import 'items.dart';
import 'states.dart';

class Returns extends StatefulWidget {
  const Returns({super.key});

  @override
  State<Returns> createState() => _ReturnsState();
}

class _ReturnsState extends State<Returns> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InvoiceCubit, InvoiceStates>(
        listener: (context, state) {},
        builder: (context, state) {
          var cubit = BlocProvider.of<InvoiceCubit>(context);
          var formatter = NumberFormat('0000');
          var totalFormatter = NumberFormat('###.##');
          MediaQueryData mediaQueryData = MediaQuery.of(context);
          double screenWidth = mediaQueryData.size.width;
          double screenHeight = mediaQueryData.size.height;
          double blockSizeHorizontal = screenWidth / 100;
          double blockSizeVertical = screenHeight / 100;
          var appBar = AppBar(
              backgroundColor: const Color.fromRGBO(32, 67, 89, 1),
              title:
                  Title(color: Colors.cyan, child: const Text('Bill maker')));

          return WillPopScope(
            onWillPop: () async {
              debugPrint("done");
              Navigator.pop(context);
              cubit.allReturnsItems.removeLast();
              cubit.currentReturnsItem.removeLast();
              cubit.priceEditingController =
                  TextEditingController(text: "1");
              return true;
            },
            child: Scaffold(
              appBar: AppBar(
                  backgroundColor: const Color.fromRGBO(50, 103, 137, 1),
                  title: const Text("Business")),
              body: Column(
                children: [
                  defaultCard(
                      fontSize: 20,
                      smallConHeigt: (MediaQuery.of(context).size.height -
                              appBar.preferredSize.height -
                              MediaQuery.of(context).padding.top) *
                          0.1,
                      smallConWedth: MediaQuery.of(context).size.width,
                      text: 'RETURN #:${formatter.format(cubit.getInvoiceNum())}',
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
                            MaterialPageRoute(
                                builder: (context) => const Client()),
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
                            cubit.sellsOrReturns=true;
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
                                                      controller:
                                                          cubit.discountCon,
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
                                                    style:
                                                        ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                const Color
                                                                        .fromRGBO(
                                                                    120,
                                                                    166,
                                                                    200,
                                                                    1)),
                                                    child: const Text('نسبة'),
                                                    onPressed: () {
                                                      if (cubit.formkey
                                                              .currentState!
                                                              .validate() &&
                                                          cubit.totalOfReturns
                                                              .isNotEmpty &&
                                                          num.parse(cubit
                                                                  .discountCon
                                                                  .text) <=
                                                              100) {
                                                        setState(() {
                                                          cubit.dis = num.parse(
                                                              cubit.discountCon
                                                                  .text);
                                                          debugPrint(cubit.dis
                                                              .toString());
                                                          cubit.returnsTotalAfter = cubit
                                                                  .returnsTotalBefor -
                                                              ((cubit.dis / 100) *
                                                                  cubit
                                                                      .returnsTotalBefor);
                                                        });
          
                                                        Navigator.pop(context);
                                                        cubit.discountCon.clear();
                                                        debugPrint(
                                                            cubit.dis.toString());
                                                      }
                                                    }),
                                                ElevatedButton(
                                                    style:
                                                        ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                const Color
                                                                        .fromRGBO(
                                                                    120,
                                                                    166,
                                                                    200,
                                                                    1)),
                                                    child: const Text('قيمة'),
                                                    onPressed: () {
                                                      if (cubit.formkey
                                                              .currentState!
                                                              .validate() &&
                                                          cubit.totalOfReturns
                                                              .isNotEmpty &&
                                                          num.parse(cubit
                                                                  .discountCon
                                                                  .text) <=
                                                              cubit.totalAfter) {
                                                        setState(() {
                                                          cubit.dis = num.parse(
                                                              cubit.discountCon
                                                                  .text);
          
                                                          cubit.returnsTotalAfter =
                                                              cubit.returnsTotalBefor -
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
                                          "TOTAL : ${cubit.dis == 0 ? totalFormatter.format(cubit.returnsTotalBefor) : totalFormatter.format(cubit.returnsTotalAfter)} ",
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
                    padding:
                        const EdgeInsets.only(left: 10, right: 10, bottom: 5),
                    child: SizedBox(
                        width: double.infinity,
                        height: 240,
                        child: Card(
                          color: const Color.fromRGBO(233, 238, 244, 1),
                          child: Column(
                            children: [
                              Expanded(
                                child:
                                    cubit.allReturnsItems.isEmpty &&
                                            cubit.returnsQuantity.isEmpty &&
                                            cubit.totalOfReturns.isEmpty
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
                                                    padding:
                                                        const EdgeInsets.all(3.0),
                                                    child: SizedBox(
                                                      width: blockSizeHorizontal *
                                                          93,
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
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    Colors.grey),
                                                          ),
                                                          Text("QUANTITY",
                                                              style: TextStyle(
                                                                  fontSize: 10,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .grey)),
                                                          Text("PRICE",
                                                              style: TextStyle(
                                                                  fontSize: 10,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .grey)),
                                                          Text("TOTAL PRICE",
                                                              style: TextStyle(
                                                                  fontSize: 10,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .grey)),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: ListView.builder(
                                                    itemCount: cubit
                                                        .allReturnsItems.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                                left: 10,
                                                                right: 10,
                                                                top: 5),
                                                        child: SizedBox(
                                                          height: 40,
                                                          child: Dismissible(
                                                            key:UniqueKey(),
                                                            onDismissed:
                                                                (direction) {
                                                              showDialog(
                                                                context: context,
                                                                builder:
                                                                    (context) {
                                                                  return Wrap(
                                                                      children: <
                                                                          Widget>[
                                                                        StatefulBuilder(
                                                                          builder: (BuildContext
                                                                                  context,
                                                                              void Function(void Function())
                                                                                  setState) {
                                                                            return AlertDialog(
                                                                              title:
                                                                                  const Text('  هل تريد حذف هذه المادة  '),
                                                                              content:
                                                                                  Form(
                                                                                key: cubit.returnsFormKey,
                                                                                child: Column(children: []),
                                                                              ),
                                                                              actions: <Widget>[
                                                                                ElevatedButton(
                                                                                  style: ElevatedButton.styleFrom(backgroundColor: const Color.fromRGBO(120, 166, 200, 1)),
                                                                                  child: const Text('CANCEL'),
                                                                                  onPressed: () {
                                                                                    Navigator.pop(context);
                                                                                  },
                                                                                ),
                                                                                Builder(builder: (context) {
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
                                                                    120,
                                                                    166,
                                                                    200,
                                                                    1),
                                                                child: Padding(
                                                                  padding: const EdgeInsets
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
                                                                            .allReturnsItems[
                                                                                index]
                                                                                [
                                                                                'item_desc']
                                                                            .toString(),
                                                                        style: const TextStyle(
                                                                            fontWeight: FontWeight
                                                                                .w900,
                                                                            fontSize:
                                                                                15),
                                                                      ),
                                                                      Text(
                                                                        (cubit.returnsQuantity[index] 
                                                                              )
                                                                            .toString(),
                                                                        style: const TextStyle(
                                                                            fontWeight: FontWeight
                                                                                .w900,
                                                                            fontSize:
                                                                                15),
                                                                      ),
                                                                      Text(
                                                                        "${cubit.priceOfReturns[index].toString()}JD",
                                                                        style: const TextStyle(
                                                                            fontWeight: FontWeight
                                                                                .w900,
                                                                            fontSize:
                                                                                15),
                                                                      ),
                                                                      Text(
                                                                        "${cubit.totalOfReturns[index].toString()}JD",
                                                                        style: const TextStyle(
                                                                            fontWeight: FontWeight
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
                                        "Befor discount: ${cubit.totalOfReturns.isEmpty ? "0" : totalFormatter.format(cubit.totalBefor)}",
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
                                        if (cubit.allReturnsItems.isNotEmpty &&
                                            cubit.returnsQuantity.isNotEmpty &&
                                            cubit.totalOfReturns.isNotEmpty) {
                                          cubit.insertToInvoiceInfo(
                                              clientId: cubit.client_id,
                                              notes: "",
                                              invoiceNumber:
                                                  cubit.getInvoiceNum(),
                                              invoiceDate:
                                                  cubit.formattedDate.toString(),
                                              clientName: cubit.client_name,
                                              total: cubit.totalAfter);
                                          cubit.allReturnsItems.forEach((element) {
                                            cubit.insertInvoiceItems(
                                              infoId: cubit.getInfoId(),
                                              unitId: 0,
                                              quentity: int.parse(cubit.returnsQuantity[
                                                      cubit.allReturnsItems
                                                          .indexOf(element)]) *
                                                  (-1),
                                              price: (cubit.totalOfReturns[cubit
                                                  .allReturnsItems
                                                  .indexOf(element)]),
                                              tax: int.parse(cubit.dropdownValue),
                                              invoiceNumber:
                                                  cubit.getInvoiceNum(),
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
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.startFloat,
              floatingActionButton: Row(
                children: const <Widget>[],
              ),
            ),
          );
        });
  }
}

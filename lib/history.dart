import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'bill_screen.dart';
import 'cubit.dart';
import 'states.dart';

class History extends StatefulWidget {
  const History({Key? key}) : super(key: key);

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InvoiceCubit, InvoiceStates>(
        listener: (context, state) {},
        builder: (context, state) {
          var cubit = BlocProvider.of<InvoiceCubit>(context);

          var totalFormatter = NumberFormat('##.00');

          return Stack(children: [
            Scaffold(
              appBar: AppBar(
                actions: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(5),
                        child: SizedBox(
                            height: 50,
                            width: (MediaQuery.of(context).size.width / 2) - 20,
                            child: Card(
                              elevation: 20,
                              color: const Color.fromRGBO(32, 67, 89, 1),
                              child: Center(
                                  child: cubit.filterdHistory.isEmpty
                                      ? const Text(
                                          "TOTAL:0",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Color.fromRGBO(230, 92, 79, 1),
                                          ),
                                        )
                                      : Text(
                                          "TOTAL:${totalFormatter.format(cubit.dayTotal).toString()}",
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Color.fromRGBO(230, 92, 79, 1),
                                          ),
                                        )),
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width / 2,
                          child: TextFormField(

                            style: const TextStyle(color: Colors.white),
                            // onTap: () {
                            //   cubit.historyFilteringController.clear();
                            //   showDatePicker(context: context, initialDate: DateTime.now(), firstDate:DateTime.parse("2021-01-01"), lastDate:  DateTime.now()).then((value) {
                            //     cubit.historyFilteringController.text=cubit.formatOfDate.format(value!);
                            //     //cubit.filtering(value.toString(),"history");
                            //   });
                            // },
                            controller: cubit.historyFilteringController,
                            onChanged: (value) {
                              cubit.filtering(value.toString(), "history");
                            },

                            keyboardType: TextInputType.datetime,
                            decoration: const InputDecoration(
                              labelText: "Filtering",
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black)),
                              prefixIconColor: Color.fromRGBO(120, 166, 200, 1),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                backgroundColor: Color.fromRGBO(32, 67, 89, 1),
              ),
              body: cubit.history.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: cubit.filterdHistory.length,
                                  itemBuilder: (context, index) {
                                    return Dismissible(
                                      key: UniqueKey(),
                                      onDismissed: (direction) {
                                        setState(() {});
                                        // showDialog(
                                        //   context: context,
                                        //   builder: (context) {
                                        //     return Wrap(children: <Widget>[
                                        //       StatefulBuilder(
                                        //         builder: (BuildContext context,
                                        //             void Function(void Function())
                                        //                 setState) {
                                        //           return AlertDialog(
                                        //             title: const Text(
                                        //                 'هل تريد حذف هذه المادة'),
                                        //             content: Form(
                                        //               key: cubit.formkey,
                                        //               child: Column(children: []),
                                        //             ),
                                        //             actions: <Widget>[
                                        //               ElevatedButton(
                                        //                 style: ElevatedButton
                                        //                     .styleFrom(
                                        //                         backgroundColor:
                                        //                             const Color
                                        //                                     .fromRGBO(
                                        //                                 120,
                                        //                                 166,
                                        //                                 200,
                                        //                                 1)),
                                        //                 child:
                                        //                     const Text('CANCEL'),
                                        //                 onPressed: () {
                                        //                   Navigator.pop(context);
                                        //                 },
                                        //               ),
                                        //               Builder(builder: (context) {
                                        //                 return ElevatedButton(
                                        //                     style: ElevatedButton
                                        //                         .styleFrom(
                                        //                             backgroundColor:
                                        //                                 const Color
                                        //                                         .fromRGBO(
                                        //                                     120,
                                        //                                     166,
                                        //                                     200,
                                        //                                     1)),
                                        //                     child: const Text(
                                        //                         'SAVE'),
                                        //                     onPressed: () {
                                        //                       Navigator.pop(
                                        //                           context);
                                        //                       // cubit.deleteFromDB(
                                        //                       //     id: cubit.history[
                                        //                       //             index]
                                        //                       //         ["info_id"],
                                        //                       //     tableName:
                                        //                       //         "invoice_info",
                                        //                       //     columnName:
                                        //                       //         "info_id");
                                        //                       // cubit.savedItems[index]["quentity"]>0?
                                        //                       // cubit.updateToReturns(quantity:(cubit.savedItems[index]["quentity"])*(-1),
                                        //                       //  id:cubit.savedItems[index]["info_id"]):debugPrint("did not work");
                                        //                     });
                                        //               }),
                                        //             ],
                                        //           );
                                        //         },
                                        //       ),
                                        //     ]);
                                        //   },
                                        // );
                                      },
                                      child: InkWell(
                                        onLongPress: () {
                                          cubit.showSavedItems(index);
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return Wrap(children: <Widget>[
                                                AlertDialog(
                                                  title: const Text('المزيد'),
                                                  content: Form(
                                                    child: Column(
                                                      children: [
                                                        ListTile(
                                                          title: const Text(
                                                              "اظهار تفاصيل"),
                                                          onTap: () {
                                                            Navigator.pop(
                                                                context);
                                                            showDialog(
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return Wrap(
                                                                    children: [
                                                                      AlertDialog(
                                                                        title: const Text(
                                                                            " المواد"),
                                                                        content:
                                                                            ConstrainedBox(
                                                                          constraints:
                                                                              BoxConstraints(
                                                                            maxHeight:
                                                                                MediaQuery.of(context).size.height * 0.31,
                                                                            minHeight:
                                                                                MediaQuery.of(context).size.height * 0.05,
                                                                          ),
                                                                          child:
                                                                              SingleChildScrollView(
                                                                            child:
                                                                                Column(
                                                                              children: cubit.saved.map((item) {
                                                                                return SizedBox(
                                                                                  width: MediaQuery.of(context).size.width,
                                                                                  child: Card(
                                                                                    color: const Color.fromRGBO(233, 238, 244, 1),
                                                                                    elevation: 5,
                                                                                    child: Padding(
                                                                                      padding: const EdgeInsets.all(5.0),
                                                                                      child: Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                        children: [
                                                                                          Text(
                                                                                            item["invoice_items"],
                                                                                            style: const TextStyle(
                                                                                              fontSize: 15,
                                                                                            ),
                                                                                          ),
                                                                                          Text(
                                                                                            item["quentity"].toString(),
                                                                                            style: const TextStyle(
                                                                                              fontSize: 15,
                                                                                              fontWeight: FontWeight.bold,
                                                                                            ),
                                                                                          ),
                                                                                          Text(
                                                                                            item["price"].toString(),
                                                                                            style: const TextStyle(
                                                                                              fontSize: 15,
                                                                                              fontWeight: FontWeight.bold,
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                );
                                                                              }).toList(),
                                                                            ),
                                                                          ),
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
                                                                        ],
                                                                      ),
                                                                    ]);
                                                              },
                                                            );
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  actions: <Widget>[
                                                    ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                              backgroundColor:
                                                                  const Color
                                                                          .fromRGBO(
                                                                      120,
                                                                      166,
                                                                      200,
                                                                      1)),
                                                      child:
                                                          const Text('CANCEL'),
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ]);
                                            },
                                          );
                                        },
                                        child: Card(
                                          color:
                                              Color.fromRGBO(233, 238, 244, 1),
                                          child: ListTile(
                                            title: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(cubit.history[index]
                                                        ['invoice_number']
                                                    .toString()),
                                                Text(cubit.history[index]
                                                        ['invoice_date']
                                                    .toString()),
                                                Text(
                                                    "${cubit.history[index]['client_name'].toString()} "),
                                                Text(
                                                    "${cubit.history[index]['total'].toStringAsFixed(2)} JD"),
                                              ],
                                            ),
                                            onTap: () async {},
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                          ),
                        ]),
              floatingActionButton: FloatingActionButton(
                  backgroundColor: const Color.fromRGBO(120, 166, 200, 1),
                  elevation: 20,
                  child: const Icon(
                    Icons.save,
                    size: 40,
                    color: Color.fromRGBO(233, 238, 244, 1),
                  ),
                  onPressed: () {}),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
            ),
          ]);
        });
  }
}

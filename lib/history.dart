import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

          return Scaffold(
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
                            color: Color.fromRGBO(32, 67, 89, 1),
                            child: Center(
                                child: cubit.filterdHistory.isEmpty
                                    ? const Text(
                                        "TOTAL:0",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromRGBO(230, 92, 79, 1),
                                        ),
                                      )
                                    : Text(
                                        "TOTAL:${totalFormatter.format(cubit.dayTotal).toString()}",
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromRGBO(230, 92, 79, 1),
                                        ),
                                      )),
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width / 2,
                        child: TextFormField(
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
                                      showDialog(
                                  context: context,
                                  builder: (context) {
                                    return Wrap(children: <Widget>[
                                      StatefulBuilder(
                                        builder: (BuildContext context,
                                            void Function(void Function())
                                                setState) {
                                          return AlertDialog(
                                            title:
                                                const Text('  هل تريد حذف هذه المادة'),
                                            content: Form(
                                              key: cubit.formkey,
                                              child: Column(children: []),
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
                                                  
                                                },
                                              ),
                                              Builder(builder: (context) {
                                                return ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                            backgroundColor:
                                                                const Color
                                                                        .fromRGBO(
                                                                    120,
                                                                    166,
                                                                    200,
                                                                    1)),
                                                    child: const Text('SAVE'),
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                       cubit.deleteFromDB(id: cubit.history[index]["info_id"],
                                                       tableName: "invoice_info",
                                                       columnName: "info_id"
                                                       );
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
                                      onLongPress: () {
                                        debugPrint(
                                            cubit.savedItems.length.toString());
                                        debugPrint(cubit.savedItems.toString());
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return Wrap(children: <Widget>[
                                              AlertDialog(
                                                title: const Text('المزيد'),
                                                content: Form(
                                                  child: Column(children: [
                                                    ListTile(
                                                      title: const Text(
                                                          "اظهار المواد"),
                                                      onTap: () {
                                                        Navigator.pop(context);
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return Wrap(
                                                              children: [
                                                                AlertDialog(
                                                                  title:
                                                                      const Text(
                                                                          " المواد"),
                                                                  content: Text(
                                                                      cubit.savedItems[
                                                                              index]
                                                                          [
                                                                          "invoice_items"]),
                                                                  // content: SizedBox(
                                                                  //   height: 100,
                                                                  //   width: 100,
                                                                  //   child: ListView
                                                                  //       .builder(
                                                                  //     shrinkWrap: true,
                                                                  //     itemCount: 2,
                                                                  //     // cubit
                                                                  //     //       .savedItems[index][""],
                                                                  //     itemBuilder:/* */
                                                                  //         (context,
                                                                  //             index) {
                                                                  //       return Text(cubit
                                                                  //           .savedItems[
                                                                  //               index][cubit.savedItems[int.parse(cubit.savedItems[index]["invoice_num"])]["invoice_items"]
                                                                  //               ]
                                                                  //           .toString());
                                                                  //     },
                                                                  //   ),
                                                                  // ),
                                                                  actions: [
                                                                    ElevatedButton(
                                                                      style: ElevatedButton.styleFrom(
                                                                          backgroundColor: const Color.fromRGBO(
                                                                              120,
                                                                              166,
                                                                              200,
                                                                              1)),
                                                                      child: const Text(
                                                                          'CANCEL'),
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                    ),
                                                                  ],
                                                                )
                                                              ],
                                                            );
                                                          },
                                                        );
                                                      },
                                                    ),
                                                  ]),
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
                                                    child: const Text('CANCEL'),
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
                                        color: Color.fromRGBO(233, 238, 244, 1),
                                        child: ListTile(
                                          title: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(cubit.history[index]
                                                      ['invoice_number']
                                                  .toString()),
                                              Text(
                                                  "${cubit.history[index]['client_name'].toString()} "),
                                              Text(
                                                  "${cubit.history[index]['total'].toString()} JD"),
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
          );
        });
  }
}

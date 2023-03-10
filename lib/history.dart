import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
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
          return Scaffold(
            resizeToAvoidBottomInset: false,
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
                                child: cubit.filterdsavedItemsInfo.isEmpty
                                    ? const Text(
                                        "TOTAL:0",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        "TOTAL:${(cubit.dayTotal - cubit.expensesTotal).toStringAsFixed(2)}",
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
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
                          onTap: () async {
                            cubit.historyFilteringController.clear();
                            showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.parse(
                                        cubit.savedItemsInfo[
                                                cubit.savedItemsInfo.length - 1]
                                            ["invoice_date"]),
                                    lastDate: DateTime.now())
                                .then((value) {
                              cubit.historyFilteringController.text =
                                  cubit.formatOfDate.format(value!);
                              if (cubit.historyFilteringController.text == "") {
                                Navigator.pop(context);
                              }
                              return;
                            });
                          },
                          onFieldSubmitted: (value) {
                            cubit.filtering(value.toString(), "history");
                          },
                          controller: cubit.historyFilteringController,
                          keyboardType: TextInputType.datetime,
                          decoration: InputDecoration(
                            labelText: "Filtering",
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: IconButton(
                                onPressed: () {
                                  cubit.historyFilteringController.clear();
                                  cubit.filtering("", "history");
                                },
                                icon: const Icon(Icons.clear)),
                            border: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black)),
                            prefixIconColor: Color.fromRGBO(120, 166, 200, 1),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              backgroundColor: const Color.fromRGBO(32, 67, 89, 1),
            ),
            body: cubit.savedItemsInfo.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: cubit.filterdsavedItemsInfo.length,
                                itemBuilder: (context, index) {
                                  return Dismissible(
                                    key: UniqueKey(),
                                    onDismissed: (direction) {
                                      setState(() {});
                                    },
                                    child: InkWell(
                                      onLongPress: () {
                                        debugPrint(cubit.savedItemsInfo[index]
                                            .toString());
                                        debugPrint(
                                            cubit.savedItems.toString());
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
                                                                            children:
                                                                                cubit.saved.map((item) {
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
                                        color:
                                            cubit.filterdsavedItemsInfo[index]
                                                        ["invoice_type"] ==
                                                    1
                                                ? const Color.fromRGBO(
                                                    233, 238, 244, 1)
                                                : const Color.fromRGBO(
                                                    230, 92, 79, 1),
                                        child: ListTile(
                                          title: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                cubit.filterdsavedItemsInfo[
                                                        index]['invoice_number']
                                                    .toString(),
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                cubit.filterdsavedItemsInfo[
                                                        index]['invoice_date']
                                                    .toString(),
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                "${cubit.filterdsavedItemsInfo[index]['client_name'].toString()} ",
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                cubit.filterdsavedItemsInfo[
                                                        index]['total']
                                                    .toStringAsFixed(2),
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
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
            floatingActionButton: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                    backgroundColor: const Color.fromRGBO(120, 166, 200, 1),
                    elevation: 20,
                    child: const Icon(
                      Icons.upload,
                      size: 40,
                      color: Color.fromRGBO(233, 238, 244, 1),
                    ),
                    onPressed: () async {
                      var connectivityResult =
                          await (Connectivity().checkConnectivity());
                      if (connectivityResult == ConnectivityResult.none) {
                        // There is no active internet connection.
                        Fluttertoast.showToast(
                          backgroundColor: const Color.fromRGBO(32, 67, 89, 1),
                          fontSize: 25,
                          msg: "لا يوجد اتصال بالانترنت",
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.CENTER,
                        );

                        debugPrint(connectivityResult.toString());
                      } else if(cubit.invoiceInfoTable.isNotEmpty){
                        // There is an active internet connection.
                        cubit.addInvoices();
                        cubit.addExpenses();
                        cubit.addTotal();
                        Fluttertoast.showToast(
                          backgroundColor: const Color.fromRGBO(32, 67, 89, 1),
                          fontSize: 25,
                          msg: "تم رفع الفواتير",
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.CENTER,
                        );
                        debugPrint(connectivityResult.toString());
                      }
                    }),
                FloatingActionButton(
                    backgroundColor: const Color.fromRGBO(120, 166, 200, 1),
                    elevation: 20,
                    child: const Icon(
                      Icons.list,
                      size: 40,
                      color: Color.fromRGBO(233, 238, 244, 1),
                    ),
                    onPressed: () {
                      cubit.calculateExpenses();
                      showBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return ConstrainedBox(
                              constraints: const BoxConstraints(
                                  maxHeight: 280, minHeight: 10),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Color.fromRGBO(220, 92, 79, 1),
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(10)),
                                ),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Text(
                                        "${cubit.expensesTotal}:المصاريف",
                                        style: const TextStyle(
                                            fontSize: 30,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Expanded(
                                      child: cubit.expensesList.isNotEmpty
                                          ? ListView.builder(
                                              itemBuilder: ((context, index) {
                                                return SizedBox(
                                                    height: 50,
                                                    child: Card(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(10.0),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(cubit
                                                                .expensesList[
                                                                    index][
                                                                    "expense_desc"]
                                                                .toString()),
                                                            Text(cubit
                                                                .expensesList[
                                                                    index][
                                                                    "expense_price"]
                                                                .toString()),
                                                            Text(cubit
                                                                .expensesList[
                                                                    index][
                                                                    "expense_date"]
                                                                .toString()),
                                                          ],
                                                        ),
                                                      ),
                                                    ));
                                              }),
                                              itemCount:
                                                  cubit.expensesList.length,
                                            )
                                          : const Center(child: Text("")),
                                    )
                                  ],
                                ),
                              ),
                            );
                          });
                    }),
              ],
            ),
            //floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          );
        });
  }
}

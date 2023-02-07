//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'add_items.dart';
import 'cubit.dart';
import 'shared/components/components.dart';
import 'states.dart';

ScrollController controller = ScrollController();
void scrollDown() {
  controller.jumpTo(controller.position.maxScrollExtent);
}

void scrollToMaxExtent() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    controller.animateTo(
      controller.position.maxScrollExtent,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeIn,
    );
  });
}

class Items extends StatefulWidget {
  const Items({Key? key}) : super(key: key);
  @override
  State<Items> createState() => _TestState();
}

class _TestState extends State<Items> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(context) {
    return BlocConsumer<InvoiceCubit, InvoiceStates>(
      listener: (context, state) {},
      builder: (context, state) {
        TextEditingController editItemName = TextEditingController();
        TextEditingController editItemPrice = TextEditingController();
        TextEditingController editedItemNumber = TextEditingController();
        var cubit = BlocProvider.of<InvoiceCubit>(context);
        return Scaffold(
          appBar: AppBar(
              actions: [
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: SizedBox(
                    width: 300,
                    height: 10,
                    child: TextFormField(
                      controller: cubit.itemsFilteringController,
                      onChanged: (value) {
                        cubit.filtering(value, "items");
                      },
                      keyboardType: TextInputType.name,
                      decoration: const InputDecoration(
                        labelText: "Filtering",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black)),
                        prefixIconColor: Color.fromRGBO(120, 166, 200, 1),
                      ),
                    ),

                    // defaultTextFormFeild(
                    //     color: Colors.white,
                    //     controller: cubit.itemsFilteringController,
                    //     type: TextInputType.name,
                    //     onSubmit: () {},
                    //     onChange: (value) {
                    //       cubit.filteringItems(value);
                    //     },
                    //     label: "Filtering",
                    //     prefix: Icons.search,
                    //     textInputFormatter:
                    //         FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))),
                  ),
                ),
              ],
              backgroundColor: const Color.fromRGBO(32, 67, 89, 1),
              title:
                  Title(color: Colors.amber, child: const Text('Bill maker'))),
          body: cubit.filterdItems.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: cubit.filterdItems.length,
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
                                            title: const Text(
                                                '  هل تريد حذف هذه المادة'),
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
                                                    child: const Text('DELETE'),
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      cubit.deleteFromDB(
                                                          id: cubit.filterdItems[
                                                                  index]
                                                              ["items_id"],
                                                          tableName: "items",
                                                          columnName:
                                                              "items_id");
                                                    });
                                              }),
                                            ],
                                          );
                                        },
                                      ),
                                    ]);
                                  },
                                );

                                debugPrint(cubit.filterdItems.toString());
                              },
                              child: Card(
                                child: ListTile(
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                          "${cubit.filterdItems[index]["item_desc"]} "),
                                      Text(
                                          "${cubit.filterdItems[index]["price"].toString()} JD"),
                                    ],
                                  ),
                                  onTap: () async {
                                    if (cubit.sellsOrReturns == true) {
                                      /*returns*/
                                      cubit.allReturnsItems
                                          .add(cubit.items[index]);
                                      cubit.currentReturnsItem
                                          .add(cubit.items[index]);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const AddItems()),
                                      );
                                    } else {
                                      cubit.priceEditingController =
                                          TextEditingController(
                                              text: cubit.items[index]["price"]
                                                  .toString());

                                      cubit.allAddedItems
                                          .add(cubit.items[index]);
                                      cubit.currentAddedItem
                                          .add(cubit.items[index]);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const AddItems()),
                                      );
                                    }
                                  },
                                  onLongPress: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Wrap(
                                          children: [
                                            AlertDialog(
                                              title: const Text("تعديل"),
                                              content: Form(
                                                  child: Column(
                                                children: [
                                                  defaultTextFormFeild(
                                                    color: Colors.black,
                                                    controller: editItemName,
                                                    type: TextInputType.name,
                                                    label: "Name",
                                                    prefix: Icons.abc,
                                                    onChange: () {},
                                                    onSubmit: () {},
                                                    textInputFormatter:
                                                        FilteringTextInputFormatter
                                                            .deny(r'[]'),
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  defaultTextFormFeild(
                                                    color: Colors.black,
                                                    controller: editItemPrice,
                                                    type: TextInputType.number,
                                                    label: "Price",
                                                    prefix: Icons.money,
                                                    textInputFormatter:
                                                        FilteringTextInputFormatter
                                                            .allow(RegExp(
                                                                r'[0-9]')),
                                                    onChange: () {},
                                                    onSubmit: () {},
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  // defaultTextFormFeild(
                                                  //   color: Colors.black,
                                                  //   controller: editedItemNumber,
                                                  //   type: TextInputType.number,
                                                  //   label: "Subject number",
                                                  //   prefix: Icons.numbers,
                                                  //   textInputFormatter:
                                                  //       FilteringTextInputFormatter
                                                  //           .allow(
                                                  //               RegExp(r'[0-9]')),
                                                  //   onChange: () {},
                                                  //   onSubmit: () {},
                                                  // ),
                                                ],
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
                                                  child: const Text('SAVE'),
                                                  onPressed: () {
                                                    cubit.updateSubjects(
                                                        price:
                                                            editItemPrice.text,
                                                        name: editItemName.text,
                                                        number:
                                                            cubit.items[index]
                                                                ["number"]);
                                                    Navigator.pop(context);
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
                              ),
                            );

                            //                      return FutureBuilder<DocumentSnapshot>(
                            //   future: cubit.itemss.doc().get(),
                            //   builder:
                            //       (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {

                            //     if (snapshot.hasError) {
                            //       return Text("Something went wrong");
                            //     }

                            //     if (snapshot.hasData && !snapshot.data!.exists) {
                            //       return Text("Document does not exist");
                            //     }

                            //     if (snapshot.connectionState == ConnectionState.done) {
                            //       Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
                            //       return Text("Full Name: ${data["item_name"]} ${data['item_price']}");
                            //     }

                            //     return Text("loading");
                            //   },
                            // );
                          }),
                    ),
                  ],
                ),
          // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          // floatingActionButton: Row(
          //   children: <Widget>[
          //     const Spacer(
          //       flex: 1,
          //     ),
          //     Padding(
          //       padding: const EdgeInsets.only(left: 2.5),
          //       child: Visibility(
          //         child: Builder(builder: (context) {
          //           return FloatingActionButton.extended(
          //             onPressed: () async {
          //               fill();
          //               print(cardList);
          //             },
          //             backgroundColor: Colors.indigo,
          //             label: const Text(
          //               'save',
          //               style: TextStyle(fontSize: 25),
          //             ),
          //             icon: const Icon(Icons.save),
          //           );
          //         }),
          //       ),
          //     ),
          //   ],
          // )
        );
      },
    );
  }
}
//       FutureBuilder<Album>(
// future: futureAlbum,
// builder: (context, snapshot) {
//   if (snapshot.hasData) {
//     return Text(snapshot.data!.title);
//   } else if (snapshot.hasError) {
//     return Text('${snapshot.error}');
//   }

//   // By default, show a loading spinner.
//   return const CircularProgressIndicator();
// })
/*
 */
//[{kye:value},{kye:value},{kye:value},{kye:value}]
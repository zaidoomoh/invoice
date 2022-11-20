import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test1/home.dart';

import 'cubit.dart';
import 'shared/components/components.dart';
import 'states.dart';

class AddItems extends StatefulWidget {
  const AddItems({super.key});

  @override
  State<AddItems> createState() => _AddItemsState();
}

class _AddItemsState extends State<AddItems> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InvoiceCubit, InvoiceStates>(
        listener: (context, state) {},
        builder: (context, state) {
          var cubit = BlocProvider.of<InvoiceCubit>(context);

          return Dismissible(
            key: UniqueKey(),
            onDismissed: (direction) {
              if (direction == DismissDirection.startToEnd) {
                Navigator.pop(context);
                cubit.allAddedItems.removeLast();
                cubit.currentAddedItem.removeLast();
                cubit.priceEditingController =
                    TextEditingController(text: null);
              }
            },
            child: WillPopScope(
              onWillPop: () async{
                debugPrint("done");
                Navigator.pop(context);
                cubit.allAddedItems.removeLast();
                cubit.currentAddedItem.removeLast();
                cubit.priceEditingController =
                    TextEditingController(text: null);
                    return true;
              },
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                appBar: AppBar(
                    automaticallyImplyLeading: false,
                    backgroundColor: const Color.fromRGBO(50, 103, 137, 1),
                    title: const Text("Item")),
                body: SingleChildScrollView(
                    child: Form(
                  key: cubit.formkey,
                  child: Column(children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SizedBox(
                        height: 100,
                        child: Card(
                          elevation: 20,
                          color: const Color.fromRGBO(233, 238, 244, 1),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  cubit.currentAddedItem[0]["item_desc"],
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                    (cubit.currentAddedItem[0]["price"])
                                        .toString(),
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold))
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: defaultTextFormFeild(
                        warning: "قم بادخال الكمية",
                        color: Colors.black,
                        controller: cubit.quantityController,
                        type: TextInputType.number,
                        onSubmit: () {},
                        onChange: () {},
                        label: "الكميه",
                        prefix: Icons.numbers,
                        textInputFormatter:
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Visibility(
                      visible: cubit.settingsList.isEmpty
                          ? false
                          : (cubit.cc[1] == 0 ? false : true),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: defaultTextFormFeild(
                          warning: "",
                          color: Colors.black,
                          controller: cubit.priceEditingController,
                          type: TextInputType.number,
                          onSubmit: () {},
                          onChange: () {},
                          label: "تعديل السعر",
                          prefix: Icons.numbers,
                          textInputFormatter: FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9 .]')),
                        ),
                      ),
                    )
                  ]),
                )),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerFloat,
                floatingActionButton: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: FittedBox(
                        child: FloatingActionButton.extended(
                            heroTag: "1",
                            backgroundColor:
                                const Color.fromRGBO(120, 166, 200, 1), //78a6c8
                            elevation: 20,
                            label: const Text(
                              "اضافة ",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            icon: const Icon(
                              Icons.add,
                              size: 40,
                              color: Color.fromRGBO(233, 238, 244, 1),
                            ),
                            onPressed: () {
                              if (cubit.formkey.currentState!.validate()) {

                                // {cubit.quantity
                                //     .add(cubit.quantityController.text);
                                // cubit.totalOfItem.add(((cubit.cc[1] == 1
                                //         ? num.parse(
                                //             cubit.priceEditingController.text)
                                //         : cubit.currentAddedItem[0]['price']) *
                                //     num.parse(cubit.quantityController.text)));
                                // cubit.priceOfItem.add(cubit.cc[1] == 1
                                //     ? num.parse(
                                //         cubit.priceEditingController.text)
                                //     : cubit.currentAddedItem[0]['price']);
                                // cubit.calculateTotal();
                                // cubit.currentAddedItem.clear();
                                // cubit.quantityController.clear();}
                                  
                                  cubit.addToList();
                                Navigator.pop(context);
                              }
                            }),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: FittedBox(
                        child: FloatingActionButton.extended(
                            heroTag: "2",
                            backgroundColor:
                                const Color.fromRGBO(120, 166, 200, 1), //78a6c8
                            elevation: 20,
                            label: const Text(
                              "انهاء",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            icon: const Icon(
                              Icons.close,
                              size: 40,
                              color: Color.fromRGBO(233, 238, 244, 1),
                            ),
                            onPressed: () {
                              if (cubit.formkey.currentState!.validate()) {
                                //{
                                // cubit.quantity
                                //     .add(cubit.quantityController.text);
                                // cubit.totalOfItem.add(((cubit.cc[1] == 1
                                //         ? (num.parse(
                                //             cubit.priceEditingController.text)+((cubit.items[0]["tax"]*num.parse(
                                //             cubit.priceEditingController.text))/100))
                                //         : (cubit.currentAddedItem[0]['price']+((cubit.items[0]["tax"]*cubit.currentAddedItem[0]['price'])/100))) *
                                //     num.parse(cubit.quantityController.text)));
                                // cubit.priceOfItem.add(cubit.cc[1] == 1
                                //     ? num.parse(
                                //         cubit.priceEditingController.text)
                                //     : cubit.currentAddedItem[0]['price']);
                                // debugPrint(cubit.totalOfItem.toString());
                                // cubit.calculateTotal();
                                // cubit.currentAddedItem.clear();
                                // cubit.quantityController.clear();
                                //}
                                cubit.addToList();

                                debugPrint(cubit.totalOfItem.toString());
                                debugPrint(cubit.currentAddedItem.toString());
                                debugPrint(cubit.quantity.toString());
                                debugPrint(cubit.allAddedItems.toString());

                                Navigator.of(context).pushNamedAndRemoveUntil(
                                    '/', (Route<dynamic> route) => false);
                              }
                            }),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }
}

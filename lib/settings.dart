import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit.dart';
import 'states.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(context) {
    return BlocConsumer<InvoiceCubit, InvoiceStates>(
        listener: (context, state) {},
        builder: (context, state) {
          var cubit = BlocProvider.of<InvoiceCubit>(context);

          return Scaffold(
              appBar: AppBar(
                  backgroundColor: Color.fromRGBO(50, 103, 137, 1),
                  title: const Text("اضافة عميل")),
              body: SingleChildScrollView(
                child: SizedBox(
                  height: 400,
                  child: ListView.builder(
                    itemCount: cubit.settingsList.length,
                    itemBuilder: ((context, index) {
                      return Column(
                        children: [
                          CheckboxListTile(
                            value: 
                            cubit.settingsList.isEmpty
                                ? false
                                :(cubit.cc[index]==0?false:true),
                                //bool.fromEnvironment(cubit.settingsList[index]["settings_state"])  ,
                            onChanged: ((value) {
                              print(index);
                              cubit.updateSettings(state:value==false?0:1, name: "${cubit.settingsList[index]["settings"]}");
                              print(cubit.settingsList.toString());
                              cubit.change(value, index);
                              Navigator.pop(context);
                            }),
                            title:  Text(cubit.settingsList[index]["settings"].toString()),
                          ),
                          // CheckboxListTile(
                          //   value: cubit.settingsList.isEmpty
                          //       ? false
                          //       : cubit.editPrice,
                          //   onChanged: ((value) {
                          //     print(index);
                          //     cubit.updateSettings(state: value.toString(), name: "edit sale price");
                          //     print(cubit.settingsList.toString());
                          //     cubit.change(value, index);
                          //     Navigator.pop(context);
                          //   }),
                          //   title: const Text("تعديل سعر البيع"),
                          // ),
                          // CheckboxListTile(
                          //   value: cubit.checkBoxes[2],
                          //   onChanged: ((value) {
                          //     cubit.change(value,index);
                          //   }),
                          //   title: const Text("2"),
                          // ),
                          // CheckboxListTile(
                          //   value: cubit.checkBoxes[3],
                          //   onChanged: ((value) {
                          //     cubit.change(value,index);
                          //   }),
                          //   title: const Text("3"),
                          // ),
                          // CheckboxListTile(
                          //   value: cubit.checkBoxes[4],
                          //   onChanged: ((value) {
                          //     cubit.change(value,index);
                          //   }),
                          //   title: const Text("4"),
                          // ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.startFloat,
              floatingActionButton: Row(children: <Widget>[
                Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: SizedBox(
                      height: 70,
                      child: FittedBox(
                        child: FloatingActionButton(
                            backgroundColor: Color.fromRGBO(120, 166, 200, 1),
                            elevation: 20,
                            child: const Icon(
                              Icons.save,
                              size: 40,
                              color: Color.fromRGBO(233, 238, 244, 1),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            }),
                      ),
                    ))
              ]));
        });
  }
}

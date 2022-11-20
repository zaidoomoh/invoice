import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bill_screen.dart';
import 'cubit.dart';
import 'shared/components/components.dart';
import 'states.dart';

class AddClients extends StatefulWidget {
  const AddClients({super.key});

  @override
  State<AddClients> createState() => _AddClientsState();
}

class _AddClientsState extends State<AddClients> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InvoiceCubit, InvoiceStates>(
        listener: (context, state) {},
        builder: (context, state) {
          var cubit = BlocProvider.of<InvoiceCubit>(context);
          

          TextEditingController clientName = TextEditingController();
          TextEditingController phone = TextEditingController();
          return Scaffold(
              appBar: AppBar(
                  backgroundColor: Color.fromRGBO(50, 103, 137, 1),
                  title: const Text("اضافة عميل")),
              body: SingleChildScrollView(
                child: Form(
                  key:cubit.formkey,
                  
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Client Name',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            defaultTextFormFeild(
                              
                                warning: "يرجى ملئ الحقل",
                                color: Colors.black,
                                controller: clientName,
                                type: TextInputType.name,
                                onSubmit: () {},
                                onChange: () {},
                                label: "",
                                prefix: Icons.abc,
                                textInputFormatter:
                                    FilteringTextInputFormatter.deny(
                                        RegExp("[]")))
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Phone',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            defaultTextFormFeild(
                              
                                warning: "يرجى ملئ الحقل",
                                color: Colors.black,
                                controller: phone,
                                type: TextInputType.number,
                                onSubmit: () {},
                                onChange: () {},
                                label: "",
                                prefix: Icons.phone,
                                textInputFormatter:
                                    FilteringTextInputFormatter.allow(
                                        RegExp("[0-9]")))
                          ],
                        ),
                      ),
                    ],
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
                              
                              if (cubit.formkey.currentState!.validate()) {
                                
                                cubit.insertToClients(
                                    clientName: clientName.text,
                                    phoneNumber: phone.text);

                                Navigator.pop(context);
                                debugPrint(cubit.clients.length.toString());
                              }
                              else{debugPrint("SHITTTT");}
                            }),
                      ),
                    ))
              ]));
        });
  }
}

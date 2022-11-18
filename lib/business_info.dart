import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test1/bill_screen.dart';
import 'package:test1/shared/components/components.dart';

import 'cubit.dart';
import 'states.dart';

class BusinessInfo extends StatefulWidget {
  const BusinessInfo({super.key});

  @override
  State<BusinessInfo> createState() => _BusinessInfoState();
}

class _BusinessInfoState extends State<BusinessInfo> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InvoiceCubit, InvoiceStates>(
        listener: (context, state) {},
        builder: (context, state) {
          var cubit = BlocProvider.of<InvoiceCubit>(context);

          return Scaffold(
            appBar: AppBar(
                backgroundColor: Color.fromRGBO(50, 103, 137, 1),
                title: const Text("Business")),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Business Name',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        defaultTextFormFeild(
                          color: Colors.black,
                            controller: cubit.businessName,
                            type: TextInputType.name,
                            onSubmit: () {},
                            onChange: () {},
                            label: "",
                            prefix: Icons.abc,
                            textInputFormatter:
                                FilteringTextInputFormatter.deny(RegExp("[]")))
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Email Address',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        defaultTextFormFeild(
                          color: Colors.black,
                            controller: cubit.emailAddress,
                            type: TextInputType.name,
                            onSubmit: () {},
                            onChange: () {},
                            label: "",
                            prefix: Icons.email,
                            textInputFormatter:
                                FilteringTextInputFormatter.deny(RegExp("[]")))
                      ],
                    ),
                  ),
                  SizedBox(
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
                            color: Colors.black,
                            controller: cubit.phone,
                            type: TextInputType.phone,
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
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Billing Address',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        defaultTextFormFeild(
                          color: Colors.black,
                            controller: cubit.address,
                            type: TextInputType.name,
                            onSubmit: () {},
                            onChange: () {},
                            label: "",
                            prefix: Icons.place,
                            textInputFormatter:
                                FilteringTextInputFormatter.deny(RegExp("[]")))
                      ],
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.startFloat,
            floatingActionButton: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 70,
                    child: FittedBox(
                      child: FloatingActionButton(
                          backgroundColor:
                              Color.fromRGBO(120, 166, 200, 1), //78a6c8
                          elevation: 20,
                          child: const Icon(
                            Icons.add,
                            size: 40,
                            color: Color.fromRGBO(233, 238, 244, 1),
                          ),
                          onPressed: () {
                            //cubit.addBusiness();
                            Navigator.pop(context);

                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //       builder: (context) => const BillScreen()),
                            // );
                          }),
                    ),
                  ),
                )
              ],
            ),
          );
        });
  }
}

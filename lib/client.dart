import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test1/add_clients.dart';
import 'package:hive/hive.dart';
import 'cubit.dart';
import 'shared/components/components.dart';
import 'states.dart';

class Client extends StatefulWidget {
  const Client({super.key});

  @override
  State<Client> createState() => _ClientState();
}

class _ClientState extends State<Client> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InvoiceCubit, InvoiceStates>(
        listener: (context, state) {},
        builder: (context, state) {
          var cubit = BlocProvider.of<InvoiceCubit>(context);

          TextEditingController editClientName =TextEditingController
              ();
          TextEditingController editPhone =
              TextEditingController
              ();

          return Scaffold(
              appBar: AppBar(
                  actions: [
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: SizedBox(
                        width: 250,
                        height: 10,
                        child: TextFormField(
                          controller: cubit.clientsFilteringController,
                          onChanged: (value) {
                            cubit.filtering(value, "clients");
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
                        //     color: Color.fromARGB(255, 255, 255, 255),
                        //     controller: filtering,
                        //     type: TextInputType.name,
                        //     onSubmit: () {
                        // cubit.filtering(value);
                        //     },
                        //     onChange:
                        //     (value) {
                        //       cubit.filtering(value);
                        //     },
                        //     label: "Filtering",
                        //     prefix: Icons.search,
                        //     textInputFormatter: FilteringTextInputFormatter.deny(
                        //         RegExp(''))),
                      ),
                    ),
                  ],
                  backgroundColor: Color.fromRGBO(50, 103, 137, 1),
                  title: const Text("Clients")),
              body: cubit.filteredClients.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemBuilder: ((context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                  top: 15, left: 15, right: 15),
                              child: InkWell(
                                onTap: () {
                                  cubit.clientName(index);
                                 
                                  Navigator.pop(context);
                                },
                                onLongPress: () {
                                   
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
                                                    "اظهار الرقم"),
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  showDialog(
                                                    context: context,
                                                    builder: (BuildContext
                                                        context) {
                                                      return Wrap(
                                                        children: [
                                                          AlertDialog(
                                                            title: const Text(
                                                                "الرقم هو"),
                                                            content: Text(cubit
                                                                        .clients[
                                                                    index][
                                                                "phone_number"]),
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
                                              ListTile(
                                                title: const Text("تعديل"),
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
                                                                    "تعديل"),
                                                            content: Form(
                                                                child:
                                                                    Column(
                                                              children: [
                                                                defaultTextFormFeild(
                                                                  color: Colors
                                                                      .black,
                                                                  controller:
                                                                      editClientName,
                                                                  type: TextInputType
                                                                      .name,
                                                                  label:
                                                                      "Name",
                                                                  prefix: Icons
                                                                      .abc,
                                                                  onChange:
                                                                      () {},
                                                                  onSubmit:
                                                                      () {},
                                                                  textInputFormatter:
                                                                      FilteringTextInputFormatter.deny(
                                                                          r'[]'),
                                                                ),
                                                                const SizedBox(
                                                                  height:
                                                                      10,
                                                                ),
                                                                defaultTextFormFeild(
                                                                  color: Colors
                                                                      .black,
                                                                  controller:
                                                                      editPhone,
                                                                  type: TextInputType
                                                                      .number,
                                                                  label:
                                                                      "Phone",
                                                                  prefix: Icons
                                                                      .phone,
                                                                  textInputFormatter:
                                                                      FilteringTextInputFormatter.allow(
                                                                          RegExp(r'[0-9]')),
                                                                  onChange:
                                                                      () {},
                                                                  onSubmit:
                                                                      () {},
                                                                ),
                                                              ],
                                                            )),
                                                            actions: [
                                                              ElevatedButton(
                                                                style: ElevatedButton.styleFrom(
                                                                    backgroundColor: const Color.fromRGBO(
                                                                        120,
                                                                        166,
                                                                        200,
                                                                        1)),
                                                                child: const Text(
                                                                    'SAVE'),
                                                                onPressed:
                                                                    () {

                                                                  cubit.updateClients(
                                                                      number: editPhone
                                                                          .text.toString(),
                                                                      name: editClientName
                                                                          .text,
                                                                      id: cubit.clients[index]
                                                                          [
                                                                          'client_id']);
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
                                              )
                                            ]),
                                          ),
                                          actions: <Widget>[
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
                                child: Dismissible(
                                  key:
                                      UniqueKey(), //Key(cubit.clients[index].toString()),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CircleAvatar(
                                        radius: 30,
                                        child: Container(
                                            decoration: const BoxDecoration(
                                          image: DecorationImage(
                                              image: AssetImage(
                                                  "assets/user.png"),
                                              fit: BoxFit.fill),
                                        )),
                                      ),
                                      Text(
                                        cubit.filteredClients[index]
                                            ["client_name"],
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w900),
                                      )
                                    ],
                                  ),
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
                                                const Text('  هل تريد حذف هذا العميل '),
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
                                                       cubit.deleteFromDB(
                                        id: cubit.clients[index]["client_id"],
                                        tableName: "clients",
                                        columnName: "client_id"

                                        
                                        
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
                                ),
                              ),
                            );
                          }),
                          itemCount: cubit.filteredClients.length,
                        ),
                      )
                    ],
                  ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.startFloat,
              floatingActionButton: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: SizedBox(
                      height: 70,
                      child: FittedBox(
                        child: FloatingActionButton(
                            backgroundColor: Color.fromRGBO(120, 166, 200, 1),
                            elevation: 20,
                            child: const Icon(
                              Icons.add,
                              size: 40,
                              color: Color.fromRGBO(233, 238, 244, 1),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const AddClients()),
                              );
                              //debugPrint(cubit.clients[0]['cleint_name']);
                            }),
                      ),
                    ),
                  )
                ],
              ));
        });
  }
}

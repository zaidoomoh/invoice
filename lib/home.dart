import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test1/settings.dart';
import 'bill_screen.dart';
import 'cubit.dart';
import 'states.dart';

// void initState() {
//   super.initState();
//   futureAlbum = fetchAlbum2();
//   createDatabase();
// initializeDB(subjectsTable);
// initializeDB(billsTable);
// subjectsOnList();
// }

class home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InvoiceCubit, InvoiceStates>(
      listener: (context, state) {},
      builder: (context, state) {
        var cubit = BlocProvider.of<InvoiceCubit>(context);

        return MaterialApp(
          home: Stack(children: [
            Scaffold(
              resizeToAvoidBottomInset: false,
              body: cubit.screens[cubit.bottomBarIndx],
              // appBar: AppBar(
              //   actions: [
              //   SizedBox(
              //     width: 300,
              //     height: 10,
              //     child: TextFormField(
              //       onTap: () {
              //         showDatePicker(context: context, initialDate: DateTime.now(), firstDate:DateTime.parse("2021-01-01"), lastDate:  DateTime.now()).then((value) {
              //           cubit.historyFilteringController.text=formatOfDate.format(value!);
              //           cubit.filtering(value.toString(),"history");
              //         });
              //       },
              //       controller: cubit.historyFilteringController,
              //       onChanged: (value) {
              //         cubit.filtering(value.toString(),"history");
              //       },
              //       keyboardType: TextInputType.datetime,
              //       decoration: const InputDecoration(
              //         labelText: "Filtering",
              //         prefixIcon: Icon(Icons.search),
              //         border: OutlineInputBorder(
              //             borderSide: BorderSide(color: Colors.black)),
              //         prefixIconColor: Color.fromRGBO(120, 166, 200, 1),
              //       ),
              //     ),
              //   ),
              // ],
              //     backgroundColor: Color.fromRGBO(32, 67, 89, 1),
              //     title: Title(
              //         color: Colors.cyan, child: const Text('Bill maker'))),
              bottomNavigationBar: BottomAppBar(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                shape: const CircularNotchedRectangle(),
                child: BottomNavigationBar(
                    backgroundColor: const Color.fromRGBO(230, 92, 79, 1),
                    type: BottomNavigationBarType.fixed,
                    currentIndex: cubit.bottomBarIndx,
                    onTap: (index) {
                      cubit.addTotal();
                      cubit.calculateExpenses();
                      cubit.calculateDayTotal();
                      cubit.changeScreenIndex(index);
                      debugPrint(cubit.items.toString());
                    },
                    elevation: 30,
                    selectedFontSize: 15,
                    unselectedFontSize: 13,
                    iconSize: 32,
                    selectedItemColor: const Color.fromRGBO(32, 67, 89, 1),
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(
                          Icons.new_label,
                          color: Color.fromRGBO(32, 67, 89, 1),
                        ),
                        label: 'NEW',
                      ),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.history,
                              color: Color.fromRGBO(32, 67, 89, 1)),
                          label: 'HISTORY'),
                    ]),
              ),
              // drawer: Drawer(
              //   child: ListView(padding: EdgeInsets.zero, children: [
              //     InkWell(
              //       onDoubleTap: () {
              //         Navigator.push(
              //           context,
              //           MaterialPageRoute(
              //               builder: (context) => const Settings()),
              //         );
              //       },
              //       child: const DrawerHeader(
              //         decoration: BoxDecoration(
              //           image: DecorationImage(
              //               image: AssetImage("assets/icons-settings.png"),
              //               fit: BoxFit.none),
              //           color: Color.fromRGBO(230, 92, 79, 1),
              //         ),
              //         child: Padding(
              //           padding: EdgeInsets.only(top: 100),
              //           child: Text(
              //             'المزيد',
              //             style: TextStyle(
              //                 fontSize: 30,
              //                 fontWeight: FontWeight.bold,
              //                 color: Colors.white),
              //           ),
              //         ),
              //       ),
              //     ),
              //     Builder(builder: (context) {
              //       return Visibility(
              //         visible: cubit.settingsList.isEmpty ? false : cubit.s,
              //         child: ListTile(
              //             title: const Text(
              //               ' اضافة مواد  ',
              //               style: TextStyle(
              //                   fontSize: 20, fontWeight: FontWeight.bold),
              //             ),
              //             onTap: () {
              //               cubit.openDialog(context);
              //             }),
              //       );
              //     }),
              //     Builder(builder: (context) {
              //       return ListTile(
              //         title: const Text(
              //           '',
              //           style: TextStyle(
              //               fontSize: 20, fontWeight: FontWeight.bold),
              //         ),
              //         onTap: () async {},
              //       );
              //     }),
              //   ]),
              // ),
            ),
          ]),
        );
      },
    );
  }
}



// void createDatabase() async {
//   var database = await openDatabase(
//     ' todo.db ',
//     version: 1,
//     onCreate: (database, version) {
//       print(' database created ');
//       database.execute('').then((value) {
//         print(' table created ');
//       }).catchError((e){});
//     },
//     onOpen: (database) {
//       print(' database opened ');
//     },
//   );
// }

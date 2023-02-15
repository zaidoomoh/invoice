//flutter build apk --split-per-abi --no-sound-null-safety
//import 'package:firebase_core/firebase_core.dart';
import 'dart:async';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'cubit.dart';
import 'home.dart';
import 'shared/blpc_observer.dart';
import 'states.dart';
//import 'firebase_options.dart';

void main() async{
  Timer(const Duration(seconds: 5), () {
  debugPrint("Yeah, this line is printed after 1 minutes");
});
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  await Firebase.initializeApp();
  //options: DefaultFirebaseOptions.currentPlatform,

  Bloc.observer = MyBlocObserver();
  runApp(  const MaterialApp(debugShowCheckedModeBanner: false, home: Test()));
}

class Test extends StatefulWidget {
  const Test({Key? key}) : super(key: key);
  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  @override
  Widget build(BuildContext context) {
    
    return MultiBlocProvider(providers: [
      
       BlocProvider(
        create: (BuildContext context) => InvoiceCubit()..createDatabase()..calculateDayTotal()..loadData(),),
        // BlocProvider(
        // create: (BuildContext context) => InvoiceCubit()..getItems(),),
        


    ], child: 
      BlocConsumer<InvoiceCubit, InvoiceStates>(
          listener: (context, state) {},
          builder: (context, state) {
            
    
      return Sizer(

        builder: (BuildContext context, Orientation orientation, DeviceType deviceType) { return MaterialApp(
          
          //theme: ThemeData(fontFamily: "Antihero"),
          home: home()); },
        
      );
    }));
    
       
  }
}

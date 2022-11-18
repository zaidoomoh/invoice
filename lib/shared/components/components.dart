import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../bill_screen.dart';

       
Widget defaultButon({
  required double width,
  required double height,
  required Color background,
  required Function function,
  required String text,
  required double fontSize,
}) =>
    SizedBox(
      height:height ,
      width: width,
      child: ElevatedButton(
        
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            backgroundColor: MaterialStateProperty.all<Color>(background),
          ),
          onPressed: () {
            function();
          },
          child: Text(
            text,
            style:  TextStyle(
              fontSize:fontSize ,
            ),
          )),
    );
Widget defaultCard({
 required double smallConHeigt,
  required double smallConWedth,
   required double fontSize,
  required String text,
  required String text1,
  required Color fontColor,
  required Function onTap,
}) =>
    Padding(
      padding: const EdgeInsets.only(left: 10,right: 10,top: 10),
      child: SizedBox(
        height: smallConHeigt,
        width: smallConWedth,
        
        child: InkWell(
          onTap: () {
            onTap();
          },
          child: Card(
            color: Color.fromRGBO(233,238, 244, 1),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    
                    Text(
                      text,
                      style: TextStyle(
                        fontFamily: 'Antihero',
                          fontSize:fontSize ,
                          fontWeight: FontWeight.bold,
                          color: fontColor),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    
                      Text(
                        text1,
                        style:  TextStyle(
                          fontFamily: 'Dubai',
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                  ],
                ),
              )),
        ),
      ),
    );

Widget defaultTextFormFeild(
        {required TextEditingController controller,
        required TextInputType type,
        required Function onSubmit,
        required Function onChange,
        required String label,
        required IconData prefix,
        required Color color,
        String? validating,
        
         
        TextInputFormatter? textInputFormatter}) =>
    SizedBox(
        child: TextFormField(
          
      controller: controller,
      keyboardType: type,
      onFieldSubmitted: ((value) {
        onSubmit;
      }),
      onChanged: ((value) {
        onChange();
      }),
      validator:  (value){
                   if(value!.isEmpty){
                    return validating;
                   }
                   return null;
          },
      inputFormatters: <TextInputFormatter>[textInputFormatter!],
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(prefix),
        border:  OutlineInputBorder(
          borderSide: BorderSide(color:color )
        ),
        prefixIconColor: Color.fromRGBO(120, 166, 200, 1),
      ),
    ));

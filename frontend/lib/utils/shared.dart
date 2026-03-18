import 'package:flutter/material.dart';

class Shared {
  static void mySnackBar(String message, Color color, BuildContext context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,),
        
        margin: EdgeInsets.all(15.0,),

        behavior: SnackBarBehavior.floating,

        backgroundColor: color,

        duration: Duration(seconds: 2,),
      ),
    );
  }

  static const String baseUrl = 'http://localhost:8080';

  //Csak a stílus! Méretezéshez SizedBox-ba kell rakni!
  static CircularProgressIndicator myCircularProgressIndicator() {
    return CircularProgressIndicator(
      color: Colors.amber,
      backgroundColor: Colors.greenAccent,

      padding: EdgeInsetsGeometry.all(10.0,),

      strokeWidth: 5.0,
      strokeCap: StrokeCap.round,

      semanticsLabel: "Töltődés",
    );
  }

  static AppBar myAppBar(String titleText) {
    return AppBar(
      title: Text(
        titleText,

        style: TextStyle(
          color: Colors.red,

          fontSize: 34,

          fontWeight: FontWeight.bold,
        ),

      ),

      backgroundColor: Colors.green,

      elevation: 0.0,

      centerTitle: true,
    );
  }

  //1000 = 1 sec
  static const int animationDuration = 800;

  static RegExp onlyNumbers = RegExp(r'^\d*\.?\d*');
}
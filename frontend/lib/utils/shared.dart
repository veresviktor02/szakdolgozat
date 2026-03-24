import 'package:flutter/material.dart';

class Shared {
  static void mySnackBar(String message, Color color, BuildContext context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,),
        
        margin: const EdgeInsets.all(15.0,),

        behavior: SnackBarBehavior.floating,

        backgroundColor: color,

        duration: const Duration(seconds: 2,),
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

        overflow: TextOverflow.fade,

        style: const TextStyle(
          color: Colors.black,

          fontSize: 34,

          fontWeight: FontWeight.bold,
        ),
      ),

      backgroundColor: Colors.green[700],

      shadowColor: Colors.green[300],

      elevation: 0.0,

      centerTitle: true,
    );
  }

  //1000 = 1 sec
  static const int animationDuration = 800;

  static RegExp onlyNumbers = RegExp(r'^\d*\.?\d*');

  static const Color backgroundColor = Colors.white;

  static ButtonStyle myButtonStyle = ButtonStyle(
    backgroundColor: WidgetStateProperty.all(Colors.greenAccent[100]),
    foregroundColor: WidgetStateProperty.all(Colors.green[900]),
    shadowColor: WidgetStateProperty.all(Colors.greenAccent),

    textStyle: WidgetStateProperty.all(
      const TextStyle(
        fontWeight: FontWeight.bold,

        fontSize: 15,
      ),
    ),
  );
}
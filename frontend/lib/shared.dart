import 'package:flutter/material.dart';

class Shared {
  static void mySnackBar(String message, Color color, BuildContext context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,),

        backgroundColor: color,

        duration: Duration(seconds: 2,),
      ),
    );
  }

  static String baseUrl = 'http://localhost:8080';
}
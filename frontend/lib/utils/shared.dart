import 'package:flutter/material.dart';

class Shared {
  //WIDGETEK
  /////////////////////////////////////////////////////////////////////////////
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

  //Csak a stílus! Méretezéshez SizedBox-ba kell rakni!
  static CircularProgressIndicator myCircularProgressIndicator() {
    return const CircularProgressIndicator(
      color: Colors.amber,
      backgroundColor: Colors.greenAccent,

      padding: EdgeInsetsGeometry.all(10.0,),

      strokeWidth: 5.0,
      strokeCap: StrokeCap.round,

      semanticsLabel: 'Töltődés',
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

  //STÍLUSOK
  /////////////////////////////////////////////////////////////////////////////

  static ButtonStyle myButtonStyle = ButtonStyle(
    backgroundColor: WidgetStateProperty.all(Colors.greenAccent[100]),
    foregroundColor: WidgetStateProperty.all(Colors.green[900]),
    shadowColor: WidgetStateProperty.all(Colors.greenAccent),

    textStyle: WidgetStateProperty.all(
      const TextStyle(
        fontSize: 15,

        fontWeight: FontWeight.bold,
      ),
    ),
  );

  static InputDecoration inputDecoration(labelText, hintText) {
    return InputDecoration(
      filled: true,
      fillColor: Shared.textFieldFillColor,

      border: OutlineInputBorder(),

      contentPadding: const EdgeInsets.all(15.0,),

      labelText: labelText,
      hintText: hintText,

      hintStyle: const TextStyle(
        color: Colors.black,

        fontSize: 14,
      ),

      labelStyle: const TextStyle(
        color: Colors.black,

        fontSize: 15,
      ),
    );
  }

  //SZÍNEK
  /////////////////////////////////////////////////////////////////////////////

  static final Color backgroundColor = Colors.greenAccent[700]!;

  static final Color dropdownColor = Colors.greenAccent[400]!;

  static final Color textFieldFillColor = Colors.greenAccent[400]!;

  static final Color boxDecorationColor = Colors.greenAccent[200]!;

  static final Color circularPercentIndicatorBackgroundColor = Colors.grey[300]!;

  static final Color cardColor = Colors.lightGreenAccent;

  static final Color cardShadowColor = Colors.greenAccent;

  /////////////////////////////////////////////////////////////////////////////

  //ÁLLANDÓ VÁLTOZÓK
  /////////////////////////////////////////////////////////////////////////////
  static const String baseUrl = 'http://localhost:8080';

  static const double pageWidth = 600;

  //1000 = 1 sec
  static const int animationDuration = 800;

  /////////////////////////////////////////////////////////////////////////////

  //MEGJELENÉS
  /////////////////////////////////////////////////////////////////////////////
  static final RegExp onlyNumbers = RegExp(r'^\d*\.?\d*');

  static String format(double value) => value.toStringAsFixed(1);
  /////////////////////////////////////////////////////////////////////////////
}
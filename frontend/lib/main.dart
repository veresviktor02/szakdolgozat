import 'package:flutter/material.dart';

import 'package:flutter_application/route_generator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        //TODO: style (fontFamily, stb.)

        scrollbarTheme: ScrollbarThemeData(
          thumbColor: WidgetStateProperty.all(Colors.greenAccent),

          thickness: WidgetStateProperty.all(10),

          radius: const Radius.circular(8),
        ),
      ),

      initialRoute: '/',
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}

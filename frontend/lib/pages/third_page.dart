import 'package:flutter/material.dart';

class ThirdPage extends StatefulWidget {

  const ThirdPage({super.key});

  @override
  State<ThirdPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<ThirdPage> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: appbar(),

      backgroundColor: Colors.white,

      body: Column(
          children: [
            Text('Ez a harmadik lap '),
          ]
      ),
    );
  }

}

AppBar appbar() {
  return AppBar(

    title: Text(
      'Harmadik oldal',
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
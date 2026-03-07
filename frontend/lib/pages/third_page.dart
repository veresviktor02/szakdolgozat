import 'package:flutter/material.dart';

import '../utils/shared.dart';

class ThirdPage extends StatefulWidget {

  const ThirdPage({super.key});

  @override
  State<ThirdPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<ThirdPage> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: Shared.myAppBar('Harmadik oldal',),

      backgroundColor: Colors.white,

      body: Column(
          children: [
            Text('Ez a harmadik lap '),
          ]
      ),
    );
  }

}
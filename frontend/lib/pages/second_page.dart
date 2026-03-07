import 'package:flutter/material.dart';

import '../utils/shared.dart';

class SecondPage extends StatefulWidget {
  //Ezt adta át az előző oldal!
  final String data;

  const SecondPage({
    super.key,
    required this.data
  });

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Shared.myAppBar('Második oldal',),

      backgroundColor: Colors.white,

      body: Column(
        children: [
          //Így kell meghívni!
          Text('Ez a második lap, átadott paraméter: ${widget.data}'),
        ]
      ),
    );
  }
}
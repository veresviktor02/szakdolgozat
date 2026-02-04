import 'package:flutter/material.dart';

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
      appBar: appbar(),

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

AppBar appbar() {
  return AppBar(

    title: Text(
      'Második oldal',
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

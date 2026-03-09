import 'package:flutter/material.dart';

import '../utils/shared.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({
    super.key,
  });

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {

  @override
  void initState() {
    super.initState();

  }

  @override
  void dispose() {

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Shared.myAppBar('Ranglista',),

      backgroundColor: Colors.white,

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0,),

          child: Column(
            children: [
              Text('Ranglista oldal',),
            ],
          ),
        ),
      ),
    );
  }

//////////////////////////////////////////////////////////////////////////
////////////////////Itt ér véget a _SettingsPageState!////////////////////
//////////////////////////////////////////////////////////////////////////
}
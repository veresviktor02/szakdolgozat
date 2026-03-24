import 'package:flutter/material.dart';

import '/day/day_service.dart';

import '/user/user_model.dart';

import '/utils/shared.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key,});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  final dayService = DayService();

  late Future<List<User>> mostActiveUsersFuture;

  @override
  void initState() {
    super.initState();

    mostActiveUsersFuture = dayService.getMostActiveUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Shared.myAppBar('Ranglista',),

      backgroundColor: Shared.backgroundColor,

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0,),

          child: Column(
            children: [
              const Text(
                'Ranglista oldal',

                style: TextStyle(fontSize: 32,),
              ),

              const SizedBox(height: 20,),

              const Text(
                'Itt találod a legaktívabb felhasználókat.',

                style: TextStyle(fontSize: 26,),
              ),

              const SizedBox(height: 10,),

              Expanded(
                child: FutureBuilder<List<User>>(
                  future: mostActiveUsersFuture,

                  builder: (context, userSnapshot) {
                    if(userSnapshot.connectionState == ConnectionState.waiting) {
                      return Shared.myCircularProgressIndicator();
                    }
                    if(userSnapshot.hasError) {
                      return Text('Hiba történt: ${userSnapshot.error}',);
                    }

                    final users = userSnapshot.data ?? [];

                    if(users.isEmpty) {
                      return const Center(
                        child: Text(
                          'Nincs megjeleníthető felhasználó.',

                          style: TextStyle(fontSize: 18,),
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: users.length,

                      separatorBuilder: (_, __) => const SizedBox(height: 12,),

                      itemBuilder: (context, index) {
                        final user = users[index];

                        return Container(
                          padding: const EdgeInsets.all(15.0,),

                          decoration: BoxDecoration(
                            color: colorOfBestUsers(index),

                            border: Border.all(color: Colors.grey.shade300,),

                            borderRadius: BorderRadius.circular(12),
                          ),

                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 22,

                                backgroundColor: Colors.blue,

                                child: Text(
                                  '${index + 1}',

                                  style: const TextStyle(
                                    color: Colors.white,

                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 10,),

                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                                  children: [
                                    Text(
                                      user.name,

                                      style: const TextStyle(
                                        fontSize: 20,

                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),

                                    FutureBuilder<int>(
                                      future: dayService.getCurrentActivityStreak(user.id),

                                      builder: (context, streakSnapshot) {
                                        if(streakSnapshot.connectionState == ConnectionState.waiting) {
                                          return Shared.myCircularProgressIndicator();
                                        }
                                        if(streakSnapshot.hasError) {
                                          return Text('Hiba: ${streakSnapshot.error}');
                                        }
                                        return Text(
                                          '🔥 ${streakSnapshot.data} nap',

                                          style: const TextStyle(
                                            fontSize: 20,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color colorOfBestUsers(int index) {
    switch(index) {
      case 0:
        return Colors.orangeAccent.shade200;
      case 1:
        return Colors.grey.shade400;
      case 2:
        return Colors.brown.shade200;
    }

    return Colors.grey.shade50;
  }

//////////////////////////////////////////////////////////////////////////
////////////////////Itt ér véget a _SettingsPageState!////////////////////
//////////////////////////////////////////////////////////////////////////
}
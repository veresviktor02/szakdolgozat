import 'package:flutter/material.dart';

import '../user/user_model.dart';

import '../user/user_service.dart';
import '../user/user_type.dart';
import '../utils/shared.dart';

class SettingsPage extends StatefulWidget {
  final int userId;

  const SettingsPage({
    super.key,

    required this.userId,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final UserService userService = UserService();

  User? user;
  bool isLoading = true;
  bool isSaving = false;

  late final TextEditingController nameController;
  late final TextEditingController weightController;
  late final TextEditingController heightController;

  final TextEditingController calculationController = TextEditingController();

  UserType userType = UserType.FREE;
  bool differentDays = false;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController();
    weightController = TextEditingController();
    heightController = TextEditingController();

    refreshPage();
  }

  Future<void> refreshPage() async {
    setState(() {
      isLoading = true;
    });

    try {
      final loadedUser = await userService.getUserById(widget.userId);

      if(!mounted) {
        return;
      }

      setState(() {
        user = loadedUser;

        nameController.text = loadedUser.name;
        weightController.text = loadedUser.weight.toString();
        heightController.text = loadedUser.height.toString();

        userType = loadedUser.userType;
        differentDays = loadedUser.differentDays;

        isLoading = false;
      });
    } catch (error) {
      if(!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
      });

      Shared.mySnackBar(
        'Hiba a felhasználó betöltésekor: $error',
        Colors.red,
        context,
      );
    }
  }

  Future<void> saveUser() async {
    if (user == null) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final updatedUser = User(
        id: user!.id,
        name: nameController.text,
        weight: double.parse(weightController.text),
        height: double.parse(heightController.text),
        userType: userType,
        differentDays: differentDays,
        dailyTarget: user!.dailyTarget,
      );

      await userService.updateUserById(widget.userId, updatedUser);

      if(!mounted) {
        return;
      }

      Shared.mySnackBar(
        'Adatok sikeresen mentve!',
        Colors.green,
        context,
      );

    } catch (error) {
      if(!mounted) {
        return;
      }

      Shared.mySnackBar(
        'Hiba mentés közben: $error',
        Colors.red,
        context,
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    weightController.dispose();
    heightController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Shared.myAppBar('Beállítások',),

      backgroundColor: Colors.white,

      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,

          children: [
            Container(
              width: 300,
              height: 350,

              padding: const EdgeInsets.all(15.0,),
              margin: const EdgeInsets.all(40.0,),

              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent,),
              ),

              child: Column(
                children: [
                  TextField(
                    controller: nameController,

                    decoration: const InputDecoration(
                      labelText: 'Név',

                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 15,),

                  TextField(
                    controller: weightController,

                    keyboardType: TextInputType.number,

                    decoration: const InputDecoration(
                      labelText: 'Testtömeg (kg)',

                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 15,),

                  TextField(
                    controller: heightController,

                    keyboardType: TextInputType.number,

                    decoration: const InputDecoration(
                      labelText: 'Magasság (cm)',

                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 10,),

                  SwitchListTile(
                    title: const Text('Különböző napok',),

                    value: differentDays,

                    onChanged: (value) {
                      setState(() {
                        differentDays = value;
                      });
                    },
                  ),

                  //TODO: kuponkód, adatvalidáció!

                  const SizedBox(height: 10,),

                  ElevatedButton(
                    onPressed: isSaving ? null : saveUser,

                    child: isSaving
                        ? Shared.myCircularProgressIndicator()
                        : const Text('Mentés',),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20,),

            Container(
              width: 400,
              height: 550,

              padding: const EdgeInsets.all(15.0,),
              margin: const EdgeInsets.all(40.0,),

              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent,),
              ),

              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 20.0,),

                    child: Text(
                        'Napi kalóriaszükséglet kiszámítása',

                      style: TextStyle(
                        fontSize: 18,

                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15,),

                  TextField(
                    //controller: weightController,

                    decoration: const InputDecoration(
                      labelText: 'Nem',

                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 15,),

                  TextField(
                    //controller: nameController,

                    keyboardType: TextInputType.number,

                    decoration: const InputDecoration(
                      labelText: 'Életkor',

                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 15,),

                  TextField(
                    controller: weightController,

                    keyboardType: TextInputType.number,

                    decoration: const InputDecoration(
                      labelText: 'Testtömeg (kg)',

                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 15,),

                  TextField(
                    controller: heightController,

                    keyboardType: TextInputType.number,

                    decoration: const InputDecoration(
                      labelText: 'Magasság (cm)',

                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 15,),

                  TextField(
                    //controller: weightController,

                    decoration: const InputDecoration(
                      labelText: 'Aktivitási szint',

                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 10,),

                  ElevatedButton(
                    onPressed: () {
                      calculateDailyCalories();
                    },

                    child: Text('Kiszámítás'),),

                  const SizedBox(height: 15,),

                  TextField(
                    controller: calculationController,

                    readOnly: true,

                    decoration: const InputDecoration(
                      labelText: 'Napi kalória (Kcal)',

                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  //BMR Mifflin-St Jeor
  //For men:
  //BMR = 10W + 6.25H - 5A + 5
  //For women:
  //BMR = 10W + 6.25H - 5A - 161

  //Activity level multiplier:
  //Sedentary	- 1.2	- little or no exercise
  //Lightly active - 1.375 - light exercise 1–3 days/week
  //Moderately active -	1.55 - exercise 3–5 days/week
  //Very active	- 1.725 - hard exercise 6–7 days/week
  //Extremely active - 1.9 - athlete / physical job
  void calculateDailyCalories() {
    //TODO User bővítése.
    var age = 22;
    var gender = 'Men';
    var activityLevel = 'BMR';

    double calculatedCalories = double.parse(weightController.text) * 10 + double.parse(heightController.text) * 6.25 - 5 * age + 5;

    calculationController.text = calculatedCalories.toString();
  }

//////////////////////////////////////////////////////////////////////////
////////////////////Itt ér véget a _SettingsPageState!////////////////////
//////////////////////////////////////////////////////////////////////////
}
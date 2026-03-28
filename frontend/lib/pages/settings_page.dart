import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/user/user_model.dart';
import '/user/user_service.dart';
import '/user/user_type.dart';

import '/utils/shared.dart';

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

  //Kontrollerek
  late final TextEditingController nameController;
  late final TextEditingController weightController;
  late final TextEditingController heightController;
  late final TextEditingController genderController;
  late final TextEditingController ageController;
  late final TextEditingController activityController;

  final TextEditingController calculationController = TextEditingController();
  //

  final List<String> genders = ['Férfi', 'Nő', 'Egyéb',];

  final List<String> activityLevels = [
    'Ülőmunka (Kevés vagy semmi mozgás)',
    'Enyhe aktivitás (heti 1-3 edzés)',
    'Közepes aktivitás (heti 4-5 edzés)',
    'Nagy aktivitás (szinte mindennapi edzés)',
    'Extrém aktivitás (atléta / fizikai munka)',
  ];

  String? selectedGender;
  String? selectedActivityLevel;

  UserType userType = UserType.FREE;
  bool differentDays = false;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController();
    weightController = TextEditingController();
    heightController = TextEditingController();
    genderController = TextEditingController();
    ageController = TextEditingController();
    activityController = TextEditingController();

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
        foods: [], //TODO
        days: [], //TODO
        measurementUnits: []//TODO
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
    genderController.dispose();
    ageController.dispose();
    activityController.dispose();
    calculationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Shared.myAppBar('Beállítások',),

      backgroundColor: Shared.backgroundColor,

      //TODO reszponzívvá alakítani!
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,

          children: [
            Container(
              width: 400,
              height: 700,

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

                    style: Shared.myButtonStyle,

                    child: isSaving
                        ? Shared.myCircularProgressIndicator()
                        : const Text('Mentés',),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20,),

            Container(
              width: 400,
              height: 700,

              padding: const EdgeInsets.all(15.0,),
              margin: const EdgeInsets.all(40.0,),

              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent,),
              ),

              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 20.0,),

                    child: Text(
                      'Napi kalóriaszükséglet kiszámítása',

                      style: TextStyle(
                        fontSize: 18,

                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),

                  _dropdown(
                    selectedGender,
                    'Nem',
                    genders,
                    (value) {
                      setState(() {
                        selectedGender = value;
                      });
                    },
                  ),

                  _dropdown(
                    selectedActivityLevel,
                    'Aktivitási szint',
                    activityLevels,
                    (value) {
                      setState(() {
                        selectedActivityLevel = value;
                      });
                    },
                  ),

                  const SizedBox(height: 7.5,),

                  TextField(
                    controller: ageController,

                    keyboardType: TextInputType.number,

                    maxLength: 2,

                    inputFormatters: [
                      FilteringTextInputFormatter.allow(Shared.onlyNumbers,),
                    ],

                    decoration: const InputDecoration(
                      labelText: 'Életkor',

                      //Nem jelenik meg számláló (0/2, 1/2).
                      counterText: '',

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

                  ElevatedButton(
                    onPressed: () {
                      calculateDailyCalories();
                    },

                    style: Shared.myButtonStyle,

                    child: const Text('Kiszámítás',),
                  ),

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

  //https://www.calculator.net/bmr-calculator.html
  void calculateDailyCalories() {
    double calculatedCalories = 0;

    //BMR Mifflin-St Jeor
    //For men:
    //BMR = 10W + 6.25H - 5A + 5
    //For women:
    //BMR = 10W + 6.25H - 5A - 161
    switch(selectedGender) {
      case 'Férfi':
        calculatedCalories = double.parse(weightController.text) * 10 +
            double.parse(heightController.text) * 6.25 -
            5 * double.parse(ageController.text) +
            5;
      default:
        calculatedCalories = double.parse(weightController.text) * 10 +
        double.parse(heightController.text) * 6.25 -
        161;
    }

    //Activity level multiplier:
    //Sedentary	- 1.2	- little or no exercise
    //Lightly active - 1.375 - light exercise 1–3 days/week
    //Moderately active -	1.55 - exercise 3–5 days/week
    //Very active	- 1.725 - hard exercise 6–7 days/week
    //Extremely active - 1.9 - athlete / physical job
    switch(selectedActivityLevel) {
      case 'Ülőmunka (Kevés vagy semmi mozgás)':
        calculatedCalories = calculatedCalories * 1.2;
      case 'Enyhe aktivitás (heti 1-3 edzés)':
        calculatedCalories = calculatedCalories * 1.375;
      case 'Közepes aktivitás (heti 4-5 edzés)':
        calculatedCalories = calculatedCalories * 1.55;
      case 'Nagy aktivitás (szinte mindennapi edzés)':
        calculatedCalories = calculatedCalories * 1.725;
      default:
        calculatedCalories = calculatedCalories * 1.9;
    }

    calculationController.text = Shared.format(calculatedCalories);
  }

  Widget _dropdown(selectedItem, labelText, List<String> itemList, onChanged) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 7.5, 0.0, 7.5,),

      child: DropdownButtonFormField<String>(
        value: selectedItem,

        decoration: InputDecoration(
          labelText: labelText,

          border: OutlineInputBorder(),
        ),

        items: itemList.map((item) {
          return DropdownMenuItem(
            value: item,

            child: Text(item,),
          );
        }).toList(),

        onChanged: onChanged,

        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Válassz egy elemet!';
          }

          return null;
        },
      ),
    );
  }

//////////////////////////////////////////////////////////////////////////
////////////////////Itt ér véget a _SettingsPageState!////////////////////
//////////////////////////////////////////////////////////////////////////
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../user/user_service.dart';
import '../user/user_type.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final UserService userService = UserService();

  bool differentDays = false;

  UserType userType = UserType.FREE;

  //Beviteli mezők
  final nameController = TextEditingController();
  final weightController = TextEditingController();
  final heightController = TextEditingController();
  final couponController = TextEditingController();
  //

  //7x4 TextEditingController
  late final List<List<TextEditingController>> controllers;

  //7x4 double (kcal, fat, carb, protein)
  //NEM lehet List<KcalAndNutrients>, mert final minden field, nem lehet értéket adni!
  late final List<List<double>> dailyTargetValues;

  @override
  void initState() {
    super.initState();

    controllers = List.generate(
      7, (_) => List.generate(
        4, (_) => TextEditingController(),
      ),
    );

    dailyTargetValues = List.generate(
      7,(_) => List.generate(
        4, (_) => 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appbar(),

      backgroundColor: Colors.white,

      body: SizedBox(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              _greeting(),

              const SizedBox(height: 10,),

              _fillData(),

              const SizedBox(height: 10,),

              _navigateToHomePage(context,),

              const SizedBox(height: 10,),

              _fillDailyTarget(),

              const SizedBox(height: 10,),

              _saveUserButton(),
            ],


          ),
        ),
      ),
    );
  }

  Center _fillData() {
    return Center(
      child: SizedBox(
        width: 400,
        height: 600,

        child: Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.blueAccent,),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [
              _userDataInput(
                nameController,
                'Név:',
                'Név',
                FilteringTextInputFormatter.allow(RegExp(r'.*'),),
              ),

              const SizedBox(height: 10,),

              _userDataInput(
                weightController,
                'Testtömeg (kg):',
                'Testtömeg',
                FilteringTextInputFormatter.allow(RegExp(r'[\d\.]')),
              ),

              const SizedBox(height: 10,),

              _userDataInput(
                heightController,
                'Magasság (cm):',
                'Magasság',
                FilteringTextInputFormatter.allow(RegExp(r'[\d\.]')),
              ),

              const SizedBox(height: 10,),

              _userDataInput(
                couponController,
                'Kuponkód:',
                'Kuponkód',
                FilteringTextInputFormatter.allow(RegExp(r'.*'),),
              ),

              const SizedBox(height: 10,),

              _differentDaysSwitch(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> sendUser() async {
    //PREMIUM kuponkóddal prémium felhasználói szint!
    if(couponController.text == 'PREMIUM') {
      userType = UserType.PREMIUM;
    }

    //Nem jogosult a prémium funkcióra az ingyenes felhasználó!
    if(userType == UserType.FREE && differentDays) {
      _mySnackBar(
        'FREE felhasználó (Név: ${nameController.text}) nem jogosult különböző napokra!',
        Colors.red,
      );

      throw Exception(
        'FREE felhasználó (Név: ${nameController.text}) nem jogosult különböző napokra!',
      );
    }

    _mySnackBar(
      'Felhasználó sikeresen létrehozva! (Név: ${nameController.text})',
      Colors.green,
    );

    await userService.sendUser(
      nameController.text,
      double.parse(heightController.text),
      double.parse(weightController.text),
      userType,
      differentDays,
    );
  }

  ElevatedButton _saveUserButton() {
    return ElevatedButton(
      onPressed: () {
        print('Regisztrációs gomb lenyomva! (User elmentése.)',);

        sendUser();
      },

      child: const Text('User mentése',),
    );
  }

  void _mySnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),

        backgroundColor: color,

        duration: Duration(seconds: 2),
      ),
    );
  }

  SwitchListTile _differentDaysSwitch() {
    return SwitchListTile(
      title: Text(
        'Különböző napok (csak PREMIUM-oknak!)',

        style: TextStyle(
          fontSize: 14,
        ),
      ),

      value: differentDays,

      onChanged: (bool value) {
        //Jó a kuponkód ÉS még nincs bekapcsolva.
        if(couponController.text == 'PREMIUM' && value) {
          _mySnackBar(
            'Milyen érzés PREMIUM ügyfélnek lenni? szerintünk nagyon jó!',
            Colors.green,
          );

          setState(() => differentDays = value);
        }
        //Be van kapcsolva (és kikapcsolom).
        //Azért kell, mert ha a PREMIUM kóddal bekapcsolja,
        //akkor a kód törlése után nem tudja kikapcsolni!
        else if(!value) {
          _mySnackBar(
            'Biztos kikapcsolod? Ez egy nagyon jó funkció!',
            Colors.orangeAccent,
          );

          //Ha átváltja a felhasználó különböző napokra és elmenti az adatokat,
          //akkor a visszaváltásnál megőrződnek a volt értékek!
          for(int day = 1; day < 7; day++) {
            for(int nutrient = 0; nutrient < 4; nutrient++) {
              dailyTargetValues[day][nutrient] = 0.0;
            }
          }

          setState(() => differentDays = value);
        }
        //Rossz a kuponkód ÉS ki van kapcsolva.
        else {
          _mySnackBar(
            'Csak PREMIUM felhasználóknak! Te nem vagy az!',
            Colors.red,
          );
        }
      },
    );
  }

  final List<String> weekdays = [
    'Hétfő',
    'Kedd',
    'Szerda',
    'Csütörtök',
    'Péntek',
    'Szombat',
    'Vasárnap',
  ];

  Widget _fillDailyTarget() {
    if(differentDays) {
      return Center(
        child: Container(
          width: 500,
          height: 700,

          padding: const EdgeInsets.all(10),

          decoration: BoxDecoration(
            border: Border.all(color: Colors.blueAccent),
          ),

          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: 7,

                  itemBuilder: (context, dayIndex) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.all(5),

                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueAccent),
                      ),

                      child: Row(
                        children: [
                          SizedBox(
                            width: 100,

                            child: Text(
                              weekdays[dayIndex],

                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),

                          _buildNutrientField(
                            'Kcal',
                            controllers[dayIndex][0],
                            (val) => dailyTargetValues[dayIndex][0] = double.tryParse(val)!,
                          ),

                          _buildNutrientField(
                            'Zsír',
                            controllers[dayIndex][1],
                            (val) => dailyTargetValues[dayIndex][1] = double.tryParse(val)!,
                          ),

                          _buildNutrientField(
                            'Szénhidrát',
                            controllers[dayIndex][2],
                            (val) => dailyTargetValues[dayIndex][2] = double.tryParse(val)!,
                          ),

                          _buildNutrientField(
                            'Fehérje',
                            controllers[dayIndex][3],
                            (val) => dailyTargetValues[dayIndex][3] = double.tryParse(val)!,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              ElevatedButton(
                onPressed: () {
                  setState(() {
                    print('Napi célok (differentDays == true):',);

                    for(int i = 0; i < 7; i++) {
                      print('${weekdays[i]}: ${dailyTargetValues[i]}',);
                    }
                  });
                },

                child: const Text('Mentés a napi célhoz',),
              ),
            ],
          ),
        ),
      );
    }

    return Center(
      child: Container(
        width: 500,
        height: 700,

        padding: const EdgeInsets.all(10),

        decoration: BoxDecoration(
          border: Border.all(color: Colors.blueAccent),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,

          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),

              child: Text(
                'Minden napra ugyannyi tápanyagot tudsz beálllítani! \n'
                'Ha nem tetszik, használd a PREMIUM kódot!',

                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(height: 20,),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                _buildNutrientField(
                  'Kcal',
                  controllers[0][0],
                  (val) {
                    for(int day = 0; day < 7; day++) {
                      dailyTargetValues[day][0] = double.tryParse(val)!;
                      print('Kcal ciklus változó: ${day} - Kcal értéke: ${dailyTargetValues[day][0]}',);
                    }
                  }
                ),

                _buildNutrientField(
                  'zsír',
                  controllers[0][1],
                  (val) {
                    for(int day = 0; day < 7; day++) {
                      dailyTargetValues[day][1] = double.tryParse(val)!;
                    }
                  }
                ),

                _buildNutrientField(
                  'Szénhidrát',
                  controllers[0][2],
                  (val) {
                    for(int day = 0; day < 7; day++) {
                      dailyTargetValues[day][2] = double.tryParse(val)!;
                    }
                  }
                ),

                _buildNutrientField(
                  'Fehérje',
                  controllers[0][3],
                  (val) {
                    for(int day = 0; day < 7; day++) {
                      dailyTargetValues[day][3] = double.tryParse(val)!;
                    }
                  }
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),

              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    print('Napi célok (differentDays == false):',);

                    for(int i = 0; i < 7; i++) {
                      print('${weekdays[i]}: ${dailyTargetValues[i]}',);
                    }
                  });
                },

                child: const Text('Mentés a napi célhoz',),
              ),
            ),
          ],
        ),
      )
    );
  }

  Widget _buildNutrientField(
      String label,
      TextEditingController controller,
      Function(String) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),

      child: Column(
        children: [
          Text(label),

          SizedBox(
            width: 80,

            child: TextField(
              keyboardType: TextInputType.number,

              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,

                contentPadding: EdgeInsets.all(10),

                hintText: '0',

                hintStyle: TextStyle(
                  color: Colors.grey,

                  fontSize: 14,
                ),
              ),

              onChanged: onChanged,

              controller: controller,
            ),
          ),
        ],
      ),
    );
  }

}

SizedBox _userDataInput(
    TextEditingController controller,
    String labelText,
    String hintText,
    FilteringTextInputFormatter format,
    ) {
  return SizedBox(
    child: Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent),
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,

        children: [
          SizedBox(
            width: 150,

            child: Text(labelText,),
          ),

          const SizedBox(width: 10,),

          Container(
            width: 140,
            height: 100,

            alignment: Alignment.center,

            child: TextField(
              controller: controller,


              inputFormatters: [
                format
              ],

              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,

                contentPadding: EdgeInsets.all(15),

                hintText: hintText,

                hintStyle: TextStyle(
                  color: Colors.grey,

                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Padding _greeting() {
  return Padding(
    padding: const EdgeInsets.all(8.0),

    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,

      children: [
        Text(
          'Ez a bejelentkezési oldal. Kérlek, töltsd ki az alábbi adatokat a kezdéshez!',

          style: TextStyle(
            fontSize: 30,
          ),
        ),
      ],
    ),
  );
}

ElevatedButton _navigateToHomePage(BuildContext context,) {
  return ElevatedButton(
      onPressed: () {
        print('Gomb lenyomva! (Home oldal gombja)',);

        Navigator.of(context).pushNamed(
          '/home',
        );
      },

      child: const Text('Home Page'),
  );
}

AppBar _appbar() {
  return AppBar(

    title: Text(
      'Üdvözöllek a Kalóriaszámláló alkalmazásban!',

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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_application/food/kcal_and_nutrients_model.dart';

import '../coupon/coupon_service.dart';
import '../coupon/coupon_status.dart';

import '../utils/my_calendar.dart';
import '../utils/shared.dart';

import '../user/user_model.dart';
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

  User? tempUser;

  //Beviteli mezők
  final nameController = TextEditingController();
  final weightController = TextEditingController();
  final heightController = TextEditingController();
  final couponController = TextEditingController();
  //

  //Kupon check
  final CouponService couponService = CouponService();

  bool couponChecking = false;
  bool isCouponValid = false;
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
  void dispose() {
    super.dispose();

    nameController.dispose();
    weightController.dispose();
    heightController.dispose();
    couponController.dispose();

    for(int days = 0; days < 7; days++) {
      for(int nutrient = 0; nutrient < 4; nutrient++) {
        controllers[days][nutrient].dispose();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Shared.myAppBar('Üdvözöllek a Kalóriaszámláló alkalmazásban!',),

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

              _fillDailyTarget(),

              const SizedBox(height: 10,),

              _saveUserButton(),

              _navigateToHomePage(context,),

              _navigateUserToHomePage(context,),
            ],


          ),
        ),
      ),
    );
  }

  Future<void> validateCouponCode() async {
    final couponCode = couponController.text.trim();

    if(couponCode.isEmpty) {
      Shared.mySnackBar(
        'Adj meg egy kuponkódot!',
        Colors.blueAccent,
        context,
      );

      setState(() {
        isCouponValid = false;
      });

      return;
    }

    setState(() {
      couponChecking = true;
    });

    try {
      final couponStatus = await couponService.validateCoupon(couponCode);

      if(!mounted) {
        return;
      }

      checkCouponStatus(couponStatus);

    } catch (error) {
      if(!mounted) {
        return;
      }

      Shared.mySnackBar(
        'Hiba kupon ellenőrzésnél: $error',
        Colors.red,
        context
      );
    } finally {
      setState(() {
        couponChecking = false;
      });
    }
  }

  void checkCouponStatus(CouponStatus couponStatus) {
    switch(couponStatus) {
      case CouponStatus.VALID:
        Shared.mySnackBar(
          'Kupon érvényes!',
          Colors.green,
          context,
        );

        setState(() {
          isCouponValid = true;
        });

      case CouponStatus.USED:
        Shared.mySnackBar(
          'A megadott kupont már felhasználták!',
          Colors.red,
          context,
        );

        setState(() {
          isCouponValid = false;
        });

      case CouponStatus.NOT_FOUND:
        Shared.mySnackBar(
          'A megadott kupon nem létezik!',
          Colors.red,
          context,
        );

        setState(() {
          isCouponValid = false;
        });

      case CouponStatus.EXPIRED:
        Shared.mySnackBar(
          'A megadott kupon érvényességi ideje már lejárt!',
          Colors.red,
          context,
        );

        setState(() {
          isCouponValid = false;
        });
    }
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
                controller: nameController,
                labelText: 'Név:',
                hintText: 'Név',
                format: FilteringTextInputFormatter.allow(RegExp(r'.*'),),
              ),

              const SizedBox(height: 10,),

              _userDataInput(
                controller: weightController,
                labelText: 'Testtömeg (kg):',
                hintText: 'Testtömeg',
                format: FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ),

              const SizedBox(height: 10,),

              _userDataInput(
                controller: heightController,
                labelText: 'Magasság (cm):',
                hintText: 'Magasság',
                format: FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ),

              const SizedBox(height: 10,),

              _userDataInput(
                controller: couponController,
                labelText: 'Kuponkód:',
                hintText: 'Kuponkód',
                format: FilteringTextInputFormatter.allow(RegExp(r'.*'),),
                isEnabled: !isCouponValid
              ),

              Padding(
                padding: const EdgeInsets.all(10.0,),

                child: ElevatedButton(
                  onPressed: validateCouponCode,

                  child: Text('Kupon ellenőrzése',),
                ),
              ),

              const SizedBox(height: 10,),

              _differentDaysSwitch(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> sendUserFromWelcome() async {
    //PREMIUM kuponkóddal prémium felhasználói szint!
    if(isCouponValid) {
      userType = UserType.PREMIUM;
    }

    //Nem jogosult a prémium funkcióra az ingyenes felhasználó!
    if(userType == UserType.FREE && differentDays) {
      Shared.mySnackBar(
        'FREE felhasználó (Név: ${nameController.text}) nem jogosult különböző napokra!',
        Colors.red,
        context,
      );

      throw Exception(
        'FREE felhasználó (Név: ${nameController.text}) nem jogosult különböző napokra!',
      );
    }

    Shared.mySnackBar(
      'Felhasználó sikeresen létrehozva! (Név: ${nameController.text})',
      Colors.green,
      context,
    );

    tempUser = User(
        id: 1,
        name: nameController.text,
        height: double.parse(heightController.text),
        weight: double.parse(weightController.text),
        userType: userType,
        differentDays: differentDays,
        dailyTarget: List.generate(7, (index) => KcalAndNutrients(
            kcal: dailyTargetValues[index][0],
            fat: dailyTargetValues[index][1],
            carb: dailyTargetValues[index][2],
            protein: dailyTargetValues[index][3],
          ),
        ),
    );

    await userService.sendUser(
      nameController.text,
      double.parse(heightController.text),
      double.parse(weightController.text),
      userType,
      differentDays,
      List.generate(7, (index) => KcalAndNutrients(
          kcal: dailyTargetValues[index][0],
          fat: dailyTargetValues[index][1],
          carb: dailyTargetValues[index][2],
          protein: dailyTargetValues[index][3],
        ),
      ),
    );

    zeroAllTextFields();
  }

  Widget _saveUserButton() {
    return Padding(
      padding: const EdgeInsets.all(15.0,),

      child: Center(
        child: ElevatedButton(
          onPressed: () {
            sendUserFromWelcome();

            if(isCouponValid) {
              couponService.useCoupon(couponController.text, tempUser!.id);
            }

            zeroAllTextFields();
          },

          child: const Text('User mentése',),
        ),
      ),
    );
  }

  SwitchListTile _differentDaysSwitch() {
    return SwitchListTile(
      title: const Text(
        'Különböző napok (csak PREMIUM-oknak!)',

        style: TextStyle(
          fontSize: 14,
        ),
      ),

      value: differentDays,

      onChanged: (bool value) {
        //Jó a kuponkód ÉS még nincs bekapcsolva.
        if(isCouponValid && value) {
          Shared.mySnackBar(
            'Milyen érzés PREMIUM ügyfélnek lenni? szerintünk nagyon jó!',
            Colors.green,
            context,
          );

          setState(() => differentDays = value);
        }
        //Be van kapcsolva (és kikapcsolom).
        //Azért kell, mert ha a PREMIUM kóddal bekapcsolja,
        //akkor a kód törlése után nem tudja kikapcsolni!
        else if(!value) {
          differentDays = false;

          Shared.mySnackBar(
            'Biztos kikapcsolod? Ez egy nagyon jó funkció!',
            Colors.orangeAccent,
            context,
          );

          //Ha átváltja a felhasználó különböző napokra és elmenti az adatokat,
          //akkor a visszaváltásnál megőrződnek a volt értékek!
          for(int day = 1; day < 7; day++) {
            for(int nutrient = 0; nutrient < 4; nutrient++) {
              dailyTargetValues[day][nutrient] = 0.0;
            }
          }

          setState(() => differentDays = value);
        } else {
          //Rossz a kuponkód ÉS ki van kapcsolva.
          Shared.mySnackBar(
            'Csak PREMIUM felhasználóknak! Te nem vagy az!',
            Colors.red,
            context,
          );
        }
      },
    );
  }



  Center _fillDailyTarget() {
    if(differentDays) {
      return Center(
        child: Container(
          width: 500,
          height: 700,

          padding: const EdgeInsets.all(10.0,),

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
                      margin: const EdgeInsets.symmetric(vertical: 5.0,),
                      padding: const EdgeInsets.all(5.0,),

                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueAccent,),
                      ),

                      child: Row(
                        children: [
                          SizedBox(
                            width: 100,

                            child: Text(
                              MyCalendar.nameOfDays[dayIndex],

                              style: const TextStyle(
                                fontSize: 20,

                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          _nutrientField(
                            'Kcal',
                            controllers[dayIndex][0],
                            (val) => dailyTargetValues[dayIndex][0] = double.tryParse(val)!,
                          ),

                          _nutrientField(
                            'Zsír',
                            controllers[dayIndex][1],
                            (val) => dailyTargetValues[dayIndex][1] = double.tryParse(val)!,
                          ),

                          _nutrientField(
                            'Szénhidrát',
                            controllers[dayIndex][2],
                            (val) => dailyTargetValues[dayIndex][2] = double.tryParse(val)!,
                          ),

                          _nutrientField(
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
            ],
          ),
        ),
      );
    }

    return Center(
      child: Container(
        width: 500,
        height: 700,

        padding: const EdgeInsets.all(10.0,),

        decoration: BoxDecoration(
          border: Border.all(color: Colors.blueAccent),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,

          children: [
            Padding(
              padding: const EdgeInsets.all(15.0,),

              child: const Text(
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
                _nutrientField(
                  'Kcal',
                  controllers[0][0],
                  (val) {
                    for(int day = 0; day < 7; day++) {
                      dailyTargetValues[day][0] = double.tryParse(val)!;
                    }
                  }
                ),

                _nutrientField(
                  'zsír',
                  controllers[0][1],
                  (val) {
                    for(int day = 0; day < 7; day++) {
                      dailyTargetValues[day][1] = double.tryParse(val)!;
                    }
                  }
                ),

                _nutrientField(
                  'Szénhidrát',
                  controllers[0][2],
                  (val) {
                    for(int day = 0; day < 7; day++) {
                      dailyTargetValues[day][2] = double.tryParse(val)!;
                    }
                  }
                ),

                _nutrientField(
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
          ],
        ),
      )
    );
  }

  Padding _nutrientField(
    String label,
    TextEditingController controller,
    Function(String) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0,),

      child: Column(
        children: [
          Text(label),

          SizedBox(
            width: 80,

            child: TextField(
              keyboardType: TextInputType.number,

              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],

              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,

                contentPadding: EdgeInsets.all(10.0,),

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

  void zeroAllTextFields() {
    for(int day = 0; day < 7; day++) {
      for(int nutrient = 0; nutrient < 4; nutrient++) {
        controllers[day][nutrient].text = '';
      }
    }

    nameController.text = '';
    weightController.text = '';
    heightController.text = '';
    couponController.text = '';
  }

  Widget _navigateUserToHomePage(BuildContext context,) {
    return Padding(
      padding: const EdgeInsets.all(12.0,),

      child: Center(
        child: ElevatedButton(
          onPressed: () {
            //Adatok megadása nélkül ne tudja lenyomni a 'Belépés' gombot.
            if(tempUser == null) {
              Shared.mySnackBar(
                'Még nem adtál meg adatokat! Töltsd ki a fentebbi mezőket!',
                Colors.red,
                context,
              );
            } else {
              print('Gomb lenyomva! (User ${tempUser?.name} oldal gombja)',);

              Navigator.of(context).pushNamed(
                '/home',

                arguments: tempUser,
              );
            }
          },

          child: const Text('Belépés',),
        ),
      ),
    );
  }
}

Container _userDataInput({
  required TextEditingController controller,
  required String labelText,
  required String hintText,
  required FilteringTextInputFormatter format,
  bool isEnabled = true,
}) {
  return Container(
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
            enabled: isEnabled,

            inputFormatters: [
              format,
            ],

            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,

              contentPadding: EdgeInsets.all(15.0,),

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
  );
}

Padding _greeting() {
  return Padding(
    padding: const EdgeInsets.all(8.0,),

    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,

      children: [
        const Text(
          'Ez a bejelentkezési oldal. Kérlek, töltsd ki az alábbi adatokat a kezdéshez!',

          style: TextStyle(
            fontSize: 30,
          ),
        ),
      ],
    ),
  );
}

Widget _navigateToHomePage(BuildContext context,) {
  return Padding(
    padding: const EdgeInsets.all(12.0,),

    child: Center(
      child: ElevatedButton(
          onPressed: () {
            print('Gomb lenyomva! (Home oldal gombja)',);

            Navigator.of(context).pushNamed(
              '/home',

              arguments: User(
                id: 0,
                name: 'Unnamed User',
                height: 190.0,
                weight: 81.0,
                userType: UserType.FREE,
                differentDays: false,
                dailyTarget: List.generate(
                  7, (_) => KcalAndNutrients(
                    kcal: 2000.0,
                    fat: 40.0,
                    carb: 250.0,
                    protein: 160.0
                  ),
                ),
              ),
            );
          },

          child: const Text('Home Page',),
      ),
    ),
  );
}

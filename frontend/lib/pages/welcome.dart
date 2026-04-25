import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:go_router/go_router.dart';

import '/day/day_service.dart';

import '/food/kcal_and_nutrients_model.dart';

import '/coupon/coupon_service.dart';
import '/coupon/coupon_status.dart';

import '/user/user_model.dart';
import '/user/user_service.dart';
import '/user/user_type.dart';

import '/utils/my_calendar.dart';
import '/utils/shared.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final UserService userService = UserService();
  final DayService dayService = DayService();

  bool differentDays = false;

  UserType userType = UserType.FREE;

  User? tempUser;

  //Beviteli mezők
  final nameController = TextEditingController();
  final passwordController1 = TextEditingController();
  final passwordController2 = TextEditingController();
  final weightController = TextEditingController();
  final heightController = TextEditingController();
  final couponController = TextEditingController();
  //

  //Jelszó check
  bool hasLowercase = false;
  bool hasUppercase = false;
  bool hasNumber = false;
  final int minLength = 6;
  final int maxLength = 30;
  bool correctLength = false;
  //

  bool hidePassword = true;

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

    loadDefaultUser();
  }

  void zeroAllTextFields() {
    for(int day = 0; day < 7; day++) {
      for(int nutrient = 0; nutrient < 4; nutrient++) {
        controllers[day][nutrient].text = '';
      }
    }

    nameController.text = '';
    passwordController1.text = '';
    passwordController2.text = '';
    weightController.text = '';
    heightController.text = '';
    couponController.text = '';

    setState(() {
      hasLowercase = false;
      hasUppercase = false;
      hasNumber = false;
      correctLength = false;
    });
  }

  //Vele tudunk bejelentkezni az adatok kitöltése nélkül!
  Future<void> loadDefaultUser() async {
    try {
      final user = await userService.getUserById(1);

      if(!mounted) {
        return;
      }

      setState(() {
        tempUser = user;
      });
    } catch(e, stackTrace) {
      print('User betöltési hiba: $e');
      print(stackTrace);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    passwordController1.dispose();
    passwordController2.dispose();
    weightController.dispose();
    heightController.dispose();
    couponController.dispose();

    for(int days = 0; days < 7; days++) {
      for(int nutrient = 0; nutrient < 4; nutrient++) {
        controllers[days][nutrient].dispose();
      }
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Shared.myAppBar('Regisztráció',),

      backgroundColor: Shared.backgroundColor,

      body: SizedBox(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              _greeting(),

              _fillData(),

              _fillDailyTarget(),

              _saveUserButton(),

              _navigateToHomePage(),

              _navigateUserToHomePage(),
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
        message: 'Adj meg egy kuponkódot!',
        color: Colors.blueAccent,
        context: context,
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

    } catch(error) {
      if(!mounted) {
        return;
      }

      Shared.mySnackBar(
        message: 'Hiba kupon ellenőrzésnél: $error',
        color: Colors.red,
        context: context
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
          message: 'Kupon érvényes!',
          color: Colors.green,
          context: context,
        );

        setState(() {
          isCouponValid = true;
        });

      case CouponStatus.USED:
        Shared.mySnackBar(
          message: 'A megadott kupont már felhasználták!',
          color: Colors.red,
          context: context,
        );

        setState(() {
          isCouponValid = false;
        });

      case CouponStatus.NOT_FOUND:
        Shared.mySnackBar(
          message: 'A megadott kupon nem létezik!',
          color: Colors.red,
          context: context,
        );

        setState(() {
          isCouponValid = false;
        });

      case CouponStatus.EXPIRED:
        Shared.mySnackBar(
          message: 'A megadott kupon érvényességi ideje már lejárt!',
          color: Colors.red,
          context: context,
        );

        setState(() {
          isCouponValid = false;
        });
    }
  }

  Center _fillData() {
    return Center(
      child: Container(
        width: Shared.pageWidth,
        color: Shared.boxDecorationColor,

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,

          children: [
            _userDataInput(
              controller: nameController,
              labelText: 'Név:',
              hintText: 'Név',
            ),

            _userDataInput(
              controller: passwordController1,
              labelText: 'Jelszó:',
              hintText: 'Jelszó',
              hiddenText: hidePassword,
              showToggle: true,

              onToggleVisibility: () {
                setState(() {
                  hidePassword = !hidePassword;
                });
              },

              onChanged: validatePassword
            ),

            _passwordChecklist(),

            _userDataInput(
              controller: passwordController2,
              labelText: 'Jelszó ismét:',
              hintText: 'Jelszó ismét',
              hiddenText: hidePassword,
            ),

            _userDataInput(
              controller: weightController,
              labelText: 'Testtömeg (kg):',
              hintText: 'Testtömeg',
              format: FilteringTextInputFormatter.allow(Shared.onlyNumbers),
            ),

            _userDataInput(
              controller: heightController,
              labelText: 'Magasság (cm):',
              hintText: 'Magasság',
              format: FilteringTextInputFormatter.allow(Shared.onlyNumbers),
            ),

            _userDataInput(
              controller: couponController,
              labelText: 'Kuponkód:',
              hintText: 'Kuponkód',
              isEnabled: !isCouponValid
            ),

            Padding(
              padding: const EdgeInsets.all(10.0,),

              child: ElevatedButton(
                onPressed: validateCouponCode,

                style: Shared.myButtonStyle,

                child: const Text('Kupon ellenőrzése',),
              ),
            ),

            _differentDaysSwitch(),
          ],
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
        message: 'FREE felhasználó (Név: ${nameController.text}) nem jogosult különböző napokra!',
        color: Colors.red,
        context: context,
      );

      return;
    }

    //Ha üresek a kontrollerek, akkor
    if(areControllersEmpty()) {
      Shared.mySnackBar(
        message: 'Még nem adtál meg minden adatot! Töltsd ki a fentebbi mezőket!',
        color: Colors.red,
        context: context,
      );

      return;
    }

    if(!checkIfPasswordFieldsMatch()) {
      Shared.mySnackBar(
        message: 'A jelszómezők nem egyeznek meg!',
        color: Colors.red,
        context: context,
      );

      return;
    }

    if(!isPasswordValid()) {
      Shared.mySnackBar(
        message: 'A jelszó nem teljesíti az összes követelményt!',
        color: Colors.red,
        context: context,
      );

      return;
    }

    Shared.mySnackBar(
      message: 'Felhasználó sikeresen létrehozva! (Név: ${nameController.text})',
      color: Colors.green,
      context: context,
    );

    await userService.sendUser(
      nameController.text,
      passwordController1.text,
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
      [],
      [],
      [],
    );
  }

  void validatePassword(String password) {
    setState(() {
      hasLowercase = RegExp(r'[a-z]').hasMatch(password);
      hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
      hasNumber = RegExp(r'[0-9]').hasMatch(password);
      correctLength = password.length >= minLength && password.length <= maxLength;
    });
  }

  bool isPasswordValid() {
    return hasLowercase
        && hasUppercase
        && hasNumber
        && passwordController1.text.length >= minLength
        && passwordController1.text.length <= maxLength;
  }

  Widget _passwordChecklist() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5,),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _checkItem("6-30 karakter", correctLength,),
          _checkItem("Kisbetű", hasLowercase,),
          _checkItem("Nagybetű", hasUppercase,),
          _checkItem("Szám", hasNumber,),
        ],
      ),
    );
  }

  Widget _checkItem(String text, bool valid) {
    return Row(
      children: [
        Icon(
          valid ? Icons.check : Icons.close,

          color: valid ? Colors.green : Colors.red,

          size: 25,
        ),

        const SizedBox(width: 5),

        Text(
          text,

          style: TextStyle(fontSize: 16,),
        ),
      ],
    );
  }

  Widget _saveUserButton() {
    return Padding(
      padding: const EdgeInsets.all(15.0,),

      child: Center(
        child: ElevatedButton(
          onPressed: () async {
            await sendUserFromWelcome();

            if(isCouponValid) {
              useCoupon(couponController.text, tempUser!.id);
            }

            zeroAllTextFields();
          },

          style: Shared.myButtonStyle,

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
          fontSize: 16,
        ),
      ),

      activeThumbColor: Colors.green.shade50,
      activeTrackColor: Colors.green,
      inactiveThumbColor: Colors.green.shade50,
      inactiveTrackColor: Colors.green,

      tileColor: Shared.boxDecorationColor,

      value: differentDays,

      onChanged: (bool value) {
        switchListTileCouponCheck(value);
      },
    );
  }

  void switchListTileCouponCheck(bool value) {
    //Jó a kuponkód ÉS még nincs bekapcsolva.
    if(isCouponValid && value) {
      Shared.mySnackBar(
        message: 'Milyen érzés PREMIUM ügyfélnek lenni? szerintünk nagyon jó!',
        color: Colors.green,
        context: context,
      );

      setState(() => differentDays = value);
    }
    //Be van kapcsolva (és kikapcsolom).
    else if(!value) {
      differentDays = false;

      Shared.mySnackBar(
        message: 'Biztos kikapcsolod? Ez egy nagyon jó funkció!',
        color: Colors.orangeAccent,
        context: context,
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
        message: 'Csak PREMIUM felhasználóknak! Te nem vagy az!',
        color: Colors.red,
        context: context,
      );
    }
  }

  Center _fillDailyTarget() {
    if(differentDays) {
      return Center(
        child: Container(
          width: Shared.pageWidth,
          height: 650,

          padding: const EdgeInsets.all(10.0,),

          decoration: BoxDecoration(
            color: Shared.boxDecorationColor,
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
                        color: Shared.boxDecorationColor,
                      ),

                      child: Row(
                        children: [
                          SizedBox(
                            width: 140,

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
                            (val) => dailyTargetValues[dayIndex][0] = double.tryParse(val) ?? 0.0,
                          ),

                          _nutrientField(
                            'Zsír',
                            controllers[dayIndex][1],
                            (val) => dailyTargetValues[dayIndex][1] = double.tryParse(val) ?? 0.0,
                          ),

                          _nutrientField(
                            'Szénhidrát',
                            controllers[dayIndex][2],
                            (val) => dailyTargetValues[dayIndex][2] = double.tryParse(val) ?? 0.0,
                          ),

                          _nutrientField(
                            'Fehérje',
                            controllers[dayIndex][3],
                            (val) => dailyTargetValues[dayIndex][3] = double.tryParse(val) ?? 0.0,
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
        width: Shared.pageWidth,

        padding: const EdgeInsets.all(10.0,),

        decoration: BoxDecoration(
          color: Shared.boxDecorationColor,
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,

          children: [
            const Padding(
              padding: EdgeInsets.all(15.0,),

              child: Text(
                'Minden napra ugyannyi tápanyagot tudsz beállítani!',

                textAlign: TextAlign.center,

                style: TextStyle(fontSize: 16,),
              ),
            ),

            const SizedBox(height: 10,),

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
                    'Zsír',
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
      ),
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
          Text(label,),

          SizedBox(
            width: 80,

            child: TextField(
              keyboardType: TextInputType.number,

              inputFormatters: [
                FilteringTextInputFormatter.allow(Shared.onlyNumbers),
              ],

              decoration: Shared.inputDecoration(null, '0'),

              onChanged: onChanged,

              controller: controller,
            ),
          ),
        ],
      ),
    );
  }

  bool checkIfPasswordFieldsMatch() {
    return passwordController1.text == passwordController2.text;
  }

  bool areControllersEmpty() {
    return nameController.text == '' ||
        passwordController1.text == '' ||
        passwordController2.text == '' ||
        heightController.text == '' ||
        weightController.text == '' ||
        controllers[0][0].text == '' ||
        controllers[0][1].text == '' ||
        controllers[0][2].text == '' ||
        controllers[0][3].text == '';
  }

  void useCoupon(couponCode, userId) {
    couponService.useCoupon(couponCode, userId);
  }

  Widget _navigateUserToHomePage() {
    return Padding(
      padding: const EdgeInsets.all(12.0,),

      child: Center(
          child: ElevatedButton(
            onPressed: () async {
              try {
                User user = await userService.getUserByName(nameController.text);

                if(!mounted) return;

                //.go, hogy ne lehessen visszanavigálni a belépési képernyőre!
                context.go('/home/${user.id}');
              } catch (e) {
                if (!mounted) return;

                Shared.mySnackBar(
                  message: 'Felhasználó (Név: ${nameController.text}) nem található!',
                  color: Colors.red,
                  context: context,
                );
              }
            },

            style: Shared.myButtonStyle,

            child: const Text('Belépés',),
          )
      ),
    );
  }

  Widget _navigateToHomePage() {
    return Padding(
      padding: const EdgeInsets.all(12.0,),

      child: Center(
        child: ElevatedButton(
          onPressed: () {
            if (tempUser == null) {
              Shared.mySnackBar(
                message: 'A felhasználó még nem töltődött be!',
                color: Colors.red,
                context: context,
              );

              return;
            }

            context.go('/home/${tempUser!.id}');
          },

          style: Shared.myButtonStyle,

          child: const Text('Home Page',),
        ),
      ),
    );
  }

/////////////////////////////////////////////////////////////////////////
////////////////////Itt ér véget a _WelcomePageState!////////////////////
/////////////////////////////////////////////////////////////////////////
}

Container _userDataInput({
  required TextEditingController controller,
  required String labelText,
  required String hintText,
  FilteringTextInputFormatter? format,
  Function(String)? onChanged,
  bool isEnabled = true,
  bool hiddenText = false,
  bool showToggle = false,
  VoidCallback? onToggleVisibility,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Shared.boxDecorationColor,
    ),

    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      children: [
        Padding(
          padding: const EdgeInsets.all(10.0,),

          child: SizedBox(
            width: 150,

            child: Text(labelText,),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(10.0,),

          child: Container(
            width: 140,
            height: 60,

            alignment: Alignment.center,

            child: TextField(
              controller: controller,
              enabled: isEnabled,
              obscureText: hiddenText,

              onChanged: onChanged,

              inputFormatters: [
                format ?? FilteringTextInputFormatter.allow(RegExp(r'.*'),),
              ],

              decoration: Shared.inputDecoration(null, hintText).copyWith(
                suffixIcon: showToggle
                    ? IconButton(
                  icon: Icon(
                    hiddenText
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: onToggleVisibility,
                )
                    : null,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Padding _greeting() {
  return const Padding(
    padding: EdgeInsets.all(8.0,),

    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,

      children: [
        Text(
          'Ez a regisztrációs oldal.\nTöltsd ki az alábbi adatokat a kezdéshez!',

          textAlign: TextAlign.center,

          style: TextStyle(
            fontSize: 26,
          ),
        ),
      ],
    ),
  );
}

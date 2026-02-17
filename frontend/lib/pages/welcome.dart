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

  @override
  void initState() {
    super.initState();
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
        setState(() => differentDays = value);
      },
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
                  color: Color(0xffDDDADA),
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
import 'package:flutter/material.dart';

import '../user/user_service.dart';
import '../user/user_type.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final UserService userService = UserService();

  //Beviteli mezők
  final nameController = TextEditingController();
  final weightController = TextEditingController();
  final heightController = TextEditingController();
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

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          _greeting(),

          _fillData(),

          _navigateToHomePage(context,),

          _saveUserButton(),
        ],


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
              _userDataInput(nameController, 'Név:', 'Név',),

              _userDataInput(weightController, 'Testtömeg (kg):', 'Testtömeg',),

              _userDataInput(heightController, 'Magasság (cm):', 'Magasság',),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> sendUser() async {
    await userService.sendUser(
      nameController.text,
      double.parse(heightController.text),
      double.parse(weightController.text),
      UserType.FREE,
      false,
    );
  }

  ElevatedButton _saveUserButton() {
    return ElevatedButton(
      onPressed: () {
        print('Regisztrációs gomb lenyomva! (User elmentése.)',);

        sendUser();
      },

      child: const Text('User mentése'),
    );
  }

}



SizedBox _userDataInput(TextEditingController controller, String labelText, String hintText,) {
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

        //TODO: user paramétereit menteni!
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
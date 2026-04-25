import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import '/user/user_model.dart';
import '/user/user_service.dart';

import '/utils/shared.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final UserService userService = UserService();

  //Beviteli mezők
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  //

  bool hidePassword = true;

  @override
  void dispose() {
    nameController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  Future<void> login() async {
    final name = nameController.text.trim();
    final password = passwordController.text;

    zeroAllTextFields();

    if(name.isEmpty || password.isEmpty) {
      Shared.mySnackBar(
        message: 'Add meg a nevedet és a jelszavadat!',
        color: Colors.red,
        context: context,
      );

      return;
    }

    try {
      final user = await getUserByName(name);

      if(!mounted) return;

      if(user.password != password) {
        Shared.mySnackBar(
          message: 'Hibás jelszó!',
          color: Colors.red,
          context: context,
        );

        return;
      }

      context.go('/home/${user.id}',);

    } catch(e) {
      if(!mounted) return;

      Shared.mySnackBar(
        message: 'Felhasználó $name nem található!',
        color: Colors.red,
        context: context,
      );
    }
  }

  void zeroAllTextFields() {
    nameController.text = '';
    passwordController.text = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Shared.myAppBar('Bejelentkezés',),

      backgroundColor: Shared.backgroundColor,

      body: Center(
        child: Container(
          width: Shared.pageWidth,

          color: Shared.boxDecorationColor,

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            mainAxisSize: MainAxisSize.min,

            children: [
              _fillData(),

              _navigateToHomePage(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fillData() {
    return Column(
      children: [
        _userDataInput(
          controller: nameController,
          text: 'Név',
        ),

        _userDataInput(
          controller: passwordController,
          text: 'Jelszó',
          hidden: hidePassword,
          showToggle: true,

          onToggleVisibility: () {
            setState(() {
              hidePassword = !hidePassword;
            });
          },
        ),
      ],
    );
  }

  Widget _userDataInput({
    required TextEditingController controller,
    required String text,
    bool hidden = false,
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
            padding: const EdgeInsets.all(8.0,),

            child: SizedBox(
              width: 150,

              child: Text('$text:',),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0,),

            child: Container(
              width: 200,
              height: 60,

              alignment: Alignment.center,

              child: TextField(
                controller: controller,

                obscureText: hidden,

                decoration: Shared.inputDecoration(null, text).copyWith(
                  suffixIcon: showToggle
                    ? IconButton(
                      icon: Icon(
                        hidden
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

  Widget _navigateToHomePage() {
    return Padding(
      padding: const EdgeInsets.all(10.0,),

      child: ElevatedButton(
        onPressed: login,

        style: Shared.myButtonStyle,

        child: const Text('Belépés',),
      ),
    );
  }

  Future<User> getUserByName(name) {
    return userService.getUserByName(name);
  }
}
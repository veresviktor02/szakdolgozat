import 'package:flutter/material.dart';

import 'package:flutter_application/pages/welcome.dart';
import 'package:flutter_application/pages/home/home.dart';
import 'package:flutter_application/pages/second_page.dart';
import 'package:flutter_application/pages/third_page.dart';
import 'package:flutter_application/user/user_model.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch(settings.name) {
      //Üdvözlőoldal
      case '/':
        return MaterialPageRoute(builder: (_) => WelcomePage());

      //Főoldal
      case '/home':
        final user = settings.arguments as User;

        return MaterialPageRoute(builder: (_) => HomePage(user: user,),);

      //Második oldal: Feltétel szükséges
      case '/second':
        if(settings.arguments is String) { //TODO: átalakítani a feltételt!
          return MaterialPageRoute(
            builder: (_) => SecondPage(
              data: settings.arguments.toString(),
            ),
          );
        }
        //Ha a route jó, de a feltétel nem teljesül, akkor Error oldal!
        return _errorRoute();

      //Harmadik oldal
      case '/third':
        return MaterialPageRoute(builder: (_) => ThirdPage());

      //Error oldal, nem található a keresett route!
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
        builder: (_) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Error'),
            ),
            body: Center(
              child: Text('ERROR'),
            ),
          );
        });
  }
}
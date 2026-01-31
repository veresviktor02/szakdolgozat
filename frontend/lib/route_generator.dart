import 'package:flutter/material.dart';

import 'package:flutter_application/pages/home.dart';
import 'package:flutter_application/pages/second_page.dart';
import 'package:flutter_application/pages/third_page.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      //Főoldal
      case '/':
        return MaterialPageRoute(builder: (_) => HomePage());

      //Második oldal: Feltétel szükséges
      case '/second':
        if (settings.arguments is String) { //TODO: átalakítani a feltételt!
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
    return MaterialPageRoute(builder: (_) {
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
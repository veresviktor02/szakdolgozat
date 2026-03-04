import 'package:flutter_application/food/kcal_and_nutrients_model.dart';

import 'package:flutter_application/user/user_model.dart';
import 'package:flutter_application/user/user_type.dart';

import '../shared.dart';

import 'package:http/http.dart' as http;

import 'dart:convert';

class UserService {
  Future<List<User>> fetchUsers() async {
    final response = await http.get(
      Uri.parse('${Shared.baseUrl}/users'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if(response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);

      return jsonList.map((jsonItem) => User.fromJson(jsonItem)).toList();
    }
    throw Exception(
      'Felhasználók lekérése sikertelen! (${response.statusCode})',
    );
  }

  Future<void> sendUser(
      String name,
      double height,
      double weight,
      UserType userType,
      bool differentDays,
      List<KcalAndNutrients> dailyTarget,
  ) async {
    final response = await http.post(
      Uri.parse('${Shared.baseUrl}/users'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'height': height,
        'weight': weight,
        'userType': userType.name, //sima userType hibás!
        'differentDays': differentDays,
        'dailyTarget': dailyTarget,
      }),
    );

    print(response.body);

    if(response.statusCode != 200) {
      throw Exception(
        'Felhasználó küldése sikertelen! (${response.statusCode})',
      );
    }
  }
}
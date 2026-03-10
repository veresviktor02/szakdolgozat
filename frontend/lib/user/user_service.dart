import 'dart:convert';

import 'package:flutter_application/day/measurement_unit/measurement_unit_model.dart';
import 'package:http/http.dart' as http;

import '/user/user_model.dart';
import '/user/user_type.dart';

import '/day/day_model.dart';

import '/food/food_model.dart';
import '/food/kcal_and_nutrients_model.dart';

import '/utils/shared.dart';

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

  Future<User> getUserById(int id) async {
    final response = await http.get(
      Uri.parse('${Shared.baseUrl}/users/$id'),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Hiba User lekérésekor (ID: $id).');
    }
  }

  Future<void> sendUser(
      String name,
      double height,
      double weight,
      UserType userType,
      bool differentDays,
      List<KcalAndNutrients> dailyTarget,
      List<Food> foods,
      List<Day> days,
      List<MeasurementUnit> measurementUnits,
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
        'foods': foods,
        'days': days,
        'measurementUnits': measurementUnits,
      }),
    );

    if(response.statusCode != 200) {
      throw Exception(
        'Felhasználó küldése sikertelen! (${response.statusCode})',
      );
    }
  }

  Future<void> updateUserById(int userId, User user) async {
    final response = await http.put(
      Uri.parse('${Shared.baseUrl}/users/$userId'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': user.name,
        'height': user.height,
        'weight': user.weight,
        'userType': user.userType.name,
        'differentDays': user.differentDays,
        'dailyTarget': user.dailyTarget.map((target) => {
          'kcal': target.kcal,
          'fat': target.fat,
          'carb': target.carb,
          'protein': target.protein,
        }).toList(),
        //TODO
      }),
    );

    if(response.statusCode != 200) {
      throw Exception('Nem sikerült frissíteni a felhasználót');
    }
  }
}
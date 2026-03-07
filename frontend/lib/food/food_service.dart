import 'package:http/http.dart' as http;

import 'dart:convert';

import '../shared.dart';

import 'food_model.dart';

import 'kcal_and_nutrients_model.dart';

class FoodService {
  Future<List<Food>> fetchFoods() async {
    final response = await http.get(
      Uri.parse('${Shared.baseUrl}/foods'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if(response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);

      return jsonList.map((jsonItem) => Food.fromJson(jsonItem)).toList();
    }
    throw Exception(
      'Ételek lekérése sikertelen! (${response.statusCode})',
    );
  }

  Future<void> sendFood(String name, KcalAndNutrients kcalAndNutrients) async {
    final response = await http.post(
      Uri.parse('${Shared.baseUrl}/foods'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'kcalAndNutrients': kcalAndNutrients.toJson(),
      })
    );

    print(response.body);
  }
}
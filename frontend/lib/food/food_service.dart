import 'dart:convert';

import 'package:http/http.dart' as http;

import 'food_model.dart';

import 'kcal_and_nutrients_model.dart';

import '/utils/shared.dart';

class FoodService {
  Future<List<Food>> fetchFoods(int id) async {
    final response = await http.get(
      Uri.parse('${Shared.baseUrl}/foods/$id'),
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

  Future<void> sendFood(int userId, String name, KcalAndNutrients kcalAndNutrients) async {
    final response = await http.post(
      Uri.parse('${Shared.baseUrl}/foods/$userId'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'userId': userId,
        'name': name,
        'kcalAndNutrients': kcalAndNutrients.toJson(),
      })
    );

    if(response.statusCode != 200) {
      throw Exception('Étel küldése sikertelen! (${response.body})');
    }
  }

  Future<void> deleteFood(int foodId) async {
    final response = await http.delete(
      Uri.parse(
        '${Shared.baseUrl}/foods/$foodId',
      ),
    );

    if(response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Étel törlése sikertelen!');
    }
  }

  Future<Food> getFoodById(int userId, int foodId) async {
    final response = await http.get(
      Uri.parse('${Shared.baseUrl}/foods/$userId/$foodId'),
    );

    if (response.statusCode == 200) {
      return Food.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Hiba étel lekérésekor (ID: $foodId).');
    }
  }
}
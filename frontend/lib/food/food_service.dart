import 'package:http/http.dart' as http;

import 'dart:convert';

import '../utils/shared.dart';

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

    if(response.statusCode != 200) {
      throw Exception('Étel küldése sikertelen!');
    }
  }

  Future<void> deleteFood(int id) async {
    final response = await http.delete(
      Uri.parse(
        '${Shared.baseUrl}/foods/$id',
      ),
    );

    if(response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Étel törlése sikertelen!');
    }
  }

  Future<Food> getFoodById(int id) async {
    final response = await http.get(
      Uri.parse('${Shared.baseUrl}/foods/$id'),
    );

    if (response.statusCode == 200) {
      return Food.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Hiba étel lekérésekor (ID: $id).');
    }
  }
}
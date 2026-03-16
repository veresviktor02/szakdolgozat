import 'dart:convert';

import 'package:http/http.dart' as http;

import '/day/day_model.dart';
import '/day/measurement_unit/measurement_unit_model.dart';

import '/food/kcal_and_nutrients_model.dart';

import '/utils/shared.dart';

class DayService {
  Future<List<Day>> fetchDays(int id) async {
    final response = await http.get(
      Uri.parse('${Shared.baseUrl}/days/$id'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if(response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);

      return jsonList.map((jsonItem) => Day.fromJson(jsonItem)).toList();
    }
    throw Exception(
      'Napok lekérése sikertelen! (${response.statusCode})',
    );
  }

  Future<void> removeFoodFromDay(int dayId, int foodId) async {
    final response = await http.delete(
      Uri.parse(
        '${Shared.baseUrl}/days/$dayId/$foodId',
      ),
    );

    //HTTP 204: No content! - Delete sikeres, de nincs válasz!
    if(response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Étel törlése a napból sikertelen!');
    }
  }

  Future<KcalAndNutrients> getTotalKcalAndNutrients(int userId, int dayId) async {
    final response = await http.get(
      Uri.parse('${Shared.baseUrl}/days/$userId/$dayId/total'),
    );

    if(response.statusCode == 200) {
      final Map<String, dynamic> jsonMap = json.decode(response.body);

      return KcalAndNutrients.fromJson(jsonMap);
    }

    throw Exception('Kcal és tápanyagok lekérése sikertelen! (Válasz: ${response.statusCode})');
  }

  Future<void> createEmptyDays(int id) async {
    final response = await http.get(
      Uri.parse('${Shared.baseUrl}/days/create-empty-days/$id'),
    );

    if(response.statusCode == 200) {
      throw Exception('Üres napok létrehozása nem sikerült! (${response.body})');
    }
  }

  Future<void> addFoodToDay(
      int userId,
      int dayId,
      String name,
      KcalAndNutrients kcalAndNutrients,
      double foodWeight,
      MeasurementUnit measurementUnit,
  ) async {
    final response = await http.post(
      Uri.parse(
        '${Shared.baseUrl}/days/$userId/$dayId',
      ),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'kcalAndNutrients': kcalAndNutrients.toJson(),
        'foodWeight': foodWeight,
        'measurementUnit': measurementUnit.toJson(),
      }),
    );

    if(response.statusCode != 200) {
      throw Exception(
        'Étel hozzáadása a naphoz (ID: $dayId) sikertelen! (Válasz: ${response.statusCode})',
      );
    }
  }
}
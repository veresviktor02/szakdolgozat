import 'package:flutter_application/day/day_model.dart';
import 'package:flutter_application/food/kcal_and_nutrients_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DayService {
  static const String _baseUrl = 'http://localhost:8080';

  Future<List<Day>> fetchDays() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/days'),
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
    final response = await http.delete(Uri.parse(
      '$_baseUrl/days/$dayId/foods/$foodId',
    ));

    //HTTP 204: No content! - Delete sikeres, de nincs válasz!
    if(response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Étel törlése sikertelen!');
    }
  }

  Future<KcalAndNutrients> getTotalKcalAndNutrients(int dayId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/days/$dayId/total'),
    );

    if(response.statusCode == 200) {
      final Map<String, dynamic> jsonMap = json.decode(response.body);

      return KcalAndNutrients.fromJson(jsonMap);
    }
    throw Exception("Kcal és tápanyagok lekérése sikertelen! (Válasz: ${response.statusCode})");
  }


}
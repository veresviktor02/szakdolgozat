import 'dart:convert';

import 'package:http/http.dart' as http;

import '/utils/shared.dart';

import 'nutrition_response.dart';

class APIService {
  Future<NutritionResponse> fetchNutritions(String query, int userId) async {
    //Kicserélni a space-eket +-ra
    final normalizedQuery = query.trim().replaceAll(' ', '+');

    //Space encode (%20), mert + jellel nem működik ez az API!
    final encodedQuery = Uri.encodeComponent(normalizedQuery);

    final response = await http.get(
      Uri.parse('${Shared.baseUrl}/api?query=$encodedQuery&userId=$userId',),
    );

    switch(response.statusCode) {
      case 200:
        return NutritionResponse.fromJson(jsonDecode(response.body));
      case 500:
        throw Exception('Maximum 5 kérés / perc!');
      default:
        throw Exception('Nem sikerült az adatokat lekérni az API-tól!');
    }
  }
}
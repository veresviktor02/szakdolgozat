import 'dart:convert';

import 'package:http/http.dart' as http;

import 'nutrition_response.dart';

class APIService {
  final String _baseUrl = 'http://localhost:8080';

  Future<NutritionResponse> fetchNutritions(String query) async {
    //Kicserélni a space-eket +-ra
    final normalizedQuery = query.trim().replaceAll(' ', '+');

    //Space encode (%20), mert + jellel nem működik ez az API!
    final encodedQuery = Uri.encodeComponent(normalizedQuery);

    final uri = Uri.parse('$_baseUrl/api?query=$encodedQuery');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return NutritionResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Nem sikerült az adatokat lekérni az API-tól!');
    }
  }
}
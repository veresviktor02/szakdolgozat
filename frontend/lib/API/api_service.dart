import 'dart:convert';

import 'package:http/http.dart' as http;

import 'nutrition_response.dart';

class APIService {
  final String baseUrl;

  APIService(this.baseUrl);

  Future<NutritionResponse> fetchNutrition(String query) async {

    //Kicserélni a space-eket +-ra
    final normalizedQuery = query.trim().replaceAll(' ', '+');

    //Space encode (%20), mert + jellel nem működik ez az API!
    final encodedQuery = Uri.encodeComponent(normalizedQuery);

    final uri = Uri.parse('$baseUrl/api?query=$encodedQuery');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return NutritionResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to load nutrition data");
    }
  }
}
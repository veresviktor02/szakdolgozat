import 'package:flutter_application/day/day_model.dart';
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

  //TODO: sendDay()
}
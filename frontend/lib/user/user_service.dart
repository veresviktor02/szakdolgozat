import 'package:flutter_application/user/user_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FoodService {
  static const String _baseUrl = 'http://localhost:8080';

  Future<List<User>> fetchUsers() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/users'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);

      return jsonList.map((jsonItem) => User.fromJson(jsonItem)).toList();
    }
    throw Exception(
      'Felhasználók lekérése sikertelen! (${response.statusCode})',
    );
  }

  //TODO: sendUser()
}
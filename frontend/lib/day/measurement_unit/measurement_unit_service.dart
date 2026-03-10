import 'dart:convert';

import 'package:http/http.dart' as http;

import 'measurement_unit_model.dart';

import '/utils/shared.dart';

class MeasurementUnitService {
  Future<List<MeasurementUnit>> fetchMeasurementUnits(int id) async {
    final response = await http.get(
      Uri.parse('${Shared.baseUrl}/measurementUnits/$id'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if(response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);

      return jsonList.map((jsonItem) => MeasurementUnit.fromJson(jsonItem)).toList();
    }
    throw Exception(
      'Mértékegységek lekérése sikertelen! (${response.statusCode})',
    );
  }

  Future<void> sendMeasurementUnit(String measurementUnitName, int measurementUnitInGrams) async {
    final response = await http.post(
        Uri.parse('${Shared.baseUrl}/measurementUnits'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'measurementUnitName': measurementUnitName,
          'measurementUnitInGrams': measurementUnitInGrams,
        })
    );

    if(response.statusCode != 200) {
      throw Exception('Mértékegység hozzáadása sikertelen!');
    }
  }

  Future<void> deleteMeasurementUnit(int id) async {
    final response = await http.delete(
      Uri.parse(
        '${Shared.baseUrl}/measurementUnits/$id',
      ),
    );

    if(response.statusCode != 200 && response.statusCode != 204) {
      print(response.body);
      throw Exception('Mértékegység törlése sikertelen!');
    }
  }
}
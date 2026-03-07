import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../utils/shared.dart';

import 'package:flutter_application/day/measurement_unit/measurement_unit_model.dart';

class MeasurementUnitService {
  Future<List<MeasurementUnit>> fetchMeasurementUnits() async {
    final response = await http.get(
      Uri.parse('${Shared.baseUrl}/measurementUnits'),
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
        Uri.parse('${Shared.baseUrl}/measurementUnit'),
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

  Future<void> deleteMeasurementUnit() async {
    //TODO
  }
}
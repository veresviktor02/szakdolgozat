import 'package:flutter/material.dart';

import 'kcal_and_nutrients_model.dart';

class Food {
  final int id;
  final String name;
  final KcalAndNutrients kcalAndNutrients;

  Food({
    required this.id,
    required this.name,
    required this.kcalAndNutrients,
  });

  @override
  String toString() {
    return toJson().toString();
  }

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: json['id'],
      name: json['name'],
      kcalAndNutrients:
      KcalAndNutrients.fromJson(json['kcalAndNutrients']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'kcalAndNutrients': kcalAndNutrients.toJson(),
    };
  }


}
import 'package:flutter/material.dart';

import 'kcal_and_nutrients_model.dart';

class Food {
  final String name;
  final KcalAndNutrients kcalAndNutrients;

  Food({
    required this.name,
    required this.kcalAndNutrients,
  });

  @override
  String toString() {
    return toJson().toString();
  }

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      name: json['name'],
      kcalAndNutrients:
      KcalAndNutrients.fromJson(json['kcalAndNutrients']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'kcalAndNutrients': kcalAndNutrients.toJson(),
    };
  }


}
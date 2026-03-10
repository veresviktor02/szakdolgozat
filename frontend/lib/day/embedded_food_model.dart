import '/day/measurement_unit/measurement_unit_model.dart';

import '../food/food_model.dart';
import '../food/kcal_and_nutrients_model.dart';

class EmbeddedFood {
  final int id;
  final String name;
  final KcalAndNutrients kcalAndNutrients;
  final double foodWeight;
  final MeasurementUnit measurementUnit;
  final Food? food;

  EmbeddedFood({
    required this.id,
    required this.name,
    required this.kcalAndNutrients,
    required this.foodWeight,
    required this.measurementUnit,
    this.food,
  });

  @override
  String toString() {
    return toJson().toString();
  }

  factory EmbeddedFood.fromJson(Map<String, dynamic> json) {
    return EmbeddedFood(
      id: json['id'],
      name: json['name'],
      kcalAndNutrients: KcalAndNutrients.fromJson(json['kcalAndNutrients']),
      foodWeight: (json['foodWeight'] as num).toDouble(),
      measurementUnit: MeasurementUnit.fromJson(json['measurementUnit']),
      food: json['food'] != null
          ? Food.fromJson(json['food'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'kcalAndNutrients': kcalAndNutrients.toJson(),
      'foodWeight': foodWeight,
      'measurementUnit': measurementUnit.toJson(),
      'food': food?.toJson(),
    };
  }
}
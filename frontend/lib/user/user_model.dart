import '/user/user_type.dart';

import '/day/day_model.dart';
import '/day/measurement_unit/measurement_unit_model.dart';

import '/food/food_model.dart';
import '/food/kcal_and_nutrients_model.dart';

class User {
  final int id;
  final String name;
  final double height;
  final double weight;
  final UserType userType;
  final bool differentDays;
  final List<KcalAndNutrients> dailyTarget;
  final List<Food> foods;
  final List<Day> days;
  final List<MeasurementUnit> measurementUnits;

  User({
    required this.id,
    required this.name,
    required this.height,
    required this.weight,
    required this.userType,
    required this.differentDays,
    required this.dailyTarget,
    required this.foods,
    required this.days,
    required this.measurementUnits,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      height: json['height'],
      weight: json['weight'],
      userType: UserType.values.firstWhere(
            (e) => e.name == json['userType'],
      ),
      differentDays: json['differentDays'],
      dailyTarget: (json['dailyTarget'] as List<dynamic>)
          .map((item) => KcalAndNutrients.fromJson(item))
          .toList(),
      foods: (json['foods'] as List<dynamic>)
          .map((item) => Food.fromJson(item))
          .toList(),
      days: (json['days'] as List<dynamic>)
          .map((item) => Day.fromJson(item))
          .toList(),
      measurementUnits: (json['measurementUnits'] as List<dynamic>)
          .map((item) => MeasurementUnit.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'height': height,
      'weight': weight,
      'userType': userType.name,
      'differentDays': differentDays,
      'dailyTarget': dailyTarget.map((item) => item.toJson()).toList(),
      'foods': foods.map((item) => item.toJson()).toList(),
      'days': days.map((item) => item.toJson()).toList(),
      'measurementUnits': measurementUnits.map((item) => item.toJson()).toList(),
    };
  }
}
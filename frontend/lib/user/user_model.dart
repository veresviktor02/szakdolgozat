import 'package:flutter_application/food/kcal_and_nutrients_model.dart';

import 'package:flutter_application/user/user_type.dart';

class User {
  final int id;
  final String name;
  final double height;
  final double weight;
  final UserType userType;
  final bool differentDays;
  final List<KcalAndNutrients> dailyTarget;

  User({
    required this.id,
    required this.name,
    required this.height,
    required this.weight,
    required this.userType,
    required this.differentDays,
    required this.dailyTarget,
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
      'dailyTarget': dailyTarget,
    };
  }
}
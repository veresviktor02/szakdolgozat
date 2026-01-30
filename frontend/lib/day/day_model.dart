import 'package:flutter_application/food/food_model.dart';

class Day {
  final DateTime date;
  final List<Food> foodList;

  Day({
    required this.date,
    required this.foodList,
  });

  factory Day.fromJson(Map<String, dynamic> json) {
    return Day(
      date: DateTime.parse(json['date']),
      foodList: (json['foodList'] as List<dynamic>)
          .map((item) => Food.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String().split('T')[0], //TODO: Nap utáni rész levágása!
      'foodList': foodList.map((food) => food.toJson()).toList(),
    };
  }
}
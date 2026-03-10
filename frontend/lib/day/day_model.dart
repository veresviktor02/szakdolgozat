import 'embedded_food_model.dart';

class Day {
  final int id;
  final DateTime date;
  final List<EmbeddedFood> foodList;
  //final User user; //@JsonBackReference miatt nem kell!

  Day({
    required this.id,
    required this.date,
    required this.foodList,
  });

  factory Day.fromJson(Map<String, dynamic> json) {
    return Day(
      id: json['id'],
      date: DateTime.parse(json['date']),
      foodList: (json['foodList'] as List<dynamic>)
          .map((item) => EmbeddedFood.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String().split('T')[0],
      'foodList': foodList.map((embeddedFood) => embeddedFood.toJson()).toList(),
    };
  }
}
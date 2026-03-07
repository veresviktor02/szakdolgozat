import '../food/kcal_and_nutrients_model.dart';

class EmbeddedFood {
  final int id;
  final String name;
  final KcalAndNutrients kcalAndNutrients;
  final double foodWeight;

  EmbeddedFood({
    required this.id,
    required this.name,
    required this.kcalAndNutrients,
    required this.foodWeight,
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'kcalAndNutrients': kcalAndNutrients.toJson(),
      'foodWeight': foodWeight,
    };
  }
}
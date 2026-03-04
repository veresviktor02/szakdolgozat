import 'api_food_model.dart';

class NutritionResponse {
  final List<APIFood> items;

  NutritionResponse({required this.items});

  factory NutritionResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> list = (json['items'] as List<dynamic>?) ?? const [];

    return NutritionResponse(
      items: list.map(
          (e) => APIFood.fromJson(e as Map<String, dynamic>),
      ).toList(),
    );
  }
}
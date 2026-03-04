class APIFood {
  final String name;
  final double calories;
  final double servingSizeG;
  final double proteinG;
  final double fatTotalG;
  final double carbohydratesTotalG;

  APIFood({
    required this.name,
    required this.calories,
    required this.servingSizeG,
    required this.proteinG,
    required this.fatTotalG,
    required this.carbohydratesTotalG,
  });

  factory APIFood.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v) => (v is num)
        ? v.toDouble()
        : double.tryParse('$v') ?? 0;

    return APIFood(
      name: json['name'] ?? '',
      calories: toDouble(json['calories']),
      servingSizeG: toDouble(json['serving_size_g']),
      proteinG: toDouble(json['protein_g']),
      fatTotalG: toDouble(json['fat_total_g']),
      carbohydratesTotalG: toDouble(json['carbohydrates_total_g']),
    );
  }
}
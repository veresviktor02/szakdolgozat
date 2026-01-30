class KcalAndNutrients {
  final double kcal;
  final double fat;
  final double carb;
  final double protein;

  KcalAndNutrients({
    required this.kcal,
    required this.fat,
    required this.carb,
    required this.protein,
  });

  //dynamic - bármilyen típus érkezhet! Nem jelent problémát más adat!
  factory KcalAndNutrients.fromJson(Map<String, dynamic> json) {
    return KcalAndNutrients(
      //num lehet int, lehet double (szülőtípus).
      kcal: (json['kcal'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      carb: (json['carb'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kcal': kcal,
      'fat': fat,
      'carb': carb,
      'protein': protein,
    };
  }
}
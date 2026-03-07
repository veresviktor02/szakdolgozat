class MeasurementUnit {
  final int id;
  final String measurementUnitName;
  final int measurementUnitInGrams;

  MeasurementUnit({
    required this.id,
    required this.measurementUnitName,
    required this.measurementUnitInGrams,
  });

  @override
  String toString() {
    return toJson().toString();
  }

  factory MeasurementUnit.fromJson(Map<String, dynamic> json) {
    return MeasurementUnit(
      id: json['id'],
      measurementUnitName: json['measurementUnitName'],
      measurementUnitInGrams: json['measurementUnitInGrams'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'measurementUnitName': measurementUnitName,
      'measurementUnitInGrams': measurementUnitInGrams,
    };
  }
}
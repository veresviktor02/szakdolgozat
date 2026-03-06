class Coupon {
  final int id;
  final String couponCode;
  final int? usedByUserId;
  final DateTime expirationDate;

  const Coupon({
    required this.id,
    required this.couponCode,
    required this.usedByUserId,
    required this.expirationDate,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: (json['id'] as num).toInt(),
      couponCode: (json['couponCode'] ?? '').toString(),
      usedByUserId: json['usedByUserId'] == null ? null : (json['usedByUserId'] as num).toInt(),
      expirationDate: DateTime.parse(json['expirationDate']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'couponCode': couponCode,
    'usedByUserId': usedByUserId,
    'expirationDate': expirationDate.toIso8601String().split('T')[0],
  };

  bool get isUsed => usedByUserId != null;
}
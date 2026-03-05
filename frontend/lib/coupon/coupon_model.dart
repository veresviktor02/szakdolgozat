class Coupon {
  final int id;
  final String couponCode;
  final int? usedByUserId;

  const Coupon({
    required this.id,
    required this.couponCode,
    required this.usedByUserId,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: (json['id'] as num).toInt(),
      couponCode: (json['couponCode'] ?? '').toString(),
      usedByUserId: json['usedByUserId'] == null ? null : (json['usedByUserId'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'couponCode': couponCode,
    'usedByUserId': usedByUserId,
  };

  bool get isUsed => usedByUserId != null;
}
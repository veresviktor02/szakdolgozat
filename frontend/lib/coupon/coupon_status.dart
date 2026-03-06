enum CouponStatus {
  VALID,
  USED,
  EXPIRED,
  NOT_FOUND,
}

extension CouponStatusParser on CouponStatus {
  static CouponStatus fromString(String value) {
    final cleaned = value.trim().replaceAll('"', '');

    return CouponStatus.values.firstWhere(
          (e) => e.name == cleaned,
      orElse: () => throw Exception('Ismeretlen státusz: "$cleaned"'),
    );
  }
}
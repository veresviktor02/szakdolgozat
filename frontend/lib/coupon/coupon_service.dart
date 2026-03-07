import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:flutter_application/coupon/coupon_status.dart';

import '../utils/shared.dart';

class CouponService {
  Future<CouponStatus> validateCoupon(String couponCode) async {
    couponCode = couponCode.trim().toUpperCase();

    final uri = Uri.parse(
        '${Shared.baseUrl}/coupons/validate/$couponCode'
    );

    final response = await http.get(uri);

    if(response.statusCode == 200 || response.statusCode == 404) {
      return CouponStatusParser.fromString(response.body);
    }

    throw Exception(
      'Kupon ellenőrzés sikertelen! (${response.statusCode})',
    );
  }

  Future<void> useCoupon(String couponCode, int userId) async {
    final uri = Uri.parse(
        '${Shared.baseUrl}/coupons/$couponCode/use/$userId'
    );

    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "couponCode": couponCode,
        "userId": userId,
      }),
    );

    if(response.statusCode != 200) {
      throw Exception('Kupon felhasználása sikertelen! (${response.statusCode})');
    }
  }
}
import 'package:http/http.dart' as http;

import 'package:flutter_application/coupon/coupon_status.dart';

import '../shared.dart';

class CouponService {
  Future<CouponStatus> validateCoupon(String couponCode) async {
    couponCode = couponCode.trim().toUpperCase();

    final uri = Uri.parse(
        '${Shared.baseUrl}/coupons/validate?couponCode=$couponCode'
    );

    final response = await http.get(uri);

    if(response.statusCode == 200 && response.body == "true") {
      return CouponStatus.VALID;
    }
    if(response.statusCode == 200 && response.body == "false") {
      return CouponStatus.USED;
    }
    if(response.statusCode == 404) {
      return CouponStatus.NOT_FOUND;
    }
    //TODO: Lejárt kuponok kezelése!
    /*
    if(response.statusCode == ???) {
      return CouponStatus.EXPIRED;
    }
    */

    throw Exception(
      'Kupon ellenőrzés sikertelen! (${response.statusCode})',
    );
  }
}
package Calorie.Coupon;

import Calorie.Exceptions.CouponException;

import jakarta.annotation.PostConstruct;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import java.time.LocalDate;

import java.util.List;

@Service
public class CouponService {
    @PostConstruct
    public void init() {
        createCoupons();
    }

    private final CouponRepository couponRepository;

    public CouponService(CouponRepository couponRepository) {
        this.couponRepository = couponRepository;
    }

    public ResponseEntity<CouponStatus> checkIfCouponIsValid(String couponCode) {
        couponCode = couponCode.trim().toUpperCase();

        try {
            List<Coupon> coupons = couponRepository.findAll();

            Coupon matchedCoupon = null;

            for(Coupon coupon : coupons) {
                try {
                    String decryptedCode = coupon.getPlainCouponCode();

                    if(decryptedCode.equalsIgnoreCase(couponCode)) {
                        matchedCoupon = coupon;

                        break;
                    }
                } catch (Exception e) {}
            }

            if(matchedCoupon == null) {
                return ResponseEntity
                        .status(HttpStatus.NOT_FOUND)
                        .body(CouponStatus.NOT_FOUND);
            }

            if(matchedCoupon.isExpired()) {
                return ResponseEntity.ok(CouponStatus.EXPIRED);
            }

            if(matchedCoupon.isUsed()) {
                return ResponseEntity.ok(CouponStatus.USED);
            }

            return ResponseEntity.ok(CouponStatus.VALID);

        } catch (Exception e) {
            throw new CouponException(
                    "checkIfCouponIsValid(String couponCode) hibát dobott!", e
            );
        }
    }

    public void useCoupon(String couponCode, Integer userId) {
        Coupon coupon = couponRepository
                .findByCouponCode(couponCode.trim().toUpperCase())
                .orElseThrow(
                        () -> new CouponException("Kupon nem található!")
                );

        if(coupon.isExpired()) {
            throw new CouponException("A kupon lejárt!");
        }

        if(coupon.isUsed()) {
            throw new CouponException("A kupon már fel lett használva!");
        }

        coupon.setUsedByUserId(userId);

        try {
            couponRepository.save(coupon);
        } catch(Exception e) {
            throw new CouponException("couponRepository.save(coupon) hibát dobott!", e);
        }
    }

    public List<Coupon> getAllCoupons() {
        try {
            return couponRepository.findAll();
        } catch(Exception e) {
            throw new CouponException("couponRepository.findAll() hibát dobott!", e);
        }
    }

    public void createCoupons() {
        for(int i = 1; i <= 10; i++) {
            String couponCode = "PREMIUM" + i;

            Coupon coupon = new Coupon();
            coupon.setCouponCode(couponCode);

            //Teszteléshez, hogy tudjuk tesztelni a használt kuponkódok beváltását!
            if(i == 7) {
                coupon.setUsedByUserId(68);
            } else {
                coupon.setUsedByUserId(null);
            }

            //Teszteléshez, hogy tudjuk tesztelni a lejárt kuponkódok beváltását!
            if(i == 10) {
                coupon.setExpirationDate(LocalDate.of(2020, 1, 1));
            } else {
                coupon.setExpirationDate(LocalDate.of(2030, 12, 31));
            }

            try {
                couponRepository.save(coupon);
            } catch(Exception e) {
                throw new CouponException("couponRepository.save(coupon) hibát dobott!", e);
            }
        }
    }
}

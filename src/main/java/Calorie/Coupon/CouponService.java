package Calorie.Coupon;

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

        //Kupon nem létezik
        if(!couponRepository.existsByCouponCode(couponCode)) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(CouponStatus.NOT_FOUND);
        }

        Coupon coupon = couponRepository.findCouponByCouponCode(couponCode);

        //Kupon létezik, de lejárt.
        if(coupon.isExpired()) {
            return ResponseEntity.ok(CouponStatus.EXPIRED);
        }

        //Kupon létezik, de használt.
        if(coupon.isUsed()) {
            return ResponseEntity.ok(CouponStatus.USED);
        }

        //Kupon aktív.
        return ResponseEntity.ok(CouponStatus.VALID);
    }

    public void useCoupon(String couponCode, Integer userId) {
        Coupon coupon = couponRepository
                .findByCouponCode(couponCode.trim().toUpperCase())
                .orElseThrow(
                        () -> new RuntimeException("Kupon nem található!")
                );

        if(coupon.isExpired()) {
            throw new IllegalStateException("A kupon lejárt!");
        }

        if(coupon.isUsed()) {
            throw new IllegalStateException("A kupon már fel lett használva!");
        }

        coupon.setUsedByUserId(userId);

        couponRepository.save(coupon);
    }

    public List<Coupon> getAllCoupons() {
        return couponRepository.findAll();
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

            couponRepository.save(coupon);
        }
    }
}

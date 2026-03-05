package Calorie.Coupon;

import jakarta.annotation.PostConstruct;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

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

    public ResponseEntity<Boolean> checkIfCouponIsValid(String couponCode) {
        couponCode = couponCode.trim().toUpperCase();

        //Kupon nem létezik
        if(!couponRepository.existsByCouponCode(couponCode)) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(false);
        }

        Coupon coupon = couponRepository.findCouponByCouponCode(couponCode);

        //Kupon létezik (használt vagy nem használt)
        return ResponseEntity.ok(!coupon.isUsed());
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

            couponRepository.save(coupon);
        }
    }
}

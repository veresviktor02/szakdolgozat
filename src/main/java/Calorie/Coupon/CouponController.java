package Calorie.Coupon;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@CrossOrigin(origins = "*")
@RequestMapping("coupons")
public class CouponController {
    private final CouponService couponService;

    public CouponController(CouponService couponService) {
        this.couponService = couponService;
    }

    @GetMapping("/validate")
    public ResponseEntity<Boolean> checkIfCouponIsValid(@RequestParam String couponCode) {
        return couponService.checkIfCouponIsValid(couponCode.trim().toUpperCase());
    }

    //Csak tesztelésre!
    @GetMapping()
    public List<Coupon> getAllCoupons() {
        return couponService.getAllCoupons();
    }
}

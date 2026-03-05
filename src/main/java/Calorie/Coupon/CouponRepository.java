package Calorie.Coupon;

import org.springframework.data.jpa.repository.JpaRepository;

public interface CouponRepository extends JpaRepository<Coupon, Integer> {
    boolean existsByCouponCode(String couponCode);

    Coupon findCouponByCouponCode(String couponCode);
}

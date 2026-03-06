package Calorie.Coupon;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface CouponRepository extends JpaRepository<Coupon, Integer> {
    boolean existsByCouponCode(String couponCode);

    Coupon findCouponByCouponCode(String couponCode);

    Optional<Coupon> findByCouponCode(String couponCode);
}

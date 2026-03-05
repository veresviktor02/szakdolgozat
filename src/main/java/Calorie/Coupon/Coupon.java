package Calorie.Coupon;

import com.fasterxml.jackson.annotation.JsonIgnore;

import jakarta.persistence.*;

@Entity
public class Coupon {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(unique = true)
    private String couponCode;

    //Ha "null", akkor nem volt felhasználva, nem kell külön "boolean used" mező!
    private Integer usedByUserId;

    public Coupon() {}

    public Coupon(Integer id, String couponCode, Integer usedByUserId) {
        this.id = id;
        setCouponCode(couponCode);
        this.usedByUserId = usedByUserId;
    }

    public Integer getId() {
        return id;
    }

    public String getCouponCode() {
        return couponCode;
    }

    public Integer getUsedByUserId() {
        return usedByUserId;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public void setCouponCode(String couponCode) {
        if(couponCode.length() < 5 || couponCode.length() > 20) {
            throw new IllegalArgumentException(
                    "A kuponkódnak 5 és 20 karakter között kell lennie!"
            );
        }

        this.couponCode = couponCode.trim().toUpperCase();
    }

    public void setUsedByUserId(Integer usedByUserId) {
        this.usedByUserId = usedByUserId;
    }

    //Csak a JSON kérésben jelenik meg, adatbázisban nem!
    @JsonIgnore
    public boolean isUsed() {
        return getUsedByUserId() != null;
    }

    @Override
    public String toString() {
        return "Kupon:" + '\n' +
                "ID: " + id + '\n' +
                "Kuponkód: " + couponCode + '\n' +
                "Felhasználva: " + usedByUserId;
    }
}

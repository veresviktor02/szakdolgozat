package Calorie.Coupon;

import com.fasterxml.jackson.annotation.JsonIgnore;

import jakarta.persistence.*;

import java.time.LocalDate;

@Entity
public class Coupon {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(unique = true)
    private String couponCode;

    //Ha "null", akkor nem volt felhasználva, nem kell külön "boolean used" mező!
    //Ne jelenlen meg a JSON kérésben, mint mező! Elég az "isUsed" függvény!
    @JsonIgnore
    private Integer usedByUserId;

    private LocalDate expirationDate;

    public Coupon() {}

    public Coupon(Integer id, String couponCode, Integer usedByUserId, LocalDate expirationDate) {
        this.id = id;
        setCouponCode(couponCode);
        this.usedByUserId = usedByUserId;
        this.expirationDate = expirationDate;
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

    public LocalDate getExpirationDate() {
        return expirationDate;
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

    public void setExpirationDate(LocalDate expirationDate) {
        this.expirationDate = expirationDate;
    }


    public boolean isUsed() {
        return getUsedByUserId() != null;
    }

    @JsonIgnore
    public boolean isExpired() {
        return getExpirationDate().isBefore(LocalDate.now());
    }

    @Override
    public String toString() {
        return "Kupon:" + '\n' +
                "ID: " + id + '\n' +
                "Kuponkód: " + couponCode + '\n' +
                "Felhasználva: " + usedByUserId;
    }
}

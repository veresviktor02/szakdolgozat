package Calorie.User;

import jakarta.persistence.*;

import java.util.Objects;

//Azért kell átnevezni, mert a PostgreSQL a "User" nevet használja már!!!
@Entity
@Table(name = "app_user")
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;
    private String name;
    private Double weight;
    private Double height;
    //Az annotáció nélkül 0,1-ként lenne eltárolva az adatbázisban!!!
    @Enumerated(EnumType.STRING)
    private UserType userType; //FREE, PREMIUM

    //Feltétel igenhez legyen: usertype == PREMIUM!!!
    private boolean differentDays;

    public User() {}

    public User(Integer id, String name, Double weight, Double height, UserType userType, boolean differentDays) {
        this.id = id;
        this.name = name;
        this.weight = weight;
        this.height = height;
        this.userType = userType;
        this.differentDays = differentDays;
    }

    public Integer getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public Double getWeight() {
        return weight;
    }

    public Double getHeight() {
        return height;
    }

    public UserType getUserType() {
        return userType;
    }

    public boolean isDifferentDays() {
        return differentDays;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setWeight(Double weight) {
        this.weight = weight;
    }

    public void setHeight(Double height) {
        this.height = height;
    }

    public void setUserType(UserType userType) {
        this.userType = userType;
    }

    public void setDifferentDays(boolean differentDays) {
        this.differentDays = differentDays;
    }

    @Override
    public boolean equals(Object o) {
        if(o == null || getClass() != o.getClass()) return false;
        User user = (User) o;
        return differentDays == user.differentDays && Objects.equals(id, user.id) && Objects.equals(name, user.name) && Objects.equals(weight, user.weight) && Objects.equals(height, user.height) && userType == user.userType;
    }

    @Override
    public int hashCode() {
        return Objects.hash(id, name, weight, height, userType, differentDays);
    }

    @Override
    public String toString() {
        return "User: " + '\n' +
                "id = " + id + '\n' +
                "name = " + name + '\n' +
                "weight = " + weight + '\n' +
                "height = " + height + '\n' +
                "userType = " + userType + '\n' +
                "differentDays = " + differentDays;
    }
}

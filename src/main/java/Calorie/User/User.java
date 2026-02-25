package Calorie.User;

import Calorie.Food.KcalAndNutrients;
import jakarta.persistence.*;

import java.util.ArrayList;
import java.util.List;
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

    private boolean differentDays;

    @ElementCollection
    private List<KcalAndNutrients> dailyTarget = new ArrayList<>(7);

    public User() {}

    public User(
            Integer id,
            String name,
            Double weight,
            Double height,
            UserType userType,
            boolean differentDays,
            List<KcalAndNutrients> dailyTarget
    ) {
        this.id = id;
        setName(name);
        setWeight(weight);
        setHeight(height);
        this.userType = userType;
        setDifferentDays(differentDays);
        setDailyTarget(dailyTarget);
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

    public List<KcalAndNutrients> getDailyTarget() {
        return dailyTarget;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public void setName(String name) {
        if(name.length() < 3 || name.length() > 20) {
            throw new IllegalArgumentException(
                    "A névnek 3 és 20 karakter között kell lennie!"
            );
        }

        this.name = name;
    }

    public void setWeight(Double weight) {
        if(weight < 40 || weight > 250) {
            throw new IllegalArgumentException(
                    "Túl alacsony vagy magas súly!"
            );
        }

        this.weight = weight;
    }

    public void setHeight(Double height) {
        if(height < 100 || height > 250) {
            throw new IllegalArgumentException(
                    "Túl alacsony vagy magas magasság!"
            );
        }

        this.height = height;
    }

    public void setUserType(UserType userType) {
        this.userType = userType;
    }

    public void setDifferentDays(boolean differentDays) {
        if(getUserType() == UserType.FREE && differentDays) {
            throw new IllegalArgumentException(
                    "FREE felhasználó nem használhatja ezt a funkciót!"
            );
        }

        this.differentDays = differentDays;
    }

    public void setDailyTarget(List<KcalAndNutrients> dailyTarget) {
        if(dailyTarget == null || dailyTarget.isEmpty()) {
            this.dailyTarget = List.of(
                    new KcalAndNutrients(0.0, 0.0, 0.0, 0.0),
                    new KcalAndNutrients(0.0, 0.0, 0.0, 0.0),
                    new KcalAndNutrients(0.0, 0.0, 0.0, 0.0),
                    new KcalAndNutrients(0.0, 0.0, 0.0, 0.0),
                    new KcalAndNutrients(0.0, 0.0, 0.0, 0.0),
                    new KcalAndNutrients(0.0, 0.0, 0.0, 0.0),
                    new KcalAndNutrients(0.0, 0.0, 0.0, 0.0)
            );
        }

        if(getUserType() == UserType.FREE) {
            for(int i = 1; i < Objects.requireNonNull(dailyTarget).size(); i++) {
                if(!dailyTarget.getFirst().equals(dailyTarget.get(i))) {
                    throw new IllegalArgumentException(
                            "FREE felhasználó nem használhatja ezt a funkciót!"
                    );
                }
            }
        }

        if(dailyTarget != null &&
            !dailyTarget.isEmpty() &&
            !isDifferentDays() &&
            !Objects.equals(
                    dailyTarget.getFirst().getKcal(),
                    dailyTarget.get(1).getKcal()
                )
        ) {
            throw new IllegalArgumentException(
                    "Nem használható ez a funkció, ha differentDays hamis!"
            );
        }

        this.dailyTarget = dailyTarget;
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
                "differentDays = " + differentDays + '\n' +
                "dailyTarget = " + dailyTarget;
    }
}

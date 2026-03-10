package Calorie.Food;

import Calorie.User.User;

import com.fasterxml.jackson.annotation.JsonBackReference;

import jakarta.persistence.*;

import java.util.Objects;

@Entity
@Table(name = "food")
public class Food {
    //Wrapper osztály, mert JSON-ban nem lehet null, Spring boot utólag ad neki értéket!
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    private String name;

    //Összetett adattípushoz kell! Nem külön adatbáziselem, nincs idegenkulcs, stb.!
    @Embedded
    private KcalAndNutrients kcalAndNutrients;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    @JsonBackReference //Ettől nem lesz rekurzív a JSON!
    private User owner;

    public Food() {}

    public Food(Integer id, String name, KcalAndNutrients kcalAndNutrients,  User owner) {
        this.id = id;
        setName(name);
        this.kcalAndNutrients = kcalAndNutrients;
        this.owner = owner;
    }

    public Integer getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public KcalAndNutrients getKcalAndNutrients() {
        return kcalAndNutrients;
    }

    public User getOwner() {
        return owner;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public void setName(String name) {
        if(name.length() < 2 || name.length() > 40) {
            throw new IllegalArgumentException(
                    "A névnek 2 és 40 karakter között kell lennie!"
            );
        }

        this.name = name;
    }

    public void setKcalAndNutrients(KcalAndNutrients kcalAndNutrients) {
        this.kcalAndNutrients = kcalAndNutrients;
    }

    public void setOwner(User owner) {
        this.owner = owner;
    }

    @Override
    public boolean equals(Object o) {
        if(o == null || getClass() != o.getClass()) return false;
        Food food = (Food) o;
        return Objects.equals(id, food.id) &&
                Objects.equals(name, food.name) &&
                Objects.equals(kcalAndNutrients, food.kcalAndNutrients);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id, name, kcalAndNutrients);
    }

    @Override
    public String toString() {
        return "Food: " + '\n' +
                "id = " + id + '\n' +
                "name = " + name + '\n' +
                "KcalAndNutrients = " + kcalAndNutrients;
    }
}

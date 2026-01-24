package Calorie.Food;

import jakarta.persistence.*;

import java.util.Objects;

@Entity
public class Food {
    //Wrapper osztály, mert JSON-ban nem lehet null, Spring boot utólag ad neki értéket!
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;
    private String name;
    //Összetett adattípushoz kell! Nem külön adatbáziselem, nincs idegenkulcs, stb.!
    @Embedded
    private KcalAndNutrients kcalAndNutrients;

    public Food() {}

    public Food(Integer id, String name, KcalAndNutrients kcalAndNutrients) {
        this.id = id;
        this.name = name;
        this.kcalAndNutrients = kcalAndNutrients;
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

    public void setId(Integer id) {
        this.id = id;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setKcalAndNutrients(KcalAndNutrients kcalAndNutrients) {
        this.kcalAndNutrients = kcalAndNutrients;
    }

    @Override
    public boolean equals(Object o) {
        if(o == null || getClass() != o.getClass()) return false;
        Food food = (Food) o;
        return id == food.id && Objects.equals(name, food.name) && Objects.equals(kcalAndNutrients, food.kcalAndNutrients);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id, name, kcalAndNutrients);
    }

    @Override
    public String toString() {
        return "Food: " + '\n' +
                "id = " + id + '\n' +
                "name='" + name + '\n' +
                kcalAndNutrients;
    }
}

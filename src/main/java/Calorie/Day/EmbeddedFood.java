package Calorie.Day;

import Calorie.Food.KcalAndNutrients;
import jakarta.persistence.*;

import java.util.Objects;

@Entity
public class EmbeddedFood {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;
    private String name;

    @Embedded
    private KcalAndNutrients kcalAndNutrients;

    public EmbeddedFood() {}

    public EmbeddedFood(Integer id, String name, KcalAndNutrients kcalAndNutrients) {
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
        EmbeddedFood food = (EmbeddedFood) o;
        return id == food.id && Objects.equals(name, food.name) && Objects.equals(kcalAndNutrients, food.kcalAndNutrients);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id, name, kcalAndNutrients);
    }

    @Override
    public String toString() {
        return "Food in day: " + '\n' +
                "id = " + id + '\n' +
                "name = " + name + '\n' +
                kcalAndNutrients;
    }
}

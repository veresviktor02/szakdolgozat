package Calorie.Day;

import Calorie.Day.MeasurementUnit.MeasurementUnit;

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
    //Ez 100 grammonként értendő!
    private KcalAndNutrients kcalAndNutrients;

    private double foodWeight;

    @ManyToOne
    @JoinColumn(name = "measurement_unit_id")
    private MeasurementUnit measurementUnit;

    public EmbeddedFood() {}

    public EmbeddedFood(
            Integer id,
            String name,
            KcalAndNutrients kcalAndNutrients,
            double foodWeight,
            MeasurementUnit measurementUnit
    ) {
        this.id = id;
        this.name = name;
        this.kcalAndNutrients = kcalAndNutrients;
        setFoodWeight(foodWeight);
        this.measurementUnit = measurementUnit;
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

    public double getFoodWeight() {
        return foodWeight;
    }

    public MeasurementUnit getMeasurementUnit() {
        return measurementUnit;
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

    public void setFoodWeight(double foodWeight) {
        if(foodWeight < 0) {
            throw new IllegalArgumentException(
                    "Az étel súlya nem lehet negatív!"
            );
        }
        this.foodWeight = foodWeight;
    }

    public void setMeasurementUnit(MeasurementUnit measurementUnit) {
        this.measurementUnit = measurementUnit;
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
        return "Étel a napban: " + '\n' +
                "ID = " + id + '\n' +
                "Név = " + name + '\n' +
                "Tápanyag információ: " + kcalAndNutrients + '\n' +
                "Tömeg: " + foodWeight;
    }
}

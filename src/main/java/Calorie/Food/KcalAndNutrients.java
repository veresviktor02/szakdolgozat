package Calorie.Food;

import jakarta.persistence.Embeddable;

import java.util.Objects;

//Azt jelzi, hogy nem egy külön entitás, hanem összetett adattípus!
@Embeddable
public class KcalAndNutrients {
    private Double kcal;
    private Double fat;
    private Double carb;
    private Double protein;

    public KcalAndNutrients() {}

    public KcalAndNutrients(Double kcal, Double fat, Double carb, Double protein) {
        this.kcal = kcal;
        this.fat = fat;
        this.carb = carb;
        this.protein = protein;
    }

    public Double getKcal() {
        return kcal;
    }

    public Double getFat() {
        return fat;
    }

    public Double getCarb() {
        return carb;
    }

    public Double getProtein() {
        return protein;
    }

    public void setKcal(Double kcal) {
        this.kcal = kcal;
    }

    public void setFat(Double fat) {
        this.fat = fat;
    }

    public void setCarb(Double carb) {
        this.carb = carb;
    }

    public void setProtein(Double protein) {
        this.protein = protein;
    }

    @Override
    public boolean equals(Object o) {
        if(o == null || getClass() != o.getClass()) return false;
        KcalAndNutrients that = (KcalAndNutrients) o;
        return Objects.equals(kcal, that.kcal) && Objects.equals(fat, that.fat) && Objects.equals(carb, that.carb) && Objects.equals(protein, that.protein);
    }

    @Override
    public int hashCode() {
        return Objects.hash(kcal, fat, carb, protein);
    }

    @Override
    public String toString() {
        return "KcalAndNutrients: " + '\n' +
                "kcal = " + kcal + '\n' +
                "fat = " + fat + '\n' +
                "carb = " + carb + '\n' +
                "protein = " + protein;
    }
}

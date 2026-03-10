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
        checkIfCaloriesAreLess(kcal, fat, carb, protein);

        //Nem a settert hívjuk meg, mert kezdetben még nincs beállítva semmi,
        //amit lehetne mérni (null).
        checkIfNutrientIsNegative(kcal, "Kcal");
        checkIfNutrientIsNegative(fat, "Fat");
        checkIfNutrientIsNegative(carb, "Carb");
        checkIfNutrientIsNegative(protein, "Protein");

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
        checkIfNutrientIsNegative(kcal, "Kcal");
        checkIfCaloriesAreLess(kcal, getFat(), getCarb(), getProtein());

        this.kcal = kcal;
    }

    public void setFat(Double fat) {
        checkIfNutrientIsNegative(fat, "Fat");
        checkIfCaloriesAreLess(getKcal(), fat, getCarb(), getProtein());

        this.fat = fat;
    }

    public void setCarb(Double carb) {
        checkIfNutrientIsNegative(carb, "Carb");
        checkIfCaloriesAreLess(getKcal(), getFat(), carb, getProtein());

        this.carb = carb;
    }

    public void setProtein(Double protein) {
        checkIfNutrientIsNegative(protein, "Protein");
        checkIfCaloriesAreLess(getKcal(), getFat(), getCarb(), protein);

        this.protein = protein;
    }

    public void checkIfNutrientIsNegative(double nutrient, String nutrientName) {
        if(nutrient < 0) {
            throw new IllegalArgumentException(nutrientName + " nem lehet negatív!");
        }
    }

    public void checkIfCaloriesAreLess(Double kcal, Double fat, Double carb, Double protein) {
        if(kcal < fat * 9 + carb * 4 + protein * 4) {
            throw new IllegalArgumentException("Túl sok kalória a nutríciók értéke!");
        }
    }

    @Override
    public boolean equals(Object o) {
        if(o == null || getClass() != o.getClass()) return false;
        KcalAndNutrients that = (KcalAndNutrients) o;
        return Objects.equals(kcal, that.kcal) &&
                Objects.equals(fat, that.fat) &&
                Objects.equals(carb, that.carb) &&
                Objects.equals(protein, that.protein);
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

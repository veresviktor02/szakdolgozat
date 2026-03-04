package Calorie.API;

import com.fasterxml.jackson.annotation.JsonProperty;

public class Nutritions {
    private String name;
    private Double calories;

    @JsonProperty("serving_size_g")
    private Double servingSizeG;

    @JsonProperty("protein_g")
    private Double proteinG;

    @JsonProperty("fat_total_g")
    private Double fatTotalG;

    @JsonProperty("carbohydrates_total_g")
    private Double carbohydratesTotalG;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Double getCalories() {
        return calories;
    }

    public void setCalories(Double calories) {
        this.calories = calories;
    }

    public Double getServingSizeG() {
        return servingSizeG;
    }

    public void setServingSizeG(Double servingSizeG) {
        this.servingSizeG = servingSizeG;
    }

    public Double getProteinG() {
        return proteinG;
    }

    public void setProteinG(Double proteinG) {
        this.proteinG = proteinG;
    }

    public Double getFatTotalG() {
        return fatTotalG;
    }

    public void setFatTotalG(Double fatTotalG) {
        this.fatTotalG = fatTotalG;
    }

    public Double getCarbohydratesTotalG() {
        return carbohydratesTotalG;
    }

    public void setCarbohydratesTotalG(Double carbohydratesTotalG) {
        this.carbohydratesTotalG = carbohydratesTotalG;
    }
}

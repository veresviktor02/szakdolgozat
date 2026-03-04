package Calorie.API;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.util.List;

public class NutritionResponse {
    @JsonProperty("items")
    private List<Nutritions> nutritionsList;

    public List<Nutritions> getNutritionsList() {
        return nutritionsList;
    }

    public void setNutritionsList(List<Nutritions> nutritionsList) {
        this.nutritionsList = nutritionsList;
    }
}

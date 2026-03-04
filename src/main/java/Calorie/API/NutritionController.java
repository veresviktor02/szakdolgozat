package Calorie.API;

import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")
public class NutritionController {
    private final NutritionService nutritionService;

    public NutritionController(NutritionService nutritionService) {
        this.nutritionService = nutritionService;
    }

    @GetMapping
    public NutritionResponse getNutrition(@RequestParam String query) {
        return nutritionService.getNutrition(query);
    }
}

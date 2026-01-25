package Calorie.Food;

import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("foods")
public class FoodController {
    private final FoodService foodService;
    public FoodController(FoodService foodService) {
        this.foodService = foodService;
    }

    @GetMapping
    public List<Food> getFoods() {
        return foodService.getAllFoods();
    }

    @GetMapping("{id}")
    public Food getFoodById(@PathVariable Integer id) {
        return foodService.getFoodById(id);
    }

    @PostMapping
    public void addNewFood(@RequestBody Food food) {
        foodService.insertFood(food);
    }

    @DeleteMapping("{id}")
    public void deleteFoodById(@PathVariable Integer id) {
        foodService.deleteFoodById(id);
    }

    @PutMapping("{id}")
    public void updateFoodById(@PathVariable Integer id, @RequestBody Food food) {
        foodService.updateFoodById(id, food);
    }

    /*
        void helyett ResponseEntity<String> kell!!!

        return ResponseEntity
            .status(HttpStatus.CREATED) // HTTP 201
            .body("Food " + food.getName() + " created successfully!");
     */
}

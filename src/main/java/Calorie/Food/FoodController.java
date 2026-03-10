package Calorie.Food;

import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@CrossOrigin(origins = "*")
@RequestMapping("foods")
public class FoodController {
    private final FoodService foodService;

    public FoodController(FoodService foodService) {
        this.foodService = foodService;
    }

    //GET
    @GetMapping("/{id}")
    public List<Food> getFoodsByUserId(@PathVariable Integer id) {
        return foodService.getFoodsByUserId(id);
    }

    @GetMapping("/foodById/{id}")
    public Food getFoodById(@PathVariable Integer id) {
        return foodService.getFoodById(id);
    }

    ///////////////////////////////////////////////////////////////////////////////

    //POST
    @PostMapping("{userId}")
    public void addNewFood(@PathVariable Integer userId, @RequestBody Food food) {
        foodService.insertFood(userId, food);
    }

    ///////////////////////////////////////////////////////////////////////////////

    //PUT
    @PutMapping("{id}")
    public void updateFoodById(@PathVariable Integer id, @RequestBody Food food) {
        foodService.updateFoodById(id, food);
    }

    ///////////////////////////////////////////////////////////////////////////////

    //DELETE
    @DeleteMapping("{id}")
    public void deleteFoodById(@PathVariable Integer id) {
        foodService.deleteFoodById(id);
    }
}

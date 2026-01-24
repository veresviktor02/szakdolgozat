package Calorie.Food;

import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class FoodService {
    private FoodRepository foodRepository;

    public FoodService(FoodRepository foodRepository) {
        this.foodRepository = foodRepository;
    }

    public List<Food> getAllFoods() {
        return foodRepository.findAll();
    }

    public void insertFood(Food food) {
        foodRepository.save(food);
    }

    public Food getFoodById(Integer id) {
        return foodRepository.findById(id)
                .orElseThrow(() -> new IllegalStateException(id + " not found."));
    }
}

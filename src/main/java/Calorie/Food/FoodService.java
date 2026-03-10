package Calorie.Food;

import Calorie.User.User;
import Calorie.User.UserRepository;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class FoodService {
    private final FoodRepository foodRepository;
    private final UserRepository userRepository;

    public FoodService(FoodRepository foodRepository, UserRepository userRepository) {
        this.foodRepository = foodRepository;
        this.userRepository = userRepository;
    }

    public List<Food> getFoodsByUserId(Integer userId) {
        return foodRepository.findByOwnerId(userId);
    }

    public void insertFood(Integer userId, Food food) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalStateException(
                        "A megadott felhasználó nem található! (ID: " + userId + ')'
                ));

        food.setOwner(user);

        foodRepository.save(food);
    }

    @Transactional
    public void updateFoodById(Integer foodId, Food newFood) {
        Food oldFood = foodRepository.findById(foodId).orElseThrow(
                () -> new IllegalStateException(
                        "A frissíteni kívánt étel nem található! (ID: " + foodId + ')'
                ));

        oldFood.setName(newFood.getName());
        oldFood.setKcalAndNutrients(newFood.getKcalAndNutrients());
    }

    public void deleteFoodById(Integer id) {
        if(!foodRepository.existsById(id)) {
            throw new IllegalStateException(
                    "A törölni kívánt étel nem található! (ID: " + id + ')'
            );
        }

        foodRepository.deleteById(id);
    }

    public Food getFoodById(Integer id) {
        return foodRepository.findById(id)
                .orElseThrow(() -> new IllegalStateException(
                        "A megadott ID nem található! (" + id + ')'
                ));
    }
}

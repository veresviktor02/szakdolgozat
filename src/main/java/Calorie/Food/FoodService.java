package Calorie.Food;

import Calorie.Exceptions.FoodException;
import Calorie.Exceptions.UserException;

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
        try {
            return foodRepository.findByOwnerId(userId);
        } catch(Exception e) {
            throw new FoodException("foodRepository.findByOwnerId(userId) hibát dobott!", e);
        }
    }

    public void insertFood(Integer userId, Food food) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new UserException(
                        "A megadott felhasználó nem található! (ID: " + userId + ')'
                ));

        food.setOwner(user);

        try {
            foodRepository.save(food);
        } catch(Exception e) {
            throw new FoodException("foodRepository.save(food) hibát dobott!", e);
        }
    }

    @Transactional
    public void updateFoodById(Integer foodId, Food newFood) {
        Food oldFood = foodRepository.findById(foodId).orElseThrow(
                () -> new FoodException(
                        "A frissíteni kívánt étel nem található! (ID: " + foodId + ')'
                ));

        oldFood.setName(newFood.getName());
        oldFood.setKcalAndNutrients(newFood.getKcalAndNutrients());
    }

    public void deleteFoodById(Integer id) {
        if(!foodRepository.existsById(id)) {
            throw new FoodException(
                    "A törölni kívánt étel nem található! (ID: " + id + ')'
            );
        }

        try {
            foodRepository.deleteById(id);
        } catch(Exception e) {
            throw new FoodException("foodRepository.deleteById(id) hibát dobott!", e);
        }
    }

    public Food getFoodById(Integer userId, Integer foodId) {
        return foodRepository.findByIdAndOwnerId(foodId, userId)
                .orElseThrow(() -> new FoodException(
                        "A megadott ID nem található! (" + foodId + ')'
                ));
    }
}

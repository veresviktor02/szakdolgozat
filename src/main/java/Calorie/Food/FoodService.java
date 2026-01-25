package Calorie.Food;

import jakarta.transaction.Transactional;
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

    //Csak frissítéshez használjuk, új rekord beszúrásához nem!
    //@Transactional - ne vesszenek el a módosítások!!!
    @Transactional
    public void updateFoodById(Integer id, Food newFood) {
        Food oldFood = foodRepository.findById(id).orElseThrow(
                () -> new IllegalStateException(
                        "A frissíteni kívánt étel nem található! (ID: " + id + ')'
                ));

        oldFood.setName(newFood.getName());
        oldFood.setKcalAndNutrients(newFood.getKcalAndNutrients());
    }

    public void deleteFoodById(Integer id) {
        foodRepository.deleteById(id);
    }

    public Food getFoodById(Integer id) {
        return foodRepository.findById(id)
                .orElseThrow(() -> new IllegalStateException(
                        "A megadott ID nem található! (" + id + ')'
                ));
    }
}

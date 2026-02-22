package Calorie.FoodTest;

import Calorie.Food.Food;
import Calorie.Food.FoodRepository;
import Calorie.Food.KcalAndNutrients;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;


//@DataJpaTest
@SpringBootTest
class FoodRepositoryTest {
    @Autowired
    private FoodRepository foodRepository;

    @Test
    void saveAndLoadFood() {
        Food food = new Food(
                null,
                "Apple",
                new KcalAndNutrients(
                        100.0,
                        0.2,
                        14.0,
                        0.3
                )
        );

        Food saved = foodRepository.save(food);

        Food found = foodRepository.findById(saved.getId()).orElseThrow();

        assertEquals(food.getName(), found.getName());

        assertEquals(food.getKcalAndNutrients().getKcal(), found.getKcalAndNutrients().getKcal());

        assertEquals(food.getKcalAndNutrients().getProtein(), found.getKcalAndNutrients().getProtein());
    }
}
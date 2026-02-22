package Calorie.FoodTest;

import Calorie.Food.Food;
import Calorie.Food.FoodController;
import Calorie.Food.FoodService;
import Calorie.Food.KcalAndNutrients;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

class FoodControllerTest {

    @Test
    void getFoods_shouldReturnList() {

        FoodService service = mock(FoodService.class);

        FoodController controller = new FoodController(service);

        Food food = new Food(
                1,
                "Apple",
                new KcalAndNutrients(
                        52.0,
                        0.2,
                        14.0, 0.3
                )
        );

        when(service.getAllFoods()).thenReturn(List.of(food));

        List<Food> foodList = controller.getFoods();

        assertEquals(food.getId(), foodList.size());
        assertEquals(food.getName(), foodList.get(0).getName());
    }
}
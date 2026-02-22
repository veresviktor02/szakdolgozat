package Calorie.FoodTest;

import Calorie.Food.Food;
import Calorie.Food.FoodRepository;
import Calorie.Food.FoodService;
import Calorie.Food.KcalAndNutrients;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class FoodServiceTest {
    @Mock
    private FoodRepository foodRepository;

    @InjectMocks
    private FoodService foodService;

    private Food apple;

    @BeforeEach
    void init() {
        apple = new Food(
                1,
                "Apple",
                new KcalAndNutrients(
                        100.0,
                        0.2,
                        14.0,
                        0.3
                )
        );
    }

    @Test
    void getAllFoodsShouldReturnFoods() {
        when(foodRepository.findAll()).thenReturn(List.of(apple));

        List<Food> foodList = foodService.getAllFoods();

        assertEquals(
                apple.getId(),
                foodList.get(0).getId()
        );

        assertEquals(
                apple.getName(),
                foodList.get(0).getName()
        );

        assertEquals(
                apple.getKcalAndNutrients(),
                foodList.get(0).getKcalAndNutrients()
        );

        assertEquals(
                apple.getKcalAndNutrients().getKcal(),
                foodList.get(0).getKcalAndNutrients().getKcal()
        );

        assertEquals(
                apple.getKcalAndNutrients().getFat(),
                foodList.get(0).getKcalAndNutrients().getFat()
        );

        assertEquals(
                apple.getKcalAndNutrients().getCarb(),
                foodList.get(0).getKcalAndNutrients().getCarb()
        );

        assertEquals(
                apple.getKcalAndNutrients().getProtein(),
                foodList.get(0).getKcalAndNutrients().getProtein()
        );

        verify(foodRepository).findAll();
    }

    @Test
    void getFoodByIdShouldReturnFood() {
        when(foodRepository.findById(1)).thenReturn(Optional.of(apple));

        Food result = foodService.getFoodById(1);

        assertEquals(
                apple.getId(),
                result.getId()
        );

        assertEquals(
                apple.getName(),
                result.getName()
        );

        assertEquals(
                apple.getKcalAndNutrients(),
                result.getKcalAndNutrients()
        );

        assertEquals(
                apple.getKcalAndNutrients().getKcal(),
                result.getKcalAndNutrients().getKcal()
        );

        assertEquals(
                apple.getKcalAndNutrients().getFat(),
                result.getKcalAndNutrients().getFat()
        );

        assertEquals(
                apple.getKcalAndNutrients().getCarb(),
                result.getKcalAndNutrients().getCarb()
        );

        assertEquals(
                apple.getKcalAndNutrients().getProtein(),
                result.getKcalAndNutrients().getProtein()
        );
    }

    @Test
    void getFoodByIdShouldThrowIfNotFound() {
        when(foodRepository.findById(1)).thenReturn(Optional.empty());

        assertThrows(
                IllegalStateException.class,
                () -> foodService.getFoodById(1)
        );
    }

    @Test
    void insertFoodShouldCallSave() {
        foodService.insertFood(apple);

        verify(foodRepository).save(apple);
    }

    @Test
    void deleteFoodShouldCallDelete() {
        foodService.deleteFoodById(1);

        verify(foodRepository).deleteById(1);
    }

    @Test
    void updateFoodShouldUpdateFields() {
        Food banana = new Food(
                2,
                "Banana",
                new KcalAndNutrients(
                        89.0,
                        0.3,
                        23.0,
                        1.1
                )
        );

        when(foodRepository.findById(1)).thenReturn(Optional.of(apple));

        foodService.updateFoodById(1, banana);

        assertNotEquals(
                banana.getId(),
                apple.getId()
        );

        assertEquals(
                banana.getName(),
                apple.getName()
        );

        assertEquals(
                banana.getKcalAndNutrients(),
                apple.getKcalAndNutrients()
        );

        assertEquals(
                banana.getKcalAndNutrients().getKcal(),
                apple.getKcalAndNutrients().getKcal()
        );

        assertEquals(
                banana.getKcalAndNutrients().getFat(),
                apple.getKcalAndNutrients().getFat()
        );

        assertEquals(
                banana.getKcalAndNutrients().getCarb(),
                apple.getKcalAndNutrients().getCarb()
        );

        assertEquals(
                banana.getKcalAndNutrients().getProtein(),
                apple.getKcalAndNutrients().getProtein()
        );
    }

    @Test
    void updateFoodShouldThrowIfNotFound() {
        when(foodRepository.findById(1)).thenReturn(Optional.empty());

        assertThrows(
                IllegalStateException.class,
                () -> foodService.updateFoodById(1, apple)
        );
    }
}
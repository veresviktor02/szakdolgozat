package Calorie.DayTest;

import java.time.LocalDate;

import java.util.List;

import Calorie.Day.Day;
import Calorie.Day.EmbeddedFood;

import Calorie.Food.KcalAndNutrients;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertEquals;

public class DayTest {
    @Test
    void constructorShouldCreateDayWithEmptyFoodList() {
        Day day = new Day(
                1,
                LocalDate.of(2026, 2, 25),
                List.of()
        );

        assertEquals(
                day.getFoodList(),
                List.of()
        );
    }

    @Test
    void constructorShouldCreateDayWithNotEmptyFoodList() {
        EmbeddedFood food1 = new EmbeddedFood(
                1,
                "Teszt étel1",
                new KcalAndNutrients(0.0, 0.0, 0.0, 0.0)
        );

        EmbeddedFood food2 = new EmbeddedFood(
                1,
                "Teszt étel2",
                new KcalAndNutrients(0.0, 0.0, 0.0, 0.0)
        );

        List<EmbeddedFood> foodList = List.of(food1, food2);

        Day day = new Day(
                1,
                LocalDate.of(2026, 2, 25),
                List.of(food1, food2)
        );

        assertEquals(
                day.getFoodList(),
                foodList
        );
    }
}

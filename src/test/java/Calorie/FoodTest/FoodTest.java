package Calorie.FoodTest;

import Calorie.Food.Food;
import Calorie.Food.KcalAndNutrients;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

public class FoodTest {

    @Test
    void constructorShouldThrowIfTooLongOrTooShort() {
        assertThrows(
                IllegalArgumentException.class,
                () -> new Food(
                        1,
                        "",
                        new KcalAndNutrients(0.0, 0.0, 0.0, 0.0)
                )
        );
    }

    @Test
    void setNameShouldThrowIfTooLongOrTooShort() {
        Food food = new Food(
                1,
                "Teszt étel",
                new KcalAndNutrients(0.0, 0.0, 0.0, 0.0)
        );
        assertThrows(
                IllegalArgumentException.class,
                () -> food.setName("")
        );

        assertThrows(
                IllegalArgumentException.class,
                () -> food.setName(
                        "Megszentségteleníthetetlenségeskedéseitekért " +
                              "elkelkáposztástalanítottátok"
                )
        );
    }

    @Test
    void setNameShouldUpdateField() {
        Food food = new Food();

        String name = "Teszt név";

        food.setName(name);

        assertEquals(name, food.getName());

        name = "Só";

        food.setName(name);

        assertEquals(name, food.getName());

        name = "0123456789012345678901234567890123456789";

        food.setName(name);

        assertEquals(name, food.getName());


    }
}

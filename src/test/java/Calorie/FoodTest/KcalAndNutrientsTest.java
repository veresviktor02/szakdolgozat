package Calorie.FoodTest;

import Calorie.Food.KcalAndNutrients;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

class KcalAndNutrientsTest {
    @Test
    void testKcalAndNutrientsConstructorShouldThrowIfArgumentIsNegative() {
        assertThrows(
                IllegalArgumentException.class,
                () -> new KcalAndNutrients(-1.0, 0.0, 0.0, 0.0)
        );

        assertThrows(
                IllegalArgumentException.class,
                () -> new KcalAndNutrients(0.0, -1.0, 0.0, 0.0)
        );

        assertThrows(
                IllegalArgumentException.class,
                () -> new KcalAndNutrients(0.0, 0.0, -1.0, 0.0)
        );

        assertThrows(
                IllegalArgumentException.class,
                () -> new KcalAndNutrients(0.0, 0.0, 0.0, -1.0)
        );
    }

    @Test
    void testKcalAndNutrientsConstructorShouldThrowIfCaloriesAreLess() {
        assertThrows(
                IllegalArgumentException.class,
                () -> new KcalAndNutrients(0.0, 1.0, 0.0, 0.0)
        );

        assertThrows(
                IllegalArgumentException.class,
                () -> new KcalAndNutrients(0.0, 0.0, 1.0, 0.0)
        );

        assertThrows(
                IllegalArgumentException.class,
                () -> new KcalAndNutrients(0.0, 0.0, 0.0, 1.0)
        );
    }

    @Test
    void setKcalShouldUpdateField() {
        KcalAndNutrients kcalAndNutrients = new KcalAndNutrients(
                0.0,
                0.0,
                0.0,
                0.0
        );

        kcalAndNutrients.setKcal(0.0);
        assertEquals(kcalAndNutrients.getKcal(), 0.0);

        kcalAndNutrients.setKcal(100.0);
        assertEquals(kcalAndNutrients.getKcal(), 100.0);
    }

    @Test
    void setFatShouldUpdateField() {
        KcalAndNutrients kcalAndNutrients = new KcalAndNutrients(
                1000.0,
                0.0,
                0.0,
                0.0
        );

        kcalAndNutrients.setFat(0.0);
        assertEquals(kcalAndNutrients.getFat(), 0.0);

        kcalAndNutrients.setFat(100.0);
        assertEquals(kcalAndNutrients.getFat(), 100.0);
    }

    @Test
    void setCarbShouldUpdateField() {
        KcalAndNutrients kcalAndNutrients = new KcalAndNutrients(
                1000.0,
                0.0,
                0.0,
                0.0
        );

        kcalAndNutrients.setCarb(0.0);
        assertEquals(kcalAndNutrients.getCarb(), 0.0);

        kcalAndNutrients.setCarb(100.0);
        assertEquals(kcalAndNutrients.getCarb(), 100.0);
    }

    @Test
    void setProteinShouldUpdateField() {
        KcalAndNutrients kcalAndNutrients = new KcalAndNutrients(
                1000.0,
                0.0,
                0.0,
                0.0
        );

        kcalAndNutrients.setProtein(0.0);
        assertEquals(kcalAndNutrients.getProtein(), 0.0);

        kcalAndNutrients.setProtein(100.0);
        assertEquals(kcalAndNutrients.getProtein(), 100.0);
    }

    @Test
    void setKcalAndNutrientsShouldThrowIfNegative() {
        KcalAndNutrients kcalAndNutrients = new KcalAndNutrients(
                0.0,
                0.0,
                0.0,
                0.0
        );

        assertThrows(
                IllegalArgumentException.class,
                () -> kcalAndNutrients.setKcal(-1.0)
        );

        assertThrows(
                IllegalArgumentException.class,
                () -> kcalAndNutrients.setFat(-1.0)
        );

        assertThrows(
                IllegalArgumentException.class,
                () -> kcalAndNutrients.setCarb(-1.0)
        );

        assertThrows(
                IllegalArgumentException.class,
                () -> kcalAndNutrients.setProtein(-1.0)
        );
    }

    @Test
    void setKcalAndNutrientsShouldThrowIfCaloriesAreLess() {
                //170 = 10 * 9 + 10 * 4 + 10 * 4
        KcalAndNutrients setterTestKcalAndNutrients = new KcalAndNutrients(
                170.0,
                10.0,
                10.0,
                10.0
        );

        assertThrows(
                IllegalArgumentException.class,
                () -> setterTestKcalAndNutrients.setKcal(100.0)
        );

        assertThrows(
                IllegalArgumentException.class,
                () -> setterTestKcalAndNutrients.setFat(100.0)
        );

        assertThrows(
                IllegalArgumentException.class,
                () -> setterTestKcalAndNutrients.setCarb(100.0)
        );

        assertThrows(
                IllegalArgumentException.class,
                () -> setterTestKcalAndNutrients.setProtein(100.0)
        );
    }
}

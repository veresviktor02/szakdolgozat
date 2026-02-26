package Calorie.UserTest;

import Calorie.Food.KcalAndNutrients;

import Calorie.User.User;
import Calorie.User.UserType;

import java.util.List;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

class UserTest {
    @Test
    void constructorShouldThrowIfArgumentsAreWrong() {
        //Név túl rövid.
        assertThrows(
                IllegalArgumentException.class,
                () -> new User(
                        1,
                        "",
                        100.0,
                        100.0,
                        UserType.FREE,
                        false,
                        List.of()
                )
        );

        //Név túl hosszú.
        assertThrows(
                IllegalArgumentException.class,
                () -> new User(
                        1,
                        "Giacomino, Guardiano Delle Galassie E Dell'Iperspazio",
                        100.0,
                        100.0,
                        UserType.FREE,
                        false,
                        List.of()
                )
        );

        //Súly túl nagy.
        assertThrows(
                IllegalArgumentException.class,
                () -> new User(
                        1,
                        "Teszt",
                        1000.0,
                        100.0,
                        UserType.FREE,
                        false,
                        List.of()
                )
        );

        //Súly túl kicsi.
        assertThrows(
                IllegalArgumentException.class,
                () -> new User(
                        1,
                        "Teszt",
                        10.0,
                        100.0,
                        UserType.FREE,
                        false,
                        List.of()
                )
        );

        //Magasság túl nagy.
        assertThrows(
                IllegalArgumentException.class,
                () -> new User(
                        1,
                        "Teszt",
                        100.0,
                        1000.0,
                        UserType.FREE,
                        false,
                        List.of()
                )
        );

        //Magasság túl kicsi.
        assertThrows(
                IllegalArgumentException.class,
                () -> new User(
                        1,
                        "teszt",
                        100.0,
                        10.0,
                        UserType.FREE,
                        false,
                        List.of()
                )
        );

        //FREE felhasználó próbál különböző napokat használni.
        assertThrows(
                IllegalArgumentException.class,
                () -> new User(
                        1,
                        "Teszt",
                        100.0,
                        100.0,
                        UserType.FREE,
                        true,
                        List.of()
                )
        );
    }

    @Test
    void constructorShouldThrowIfListArgumentsAreWrong() {
        //FREE felhasználó akar különböző napokat használni.
        assertThrows(
                IllegalArgumentException.class,
                () -> new User(
                        1,
                        "Teszt",
                        100.0,
                        100.0,
                        UserType.FREE,
                        false,
                        List.of(
                                new KcalAndNutrients(100.0, 0.0, 0.0, 0.0),
                                new KcalAndNutrients(0.0, 0.0, 0.0, 0.0),
                                new KcalAndNutrients(0.0, 0.0, 0.0, 0.0),
                                new KcalAndNutrients(0.0, 0.0, 0.0, 0.0),
                                new KcalAndNutrients(0.0, 0.0, 0.0, 0.0),
                                new KcalAndNutrients(0.0, 0.0, 0.0, 0.0),
                                new KcalAndNutrients(0.0, 0.0, 0.0, 0.0)
                        )
                )
        );
    }

    @Test
    void constructorShouldCreateDailyTargetList() {
        //Minden nap ugyanannyi a dailyTarget értéke.
        User user = new User(
                1,
                "Teszt",
                100.0,
                100.0,
                UserType.FREE,
                false,
                List.of(
                        new KcalAndNutrients(0.0, 0.0, 0.0, 0.0),
                        new KcalAndNutrients(0.0, 0.0, 0.0, 0.0),
                        new KcalAndNutrients(0.0, 0.0, 0.0, 0.0),
                        new KcalAndNutrients(0.0, 0.0, 0.0, 0.0),
                        new KcalAndNutrients(0.0, 0.0, 0.0, 0.0),
                        new KcalAndNutrients(0.0, 0.0, 0.0, 0.0),
                        new KcalAndNutrients(0.0, 0.0, 0.0, 0.0)
                )
        );

        for(int i = 0; i < user.getDailyTarget().toArray().length; i++) {
            assertEquals(
                    new KcalAndNutrients(0.0, 0.0, 0.0, 0.0),
                    user.getDailyTarget().get(i)
            );
        }

        //Minden nap különböző a dailyTarget értéke.
        user = new User(
                1,
                "Teszt 2",
                100.0,
                100.0,
                UserType.PREMIUM,
                true,
                List.of(
                        new KcalAndNutrients(100.0, 1.0, 1.0, 1.0),
                        new KcalAndNutrients(200.0, 2.0, 2.0, 2.0),
                        new KcalAndNutrients(300.0, 3.0, 3.0, 3.0),
                        new KcalAndNutrients(400.0, 4.0, 4.0, 4.0),
                        new KcalAndNutrients(500.0, 5.0, 5.0, 5.0),
                        new KcalAndNutrients(600.0, 6.0, 6.0, 6.0),
                        new KcalAndNutrients(700.0, 7.0, 7.0, 7.0)
                )
        );

        for(int i = 0; i < user.getDailyTarget().toArray().length; i++) {
            assertEquals(
                    new KcalAndNutrients(
                            (double) (i + 1) * 100,
                            (double) i + 1,
                            (double) i + 1,
                            (double) i + 1
                    ),
                    user.getDailyTarget().get(i)
            );
        }
    }
}

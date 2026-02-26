package Calorie.UserTest;

import Calorie.Food.KcalAndNutrients;

import Calorie.User.User;
import Calorie.User.UserRepository;
import Calorie.User.UserType;

import jakarta.transaction.Transactional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertEquals;

import java.util.List;

@SpringBootTest
//Ha nincs itt, akkor hiba:
//"Unable to evaluate the expression Method threw 'org.hibernate.LazyInitializationException' exception."
@Transactional
public class UserRepositoryTest {
    @Autowired
    private UserRepository userRepository;

    @Test
    void saveAndLoadUser() {
        //Ha ID nem null, akkor hiba!
        User user = new User(
                null,
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

        User saved = userRepository.save(user);

        User found = userRepository.findById(saved.getId()).orElseThrow();

        assertEquals(user.getName(), found.getName());
        assertEquals(user.getHeight(), found.getHeight());
        assertEquals(user.getWeight(), found.getWeight());
        assertEquals(user.getUserType(), found.getUserType());
        assertEquals(user.isDifferentDays(), found.isDifferentDays());
        assertEquals(user.getDailyTarget(), found.getDailyTarget());
    }
}
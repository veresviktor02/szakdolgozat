package Calorie.UserTest;

import Calorie.Food.KcalAndNutrients;

import Calorie.User.User;
import Calorie.User.UserController;
import Calorie.User.UserService;
import Calorie.User.UserType;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertEquals;

import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import java.util.List;

class UserControllerTest {

    @Test
    void getUsersShouldReturnList() {
        UserService service = mock(UserService.class);

        UserController controller = new UserController(service);

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

        when(service.getAllUsers()).thenReturn(List.of(user));

        List<User> foodList = controller.getUsers();

        assertEquals(user.getId(), foodList.size());
        assertEquals(user.getName(), foodList.get(0).getName());
        assertEquals(user.getWeight(), foodList.get(0).getWeight());
        assertEquals(user.getHeight(), foodList.get(0).getHeight());
        assertEquals(user.getUserType(), foodList.get(0).getUserType());
        assertEquals(user.isDifferentDays(), foodList.get(0).isDifferentDays());
        assertEquals(user.getDailyTarget(), foodList.get(0).getDailyTarget());
    }
}

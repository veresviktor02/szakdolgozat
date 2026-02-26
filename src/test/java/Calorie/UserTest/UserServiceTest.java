package Calorie.UserTest;

import Calorie.Food.KcalAndNutrients;

import Calorie.User.User;
import Calorie.User.UserRepository;
import Calorie.User.UserService;
import Calorie.User.UserType;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import static org.junit.jupiter.api.Assertions.*;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.List;
import java.util.Optional;

@ExtendWith(MockitoExtension.class)
public class UserServiceTest {
    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private UserService userService;

    private User user;

    @BeforeEach
    void init() {
        user = new User(
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
    }

    @Test
    void getAllUsersShouldReturnUsers() {
        when(userRepository.findAll()).thenReturn(List.of(user));

        List<User> userList = userService.getAllUsers();

        assertEquals(
                user.getId(),
                userList.get(0).getId()
        );

        assertEquals(
                user.getName(),
                userList.get(0).getName()
        );

        assertEquals(
                user.getWeight(),
                userList.get(0).getWeight()
        );

        assertEquals(
                user.getHeight(),
                userList.get(0).getHeight()
        );

        assertEquals(
                user.getUserType(),
                userList.get(0).getUserType()
        );

        assertEquals(
                user.isDifferentDays(),
                userList.get(0).isDifferentDays()
        );

        assertEquals(
                user.getDailyTarget(),
                userList.get(0).getDailyTarget()
        );

        verify(userRepository).findAll();
    }

    @Test
    void getUserByIdShouldReturnUser() {
        when(userRepository.findById(1)).thenReturn(Optional.of(user));

        User result = userService.getUserById(1);

        assertEquals(
                user.getId(),
                result.getId()
        );

        assertEquals(
                user.getName(),
                result.getName()
        );

        assertEquals(
                user.getWeight(),
                result.getWeight()
        );

        assertEquals(
                user.getHeight(),
                result.getHeight()
        );

        assertEquals(
                user.getUserType(),
                result.getUserType()
        );

        assertEquals(
                user.isDifferentDays(),
                result.isDifferentDays()
        );

        assertEquals(
                user.getDailyTarget(),
                result.getDailyTarget()
        );
    }

    @Test
    void getUserByIdShouldThrowIfNotFound() {
        when(userRepository.findById(1)).thenReturn(Optional.empty());

        assertThrows(
                IllegalStateException.class,
                () -> userService.getUserById(1)
        );
    }

    @Test
    void insertUserShouldCallSave() {
        userService.insertUser(user);

        verify(userRepository).save(user);
    }

    @Test
    void deleteUserShouldCallDelete() {
        //MOCK-olni kell a hibadobást is, különben ez a teszt FAIL-elni fog!!!
        when(userRepository.existsById(1)).thenReturn(true);

        userService.deleteUserById(1);

        verify(userRepository).deleteById(1);
    }

    @Test
    void updateUserShouldUpdateFields() {
        User user2 = new User(
                2,
                "Teszt 2",
                200.0,
                120.0,
                UserType.PREMIUM,
                true,
                List.of(
                        new KcalAndNutrients(100.0, 1.0, 1.0, 1.0),
                        new KcalAndNutrients(200.0, 2.0, 2.0, 1.0),
                        new KcalAndNutrients(300.0, 3.0, 3.0, 1.0),
                        new KcalAndNutrients(400.0, 4.0, 4.0, 1.0),
                        new KcalAndNutrients(500.0, 5.0, 5.0, 1.0),
                        new KcalAndNutrients(600.0, 6.0, 6.0, 1.0),
                        new KcalAndNutrients(700.0, 7.0, 7.0, 1.0)
                )
        );

        when(userRepository.findById(1)).thenReturn(Optional.of(user));

        userService.updateUserById(1, user2);

        assertNotEquals(
                user2.getId(),
                user.getId()
        );

        assertEquals(
                user2.getName(),
                user.getName()
        );

        assertEquals(
                user2.getWeight(),
                user.getWeight()
        );

        assertEquals(
                user2.getHeight(),
                user.getHeight()
        );

        assertEquals(
                user2.getUserType(),
                user.getUserType()
        );

        assertEquals(
                user2.isDifferentDays(),
                user.isDifferentDays()
        );

        assertEquals(
                user2.getDailyTarget(),
                user.getDailyTarget()
        );
    }

    @Test
    void updateUserShouldThrowIfNotFound() {
        when(userRepository.findById(1)).thenReturn(Optional.empty());

        assertThrows(
                IllegalStateException.class,
                () -> userService.updateUserById(1, user)
        );
    }
}
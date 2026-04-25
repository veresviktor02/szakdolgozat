package Calorie.User;

import Calorie.Day.DayService;

import Calorie.Exceptions.UserException;

import Calorie.Food.KcalAndNutrients;

import jakarta.annotation.PostConstruct;
import jakarta.transaction.Transactional;

import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service("UserService")
public class UserService {
    @PostConstruct
    public void init() {
        createTestUser();
    }

    private final UserRepository userRepository;
    private final UserNameCheckerService userNameCheckerService;
    private final DayService dayService;

    public UserService(
            UserRepository userRepository,
            UserNameCheckerService userNameCheckerService,
            DayService dayService
    ) {
        this.userRepository = userRepository;
        this.userNameCheckerService = userNameCheckerService;
        this.dayService = dayService;
    }

    public List<User> getAllUsers() {
        try {
            return userRepository.findAll();
        } catch(Exception e) {
            throw new UserException("return userRepository.findAll() hibát dobott!", e);
        }
    }

    public void insertUser(User user) {
        if(userRepository.findByName(user.getName()).isPresent()) {
            throw new UserException("Ez a felhasználónév már foglalt!");
        }

        userNameCheckerService.validate(user.getName());

        if(user.getUserType() == UserType.FREE && user.isDifferentDays()) {
            throw new UserException(
                    "A felhasználó nem lehet FREE és különböző napos egyszerre!"
            );
        }

        try {
            userRepository.save(user);
        } catch (Exception e) {
            throw new UserException("userRepository.save(user) hibát dobott!", e);
        }

        try {
            dayService.createEmptyDays(user.getId());
        } catch (Exception e) {
            throw new UserException("dayService.createEmptyDays(user.getId()) hibát dobott!", e);
        }
    }

    @Transactional
    public void updateUserById(Integer id, User newUser) {
        User oldUser = userRepository.findById(id).orElseThrow(
                () -> new UserException(
                        "A frissíteni kívánt felhasználó nem található! (ID: " + id + ')'
                ));

        oldUser.setName(newUser.getName());
        oldUser.setHeight(newUser.getHeight());
        oldUser.setWeight(newUser.getWeight());
        oldUser.setUserType(newUser.getUserType());
        oldUser.setDifferentDays(newUser.isDifferentDays());
        oldUser.setDailyTarget(newUser.getDailyTarget());
    }

    public void deleteUserById(Integer id) {
        if(!userRepository.existsById(id)) {
            throw new UserException(
                    "A törölni kívánt felhasználó nem található! (ID: " + id + ')'
            );
        }

        try {
            userRepository.deleteById(id);
        } catch(Exception e) {
            throw new UserException("userRepository.deleteById(id)", e);
        }
    }

    public User getUserById(Integer id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new UserException(
                        "A kért felhasználó nem található! (ID: " + id + ')'
                ));
    }

    public User getUserByName(String name) {
        return userRepository.findByName(name)
                .orElseThrow(() -> new UserException(
                        "A kért felhasználó nem található! (Név: " + name + ')'
                ));
    }

    void createTestUser() {
        User user = new User();

        user.setName("Névtelen User");
        user.setHeight(100.0);
        user.setWeight(100.0);
        user.setUserType(UserType.FREE);
        user.setDifferentDays(false);
        user.setPassword("Passw0rd");

        List<KcalAndNutrients> kcalAndNutrientsList = new ArrayList<>(7);

        for(int i = 0; i < 7; i++) {
            kcalAndNutrientsList.add(i, new KcalAndNutrients(
                    2000.0,
                    40.0,
                    250.0,
                    160.0
            ));
        }

        user.setDailyTarget(kcalAndNutrientsList);

        try {
            userRepository.save(user);
        } catch(Exception e) {
            throw new UserException(
                    "userRepository.save(user) hibát dobott!", e
            );
        }

        try {
            dayService.createEmptyDays(user.getId());
        } catch(Exception e) {
            throw new UserException(
                    "dayService.createEmptyDays(user.getId()) hibát dobott!", e
            );
        }
    }
}

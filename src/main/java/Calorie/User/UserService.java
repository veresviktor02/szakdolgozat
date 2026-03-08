package Calorie.User;

import Calorie.Food.KcalAndNutrients;

import jakarta.annotation.PostConstruct;
import jakarta.transaction.Transactional;

import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
public class UserService {
    @PostConstruct
    public void init() {
        createTestUser();
    }

    private final UserRepository userRepository;

    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public List<User> getAllUsers() {
        return userRepository.findAll();
    }

    public void insertUser(User user) {
        if(user.getUserType() == UserType.FREE && user.isDifferentDays()) {
            throw new IllegalStateException(
                    "A felhasználó nem lehet FREE és különböző napos egyszerre!"
            );
        }

        userRepository.save(user);
    }

    @Transactional
    public void updateUserById(Integer id, User newUser) {
        User oldUser = userRepository.findById(id).orElseThrow(
                () -> new IllegalStateException(
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
            throw new IllegalStateException(
                    "A törölni kívánt felhasználó nem található! (ID: " + id + ')'
            );
        }

        userRepository.deleteById(id);
    }

    public User getUserById(Integer id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new IllegalStateException(
                        "A kért felhasználó nem található! (ID: " + id + ')'
                ));
    }

    void createTestUser() {
        User user = new User();

        user.setName("Névtelen User");
        user.setHeight(100.0);
        user.setWeight(100.0);
        user.setUserType(UserType.FREE);
        user.setDifferentDays(false);

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

        userRepository.save(user);
    }
}

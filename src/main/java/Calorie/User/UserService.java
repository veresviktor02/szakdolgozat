package Calorie.User;

import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class UserService {
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
    }

    public void deleteUserById(Integer id) {
        userRepository.deleteById(id);
    }

    public User getUserById(Integer id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new IllegalStateException(id + " not found."));
    }
}

package Calorie.User;

import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("users")
public class UserController {
    private final UserService userService;
    public UserController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping
    public List<User> getUsers() {
        return userService.getAllUsers();
    }

    @GetMapping("{id}")
    public User getUserById(@PathVariable Integer id) {
        return userService.getUserById(id);
    }

    @PostMapping
    public void addNewUser(@RequestBody User user) {
        userService.insertUser(user);
    }

    @DeleteMapping("{id}")
    public void deleteFoodById(@PathVariable Integer id) {
        userService.deleteUserById(id);
    }

    @PutMapping("{id}")
    public void updateFoodById(@PathVariable Integer id, @RequestBody User user) {
        userService.updateUserById(id, user);
    }
}

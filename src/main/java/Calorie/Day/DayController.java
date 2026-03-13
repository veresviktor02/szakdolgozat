package Calorie.Day;

import Calorie.Food.KcalAndNutrients;

import Calorie.User.User;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("days")
public class DayController {
    private final DayService dayService;

    public DayController(DayService dayService) {
        this.dayService = dayService;
    }

    //GET
    @GetMapping("{id}")
    public List<Day> getAllDays(@PathVariable Integer id) {
        return dayService.getAllDays(id);
    }

    @GetMapping("{userId}/{dayId}")
    public Day getDayById(@PathVariable Integer userId, @PathVariable Integer dayId) {
        return dayService.getDayById(userId, dayId);
    }

    @GetMapping("{userId}/{dayId}/total")
    public KcalAndNutrients getTotalKcalAndNutrients(
            @PathVariable Integer userId,
            @PathVariable Integer dayId
    ) {
        return dayService.getTotalKcalAndNutrients(userId, dayId);
    }

    @GetMapping("{id}/streak")
    public int getCurrentActivityStreak(@PathVariable Integer id) {
        return dayService.getCurrentActivityStreak(id);
    }

    @GetMapping("leaderboard")
    public List<User> getMostActiveUsers() {
        return dayService.getMostActiveUsers(5);
    }

    ///////////////////////////////////////////////////////////////////////////////

    //POST
    @PostMapping("{userId}")
    public void addNewDay(@PathVariable Integer userId, @RequestBody Day day) {
        dayService.insertDay(userId, day);
    }

    @PostMapping("{userId}/{dayId}")
    public void addFoodToDay(
            @PathVariable Integer userId,
            @PathVariable Integer dayId,
            @RequestBody EmbeddedFood food
    ) {
        dayService.addFoodToDay(userId, dayId, food);
    }

    @PostMapping("/create-empty-days/{id}")
    public void createEmptyDays(@PathVariable Integer id) {
        dayService.createEmptyDays(id);
    }

    ///////////////////////////////////////////////////////////////////////////////

    //PUT
    @PutMapping("{userId}/{dayId}")
    public void updateDayById(
            @PathVariable Integer userId,
            @PathVariable Integer dayId,
            @RequestBody Day day
    ) {
        dayService.updateDayById(userId, dayId, day);
    }

    ///////////////////////////////////////////////////////////////////////////////

    //DELETE
    @DeleteMapping("{id}")
    public void deleteDayById(@PathVariable Integer id) {
        dayService.deleteDayById(id);
    }

    @DeleteMapping("{dayId}/{foodId}")
    public void removeFoodFromDay(@PathVariable Integer dayId, @PathVariable Integer foodId) {
        dayService.removeFoodFromDay(dayId, foodId);
    }
}

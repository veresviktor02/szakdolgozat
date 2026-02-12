package Calorie.Day;

import Calorie.Food.Food;
import Calorie.Food.KcalAndNutrients;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("days")
public class DayController {
    private final DayService dayService;
    public DayController(DayService dayService) {
        this.dayService = dayService;
    }

    @GetMapping
    public List<Day> getDays() {
        return dayService.getAllDays();
    }

    @GetMapping("{id}")
    public Day getDayById(@PathVariable Integer id) {
        return dayService.getDayById(id);
    }

    @PostMapping
    public void addNewDay(@RequestBody Day day) {
        dayService.insertDay(day);
    }

    @DeleteMapping("{id}")
    public void deleteDayById(@PathVariable Integer id) {
        dayService.deleteDayById(id);
    }

    @PutMapping("{id}")
    public void updateFoodById(@PathVariable Integer id, @RequestBody Day day) {
        dayService.updateDayById(id, day);
    }

    @DeleteMapping("{dayId}/foods/{foodId}")
    public void removeFoodFromDay(@PathVariable Integer dayId, @PathVariable Integer foodId) {
        dayService.removeFoodFromDay(dayId, foodId);
    }

    @PostMapping("{dayId}")
    public void addFoodToDay(@PathVariable Integer dayId, @RequestBody EmbeddedFood food) {
        dayService.addFoodToDay(dayId, food);
    }

    @GetMapping("{dayId}/total")
    public KcalAndNutrients getTotalKcalAndNutrients(@PathVariable Integer dayId) {
        return dayService.getTotalKcalAndNutrients(dayId);
    }
}

package Calorie.Day;

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
}

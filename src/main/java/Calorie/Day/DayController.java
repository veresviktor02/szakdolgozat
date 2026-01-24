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
}

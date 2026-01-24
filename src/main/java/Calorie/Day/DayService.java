package Calorie.Day;

import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class DayService {
    private DayRepository dayRepository;

    public DayService(DayRepository dayRepository) {
        this.dayRepository = dayRepository;
    }

    public List<Day> getAllDays() {
        return dayRepository.findAll();
    }

    public void insertDay(Day day) {
        dayRepository.save(day);
    }

    public Day getDayById(Integer id) {
        return dayRepository.findById(id)
                .orElseThrow(() -> new IllegalStateException(id + " not found."));
    }
}

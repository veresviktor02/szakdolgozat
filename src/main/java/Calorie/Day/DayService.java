package Calorie.Day;

import jakarta.transaction.Transactional;
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

    @Transactional
    public void updateDayById(Integer id, Day newDay) {
        Day oldDay = dayRepository.findById(id).orElseThrow(
                () -> new IllegalStateException(
                        "A frissíteni kívánt nap nem található! (ID: " + id + ')'
                ));

        oldDay.setDate(newDay.getDate());
        oldDay.setFoodList(newDay.getFoodList());
    }

    public void deleteDayById(Integer id) {
        dayRepository.deleteById(id);
    }

    public Day getDayById(Integer id) {
        return dayRepository.findById(id)
                .orElseThrow(() -> new IllegalStateException(
                        "A megadott ID nem található! " + id + ')'
                ));
    }
}

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

    public void removeFoodFromDay(Integer dayId, Integer foodId) {
        //Megnézzük, hogy létezik-e a megadott nap.
        Day day = dayRepository.findById(dayId).
                orElseThrow(() -> new IllegalStateException(
                        "A megadott ID nem található! " + dayId + ')'
                ));

        //Töröljük az ételt, ha nem található, Error dobása.
        if(!day.getFoodList().removeIf(food -> food.getId().equals(foodId))) {
            throw new IllegalStateException("A megadott ID nem található! " + foodId + ')');
        }

        //Mentse el, vagy nem változik az adatbázis!
        dayRepository.save(day);

    }

    public void addFoodToDay(Integer dayId, EmbeddedFood food) {
        //Megnézzük, hogy létezik-e a megadott nap.
        Day day = dayRepository.findById(dayId).
                orElseThrow(() -> new IllegalStateException(
                        "A megadott ID nem található! " + dayId + ')'
                ));

        day.getFoodList().add(food);

        dayRepository.save(day);
    }
}

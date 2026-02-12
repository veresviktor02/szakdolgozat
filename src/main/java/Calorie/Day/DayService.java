package Calorie.Day;

import Calorie.Food.KcalAndNutrients;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class DayService {
    private final DayRepository dayRepository;

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

    @Transactional
    public void removeFoodFromDay(Integer dayId, Integer foodId) {
        //Megnézzük, hogy létezik-e a megadott nap.
        Day day = dayRepository.findById(dayId).
                orElseThrow(() -> new IllegalStateException(
                        "A megadott ID nem található! " + dayId + ')'
                ));

        //Töröljük az ételt, ha nem található, Error dobása.
        if(!day.getFoodList().removeIf(food -> food.getId().equals(foodId))) {
            throw new IllegalStateException("A megadott ID nem található! (ID: " + foodId + ')');
        }

        //Mentse el, vagy nem változik az adatbázis!
        dayRepository.save(day);

    }

    public void addFoodToDay(Integer dayId, EmbeddedFood food) {
        //Megnézzük, hogy létezik-e a megadott nap.
        Day day = dayRepository.findById(dayId).
                orElseThrow(() -> new IllegalStateException(
                        "A megadott ID nem található! (ID: " + dayId + ')'
                ));

        day.getFoodList().add(food);

        dayRepository.save(day);
    }

    @Transactional
    public KcalAndNutrients getTotalKcalAndNutrients(Integer dayId) {
        KcalAndNutrients totalKcalAndNutrients = new KcalAndNutrients(0.0, 0.0, 0.0 ,0.0);

        getDayById(dayId).getFoodList().forEach(
                food -> {
                    totalKcalAndNutrients.setKcal(totalKcalAndNutrients.getKcal() + food.getKcalAndNutrients().getKcal());
                    totalKcalAndNutrients.setFat(totalKcalAndNutrients.getFat() + food.getKcalAndNutrients().getFat());
                    totalKcalAndNutrients.setCarb(totalKcalAndNutrients.getCarb() + food.getKcalAndNutrients().getCarb());
                    totalKcalAndNutrients.setProtein(totalKcalAndNutrients.getProtein() + food.getKcalAndNutrients().getProtein());
                }
        );

        return totalKcalAndNutrients;
    }
}

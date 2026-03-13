package Calorie.Day;

import Calorie.Day.MeasurementUnit.MeasurementUnit;
import Calorie.Food.KcalAndNutrients;

import Calorie.User.User;
import Calorie.User.UserRepository;

import jakarta.annotation.PostConstruct;
import jakarta.transaction.Transactional;

import org.springframework.context.annotation.DependsOn;
import org.springframework.stereotype.Service;

import java.time.LocalDate;

import java.util.List;

@Service
@DependsOn("UserService") //Ez biztosítja, hogy a UserService előbb fog lefutni!
public class DayService {
    @PostConstruct
    public void init() {
        createEmptyDays(1);
    }

    private final DayRepository dayRepository;
    private final UserRepository userRepository;

    public DayService(DayRepository dayRepository, UserRepository userRepository) {
        this.dayRepository = dayRepository;
        this.userRepository = userRepository;
    }

    public List<Day> getAllDays(Integer id) {
        return dayRepository.findByUserId(id);
    }

    //Csak napok inicializálásához!
    public void insertDay(Integer userId, Day day) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalStateException(
                        "A felhasználó nem található! (ID: " + userId + ')'
                ));

        day.setUser(user);
        dayRepository.save(day);
    }

    @Transactional
    public void updateDayById(Integer userId, Integer dayId, Day newDay) {
        Day oldDay = dayRepository.findByIdAndUserId(dayId, userId)
                .orElseThrow(() -> new IllegalStateException(
                        "A frissíteni kívánt nap nem található! (ID: " + dayId + ')'
                ));

        oldDay.setDate(newDay.getDate());
        oldDay.setFoodList(newDay.getFoodList());
    }

    public void deleteDayById(Integer id) {
        dayRepository.deleteById(id);
    }

    public Day getDayById(Integer userId, Integer dayId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalStateException(
                        "A megadott felhasználó nem található! " + userId + ')'
                ));

        return dayRepository.findByIdAndUser(dayId, user)
                .orElseThrow(() -> new IllegalStateException(
                        "A megadott nap nem található! " + dayId + ')'
                ));
    }

    @Transactional
    public void removeFoodFromDay(Integer dayId, Integer foodId) {
        //Megnézzük, hogy létezik-e a megadott nap.
        Day day = dayRepository.findById(dayId)
                .orElseThrow(() -> new IllegalStateException(
                        "A megadott ID nem található! " + dayId + ')'
                ));

        //Töröljük az ételt, ha nem található, kivétel dobása.
        if(!day.getFoodList().removeIf(food -> food.getId().equals(foodId))) {
            throw new IllegalStateException("A megadott ID nem található! (ID: " + foodId + ')');
        }

        dayRepository.save(day);
    }

    public void addFoodToDay(Integer userId, Integer dayId, EmbeddedFood food) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalStateException(
                        "A megadott felhasználó nem található! (ID: " + userId + ')'
                ));

        //Megnézzük, hogy létezik-e a megadott nap.
        Day day = dayRepository.findByIdAndUser(dayId, user)
                .orElseThrow(() -> new IllegalStateException(
                        "A megadott nap nem található! (ID: " + dayId + ')'
                ));

        food.setDay(day);
        day.getFoodList().add(food);

        dayRepository.save(day);
    }

    @Transactional
    public KcalAndNutrients getTotalKcalAndNutrients(Integer userId, Integer dayId) {
        KcalAndNutrients totalKcalAndNutrients = new KcalAndNutrients(0.0, 0.0, 0.0 ,0.0);

        getDayById(userId, dayId).getFoodList().forEach(
                food -> {
                    totalKcalAndNutrients.setKcal(
                            totalKcalAndNutrients.getKcal() //Eddigi összeg
                                    + food.getKcalAndNutrients().getKcal() //Aktuális étel kcal
                                    * food.getFoodWeight() //Tömeg szorozva mértékegységgel
                                    * food.getMeasurementUnit().getMeasurementUnitInGrams()
                                    / 100 //Ételek nutríciója 100 grammra vetítve lett megadva!
                    );

                    totalKcalAndNutrients.setFat(
                            totalKcalAndNutrients.getFat()
                                    + food.getKcalAndNutrients().getFat()
                                    * food.getFoodWeight()
                                    * food.getMeasurementUnit().getMeasurementUnitInGrams()
                                    / 100
                    );

                    totalKcalAndNutrients.setCarb(
                            totalKcalAndNutrients.getCarb()
                                    + food.getKcalAndNutrients().getCarb()
                                    * food.getFoodWeight()
                                    * food.getMeasurementUnit().getMeasurementUnitInGrams()
                                    / 100
                    );

                    totalKcalAndNutrients.setProtein(
                            totalKcalAndNutrients.getProtein()
                                    + food.getKcalAndNutrients().getProtein()
                                    * food.getFoodWeight()
                                    * food.getMeasurementUnit().getMeasurementUnitInGrams()
                                    / 100
                    );
                }
        );

        return totalKcalAndNutrients;
    }

    //Hány napot trackelt a felhasználó egyhuzamban (mával számolva, nem történelmileg!).
    public int getCurrentActivityStreak(Integer userId) {
        int streak = 0;
        LocalDate currentDate = LocalDate.now();

        while(true) {
            Day day = dayRepository.findByDateAndUserId(currentDate, userId).orElse(null);

            if(day == null || day.getFoodList() == null || day.getFoodList().isEmpty()) {
                break;
            }

            streak++;

            currentDate = currentDate.minusDays(1);
        }

        return streak;
    }

    public void createEmptyDays(Integer id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new IllegalStateException(
                        "A felhasználó nem található! (ID: " + id + ')'
                ));

        LocalDate start = LocalDate.of(2026, 1, 1);
        LocalDate end = LocalDate.of(2026, 12, 31);

        LocalDate current = start;

        while(!current.isAfter(end)) {
            if(!dayRepository.existsByUserAndDate(user, current)) {
                Day day = new Day();

                day.setDate(current);
                day.setUser(user);

                dayRepository.save(day);
            }

            current = current.plusDays(1);
        }
    }
}

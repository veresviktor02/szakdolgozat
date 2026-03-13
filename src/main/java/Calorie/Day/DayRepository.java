package Calorie.Day;

import Calorie.User.User;

import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;

import java.util.List;
import java.util.Optional;

public interface DayRepository extends JpaRepository<Day, Integer> {
    Optional<Day> findByDate(LocalDate date);

    boolean existsByUserAndDate(User user, LocalDate current);

    Optional<Day> findByIdAndUser(Integer dayId, User user);

    List<Day> findByUserId(Integer id);

    Optional<Day> findByIdAndUserId(Integer dayId, Integer userId);

    Optional<Day> findByDateAndUserId(LocalDate currentDate, Integer userId);
}

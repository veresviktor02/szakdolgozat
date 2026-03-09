package Calorie.Day;

import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.Optional;

public interface DayRepository extends JpaRepository<Day, Integer> {
    boolean existsByDate(LocalDate date);

    Optional<Day> findByDate(LocalDate date);
}

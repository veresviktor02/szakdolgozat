package Calorie.Day;

import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;

public interface DayRepository extends JpaRepository<Day, Integer> {
    boolean existsByDate(LocalDate date);
}

package Calorie.Food;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

import java.util.Optional;

public interface FoodRepository extends JpaRepository<Food, Integer> {
    List<Food> findByOwnerId(Integer userId);

    Optional<Food> findByIdAndOwnerId(Integer foodId,  Integer userId);
}

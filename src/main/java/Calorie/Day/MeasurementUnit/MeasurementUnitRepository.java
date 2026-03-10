package Calorie.Day.MeasurementUnit;

import Calorie.User.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface MeasurementUnitRepository extends JpaRepository<MeasurementUnit, Integer> {
    List<MeasurementUnit> findByOwnerId(int id);

    Optional<MeasurementUnit> findByIdAndOwner(Integer measurementId, User user);

    Optional<MeasurementUnit> findByIdAndOwnerId(Integer id, Integer ownerId);
}

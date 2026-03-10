package Calorie.Day.MeasurementUnit;

import Calorie.User.User;
import Calorie.User.UserRepository;

import jakarta.annotation.PostConstruct;
import jakarta.transaction.Transactional;

import org.springframework.context.annotation.DependsOn;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@DependsOn("UserService") //Ez biztosítja, hogy a UserService előbb fog lefutni!
public class MeasurementUnitService {
    @PostConstruct
    public void init() {
        createDefaultMeasurementUnits(1);
    }

    private final MeasurementUnitRepository measurementUnitRepository;
    private final UserRepository userRepository;

    public MeasurementUnitService(
            MeasurementUnitRepository measurementUnitRepository,
            UserRepository userRepository
    ) {
        this.measurementUnitRepository = measurementUnitRepository;
        this.userRepository = userRepository;
    }

    public List<MeasurementUnit> getAllMeasurementUnits(Integer id) {
        return measurementUnitRepository.findByOwnerId(id);
    }

    public MeasurementUnit getMeasurementUnitById(Integer userId, Integer measurementId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalStateException(
                        "A megadott felhasználó nem található! " + userId + ')'
                ));

        return measurementUnitRepository.findByIdAndOwner(measurementId, user)
                .orElseThrow(() -> new IllegalStateException(
                        "A megadott mértékegység nem található! (ID: " + measurementId + ')'
                ));
    }

    public void addMeasurementUnit(Integer userId, MeasurementUnit measurementUnit) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalStateException(
                        "A felhasználó nem található! (ID: " + userId + ')'
                ));

        measurementUnit.setOwner(user);
        measurementUnitRepository.save(measurementUnit);
    }

    @Transactional
    public void updateMeasurementUnitById(
            Integer userId,
            Integer measurementUnitId,
            MeasurementUnit newMeasurementUnit
    ) {
        MeasurementUnit oldMeasurementUnit = measurementUnitRepository
                .findByIdAndOwnerId(measurementUnitId, userId)
                .orElseThrow(() -> new IllegalStateException(
                        "A frissíteni kívánt mértékegység nem található! (ID: " + measurementUnitId + ')'
                ));

        oldMeasurementUnit.setMeasurementUnitName(newMeasurementUnit.getMeasurementUnitName());
        oldMeasurementUnit.setMeasurementUnitInGrams(newMeasurementUnit.getMeasurementUnitInGrams());
    }

    public void removeMeasurementUnitById(Integer id) {
        if(!measurementUnitRepository.existsById(id)) {
            throw new IllegalStateException(
                    "A törölni kívánt mértékegység nem található! (ID: " + id + ')'
            );
        }

        measurementUnitRepository.deleteById(id);
    }

    private void createDefaultMeasurementUnits(Integer userId) {
        MeasurementUnit measurementUnit = new MeasurementUnit();

        measurementUnit.setMeasurementUnitName("gramm");
        measurementUnit.setMeasurementUnitInGrams(1);

        addMeasurementUnit(userId, measurementUnit);

        measurementUnit = new MeasurementUnit();

        measurementUnit.setMeasurementUnitName("100 gramm");
        measurementUnit.setMeasurementUnitInGrams(100);

        addMeasurementUnit(userId, measurementUnit);

        measurementUnit = new MeasurementUnit();

        measurementUnit.setMeasurementUnitName("kilogramm");
        measurementUnit.setMeasurementUnitInGrams(1000);

        addMeasurementUnit(userId, measurementUnit);

        measurementUnit = new MeasurementUnit();

        measurementUnit.setMeasurementUnitName("lbs");
        measurementUnit.setMeasurementUnitInGrams(453);

        addMeasurementUnit(userId, measurementUnit);
    }
}

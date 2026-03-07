package Calorie.Day.MeasurementUnit;

import Calorie.Food.Food;
import jakarta.annotation.PostConstruct;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class MeasurementUnitService {
    @PostConstruct
    public void init() {
        createDefaultMeasurementUnits();
    }

    private final MeasurementUnitRepository measurementUnitRepository;

    public MeasurementUnitService(MeasurementUnitRepository measurementUnitRepository) {
        this.measurementUnitRepository = measurementUnitRepository;
    }

    public List<MeasurementUnit> getAllMeasurementUnits() {
        return measurementUnitRepository.findAll();
    }

    public MeasurementUnit getMeasurementUnitById(Integer id) {
        return measurementUnitRepository.findById(id)
                .orElseThrow(() -> new IllegalStateException(
                        "A megadott ID nem található! (ID: " + id + ')'
                ));
    }

    public void addMeasurementUnit(MeasurementUnit measurementUnit) {
        measurementUnitRepository.save(measurementUnit);
    }

    @Transactional
    public void updateMeasurementUnitById(Integer id, MeasurementUnit newMeasurementUnit) {
        MeasurementUnit oldMeasurementUnit = measurementUnitRepository.findById(id).orElseThrow(
                () -> new IllegalStateException(
                        "A frissíteni kívánt mértékegység nem található! (ID: " + id + ')'
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

    private void createDefaultMeasurementUnits() {
        MeasurementUnit measurementUnit = new MeasurementUnit();

        measurementUnit.setMeasurementUnitName("gramm");
        measurementUnit.setMeasurementUnitInGrams(1);

        addMeasurementUnit(measurementUnit);

        measurementUnit = new MeasurementUnit();

        measurementUnit.setMeasurementUnitName("100 gramm");
        measurementUnit.setMeasurementUnitInGrams(100);

        addMeasurementUnit(measurementUnit);

        measurementUnit = new MeasurementUnit();

        measurementUnit.setMeasurementUnitName("kilogramm");
        measurementUnit.setMeasurementUnitInGrams(1000);

        addMeasurementUnit(measurementUnit);

        measurementUnit = new MeasurementUnit();

        measurementUnit.setMeasurementUnitName("lbs");
        measurementUnit.setMeasurementUnitInGrams(453);

        addMeasurementUnit(measurementUnit);
    }
}

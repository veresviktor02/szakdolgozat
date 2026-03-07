package Calorie.Day.MeasurementUnit;

import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("measurementUnits")
public class MeasurementUnitController {
    private final MeasurementUnitService measurementUnitService;

    public MeasurementUnitController(MeasurementUnitService measurementUnitService) {
        this.measurementUnitService = measurementUnitService;
    }

    @GetMapping
    public List<MeasurementUnit> getAllMeasurementUnits() {
        return measurementUnitService.getAllMeasurementUnits();
    }

    @GetMapping("{id}")
    public MeasurementUnit getMeasurementUnitById(@PathVariable Integer id) {
        return measurementUnitService.getMeasurementUnitById(id);
    }

    @PostMapping
    public void addMeasurementUnit(@RequestBody MeasurementUnit measurementUnit) {
        measurementUnitService.addMeasurementUnit(measurementUnit);
    }

    @PutMapping("{id}")
    public void updateMeasurementUnitById(
            @PathVariable Integer id,
            @RequestBody MeasurementUnit measurementUnit
    ) {
        measurementUnitService.updateMeasurementUnitById(id, measurementUnit);
    }

    @DeleteMapping("{id}")
    public void removeMeasurementUnitById(@PathVariable Integer id) {
        measurementUnitService.removeMeasurementUnitById(id);
    }
}

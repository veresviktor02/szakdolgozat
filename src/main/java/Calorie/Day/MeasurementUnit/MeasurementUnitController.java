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

    //GET
    @GetMapping("{id}")
    public List<MeasurementUnit> getAllMeasurementUnits(@PathVariable Integer id) {
        return measurementUnitService.getAllMeasurementUnits(id);
    }

    @GetMapping("{userId}/{measurementId}")
    public MeasurementUnit getMeasurementUnitById(
            @PathVariable Integer userId,
            @PathVariable Integer measurementId
    ) {
        return measurementUnitService.getMeasurementUnitById(userId, measurementId);
    }

    ///////////////////////////////////////////////////////////////////////////////

    //POST
    @PostMapping("{userId}")
    public void addMeasurementUnit(
            @PathVariable Integer userId,
            @RequestBody MeasurementUnit measurementUnit
    ) {
        measurementUnitService.addMeasurementUnit(userId, measurementUnit);
    }

    //PUT
    @PutMapping("{userId}/{measurementUnitId}")
    public void updateMeasurementUnitById(
            @PathVariable Integer userId,
            @PathVariable Integer measurementUnitId,
            @RequestBody MeasurementUnit measurementUnit
    ) {
        measurementUnitService.updateMeasurementUnitById(
                userId,
                measurementUnitId,
                measurementUnit
        );
    }

    ///////////////////////////////////////////////////////////////////////////////

    //DELETE
    @DeleteMapping("{id}")
    public void removeMeasurementUnitById(@PathVariable Integer id) {
        measurementUnitService.removeMeasurementUnitById(id);
    }
}

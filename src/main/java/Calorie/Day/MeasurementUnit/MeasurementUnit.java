package Calorie.Day.MeasurementUnit;

import jakarta.persistence.*;

@Entity
public class MeasurementUnit {
    @Id
    @GeneratedValue
    private Integer id;

    //kg, g, 100g, lbs, ...
    private String measurementUnitName;

    private int measurementUnitInGrams;

    public MeasurementUnit() {}

    public MeasurementUnit(Integer id, String measurementUnitName, int measurementUnitInGrams) {
        this.id = id;
        setMeasurementUnitName(measurementUnitName);
        setMeasurementUnitInGrams(measurementUnitInGrams);
    }

    public int getId() {
        return id;
    }

    public String getMeasurementUnitName() {
        return measurementUnitName;
    }

    public int getMeasurementUnitInGrams() {
        return measurementUnitInGrams;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public void setMeasurementUnitName(String measurementUnitName) {
        if(measurementUnitName.length() < 3 ||  measurementUnitName.length() > 20) {
            throw new IllegalArgumentException(
                    "A mértékegység nevének 3 és 20 karakter között kell lennie!"
            );
        }

        this.measurementUnitName = measurementUnitName;
    }

    public void setMeasurementUnitInGrams(int measurementUnitInGrams) {
        if(measurementUnitInGrams <= 0) {
            throw new IllegalArgumentException(
                    "Tömeg nem lehet nullánál kisebb!"
            );
        }

        this.measurementUnitInGrams = measurementUnitInGrams;
    }
}

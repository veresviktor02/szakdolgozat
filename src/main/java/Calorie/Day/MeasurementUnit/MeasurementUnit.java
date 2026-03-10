package Calorie.Day.MeasurementUnit;

import Calorie.User.User;

import com.fasterxml.jackson.annotation.JsonBackReference;

import jakarta.persistence.*;

import java.util.Objects;

@Entity
public class MeasurementUnit {
    @Id
    @GeneratedValue
    private Integer id;

    @Column(unique = true)
    //kg, g, 100g, lbs, ...
    private String measurementUnitName;

    private int measurementUnitInGrams;

    @ManyToOne
    @JoinColumn(name = "owner_id", nullable = false)
    @JsonBackReference //Ettől nem lesz rekurzív a JSON!
    private User owner;

    public MeasurementUnit() {}

    public MeasurementUnit(
            Integer id,
            String measurementUnitName,
            int measurementUnitInGrams,
            User owner
    ) {
        this.id = id;
        setMeasurementUnitName(measurementUnitName);
        setMeasurementUnitInGrams(measurementUnitInGrams);
        this.owner = owner;
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

    public User getOwner() {
        return owner;
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
                    "Tömeg nem lehet nulla vagy kisebb szám!"
            );
        }

        this.measurementUnitInGrams = measurementUnitInGrams;
    }

    public void setOwner(User owner) {
        this.owner = owner;
    }

    @Override
    public boolean equals(Object o) {
        if(o == null || getClass() != o.getClass()) return false;
        MeasurementUnit that = (MeasurementUnit) o;
        return measurementUnitInGrams == that.measurementUnitInGrams &&
                Objects.equals(id, that.id) &&
                Objects.equals(measurementUnitName, that.measurementUnitName) &&
                Objects.equals(owner, that.owner);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id, measurementUnitName, measurementUnitInGrams, owner);
    }

    @Override
    public String toString() {
        return "MeasurementUnit:" + '\n' +
                "id = " + id + '\n' +
                "measurementUnitName = " + measurementUnitName + '\n' +
                "measurementUnitInGrams = " + measurementUnitInGrams + '\n' +
                "owner = " + owner;
    }
}

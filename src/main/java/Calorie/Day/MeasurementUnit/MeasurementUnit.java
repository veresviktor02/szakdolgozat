package Calorie.Day.MeasurementUnit;

import Calorie.Exceptions.MeasurementUnitException;

import Calorie.User.User;

import com.fasterxml.jackson.annotation.JsonBackReference;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import jakarta.persistence.*;

import java.util.Objects;

//"hibernateLazyInitializer": {} ellen!
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
//Egy mértékegységnévből ne lehessen több, de más-más felhasználónak lehet így ugyanaz a név!
@Entity
@Table(uniqueConstraints = {@UniqueConstraint(columnNames = {"owner_id", "measurementUnitName"})})
public class MeasurementUnit {
    @Id
    @GeneratedValue
    private Integer id;

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
            throw new MeasurementUnitException(
                    "A mértékegység nevének 3 és 20 karakter között kell lennie!"
            );
        }

        this.measurementUnitName = measurementUnitName;
    }

    public void setMeasurementUnitInGrams(int measurementUnitInGrams) {
        if(measurementUnitInGrams <= 0) {
            throw new MeasurementUnitException(
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
        return "Mértékegység: " + '\n' +
                "ID = " + id + '\n' +
                "Mértékegység neve = " + measurementUnitName + '\n' +
                "Mértékegység grammban = " + measurementUnitInGrams + '\n' +
                "Tulajdonos = " + owner;
    }
}

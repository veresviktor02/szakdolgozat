package Calorie.Exceptions;

public class MeasurementUnitException extends RuntimeException {
    public MeasurementUnitException(String message) {
        super(message);
    }

    public MeasurementUnitException(String message, Throwable cause) {
        super(message, cause);
    }
}

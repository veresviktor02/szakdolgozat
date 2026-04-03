package Calorie.Exceptions;

public class DayException extends RuntimeException {
    public DayException(String message) {
        super(message);
    }

    public DayException(String message, Throwable cause) {
        super(message, cause);
    }
}
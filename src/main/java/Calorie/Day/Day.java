package Calorie.Day;

import Calorie.Food.Food;
import jakarta.persistence.*;

import java.time.LocalDate;
import java.util.List;
import java.util.Objects;

@Entity
public class Day {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;
    //Év-hó-nap tárolására!
    //POST előtt check, hogy van-e már az adott nap!!!
    private LocalDate date;
    //Nem primitív adattípus List-ben.
    @OneToMany(cascade = CascadeType.ALL)
    @JoinColumn(name = "day_id") // Ide kerül az idegen kulcs a Food táblába.
    private List<Food> foodList;

    public Day() {}

    public Day(Integer id, LocalDate date, List<Food> foodList) {
        this.id = id;
        this.date = date;
        this.foodList = foodList;
    }

    public Integer getId() {
        return id;
    }

    public LocalDate getDate() {
        return date;
    }

    public List<Food> getFoodList() {
        return foodList;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public void setDate(LocalDate date) {
        this.date = date;
    }

    public void setFoodList(List<Food> foodList) {
        this.foodList = foodList;
    }

    @Override
    public boolean equals(Object o) {
        if(o == null || getClass() != o.getClass()) return false;
        Day day = (Day) o;
        return Objects.equals(id, day.id) && Objects.equals(date, day.date) && Objects.equals(foodList, day.foodList);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id, date, foodList);
    }

    @Override
    public String toString() {
        return "Day: " +
                "id = " + id + '\n' +
                "date = " + date + '\n' +
                "foodList = " + foodList;
    }
}

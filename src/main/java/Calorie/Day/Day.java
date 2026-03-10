package Calorie.Day;

import Calorie.User.User;

import com.fasterxml.jackson.annotation.JsonBackReference;

import jakarta.persistence.*;

import java.time.LocalDate;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

//Egy napból ne lehessen több, de más-más felhasználónak lehet így ugyanaz a dátum!
@Entity
@Table(uniqueConstraints = {@UniqueConstraint(columnNames = {"user_id", "date"})})
public class Day {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(nullable = false)
    private LocalDate date;

    @OneToMany(mappedBy = "day", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<EmbeddedFood> foodList = new ArrayList<>();

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    @JsonBackReference // Ettől nem lesz rekurzív a JSON!
    private User user;

    public Day() {}

    public Day(Integer id, LocalDate date, List<EmbeddedFood> foodList, User user) {
        this.id = id;
        this.date = date;
        this.foodList = foodList;
        this.user = user;
    }

    public Integer getId() {
        return id;
    }

    public LocalDate getDate() {
        return date;
    }

    public List<EmbeddedFood> getFoodList() {
        return foodList;
    }

    public User getUser() {
        return user;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public void setDate(LocalDate date) {
        this.date = date;
    }

    public void setFoodList(List<EmbeddedFood> foodList) {
        this.foodList = foodList;
    }

    public void setUser(User user) {
        this.user = user;
    }

    @Override
    public boolean equals(Object o) {
        if(o == null || getClass() != o.getClass()) return false;
        Day day = (Day) o;

        return Objects.equals(id, day.id) &&
                Objects.equals(date, day.date) &&
                Objects.equals(foodList, day.foodList);
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
                "foodList = " + foodList +
                "user = " + user;
    }
}

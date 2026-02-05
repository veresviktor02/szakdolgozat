import 'package:table_calendar/table_calendar.dart';

import 'day/day_model.dart';

import 'food/food_model.dart';

class MyCalendar {
  Map<DateTime, Day> daysMap = {};

  DateTime? selectedDay;
  DateTime focusedDay = DateTime.now();

  DateTime dayOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  CalendarFormat calendarFormat = CalendarFormat.week;

  List<Food> get selectedFoods {
    if (selectedDay == null) {
      return [];
    }
    return daysMap[dayOnly(selectedDay!)]?.foodList ?? [];
  }
}
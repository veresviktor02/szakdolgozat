import 'package:table_calendar/table_calendar.dart';

import 'day/day_model.dart';

import 'food/food_model.dart';

class MyCalendar {
  Map<DateTime, Day> daysMap = {};

  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();

  DateTime dayOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  CalendarFormat calendarFormat = CalendarFormat.week;

  List<Food> get selectedFoods {
    return daysMap[dayOnly(selectedDay)]?.foodList ?? [];
  }

  String hungarianNameOfMonths(DateTime date) {
    switch(date.month) {
      case DateTime.january:
        return '${date.year} Január';
      case DateTime.february:
        return '${date.year} Február';
      case DateTime.march:
        return '${date.year} Március';
      case DateTime.april:
        return '${date.year} Április';
      case DateTime.may:
        return '${date.year} Május';
      case DateTime.june:
        return '${date.year} Június';
      case DateTime.july:
        return '${date.year} Július';
      case DateTime.august:
        return '${date.year} Augusztus';
      case DateTime.september:
        return '${date.year} Szeptember';
      case DateTime.october:
        return '${date.year} Október';
      case DateTime.november:
        return '${date.year} November';
      default:
        return '${date.year} December';
    }
  }

  String hungarianNameOfDays(DateTime day) {
    switch(day.weekday) {
      case DateTime.monday:
        return 'H';
      case DateTime.tuesday:
        return 'K';
      case DateTime.wednesday:
        return 'Sze';
      case DateTime.thursday:
        return 'Cs';
      case DateTime.friday:
        return 'P';
      case DateTime.saturday:
        return 'Szo';
      default:
        return 'V';
    }
  }
}
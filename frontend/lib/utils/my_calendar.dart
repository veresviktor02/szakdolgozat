import 'package:flutter/material.dart';

import 'package:table_calendar/table_calendar.dart';

import '../day/day_model.dart';

import '../day/embedded_food_model.dart';

class MyCalendar {
  Map<DateTime, Day> daysMap = {};

  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();

  DateTime dayOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  CalendarFormat calendarFormat = CalendarFormat.week;

  List<EmbeddedFood> get selectedFoods {
    return daysMap[dayOnly(selectedDay)]?.foodList ?? [];
  }

  static List<String> nameOfDays = [
    'Hétfő',
    'Kedd',
    'Szerda',
    'Csütörtök',
    'Péntek',
    'Szombat',
    'Vasárnap',
  ];

  static String hungarianNameOfMonths(DateTime date) {
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

  static String hungarianNameOfDays(DateTime day) {
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

  static Widget calendarDay(DateTime day, Color boxDecorationColor) {
    return Container(
      width: 70,

      margin: const EdgeInsets.all(0.0),

      padding: const EdgeInsets.all(0.0),

      decoration: BoxDecoration(
        color: boxDecorationColor,

        border: Border.all(
          color: Colors.blueAccent,

          width: 2.5,
        ),

        borderRadius: BorderRadius.circular(8),
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Text(
            MyCalendar.hungarianNameOfDays(day),

            style: const TextStyle(
              fontSize: 24,

              color: Colors.black,
            ),
          ),

          Text(
            day.day.toString().padLeft(2, '0'),

            style: const TextStyle(
              fontSize: 24,

              fontWeight: FontWeight.bold,

              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
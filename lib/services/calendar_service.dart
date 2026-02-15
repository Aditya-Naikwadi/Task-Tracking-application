import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/material.dart';

class CalendarService {
  // Foundation for calendar integration
  // This service can be expanded to sync with device calendars (Google/iCloud)
  
  static Widget buildCalendarView({
    required DateTime focusedDay,
    required DateTime selectedDay,
    required Function(DateTime, DateTime) onDaySelected,
  }) {
    return TableCalendar(
      firstDay: DateTime.now().subtract(const Duration(days: 365)),
      lastDay: DateTime.now().add(const Duration(days: 365)),
      focusedDay: focusedDay,
      selectedDayPredicate: (day) => isSameDay(selectedDay, day),
      onDaySelected: onDaySelected,
      calendarStyle: const CalendarStyle(
        selectedDecoration: BoxDecoration(color: Color(0xFF00E5FF), shape: BoxShape.circle),
        todayDecoration: BoxDecoration(color: Color(0xFF161616), shape: BoxShape.circle),
        defaultTextStyle: TextStyle(color: Colors.white),
        weekendTextStyle: TextStyle(color: Color(0xFFB0B0B0)),
      ),
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold),
      ),
    );
  }
}

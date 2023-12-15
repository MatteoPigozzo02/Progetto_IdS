import 'package:intl/intl.dart';

extension Date on DateTime {
  DateTime getDate({int years = 0, int months = 0, int days = 0}) {
    return DateTime(year + years, month + months, day + days, 0, 0, 0, 0, 0);
  }

  String getTimeString() {
    //return DateFormat.Hm().format(this);
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  bool sameDayOf(DateTime other) {
    return day == other.day && month == other.month && year == other.year;
  }

  int compareDateTo(DateTime other) {
    int res = year.compareTo(other.year);
    if (res == 0) {
      res = month.compareTo(other.month);
      if (res == 0) {
        res = day.compareTo(other.day);
      }
    }
    return res;
  }
  bool isDateAfter(DateTime other) {
    return compareDateTo(other) > 0;
  }
  String getDateString() {
    return DateFormat.yMd().format(this);
  }
}

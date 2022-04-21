import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeHelper {
  static DateTime parseDotNetDateTimeToDart(String dateTime) {
    if (dateTime == null) return null;
    if (dateTime.substring(dateTime.length - 1) != 'Z') {
      dateTime = dateTime + 'Z'; // suffix Z for UTC timezone
    }

    try {
      var date = DateTime.parse(dateTime.replaceFirst('T', ' '));
      return date;
    } catch (e) {
      return null;
    }
  }

  static bool checkOrderNotCompleted(String dateTime) {
    if (dateTime.contains("0001-01-01")) {
      return true;
    }
    return false;
  }

  static String parseDateTimeToDateHHMM(DateTime dateTime) {
    if (dateTime == null) return null;
    final df = new DateFormat('dd-MMM-yyyy hh:mm a');
    var result = df.format((dateTime));
    return result;
    //dateTime.toString().substring(0,dateTime.toString().length-7);
  }

  static DateTime parseDateTimeFrom24To12(DateTime dateTime) {
    if (dateTime == null) return null;
    final df = new DateFormat('dd-MMM-yyyy hh:mm');
    var result = df.format((dateTime));
    return DateFormat('dd-MMM-yyyy hh:mm').parse(result);
    //dateTime.toString().substring(0,dateTime.toString().length-7);
  }

  static String parseDateTimeToDate(DateTime dateTime) {
    if (dateTime == null) return null;
    final df = new DateFormat('dd-MMM-yyyy');
    var result = df.format((dateTime));
    return result;
    //dateTime.toString().substring(0,dateTime.toString().length-7);
  }

  static String parseDateTimeToYYMM(DateTime dateTime) {
    if (dateTime == null) return null;
    final df = new DateFormat('MMM yyyy');
    var result = df.format((dateTime));
    return result;
    //dateTime.toString().substring(0,dateTime.toString().length-7);
  }

  static String parseDateTimeToHHMMOnly(DateTime dateTime) {
    if (dateTime == null) return null;
    final df = new DateFormat('hh:mm a');
    var result = df.format((dateTime));
    return result;
    //dateTime.toString().substring(0,dateTime.toString().length-7);
  }

  static DateTime parseDateTimeToDateIgnoreHHMMSS(DateTime dateTime) {
    if (dateTime == null) return null;
    final df = new DateFormat('dd-MMM-yyyy');
    var result = df.format((dateTime));
    return df.parse(result);
    //dateTime.toString().substring(0,dateTime.toString().length-7);
  }

  static bool compareDatesIsSameDate(DateTime dateA, DateTime dateB) {
    if (dateA.day == dateB.day &&
        dateA.month == dateB.month &&
        dateA.year == dateB.year) return true;
    return false;
  }

  static bool compareTimeOfDays(TimeOfDay timeA, TimeOfDay timeB) {
    // return true if timeB is greater than timeA
    double _doubleATime =
        timeA.hour.toDouble() + (timeA.minute.toDouble() / 60);
    double _doubleBTime =
        timeB.hour.toDouble() + (timeB.minute.toDouble() / 60);

    double _timeDiff = _doubleBTime - _doubleATime;
    return (_timeDiff > 0);
  }
}

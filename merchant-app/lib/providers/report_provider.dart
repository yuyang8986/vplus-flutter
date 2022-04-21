import 'package:flutter/material.dart';
import 'package:vplus_merchant_app/helpers/apiHelper.dart';
import 'package:vplus_merchant_app/models/report/adminReport/adminReport.dart';
import 'package:vplus_merchant_app/models/report/dateRangeReport.dart';

class ReportProvider with ChangeNotifier {
  DateRangeReport dateRangeReport;
  AdminReport adminReport;

  DateTime selectedStartDate;
  DateTime selectedEndDate;

  setStartDate(date) {
    selectedStartDate = date;
    notifyListeners();
  }

  setEndDate(date) {
    selectedEndDate = date;
    notifyListeners();
  }

  Future<bool> getDateRangeReportFromAPI(BuildContext context,
      DateTime startTime, DateTime endTime, int storeMenuId) async {
    var hlp = Helper();

    /// pass +1 day to backend to get the last day included.
    Map<String, dynamic> data = {
      "startTimeUTC": startTime.toUtc().toString(),
      "endTimeUTC": endTime.add(Duration(days: 1)).toUtc().toString(),
      "storeMenuId": storeMenuId,
    };
    var response = await hlp.postData("api/Report/DateRangeReport", data,
        context: context, hasAuth: true);

    if (response.isSuccess && response.data != null) {
      dateRangeReport = DateRangeReport.fromJson(response.data);
      notifyListeners();
      return true;
    } else {
      // the report, please try again.");
      return false;
    }
  }

  Future<bool> getDateRangeReportAdminFromAPI(BuildContext context,
      DateTime startTime, DateTime endTime, int storeMenuId) async {
    var hlp = Helper();

    /// pass +1 day to backend to get the last day included.
    Map<String, dynamic> data = {
      "startTimeUTC": startTime.toUtc().toString(),
      "endTimeUTC": endTime.add(Duration(days: 1)).toUtc().toString(),
      "storeMenuId": storeMenuId,
    };
    var response = await hlp.postData("api/Report/AdminReport", data,
        context: context, hasAuth: true);

    if (response.isSuccess && response.data != null) {
      adminReport = AdminReport.fromJson(response.data);
      notifyListeners();
      return true;
    } else {
      // the report, please try again.");
      return false;
    }
  }

  DateRangeReport get getDateRangeReport => dateRangeReport;

  set setDateRangeReport(DateRangeReport report) {
    dateRangeReport = report;
    notifyListeners();
  }

   set setDateRangeReportAdmin(AdminReport report) {
    adminReport = report;
    notifyListeners();
  }
}

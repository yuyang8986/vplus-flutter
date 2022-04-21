import 'package:vplus_merchant_app/models/report/categoryRanking.dart';

import '../../Order.dart';

class AdminReport {
  double totalAmountPaidInPeriod;
  double totalCommission;
  double totalNetPayableToMerchant;
  List<Order> userOrders;
  AdminReport(
      {this.totalAmountPaidInPeriod,
      this.totalCommission,
      this.totalNetPayableToMerchant,
      this.userOrders});

  AdminReport.fromJson(Map<String, dynamic> json) {
    totalAmountPaidInPeriod = json['totalAmountPaidInPeriod'];
    totalCommission = json['totalCommission'];
    totalNetPayableToMerchant = json['totalNetPayableToMerchant'];
    if (json['userOrders'] != null) {
      userOrders = <Order>[];
      json['userOrders'].forEach((v) {
        userOrders.add(new Order.fromJson(v));
      });
    }
  }
}

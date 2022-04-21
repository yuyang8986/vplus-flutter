import 'package:vplus_merchant_app/models/report/categoryRanking.dart';

class DateRangeReport {
  int cashTransactionCount;
  double cashTransactionAmount;
  int cardTransactionCount;
  double cardTransactionAmount;
  List<CategoryRanking> categoriesRanking;

  DateRangeReport(
      {this.cashTransactionCount,
      this.cashTransactionAmount,
      this.cardTransactionCount,
      this.cardTransactionAmount,
      this.categoriesRanking});

  DateRangeReport.fromJson(Map<String, dynamic> json) {
    cashTransactionCount = json['cashTransactionCount'];
    cashTransactionAmount = json['cashTransactionAmount'];
    cardTransactionCount = json['cardTransactionCount'];
    cardTransactionAmount = json['cardTransactionAmount'];
    if (json['categoriesRanking'] != null) {
      categoriesRanking = new List<CategoryRanking>();
      json['categoriesRanking'].forEach((v) {
        categoriesRanking.add(new CategoryRanking.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['cashTransactionCount'] = this.cashTransactionCount;
    data['cashTransactionAmount'] = this.cashTransactionAmount;
    data['cardTransactionCount'] = this.cardTransactionCount;
    data['cardTransactionAmount'] = this.cardTransactionAmount;
    if (this.categoriesRanking != null) {
      data['categoriesRanking'] =
          this.categoriesRanking.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

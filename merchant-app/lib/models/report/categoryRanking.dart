import 'package:vplus_merchant_app/models/report/menuItemRanking.dart';

class CategoryRanking {
  String menuCategoryName;
  int menuCategoryCount;
  double menuCategoryAmount;
  int menuCategoryId;
  List<MenuItemRanking> menuItemsRanking;

  CategoryRanking(
      {this.menuCategoryName,
      this.menuCategoryCount,
      this.menuCategoryAmount,
      this.menuCategoryId,
      this.menuItemsRanking});

  CategoryRanking.fromJson(Map<String, dynamic> json) {
    menuCategoryName = json['menuCategoryName'];
    menuCategoryCount = json['menuCategoryCount'];
    menuCategoryAmount = json['menuCategoryAmount'];
    menuCategoryId = json['menuCategoryId'];
    if (json['menuItemsRanking'] != null) {
      menuItemsRanking = new List<MenuItemRanking>();
      json['menuItemsRanking'].forEach((v) {
        menuItemsRanking.add(new MenuItemRanking.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['menuCategoryName'] = this.menuCategoryName;
    data['menuCategoryCount'] = this.menuCategoryCount;
    data['menuCategoryAmount'] = this.menuCategoryAmount;
    data['menuCategoryId'] = this.menuCategoryId;
    if (this.menuItemsRanking != null) {
      data['menuItemsRanking'] =
          this.menuItemsRanking.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

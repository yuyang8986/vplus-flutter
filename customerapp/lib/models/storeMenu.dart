import 'dart:ffi';

import 'menuAddOn.dart';
import 'menuCategory.dart';
import 'menuItem.dart';

class StoreMenu {
  int storeMenuId;
  bool isActive;
  int storeId;
  List<MenuCategory> menuCategories;
  List<MenuAddOn> menuAddOns;
  List<MenuItem> menuItems;
  double priceAdjust;

  StoreMenu({
    this.storeMenuId,
    this.isActive,
    this.storeId,
    this.menuCategories,
    this.menuAddOns,
    this.menuItems,
    this.priceAdjust
  });

  StoreMenu.fromJson(Map<String, dynamic> json) {
    storeMenuId = json['storeMenuId'];
    isActive = json['isActive'];
    storeId = json['storeId'];
    menuCategories = json['menuCategories'] == null
        ? null
        : new List<MenuCategory>.from(
            json["menuCategories"].map((x) => MenuCategory.fromJson(x)));
    menuAddOns = json['menuAddOns'] == null
        ? null
        : new List<MenuAddOn>.from(
            json["menuAddOns"].map((x) => MenuAddOn.fromJson(x)));
    menuItems = json['menuItems'] == null
        ? null
        : new List<MenuItem>.from(
            json["menuItems"].map((x) => MenuItem.fromJson(x)));
    priceAdjust = json["priceAdjust"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['storeMenuId'] = this.storeMenuId;
    data['isActive'] = this.isActive;
    data['storeId'] = this.storeId;
    data['menuCategories'] =
        new List<MenuCategory>.from(menuCategories.map((e) => e));
    data['menuAddOns'] = new List<MenuAddOn>.from(menuAddOns.map((e) => e));
    data['menuItems'] = new List<MenuItem>.from(menuItems.map((e) => e));
    data['priceAdjust'] =  this.priceAdjust;
    return data;
  }
}

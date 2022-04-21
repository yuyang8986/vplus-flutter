import 'menuItem.dart';

class MenuCategory {
  int menuCategoryId;
  String menuCategoryName;
  String menuSubtitle;
  String description;
  int index;
  List<MenuItem> menuItems;
  String menuCategoryImageUrl;

  MenuCategory({
    this.menuCategoryId,
    this.menuCategoryName,
    this.description,
    this.index,
    this.menuItems,
    this.menuSubtitle,
  });

  MenuCategory.fromJson(Map<String, dynamic> json) {
    menuCategoryId = json['menuCategoryId'];
    menuCategoryName = json['menuCategoryName'];
    description = json['description'];
    index = json['index'];
    menuSubtitle = json['subtitle'];
    menuItems = json['menuItems'] == null
        ? null
        : new List<MenuItem>.from(
            json["menuItems"].map((x) => MenuItem.fromJson(x)));
    menuCategoryImageUrl = json["menuCategoryImageUrl"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['menuCategoryId'] = this.menuCategoryId;
    data['menuCategoryName'] = this.menuCategoryName;
    data['description'] = this.description;
    data['index'] = this.index;
    data['subtitle'] = this.menuSubtitle;
    data['menuItems'] = menuItems == null
        ? null
        : new List<MenuItem>.from(menuItems.map((e) => e));
    data["menuCategoryImageUrl"] = this.menuCategoryImageUrl;
    return data;
  }
}

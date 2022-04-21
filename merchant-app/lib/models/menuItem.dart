import 'package:vplus_merchant_app/models/menuAddOn.dart';

class MenuItem {
  int menuItemId;
  String menuItemName;
  String description;
  String subtitle;
  double price;
  bool isSoldOut;
  bool isActive;
  bool isPopular;
  String imageUrl;
  int index;
  int menuCategoryId;
  bool isSelectedForCategory;
  bool hasAddOns;
  List<MenuAddOn> menuAddOns;
  String image64;
  int storeKitchenId;

  MenuItem({
    this.menuItemId,
    this.menuItemName,
    this.description,
    this.price,
    this.isSoldOut,
    this.isActive,
    this.imageUrl,
    this.index,
    this.menuCategoryId,
    this.isSelectedForCategory,
    this.hasAddOns,
    this.menuAddOns,
    this.image64,
    this.subtitle,
    this.storeKitchenId,
    this.isPopular
  });

  MenuItem.fromJson(Map<String, dynamic> json) {
    menuItemId = json['menuItemId'];
    menuItemName = json['menuItemName'];
    description = json['description'];
    price = json['price'];
    isSoldOut = json['isSoldOut'];
    isActive = json['isActive'];
    imageUrl = json['imageUrl'];
    image64 = json['image64'];
    index = json['index'];
    subtitle = json['subtitle'];
    menuCategoryId = json['menuCategoryId'];
    isSelectedForCategory = json['isSelectedForCategory'];
    hasAddOns = json['hasAddOns'];
    menuAddOns = json['menuAddOns'] == null
        ? null
        : new List<MenuAddOn>.from(
            json['menuAddOns'].map((e) => MenuAddOn.fromJson(e)));
    storeKitchenId = json['storeKitchenId'];
    isPopular = json['isPopular'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['menuItemId'] = this.menuItemId;
    data['nemuItemName'] = this.menuItemName;
    data['description'] = this.description;
    data['price'] = this.price;
    data['isSoldOut'] = this.isSoldOut;
    data['isActive'] = this.isActive;
    data['imageUrl'] = this.imageUrl;
    data['image64'] = this.image64;
    data['index'] = this.index;
    data['subtitle'] = this.subtitle;
    data['menuCategoryId'] = this.menuCategoryId;
    data['isSelectedForCategory'] = this.isSelectedForCategory;
    data['hasAddOns'] = this.hasAddOns;
    data['menuAddOns'] = this.menuAddOns == null
        ? null
        : this.menuAddOns.map((e) => e.toJson()).toList();
    data['storeKitchenId'] = this.storeKitchenId;
    data['isPopular'] = this.isPopular;
    return data;
  }

  //add this equal operator so as to prevent exception when change dropdownlist for stages and rebuild the futurebuilder
  bool operator ==(o) => o is MenuItem && o.menuItemId == menuItemId;
  int get hashCode => menuItemId.hashCode;
}

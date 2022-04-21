import 'menuAddOnOption.dart';

class UserOrderItemAddOn {
  int userOrderItemAddOnId;
  List<int> menuAddOnOptionIds;
  int userOrderItemId;
  List<MenuAddOnOption> menuAddOnOptions;
  double menuAddOnExtraCost;
  String userOrderItemAddOnName;

  UserOrderItemAddOn(
      {this.userOrderItemAddOnId,
      this.userOrderItemId,
      this.menuAddOnOptions,
      this.menuAddOnExtraCost,
      this.menuAddOnOptionIds,
      this.userOrderItemAddOnName});

  UserOrderItemAddOn.fromJson(Map<String, dynamic> json) {
    userOrderItemAddOnId = json['userOrderItemAddOnId'];
    userOrderItemId = json['userOrderItemId'];
    menuAddOnOptions = json['menuAddOnOptions'] == null
        ? null
        : new List<MenuAddOnOption>.from(
            json['menuAddOnOptions'].map((o) => MenuAddOnOption.fromJson(o)));
    //menuAddOnOptionIds = json['menuAddOnOptionIds'].cast<int>();
    userOrderItemAddOnName = json['userOrderItemAddOnName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userOrderItemAddOnId'] = this.userOrderItemAddOnId;
    data['userOrderItemId'] = this.userOrderItemId;
    data['menuAddOnOptions'] = this.menuAddOnOptions != null
        ? new List<MenuAddOnOption>.from(menuAddOnOptions.map((e) => e))
        : null;
    data['menuAddOnOptionIds'] = this.menuAddOnOptionIds;
    data['userOrderItemAddOnName'] = this.userOrderItemAddOnName;

    return data;
  }
}

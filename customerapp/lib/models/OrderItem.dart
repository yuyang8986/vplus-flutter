import 'package:vplus/models/userOrderItemAddOn.dart';

import 'menuItem.dart';

class OrderItem {
  // String note;
  List<ReturnCancelStatus> returnCancelStatus;
  int userOrderItemId;
  int userOrderId;
  MenuItem menuItem;
  int menuItemId;
  bool isExtraOrdered;
  bool isExtraOrderConfirmed;
  bool isTakeAway;
  int quantity;
  double price;
  ItemStatus itemStatus;
  List<UserOrderItemAddOn> userOrderItemAddOns;
  List<String> userOrderItemAddOnReceipt;
  String cancelReason;
  String returnReason;

  OrderItem({
    // this.note,
    this.returnCancelStatus,
    this.userOrderItemId,
    this.userOrderId,
    this.menuItem,
    this.menuItemId,
    this.isExtraOrdered,
    this.isExtraOrderConfirmed,
    this.isTakeAway,
    this.quantity,
    this.price,
    this.itemStatus,
    this.userOrderItemAddOns,
    this.userOrderItemAddOnReceipt,
    this.cancelReason,
    this.returnReason,
  });

  OrderItem.fromJson(Map<String, dynamic> json) {
    userOrderItemId = json['userOrderItemId'];
    userOrderId = json['userOrderId'];
    menuItem = json['menuItem'] != null
        ? new MenuItem.fromJson(json['menuItem'])
        : null;
    isExtraOrdered = json['isExtraOrdered'];
    isExtraOrderConfirmed = json['isExtraOrderConfirmed'];
    isTakeAway = json['isTakeAway'];
    quantity = json['quantity'];
    price = json['price'];
    itemStatus = ItemStatus.values[json['userItemStatus']];
    userOrderItemAddOns = json['userOrderItemAddOns'] == null
        ? null
        : new List<UserOrderItemAddOn>.from(json['userOrderItemAddOns']
            .map((o) => UserOrderItemAddOn.fromJson(o)));
    menuItemId = json['menuItemId'];
    cancelReason = json['cancelReason'];
    returnReason = json['returnReason'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userOrderItemId'] = this.userOrderItemId;
    data['userOrderId'] = this.userOrderId;
    // pass menuItem for price check
    data['menuItem'] = this.menuItem == null
        ? null
        : data['menuItem'] = this.menuItem.toJson();
    data['isExtraOrdered'] = this.isExtraOrdered;
    data['isExtraOrderConfirmed'] = this.isExtraOrderConfirmed;
    data['isTakeAway'] = this.isTakeAway;
    data['quantity'] = this.quantity;
    data['price'] = this.price;
    data['userItemStatus'] = this.itemStatus.index;
    data['userOrderItemAddOns'] = this.userOrderItemAddOns != null &&
            !this
                .userOrderItemAddOns
                .any((element) => element.menuAddOnOptionIds == null)
        ? new List<UserOrderItemAddOn>.from(userOrderItemAddOns.map((e) => e))
        : null;
    data['menuItemId'] = this.menuItemId;
    data['returnReason'] = this.returnReason;
    data['cancelReason'] = this.cancelReason;
    return data;
  }
}

enum ItemStatus {
  AwaitingConfirmation,
  Preparing,
  Served,
  Cancelled,
  Returned,
  Voided,
  Ready
}

enum ReturnCancelStatus { OutofStock, CustomerRequest, Exchange, Spoiled }

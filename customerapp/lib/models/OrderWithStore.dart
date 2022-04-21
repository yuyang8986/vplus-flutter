import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:vplus/models/Order.dart';
import 'package:vplus/models/store.dart';

class OrderWithStore {
  Order order;
  Store store;

  OrderWithStore({this.order, this.store});
  // operator reload
  bool operator ==(o) =>
      o is OrderWithStore && o.order.userOrderId == order.userOrderId;
  int get hashCode => hashValues(order.userOrderId.hashCode, order.hashCode);

  OrderWithStore.fromJson(Map<String, dynamic> json) {
    order = Order.fromJson(json["order"]);
    store = Store.fromJson(json["store"]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["order"] = this.order.toJson();
    data["store"] = this.store.toJson();
    return data;
  }
}

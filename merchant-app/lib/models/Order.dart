
import 'package:vplus_merchant_app/helpers/date_time_helper.dart';
import 'package:vplus_merchant_app/models/ExtraOrder.dart';
import 'package:vplus_merchant_app/models/OrderItem.dart';
import 'package:vplus_merchant_app/models/user.dart';

class Order {
  OrderPaymentStatus paymentStatus;
  bool paymentSuccessful;
  bool itemBeenServed;

  bool isPaid;
  bool isAdminReset;

  int userOrderId;
  int storeMenuId;
  OrderType orderType;
  double totalAmount = 0;
  double totalPaidAmount = 0;
  double discount = 0;
  String note;
  String table;
  String takeAwayId;
  PaymentMethodType paymentMethod;
  List<OrderItem> userItems;
  DateTime orderCreateDateTimeUTC;
  DateTime orderCompleteDateTimeUTC;
  UserOrderStatus userOrderStatus;
  int numberOfItems;
  List<ExtraOrder> userExtraOrders;
  double deliveryFee;
  User user;

  Order({
    this.userOrderId,
    this.storeMenuId,
    this.orderType,
    this.totalAmount,
    this.totalPaidAmount,
    this.discount,
    this.note,
    this.table,
    this.takeAwayId,
    this.userOrderStatus,
    this.paymentMethod,
    this.orderCreateDateTimeUTC,
    this.orderCompleteDateTimeUTC,
    this.userItems,
    this.numberOfItems,
    this.paymentStatus,
    this.itemBeenServed = false,
    this.paymentSuccessful = false,
    this.isPaid = false,
    this.isAdminReset = false,
    this.userExtraOrders,
    this.deliveryFee,
    this.user
  });

  Order.fromJson(Map<String, dynamic> json) {
    userOrderId = json['userOrderId'];
    storeMenuId = json['storeMenuId'];
    orderType = OrderType.values[json['orderType']];
    totalAmount = json['totalAmount'];
    totalPaidAmount = json['totalPaidAmount'];
    discount = json['discount'];
    note = json['note'];
    table = json['table'];
    takeAwayId = json['takeAwayId'];
    isPaid = json['isPaid'];
    isAdminReset = json['isAdminReset'];
    deliveryFee = json['deliveryFee'];
    userOrderStatus = UserOrderStatus.values[json['userOrderStatus']];
    if (json["paymentMethodType"] != null) {
      paymentMethod = PaymentMethodType.values[json["paymentMethodType"]];
    } else {
      paymentMethod = null;
    }
    orderCreateDateTimeUTC = DateTimeHelper.parseDotNetDateTimeToDart(
        json['orderCreateDateTimeUTC']);
    orderCompleteDateTimeUTC = DateTimeHelper.parseDotNetDateTimeToDart(
        json['orderCompleteDateTimeUTC']);
    if (json['userItems'] != null) {
      userItems = new List<OrderItem>();
      json['userItems'].forEach((v) {
        userItems.add(new OrderItem.fromJson(v));
      });
    }
    if (json['userExtraOrders'] != null) {
      userExtraOrders = new List<ExtraOrder>();
      json['userExtraOrders'].forEach((v) {
        userExtraOrders.add(new ExtraOrder.fromJson(v));
      });
    }
     if (json['user'] != null) {
      user = User.fromJson(json['user']);
    }
    itemBeenServed ??= false;
    paymentStatus = json['isPaid']
        ? OrderPaymentStatus.Paid
        : OrderPaymentStatus.AwaitingPayment;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userOrderId'] = this.userOrderId;
    data['storeMenuId'] = this.storeMenuId;
    data['orderType'] = this.orderType.index;
    data['totalAmount'] = this.totalAmount;
    data['totalPaidAmount'] = this.totalPaidAmount;
    data['discount'] = this.discount;
    data['note'] = this.note;
    data['table'] = this.table;
    data['takeAwayId'] = this.takeAwayId;
    data['userOrderStatus'] = this.userOrderStatus.index;
    data['isPaid'] = this.isPaid;
    data['isAdminReset'] = this.isAdminReset;
    if (this.paymentMethod != null) {
      data['paymentMethodType'] = this.paymentMethod.index;
    }
    if (this.userItems != null) {
      data['userItems'] = this.userItems.map((v) => v.toJson()).toList();
    }
    if (this.userExtraOrders != null) {
      data['userExtraOrders'] =
          this.userExtraOrders.map((v) => v.toJson()).toList();
    }
    return data;
  }

  // operator reload
  bool operator ==(o) => o is Order && o.userOrderId == userOrderId;
  int get hashCode => userOrderId.hashCode;
}

enum OrderType {
  QR,
  DineIn,
  TakeAway,
  PickUp,
  Delivery,
}

enum UserOrderStatus {
  Started,
  AwaitConfirm,
  InProgress,
  Completed,
  Cancelled,
  Voided,
  Ready,
  Delivering,
  Delivered,
}

enum PaymentMethodType {
  Cash,
  Card,
  Other,
  StripeCard,
}

enum OrderPaymentStatus {
  Paid,
  Voided,
  AwaitingPayment,
  Cancelled,
  Refunded,
}

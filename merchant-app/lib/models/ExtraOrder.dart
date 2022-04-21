import 'package:vplus_merchant_app/helpers/date_time_helper.dart';
import 'package:vplus_merchant_app/models/OrderItem.dart';

class ExtraOrder {
  int userExtraOrderId;
  int userOrderId;
  DateTime orderCreateDateTimeUTC;
  String note;
  List<OrderItem> userItems;
  bool isPaid;

  ExtraOrder({
    this.userExtraOrderId,
    this.userOrderId,
    this.orderCreateDateTimeUTC,
    this.note,
    this.userItems,
    this.isPaid=false,
  });

  ExtraOrder.fromJson(Map<String, dynamic> json) {
    userExtraOrderId = json['userExtraOrderId'];
    userOrderId = json['userOrderId'];
    orderCreateDateTimeUTC = DateTimeHelper.parseDotNetDateTimeToDart(
        json['orderCreateDateTimeUTC']);
    note = json['note'];
    isPaid=json['isPaid'];
    
    if (json['userItems'] != null) {
      userItems = new List<OrderItem>();
      json['userItems'].forEach((v) {
        userItems.add(new OrderItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userExtraOrderId'] = this.userExtraOrderId;
    data['userOrderId'] = this.userOrderId;
    // orderCreateDateTimeUTC gets from the backend
    data['note'] = this.note;
    data['isPaid']=this.isPaid;
    if (this.userItems != null) {
      data['userItems'] = this.userItems.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

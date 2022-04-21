import 'package:flutter/cupertino.dart';
import 'package:vplus/helper/apiHelper.dart';
import 'package:vplus/helper/order_helper.dart';
import 'package:vplus/models/OrderWithStore.dart';

class DriverOrderListProvider extends ChangeNotifier {
  List<OrderWithStore> deliveringOrderList = [];
  List<OrderWithStore> deliveredOrderList = [];
  List<OrderWithStore> allAvailableOrderList = [];
  bool hasNextPage;
  bool isDelivered = false;
  String isActive = "1";
  OrderWithStore orderWithStore;

  Future<List<OrderWithStore>> getOrderListByDriverId(
      BuildContext context, int driverId, int pageNumber) async {
    pageNumber ??= 1;

    deliveringOrderList = [];
    deliveredOrderList = [];
    allAvailableOrderList = [];

    var helper = Helper();

    var response = await helper.getData(
        "api/Menu/userOrders/delivery/getOrders/$driverId?PageNumber=$pageNumber&IsDeliveredOrder=$isDelivered",
        context: context,
        hasAuth: true);
    var response2 = await helper.getData(
        "api/Menu/userOrders/delivery/getOrders",
        context: context,
        hasAuth: true);

    if (response.isSuccess &&
        response.data != null &&
        response2.isSuccess &&
        response2.data != null) {
      Map<String, dynamic> header = helper.getResponseHeaderXPag();
      this.hasNextPage = header["HasNext"] as bool;
      (isActive == "1")
          ? response.data.forEach((ow) {
              OrderWithStore recvOS = OrderWithStore.fromJson(ow);
              deliveringOrderList = OrderHelper.addOrUpdateOrderWithStore(
                  deliveringOrderList, recvOS);
            })
          : (isActive == "2")
              ? response2.data.forEach((ow) {
                  OrderWithStore recvOS = OrderWithStore.fromJson(ow);
                  allAvailableOrderList = OrderHelper.addOrUpdateOrderWithStore(
                      allAvailableOrderList, recvOS);
                })
              : response.data.forEach((ow) {
                  OrderWithStore recvOS = OrderWithStore.fromJson(ow);
                  deliveredOrderList = OrderHelper.addOrUpdateOrderWithStore(
                      deliveredOrderList, recvOS);
                });
      deliveringOrderList
          .sort((a, b) => b.order.userOrderId.compareTo(a.order.userOrderId));
      deliveredOrderList
          .sort((a, b) => b.order.userOrderId.compareTo(a.order.userOrderId));
      allAvailableOrderList
          .sort((a, b) => b.order.userOrderId.compareTo(a.order.userOrderId));
      notifyListeners();
    } else {
      helper.showToastError('Unable to update your orders, please try again');
    }
    return allAvailableOrderList;
  }

  bool get getHasNextPage => hasNextPage;
  List<OrderWithStore> get getAllAvailableOrderList => allAvailableOrderList;
  List<OrderWithStore> get getDeliveringOrderList => deliveringOrderList;
  List<OrderWithStore> get getDeliveredOrderList => deliveredOrderList;

  set setAllAvailableOrderList(List<OrderWithStore> newOrderList) =>
      allAvailableOrderList = newOrderList;

  set setDeliveringOrderList(List<OrderWithStore> newOrderList) =>
      deliveringOrderList = newOrderList;

  set setDeliveredOrderList(List<OrderWithStore> newOrderList) =>
      deliveredOrderList = newOrderList;

  void addOrderWithStoreToDelivered(OrderWithStore os) {
    deliveringOrderList.remove(os);
    deliveredOrderList.add(os);
    notifyListeners();
  }

  void addOrderWithStoreToDelivering(OrderWithStore os) {
    allAvailableOrderList.remove(os);
    deliveringOrderList.add(os);
    notifyListeners();
  }

  String get getIsActive => isActive;
  set setIsActive(String isNowActive) {
    isActive = isNowActive;
    notifyListeners();
  }

  setIsDelivered(bool isDeliveredFlag) {
    isDelivered = isDeliveredFlag;
    notifyListeners();
  }

  OrderWithStore get getSelectedOrderWithStore => orderWithStore;
  set setSelectedOrderWithStore(OrderWithStore newSelectedOrder) {
    orderWithStore = newSelectedOrder;
    notifyListeners();
  }
}

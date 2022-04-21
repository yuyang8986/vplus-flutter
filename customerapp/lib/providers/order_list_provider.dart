import 'package:flutter/material.dart';
import 'package:vplus/helper/apiHelper.dart';
import 'package:vplus/helper/order_helper.dart';
import 'package:vplus/models/OrderWithStore.dart';

class OrderListProvider extends ChangeNotifier {
  List<OrderWithStore> activeOrderList = [];
  List<OrderWithStore> historyOrderList = [];
  bool hasNextPage;
  bool isActive = true;
  OrderWithStore orderWithStore;


  Future<List<OrderWithStore>> getOrderListByUserId(
      BuildContext context, int userId, int pageNumber) async {
    pageNumber ??= 1;

    activeOrderList = [];

    var helper = Helper();

    var response = await helper.getData(
        "api/Menu/userOrders/user/$userId?PageNumber=$pageNumber&IsActivePage=$isActive",
        context: context,
        hasAuth: true);

    if (response.isSuccess && response.data != null) {
      Map<String, dynamic> header = helper.getResponseHeaderXPag();
      this.hasNextPage = header["HasNext"] as bool;
      // for api response, if order with store not exists in the list,
      // then add to list. (both for active order and history order)
      (isActive)
          ? response.data.forEach((ow) {
              OrderWithStore recvOS = OrderWithStore.fromJson(ow);
              activeOrderList = OrderHelper.addOrUpdateOrderWithStore(
                  activeOrderList, recvOS);
            })
          : response.data.forEach((ow) {
              OrderWithStore recvOS = OrderWithStore.fromJson(ow);
              historyOrderList = OrderHelper.addOrUpdateOrderWithStore(
                  historyOrderList, recvOS);
            });
      activeOrderList
          .sort((a, b) => b.order.userOrderId.compareTo(a.order.userOrderId));
      historyOrderList
          .sort((a, b) => b.order.userOrderId.compareTo(a.order.userOrderId));
      notifyListeners();
    } else {
      helper.showToastError('Unable to update your orders, please try again');
    }
    return activeOrderList;
  }

  bool get getHasNextPage => hasNextPage;
  List<OrderWithStore> get getActiveOrderList => activeOrderList;
  set setActiveOrderList(List<OrderWithStore> newOrderList) =>
      activeOrderList = newOrderList;

  void addOrderWithStoreToHistory(OrderWithStore os) {
    activeOrderList.remove(os);
    historyOrderList.add(os);
    notifyListeners();
  }

  List<OrderWithStore> get getHistoryOrderList => historyOrderList;
  set setHistoryOrderList(List<OrderWithStore> newOrderList) =>
      historyOrderList = newOrderList;

  bool get getIsActive => isActive;
  set setIsActive(bool isNowActive) {
    isActive = isNowActive;
    notifyListeners();
  }

  OrderWithStore get getSelectedOrderWithStore => orderWithStore;
  set setSelectedOrderWithStore(OrderWithStore newSelectedOrder) {
    orderWithStore = newSelectedOrder;
    notifyListeners();
  }
}

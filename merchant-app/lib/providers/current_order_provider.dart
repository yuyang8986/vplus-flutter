import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vplus_merchant_app/helpers/apiHelper.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/helpers/signalrHelper.dart';
import 'package:vplus_merchant_app/models/Order.dart';
import 'package:vplus_merchant_app/models/OrderItem.dart';
import 'package:vplus_merchant_app/models/menuItem.dart';
import 'package:vplus_merchant_app/models/menuAddOn.dart';
import 'package:vplus_merchant_app/models/menuAddOnOption.dart';
import 'package:vplus_merchant_app/models/userOrderItemAddOn.dart';
import 'package:vplus_merchant_app/providers/current_menu_provider.dart';
import 'package:vplus_merchant_app/providers/current_orderStatus_provider.dart';
import 'package:vplus_merchant_app/providers/current_stores_provider.dart';
import 'package:vplus_merchant_app/providers/orderlist_provider.dart';

class CurrentOrderProvider with ChangeNotifier {
  List<MenuAddOnOption> menuAddOnOptionList;
  MenuAddOn menuAddOn;
  MenuItem menuItem;
  OrderItem selectedOrderItem;
  Order order;
  Order placedOrder;

  UserOrderItemAddOn userOrderItemAddOn = new UserOrderItemAddOn();

  addOrderItem(OrderItem orderItem) {
    order.userItems.add(orderItem);
    order.totalAmount += orderItem.price;
    order.userOrderStatus = order.userOrderStatus ?? UserOrderStatus.Started;
    order.numberOfItems += orderItem.quantity;
    notifyListeners();
  }

  updateOrderItem(OrderItem newOrderItem) {
    int quantity = newOrderItem.quantity;
    double price = calculateItemPrice(newOrderItem);
    int orderItemIndex = order.userItems.indexWhere((orderItem) =>
        orderItem.menuItem.menuItemId == newOrderItem.menuItem.menuItemId);

    order.userItems[orderItemIndex].quantity = quantity;
    order.userItems[orderItemIndex].isTakeAway = newOrderItem.isTakeAway;
    order.userItems[orderItemIndex].price = price;
    order.numberOfItems +=
        (quantity - order.userItems[orderItemIndex].quantity);
    notifyListeners();
  }

  countOrderItemNumbers() {
    int totalNumber = 0;
    order.userItems.forEach((orderItem) => totalNumber += orderItem.quantity);
    return totalNumber;
  }

  bool checkIfItemInOrder(MenuItem menuItem) {
    if ((order.userItems.firstWhere(
            (userItems) => userItems.menuItem.menuItemId == menuItem.menuItemId,
            orElse: () => null)) !=
        null) {
      return true;
    } else {
      return false;
    }
  }

  removeOrderItem(OrderItem orderItem) {
    order.userItems.removeWhere(
        (item) => item.menuItem.menuItemId == orderItem.menuItem.menuItemId);
    order.numberOfItems -= orderItem.quantity;
    order.totalAmount -= orderItem.price;
    notifyListeners();
  }

  Future getExistingPlacedOrderFromAPI(BuildContext context) async {
    var helper = Helper();
    var response = await helper.getData(
        "api/menu/userOrders/" + placedOrder.userOrderId.toString(),
        context: context,
        hasAuth: true);
    if (response.isSuccess) {
      var order = Order.fromJson(response.data);
      placedOrder = order;
      notifyListeners();
    }
  }

  Future getOrderByOrderId(BuildContext context, int orderId) async {
    var helper = Helper();
    var response = await helper.getData(
        "api/menu/userOrders/" + orderId.toString(),
        context: context,
        hasAuth: true);
    if (response.isSuccess) {
      order = Order.fromJson(response.data);
      // update the placed order
      if (order.userOrderStatus != UserOrderStatus.Started) {
        placedOrder = Order.fromJson(response.data);
        order.numberOfItems = 0;
        cleanOrderItem();
      }
      notifyListeners();
    }
  }

  Order get getOrder {
    // init();
    return order;
  }

  void setOrder(Order inputOrder) {
    order = inputOrder;
    notifyListeners();
  }

  Order get getPlacedOrder {
    return placedOrder;
  }

  void clearOrder() {
    placedOrder = null;
    order = null;
    //notifyListeners();
  }

  cleanOrderItem() {
    order?.userItems = [];
    notifyListeners();
  }

  double getTotal() {
    double total = 0;
    order.userItems.forEach((e) {
      total = total + e.price;
    });
    order.totalAmount = total;
    return total;
  }

  Future<bool> initOrder(BuildContext context, int storeMenuId,
      String tableName, int orderType) async {
    var hlp = Helper();
    try {
      Map<String, dynamic> data = {
        "storeMenuId": storeMenuId,
        "table": tableName,
        "orderType": orderType,
      };

      var response = await hlp.postData("api/Menu/userOrders/init", data,
          context: context, hasAuth: true);

      if (response.isSuccess) {
        order = Order.fromJson(response.data);
        // init data for frontend
        order.numberOfItems ??= 0;
        // add order to active order
        // await Provider.of<OrderListProvider>(context, listen: false)
        //     .insertOrderToActiveOrderList(order);

        await Provider.of<OrderListProvider>(context, listen: false)
            .insertOrderToActiveOrderList(order);
        var signalr = SignalrHelper();
        var storeId = Provider.of<CurrentStoresProvider>(context, listen: false)
            .getStoreId(context);
        await signalr.sendUserOrder(
            SignalrHelper.initOrderEvent, storeId, order.userOrderId);

        notifyListeners();
        return true;
      } else {
        hlp.showToastError(
            "${AppLocalizationHelper.of(context).translate('FailedToInitTableAlert')}");
        return false;
      }
    } catch (e) {
      hlp.showToastError("Failed to initialize the table: " +
          e.toString() +
          ", please try again.");
      return false;
    }
  }

  void updateOrderStatus(BuildContext context, Order order) {
    Provider.of<OrderListProvider>(context, listen: false)
        .getActiveOrderList()
        .forEach((element) {
      if (element.userOrderId == order.userOrderId) {
        element.userOrderStatus = UserOrderStatus.InProgress;
        element.paymentStatus = OrderPaymentStatus.AwaitingPayment;
        element.paymentSuccessful = false;
        return;
      }
    });
  }

  Future<bool> submitOrder(BuildContext context, Order order) async {
    var hlp = Helper();
    var response;

    Map<String, dynamic> data = order.toJson();

    if (placedOrder != null && placedOrder?.userOrderId != null) {
      //extra order
      response = await hlp.putData(
          "api/Menu/userOrders/${placedOrder.userOrderId}/extraOrder", data,
          context: context, hasAuth: true);
    } else
    //Create new order
    {
      response = await hlp.putData("api/Menu/userOrders/submit", data,
          context: context, hasAuth: true);
    }
    if (response.isSuccess) {
      // get latest order status after submit
      var resp = await hlp.getData(
          "api/menu/userOrders/" + order.userOrderId.toString(),
          context: context,
          hasAuth: true);
      if (resp.isSuccess) {
        var data = Order.fromJson(resp.data);
        placedOrder = data;

        cleanOrderItem();

        updateOrderStatus(context, placedOrder);

        var signalr = SignalrHelper();
        var storeId = Provider.of<CurrentStoresProvider>(context, listen: false)
            .getStoreId(context);
        await signalr.sendUserOrder(
            SignalrHelper.submitOrderEvent, storeId, placedOrder.userOrderId);

        notifyListeners();
        return true;
      } else {
        hlp.showToastError(
            "${AppLocalizationHelper.of(context).translate('FailedToSubmitOrderAlert')}");
        return false;
      }
    }
  }

  Future<bool> resetTable(
    BuildContext context,
    int orderId,
  ) async {
    var hlp = Helper();

    var response = await hlp.putData(
        "api/Menu/userOrders/$orderId/resetTable", null,
        context: context, hasAuth: true);

    if (response.isSuccess) {
      order = new Order();
      notifyListeners();
      return true;
    } else {
      hlp.showToastError(
          "${AppLocalizationHelper.of(context).translate('FailedToResetTableAlert')}");
      return false;
    }
  }

  Future<bool> deleteOrder(
    BuildContext context,
    int orderId,
  ) async {
    var hlp = Helper();

    var response = await hlp.deleteData("api/Menu/userOrders/$orderId",
        context: context, hasAuth: true);

    if (response.isSuccess) {
      order = new Order();
      var signalr = SignalrHelper();
      var storeId = Provider.of<CurrentStoresProvider>(context, listen: false)
          .getStoreId(context);
      await signalr.sendUserOrder(SignalrHelper.resetOrderEvent, storeId, null);

      notifyListeners();
      return true;
    } else {
      hlp.showToastError(
          "${AppLocalizationHelper.of(context).translate('FailedToDeleteOrderAlert')}");
      return false;
    }
  }

  sendOrderNotification(
      String table, String userOrderId, BuildContext context) async {
    var hlp = Helper();
    var data = {"table": table, "userOrderId": userOrderId};
    await hlp.postData("api/notification", data, context: context);
  }

  double calculateAddOnPrice(OrderItem orderItem) {
    double totalPrice = 0;

    for (int i = 0; i < orderItem.menuItem.menuAddOns.length; i++) {
      // each addon
      double currentAddOnPrice = 0;
      for (int j = 0;
          j < orderItem.menuItem.menuAddOns[i].menuAddOnOptions.length;
          j++) {
        // each addon option
        var currentOption =
            orderItem.menuItem.menuAddOns[i].menuAddOnOptions[j];
        if (currentOption.isSelected == true) {
          currentAddOnPrice = calculateSingleOptionPrice(
              currentOption, orderItem.menuItem.price);
          totalPrice += currentAddOnPrice;
        }
      }
    }
    return totalPrice;
  }

  double calculateSingleOptionPrice(
      MenuAddOnOption option, double menuItemPrice) {
    double price;
    //calculate price
    if (option.extraCostOptionViewModel != null &&
        option.extraCostOptionViewModel.extraCostType == 2) {
      // fixed price
      price = option.extraCostOptionViewModel.fixedAmount;
    } else if (option.extraCostOptionViewModel != null &&
        option.extraCostOptionViewModel.extraCostType == 1) {
      //percentage
      price =
          ((option.extraCostOptionViewModel.percent * 0.01) * menuItemPrice);
    } else {
      //free
      price = 0;
    }
    return price;
  }

  List<String> getAddOnReceipt(OrderItem orderItem) {
    List<String> selectedAddOnReceipt = new List<String>();

    for (int i = 0; i < orderItem.menuItem.menuAddOns.length; i++) {
      // each addon
      bool hasSelectedAddOn = false;
      String currentAddOnList =
          '${orderItem.menuItem.menuAddOns[i].menuAddOnName}:\n';

      for (int j = 0;
          j < orderItem.menuItem.menuAddOns[i].menuAddOnOptions.length;
          j++) {
        // each addon option
        var currentOption =
            orderItem.menuItem.menuAddOns[i].menuAddOnOptions[j];

        if (currentOption.isSelected == true) {
          hasSelectedAddOn = true;
          double currentAddOnPrice = calculateSingleOptionPrice(
              currentOption, orderItem.menuItem.price);
          currentAddOnList +=
              '${currentOption.optionName}(\$${currentAddOnPrice.toStringAsFixed(2)})\n';
        }
      }
      // append value if any data in this addon
      if (hasSelectedAddOn == true) {
        selectedAddOnReceipt.add(currentAddOnList);
      }
    }
    return selectedAddOnReceipt;
  }

  List<String> getAddOnReceiptFromBackend(OrderItem orderItem,
      {bool showPrice = true}) {
    // This function is used to get the add on description
    // from the backend, backend gives the `userOrderItemAddOns` list
    // TODO should aggregate with the `getAddOnReceipt` function

    List<String> selectedAddOnReceipt = new List<String>();

    for (int i = 0; i < orderItem.userOrderItemAddOns.length; i++) {
      // each addon
      String currentAddOnList =
          '${orderItem.userOrderItemAddOns[i].userOrderItemAddOnName}:';
      for (int j = 0;
          j < orderItem.userOrderItemAddOns[i].menuAddOnOptions.length;
          j++) {
        // each addon option
        var currentOption =
            orderItem.userOrderItemAddOns[i].menuAddOnOptions[j];
        if (showPrice == true) {
          double currentAddOnPrice = calculateSingleOptionPrice(
              currentOption, orderItem.menuItem.price);
          currentAddOnList +=
              '${currentOption.optionName}(\$${currentAddOnPrice.toStringAsFixed(2)}) ';
        } else {
          // do not show price, just addon option
          currentAddOnList += '${currentOption.optionName} ';
        }
      }
      selectedAddOnReceipt.add(currentAddOnList);
    }
    return selectedAddOnReceipt;
  }

  double calculateItemPrice(OrderItem orderItem) {
    double singleItemPrice;
    (orderItem.menuItem.hasAddOns == true)
        ? singleItemPrice =
            calculateAddOnPrice(orderItem) + orderItem.menuItem.price
        : singleItemPrice = orderItem.menuItem.price;

    return singleItemPrice * orderItem.quantity;
  }

  List<UserOrderItemAddOn> getMenuAddOnOptionIds(OrderItem orderItem) {
    List<UserOrderItemAddOn> userOrderItemAddOns =
        new List<UserOrderItemAddOn>();

    for (int i = 0; i < orderItem.menuItem.menuAddOns.length; i++) {
      // each addon
      UserOrderItemAddOn addOn = new UserOrderItemAddOn();
      addOn.menuAddOnOptionIds = new List<int>();
      for (int j = 0;
          j < orderItem.menuItem.menuAddOns[i].menuAddOnOptions.length;
          j++) {
        // each addon option
        var currentOption =
            orderItem.menuItem.menuAddOns[i].menuAddOnOptions[j];

        if (currentOption.isSelected == true) {
          addOn.menuAddOnOptionIds.add(currentOption.menuAddOnOptionId);
          // menuAddOnOptionIds.add(currentOption.menuAddOnOptionId);
        }
      }
      // add to List if this category is selected.
      if (addOn.menuAddOnOptionIds.isNotEmpty) {
        userOrderItemAddOns.add(addOn);
      }
    }
    return userOrderItemAddOns;
  }

  OrderItem getOrderItemByMenuItemId(int menuItemId) {
    OrderItem orderItem;
    orderItem = order.userItems
        .firstWhere((userItem) => userItem.menuItem.menuItemId == menuItemId);
    return orderItem;
  }

  String getTakeAwayIdShortcut(String takeAwayId) {
    int digitLength = 6;
    String idShortcut =
        "TA" + takeAwayId.substring(takeAwayId.length - digitLength);
    return idShortcut;
  }

  List<OrderItem> aggregateAllOrderItems(Order order) {
    /// return all orderItems within the order
    /// contains both original order and extra orders
    List<OrderItem> orderItems = new List<OrderItem>();
    orderItems.addAll(order.userItems);
    order.userExtraOrders
        .forEach((extraOrder) => orderItems.addAll(extraOrder.userItems));
    // add userOrderId to each order items
    orderItems
        .forEach((orderItem) => orderItem.userOrderId = order.userOrderId);
    return orderItems;
  }

  String aggregateAllOrderNotes(Order order) {
    /// return all order notes which contain in the original order and
    /// extra orders
    String orderNote = "";
    if (order.note != null && order.note.length > 0) {
      orderNote += order.note;
    }
    order.userExtraOrders.forEach((extraOrder) {
      if (extraOrder.note != null && extraOrder.note.length > 0) {
        orderNote += "\n" + extraOrder.note;
      }
    });
    return orderNote;
  }

  Future<bool> cancelUserOrderByOrderId(
      BuildContext context, int orderId) async {
    var hlp = Helper();

    var response = await hlp.putData(
        "api/Menu/userOrders/$orderId/cancel", null,
        context: context, hasAuth: true);
    return response.isSuccess;
  }
}

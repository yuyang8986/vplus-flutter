import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:vplus_merchant_app/helpers/apiHelper.dart';
import 'package:vplus_merchant_app/models/ExtraOrder.dart';
import 'package:vplus_merchant_app/models/Order.dart';
import 'package:vplus_merchant_app/models/OrderItem.dart';
import 'package:vplus_merchant_app/models/OrderItemPrint.dart';
import "package:collection/collection.dart";
import 'package:vplus_merchant_app/providers/current_menu_provider.dart';
import 'package:vplus_merchant_app/providers/current_order_provider.dart';
import 'package:vplus_merchant_app/providers/currentuser_provider.dart';

/// This provider contains all order list related functions.

class KDSProvider with ChangeNotifier {
  List<Order> allActiveOrders;

  List<OrderItemPrint> kdsByItemsList = new List<OrderItemPrint>();
  List<Order> kdsByOrderList;

  Future<void> updateKDSDataFromAPI(BuildContext context) async {
    await getAllActiveOrdersFromAPI(context);
    updateKDSByItemList(context);
    updateKDSByOrderList(context);
  }

  Future getAllActiveOrdersFromAPI(BuildContext context) async {
    /// get all active orders for current store
    /// ONLY menuItem with current storeKitchenId and null storeKitchenId will be included
    /// menuItems with other storeKitchenId will not be included.
    int storeMenuId =
        Provider.of<CurrentMenuProvider>(context, listen: false).getStoreMenuId;
    int currentStoreKitchenId =
        Provider.of<CurrentUserProvider>(context, listen: false)
            .getCurrentUserStoreKitchenId;
    var helper = Helper();
    var response = await helper.getData(
        'api/Menu/userOrders/$storeMenuId/all?IsActivePage=true&IsMax=true',
        context: context,
        hasAuth: true);

    if (response.isSuccess == true && response.data != null) {
      allActiveOrders =
          List.from(response.data).map((e) => Order.fromJson(e)).toList();
      // revmove menuItems which belongs to other kitchen
      allActiveOrders.forEach((Order order) {
        order.userItems.removeWhere((orderItem) =>
            (orderItem.menuItem.storeKitchenId != currentStoreKitchenId &&
                orderItem.menuItem.storeKitchenId != null));
        // check extra order
        if (order.userExtraOrders != null &&
            order.userExtraOrders.length != 0) {
          order.userExtraOrders.forEach((extraOrder) {
            extraOrder.userItems.removeWhere((orderItem) =>
                (orderItem.menuItem.storeKitchenId != currentStoreKitchenId &&
                    orderItem.menuItem.storeKitchenId != null));
          });
        }
      });
    } else {
      allActiveOrders = null;
    }
  }

  Future<bool> setOrderItemReady(
      BuildContext context, List<int> orderItemsId) async {
    var helper = Helper();
    var response = await helper.putData(
        "api/Menu/userOrders/userItems/ready", orderItemsId,
        context: context, hasAuth: true);
    return (response.isSuccess) ? true : false;
  }

  List<OrderItemPrint> updateKDSByItemList(BuildContext context) {
    /// update the KDS by item list, get the latest update from api
    /// and group it to KDS by item format (OrderItemPrint)
    List<PrintableItem> allPrintableItems;

    try {
      allPrintableItems =
          castListOrderToPrintableItemList(context, allActiveOrders);
      kdsByItemsList = groupPrintableItems(context, allPrintableItems);
      notifyListeners();
      return kdsByItemsList;
    } catch (e) {
      return null;
    }
  }

  List<Order> updateKDSByOrderList(BuildContext context) {
    /// update the KDS by order list, get the latest update from api
    /// and filter all preparing order items.
    /// All orderItems (including extra order items)stores in userItems
    /// extra order usused and set to null
    try {
      kdsByOrderList = filterAllPreparingOrder(allActiveOrders);
      notifyListeners();
      return kdsByOrderList;
    } catch (e) {
      return null;
    }
  }

  List<PrintableItem> castListOrderToPrintableItemList(
      BuildContext context, List<Order> orderList) {
    // only cast Preparing orderItem to printable item list
    List<PrintableItem> allPrintableItems = new List<PrintableItem>();
    orderList.forEach((order) {
      order.userItems.forEach((orderItem) {
        if (orderItem.itemStatus == ItemStatus.Preparing) {
          DateTime placedTime = order.orderCreateDateTimeUTC;
          allPrintableItems.add(castOrderItemToPrintableItem(
              context, orderItem, order, placedTime, order.note));
        }
      });
      // check extra order
      if (order.userExtraOrders != null && order.userExtraOrders.isNotEmpty) {
        order.userExtraOrders.forEach((extraOrder) {
          extraOrder.userItems.forEach((extraOrderItem) {
            if (extraOrderItem.itemStatus == ItemStatus.Preparing) {
              DateTime placedTime = extraOrder.orderCreateDateTimeUTC;
              allPrintableItems.add(castOrderItemToPrintableItem(
                  context, extraOrderItem, order, placedTime, extraOrder.note));
            }
          });
        });
      }
    });
    return allPrintableItems;
  }

  List<OrderItemPrint> groupPrintableItems(
      BuildContext context, List<PrintableItem> printableItems) {
    /// group printable items to cascade level order:
    /// Order -> flavour -> table info
    List<OrderItemPrint> orderItemPrintList = new List<OrderItemPrint>();
    // group by menu item id
    var menuItemMap = groupBy(printableItems, (p) => p.menuItemId);
    menuItemMap.forEach((menuItemId, printableItemList) {
      OrderItemPrint orderItemPrint = new OrderItemPrint();
      orderItemPrint.menuItemId = menuItemId;
      orderItemPrint.menuItemName = printableItemList[0].menuItemName;
      orderItemPrint.quantity =
          printableItemList.fold(0, (sum, item) => sum + item.quantity);
      orderItemPrint.flavoredItems = [];
      // group by add on list
      var flavoredItemMap =
          groupBy(printableItemList, (p) => p.menuAddOnOptionIds.toString());
      flavoredItemMap.forEach((addOnListId, flavoredPrintableItemList) {
        FlavoredOrderItem flavoredOrderItem = new FlavoredOrderItem();
        flavoredOrderItem.addOnReceipt =
            flavoredPrintableItemList[0].userOrderItemAddOnReceipt;
        flavoredOrderItem.userOrderItemAddOns =
            flavoredPrintableItemList[0].userOrderItemAddOns;
        flavoredOrderItem.flavoredQuantity = flavoredPrintableItemList.fold(
            0, (sum, item) => sum + item.quantity);
        flavoredOrderItem.tableInfoList = [];
        // iterable all table information
        flavoredPrintableItemList.forEach((table) {
          FlavoredItemTableInfo flavoredItemTableInfo =
              new FlavoredItemTableInfo();
          flavoredItemTableInfo.date = table.placedTime;
          flavoredItemTableInfo.table = table.orderTable;
          flavoredItemTableInfo.quantity = table.quantity;
          flavoredItemTableInfo.userOrderItemId = table.orderItemId;
          flavoredItemTableInfo.note = table.note;
          flavoredItemTableInfo.userOrderId = table.orderId;
          // append to list
          flavoredOrderItem.tableInfoList.add(flavoredItemTableInfo);
        });
        orderItemPrint.flavoredItems.add(flavoredOrderItem);
      });
      orderItemPrintList.add(orderItemPrint);
    });
    return orderItemPrintList;
  }

  List<PrintableItem> filterPrinterItemsByFlavoredItem(
      FlavoredOrderItem flavoredOrderItem, List<PrintableItem> printableItems) {
    // filter all printable items within the flavoredOrderItem
    // by user order item id
    List<PrintableItem> filterPrintableItems = new List<PrintableItem>();
    List<int> flavoredItemIds = new List<int>();

    flavoredOrderItem.tableInfoList
        .forEach((table) => flavoredItemIds.add(table.userOrderItemId));
    printableItems.forEach((printableItem) {
      if (flavoredItemIds.contains(printableItem.orderItemId)) {
        filterPrintableItems.add(printableItem);
      }
    });
    return filterPrintableItems;
  }

  List<Order> filterAllPreparingOrder(List<Order> orderList) {
    /// given an order list, return only the orders which contain
    /// preparing order items. Also get the add on receipt
    kdsByOrderList = new List<Order>();
    orderList.forEach((order) {
      List<OrderItem> allOrderItems =
          CurrentOrderProvider().aggregateAllOrderItems(order);
      order.note = CurrentOrderProvider().aggregateAllOrderNotes(order);
      order.userItems = allOrderItems
          .where((orderItem) => orderItem.itemStatus == ItemStatus.Preparing)
          .toList();
      if (order.userItems.length != 0) {
        // Add addon receipt
        order.userItems.forEach((orderItem) =>
            orderItem.userOrderItemAddOnReceipt = CurrentOrderProvider()
                .getAddOnReceiptFromBackend(orderItem, showPrice: false));
        // remove unused extra Orders
        order.userExtraOrders = null;
        kdsByOrderList.add(order);
      }
    });

    return kdsByOrderList;
  }

  get getKDSByItemsList => kdsByItemsList;
  get getKDSByOrderList => kdsByOrderList;
}

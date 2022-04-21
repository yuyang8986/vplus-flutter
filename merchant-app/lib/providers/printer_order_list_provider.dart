import 'package:flutter/cupertino.dart';
import 'package:vplus_merchant_app/helpers/apiHelper.dart';
import 'package:vplus_merchant_app/models/Order.dart';
import 'package:vplus_merchant_app/models/OrderItem.dart';
import 'package:vplus_merchant_app/models/OrderItemPrint.dart';
import "package:collection/collection.dart";

/// This provider contains all order list related functions.

class PrinterOrderListProvider with ChangeNotifier {
  List<Order> allActiveOrders;

  List<PrintableItem> selectedPrintableItems;
  List<PrintableItem> printedPrintableItems = new List<PrintableItem>();
  List<PrintableItem> allPrintableItems = new List<PrintableItem>();
  List<OrderItemPrint> orderItemPrintList = new List<OrderItemPrint>();
  Future getAllActiveOrdersFromAPI(
      BuildContext context, int storeMenuId) async {
    var helper = Helper();
    var response = await helper.getData(
        'api/Menu/userOrders/$storeMenuId/all?IsActivePage=true&IsMax=true',
        context: context,
        hasAuth: true);

    if (response.isSuccess == true && response.data != null) {
      allActiveOrders =
          List.from(response.data).map((e) => Order.fromJson(e)).toList();
    } else {
      allActiveOrders = null;
    }
  }

  Future<List<OrderItemPrint>> allActiveOrderToOrderItemPrint(
      context, storeMenuId) async {
    try {
      await getAllActiveOrdersFromAPI(context, storeMenuId);
      allPrintableItems =
          castListOrderToPrintableItemList(context, allActiveOrders);
      orderItemPrintList =
          await groupPrintableItems(context, allPrintableItems);
      notifyListeners();
      return orderItemPrintList;
    } catch (e) {
      return Future.error(e);
    }
  }

  List<PrintableItem> castListOrderToPrintableItemList(
      BuildContext context, List<Order> orderList) {
    List<PrintableItem> allPrintableItems = new List<PrintableItem>();
    orderList.forEach((order) {
      order.userItems.forEach((orderItem) {
        var yesterday = DateTime.now().add(Duration(days: -1));
        var today = DateTime.now();
        //var cutOff = DateTime(yesterday.year, yesterday.month, yesterday.day, 19,0);
        var cutOffToday = DateTime(today.year, today.month, today.day, 19,0);
        if (order.orderCreateDateTimeUTC.toLocal().isBefore(cutOffToday)) {
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

  Future<List<OrderItemPrint>> groupPrintableItems(
      BuildContext context, List<PrintableItem> printableItems) async {
    List<OrderItemPrint> orderItemPrintList = new List<OrderItemPrint>();
    // group by menu item id
    var menuItemMap = groupBy(printableItems, (p) => p.menuItemId);
    menuItemMap.forEach((menuItemId, printableItemList) {
      OrderItemPrint orderItemPrint = new OrderItemPrint();
      orderItemPrint.menuItemId = menuItemId;
      orderItemPrint.menuItemName = printableItemList[0].menuItemName;
      orderItemPrint.subtitle = printableItemList[0].subtitle;
      orderItemPrint.price = printableItemList[0].price;
      orderItemPrint.description = printableItemList[0].description;
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

  getSelectedPrintableItem() {
    selectedPrintableItems ??= allPrintableItems;
    return selectedPrintableItems;
  }

  selectedAllPrintableItem() {
    selectedPrintableItems = allPrintableItems;
    return selectedPrintableItems;
  }

  get getPrintedPrintableItem => printedPrintableItems;

  addSelectedPrintableItem(PrintableItem p) {
    selectedPrintableItems ??= allPrintableItems;
    List<int> itemIds = new List<int>();
    selectedPrintableItems.forEach((pItem) => itemIds.add(pItem.orderItemId));
    if (!itemIds.contains(p.orderItemId)) {
      selectedPrintableItems.add(p);
    }
    // notifyListeners();
  }

  addPrintedPrintableItem(PrintableItem p) {
    printedPrintableItems ??= [];
    List<int> itemIds = new List<int>();
    printedPrintableItems.forEach((pItem) => itemIds.add(pItem.orderItemId));
    if (!itemIds.contains(p.orderItemId)) {
      printedPrintableItems.add(p);
    }
    // notifyListeners();
  }

  removeSelectedPrintableItem(PrintableItem p) {
    selectedPrintableItems ??= allPrintableItems;
    List<int> itemIds = new List<int>();
    selectedPrintableItems.forEach((pItem) => itemIds.add(pItem.orderItemId));
    if (itemIds.contains(p.orderItemId)) {
      selectedPrintableItems.remove(selectedPrintableItems
          .firstWhere((item) => item.orderItemId == p.orderItemId));
    }

    // notifyListeners();
  }

  removePrintedPrintableItem(PrintableItem p) {
    printedPrintableItems ??= [];
    List<int> itemIds = new List<int>();
    printedPrintableItems.forEach((pItem) => itemIds.add(pItem.orderItemId));
    if (itemIds.contains(p.orderItemId)) {
      printedPrintableItems.remove(printedPrintableItems
          .firstWhere((item) => item.orderItemId == p.orderItemId));
    }
    // notifyListeners();
  }

  bool checkItemPrinted(PrintableItem p) {
    return printedPrintableItems.contains(p);
  }

  get getAllPrintableItems => allPrintableItems;

  get getOrderItemPrintList => orderItemPrintList;
}

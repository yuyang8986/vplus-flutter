import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:vplus_merchant_app/models/ExtraOrder.dart';
import 'package:vplus_merchant_app/models/Order.dart';
import 'package:vplus_merchant_app/models/OrderItem.dart';
import 'package:vplus_merchant_app/models/organization.dart';
import 'package:vplus_merchant_app/models/store.dart';
import 'package:vplus_merchant_app/models/userOrderItemAddOn.dart';
import 'package:vplus_merchant_app/providers/current_order_provider.dart';

class OrderItemPrint {
  /// Each item in cascade level.
  /// OrderItemPrint means one kind of menuItem which exists in current order
  /// contains the total quantity of that MenuItem (currently in order)
  /// and each flavour (combination of addons) of the menuItem
  int orderItemPrintId;
  int menuItemId;
  String menuItemName;
  int quantity;
  double price;
  String subtitle;
  String description;
  List<FlavoredOrderItem> flavoredItems;

  OrderItemPrint(
      {this.orderItemPrintId,
      this.menuItemId,
      this.menuItemName,
      this.quantity,
      this.subtitle,
      this.flavoredItems});
}

class FlavoredOrderItem {
  /// FlavoredOrderItem is order item with the same addons.
  /// It contains tableInfoList to indicate which table have this flavoredItem
  /// as well the the quantity.
  int flavoredOrderItemId;
  int orderItemId;
  List<String> addOnReceipt;
  List<UserOrderItemAddOn> userOrderItemAddOns;
  int flavoredQuantity;
  List<FlavoredItemTableInfo> tableInfoList;

  FlavoredOrderItem(
      {this.flavoredOrderItemId,
      this.orderItemId,
      this.addOnReceipt,
      this.userOrderItemAddOns,
      this.flavoredQuantity,
      this.tableInfoList});
}

class FlavoredItemTableInfo {
  // FlavoredItemTableInfo contains tables infos which ordered the FlavoredOrderItem.
  int flavoredOrderItemId;
  DateTime date;
  String table;
  int userOrderId;
  int userOrderItemId;
  int quantity;
  String note;

  FlavoredItemTableInfo(
      {this.flavoredOrderItemId,
      this.date,
      this.table,
      this.userOrderId,
      this.userOrderItemId,
      this.quantity,
      this.note});
}

class PrintableItem {
  // order item in printable format, contains order table, datetime info.
  int menuItemId;
  String menuItemName;
  int orderItemId;
  String orderTable;
  DateTime placedTime;
  int quantity;
  List<UserOrderItemAddOn> userOrderItemAddOns;
  List<String> userOrderItemAddOnReceipt;
  List<int> menuAddOnOptionIds;
  String note;
  String subtitle;
  int orderId;
  double price;
  String description;

  PrintableItem(
      {this.menuItemId,
      this.menuItemName,
      this.orderItemId,
      this.orderTable,
      this.placedTime,
      this.quantity,
      this.userOrderItemAddOns,
      this.userOrderItemAddOnReceipt,
      this.menuAddOnOptionIds,
      this.note,
      this.subtitle,
      this.orderId});
}

PrintableItem castOrderItemToPrintableItem(BuildContext context,
    OrderItem orderItem, Order order, DateTime orderTime, String orderNote) {
  PrintableItem printableItem = new PrintableItem();
  // cast data
  printableItem.menuItemId = orderItem.menuItem.menuItemId;
  printableItem.menuItemName = orderItem.menuItem.menuItemName;
  printableItem.orderItemId = orderItem.userOrderItemId;
  printableItem.subtitle = orderItem.menuItem.subtitle;
  printableItem.price = orderItem.menuItem.price;
  printableItem.description = orderItem.menuItem.description;
  printableItem.orderTable = (order.orderType == OrderType.TakeAway)
      ? Provider.of<CurrentOrderProvider>(context, listen: false)
          .getTakeAwayIdShortcut(order.takeAwayId)
      : order.table;
  printableItem.placedTime = orderTime;
  printableItem.quantity = orderItem.quantity;
  printableItem.userOrderItemAddOns = orderItem.userOrderItemAddOns;
  if (printableItem.userOrderItemAddOns != null &&
      printableItem.userOrderItemAddOns.isNotEmpty) {
    printableItem.userOrderItemAddOnReceipt =
        Provider.of<CurrentOrderProvider>(context, listen: false)
            .getAddOnReceiptFromBackend(orderItem, showPrice: false);
    // get all option id to a list
    printableItem.menuAddOnOptionIds = [];
    orderItem.userOrderItemAddOns.forEach((addon) {
      addon.menuAddOnOptions.forEach((option) {
        printableItem.menuAddOnOptionIds.add(option.menuAddOnOptionId);
      });
    });
    printableItem.menuAddOnOptionIds.sort();
  }
  printableItem.note = orderNote;
  printableItem.orderId = order.userOrderId;

  return printableItem;
}

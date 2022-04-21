import 'dart:typed_data';

import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:image/image.dart';
import 'package:provider/provider.dart';
import 'package:vplus_merchant_app/helpers/apiHelper.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/helpers/date_time_helper.dart';
import 'package:vplus_merchant_app/helpers/stringHelper.dart';
import 'package:vplus_merchant_app/models/ExtraOrder.dart';
import 'package:vplus_merchant_app/models/Order.dart';
import 'package:vplus_merchant_app/models/OrderItem.dart';
import 'package:vplus_merchant_app/models/OrderItemPrint.dart';
import 'package:vplus_merchant_app/models/report/categoryRanking.dart';
import 'package:vplus_merchant_app/models/report/dateRangeReport.dart';
import 'package:vplus_merchant_app/models/report/menuItemRanking.dart';
import 'package:vplus_merchant_app/models/store.dart';
import 'package:vplus_merchant_app/providers/current_order_provider.dart';
import 'package:vplus_merchant_app/providers/current_stores_provider.dart';

class PrinterHelper {
  static bool connected;
  List availableBluetoothDevices = new List();
  static String currentPrinterName;
  static String currentPrinterMacAddr;

  Future<List> getBluetooth() async {
    //get paried bluetooth devices

    /// List of String, eg:
    /// [OnePlus 3#C0:EE:FB:D6:60:44, BlueTooth Printer#0F:02:17:32:57:72]
    /// format: bluetooth name, #, mac address. Split by #

    final List bluetooths = await BluetoothThermalPrinter.getBluetooths;

    print("Print $bluetooths");

    availableBluetoothDevices = bluetooths;
    return availableBluetoothDevices;
  }

  Future<bool> setConnect(String macAddr) async {
    // connect to bluetooth printer using mac address
    if (macAddr == null || macAddr.length == 0) {
      connected = false;
    } else {
      final String result = await BluetoothThermalPrinter.connect(macAddr);
      print("bluetooth printer connected: $result");
      connected = (result == "true") ? true : false;
    }
    return connected;
  }

  static bool get getIsPrinterConnected => connected;
  static set setIsPrinterConnected(bool isPrinterConnected) {
    connected = isPrinterConnected;
  }

  static String get getCurrentPrinterName => currentPrinterName;
  static set setCurrentPrinterName(String printerName) {
    currentPrinterName = printerName;
  }

  static String get getCurrentPrinterMacAddr => currentPrinterMacAddr;
  static set setCurrentPrinterMacAddr(String printerMacAddr) {
    currentPrinterMacAddr = printerMacAddr;
  }

  Future<bool> startPrint(Ticket ticket, BuildContext context) async {
    /// print ticket
    String isConnected = await BluetoothThermalPrinter.connectionStatus;
    if (isConnected == "true") {
      // print multi copies
      var hive = await Hive.openBox("printer");
      var printerSettings = hive.get('settings');
      List<int> ticketData = ticket.bytes;
      for (int i = 1; i < printerSettings['noOfCopies']; i++) {
        ticket.bytes += ticketData;
      }
      final result = await BluetoothThermalPrinter.writeBytes(ticket.bytes);
      // print("Print $result");
      return true;
    } else {
      //Hadnle Not Connected Senario
      Helper hlp = Helper();
      hlp.showToastError(
          "${AppLocalizationHelper.of(context).translate('PrinterConnectionErrorMessage')}");
      return false;
    }
  }

  Future<Ticket> initTicket() async {
    var hive = await Hive.openBox("printer");
    var printerSettings = hive.get('settings');
    Ticket ticket = Ticket(
        (printerSettings['isSmallPageWidth']) ? PaperSize.mm58 : PaperSize.mm80,
        null);
    return ticket;
  }

  Future<Ticket> testTicket() async {
    final Ticket ticket = await initTicket();

    ticket.text('Vplus printer test');
    ticket.text('Bold text', styles: PosStyles(bold: true));
    ticket.text('Reverse text', styles: PosStyles(reverse: true));
    ticket.text('Underlined text',
        styles: PosStyles(underline: true), linesAfter: 1);
    ticket.text('Align left', styles: PosStyles(align: PosAlign.left));
    ticket.text('Align center', styles: PosStyles(align: PosAlign.center));
    ticket.text('Align right',
        styles: PosStyles(align: PosAlign.right), linesAfter: 1);

    ticket.text('Text size 200%',
        styles: PosStyles(
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ));

    await showVplusFooter(ticket);
    return ticket;
  }

  Future<Ticket> singleOrderTicket(
      BuildContext context, Order order, bool toKitchen) async {
    /// Generate a new ticket for a single order
    final Ticket ticket = await initTicket();
    bool showPrice;
    bool showNote;
    bool showStoreHeader;
    Store store = Provider.of<CurrentStoresProvider>(context, listen: false)
        .getStore(context);
    if (toKitchen == true) {
      /// Kitchen do not need to show price, need to show the note
      showPrice = false;
      showNote = true;
      showStoreHeader = false;
    } else {
      showPrice = true;
      showNote = false;
      showStoreHeader = true;
    }
    // ticket starts here.
    if (showStoreHeader) {
      await generateStoreHeader(store, ticket, context);
      showSeparateLine(ticket);
    }
    generateTableHeader(order, ticket, context);

    if (toKitchen == true) {
      /// For kitchen receipt, all orders need to displayed in reverse sequence
      /// Eg: new order (extra order) on the top, oldest in the bottom.

      // show extra orders reversely if exists
      if (order.userExtraOrders != null && order.userExtraOrders.isNotEmpty) {
        final List<ExtraOrder> reversedExtraOrders =
            order.userExtraOrders.reversed.toList();
        reversedExtraOrders.forEach((extraOrder) => generateSingleExtraOrder(
            extraOrder, ticket, showNote, showPrice, context));
      }
      generateSingleOriginalOrder(order, ticket, showNote, showPrice, context);
    } else {
      /// to Consumer receipt order sequence
      /// Consumer receipt, old order on the top.
      // original order
      generateSingleOriginalOrder(order, ticket, showNote, showPrice, context);
      // show extra orders if exists
      if (order.userExtraOrders != null && order.userExtraOrders.isNotEmpty) {
        order.userExtraOrders.forEach((extraOrder) => generateSingleExtraOrder(
            extraOrder, ticket, showNote, showPrice, context));
      }
    }

    showSeparateLine(ticket);
    if (showPrice == true) {
      showGSTAndTotalPrice(context, ticket, order.totalAmount);
    }

    await showVplusFooter(ticket);

    return ticket;
  }

  Future<Ticket> singleOrderPaidPartTicket(BuildContext context, Order order,
      bool toKitchen, double totalAmount) async {
    /// print only paid part of an order
    /// use the isPaid == false to do the check
    final Ticket ticket = await initTicket();
    bool showPrice;
    bool showNote;
    if (toKitchen == true) {
      showPrice = false;
      showNote = true;
    } else {
      showPrice = true;
      showNote = false;
    }
    generateTableHeader(order, ticket, context);
    showSeparateLine(ticket);

    if (toKitchen == true) {
      /// For kitchen receipt, all orders need to displayed in reverse sequence
      /// Eg: new order (extra order) on the top, oldest in the bottom.

      // show extra orders reversely if exists
      if (order.userExtraOrders != null && order.userExtraOrders.isNotEmpty) {
        final List<ExtraOrder> reversedExtraOrders =
            order.userExtraOrders.reversed.toList();
        reversedExtraOrders.forEach((extraOrder) {
          if (extraOrder.isPaid == false)
            generateSingleExtraOrder(
                extraOrder, ticket, showNote, showPrice, context);
        });
      }
      if (order.isPaid == false)
        generateSingleOriginalOrder(
            order, ticket, showNote, showPrice, context);
    } else {
      /// to Consumer receipt order sequence
      /// Consumer receipt, old order on the top.
      // original order
      if (order.isPaid == false)
        generateSingleOriginalOrder(
            order, ticket, showNote, showPrice, context);
      // show extra orders if exists
      if (order.userExtraOrders != null && order.userExtraOrders.isNotEmpty) {
        order.userExtraOrders.forEach((extraOrder) {
          if (extraOrder.isPaid == false)
            generateSingleExtraOrder(
                extraOrder, ticket, showNote, showPrice, context);
        });
      }
    }

    showSeparateLine(ticket);
    if (showPrice == true) {
      showGSTAndTotalPrice(context, ticket, totalAmount);
    }

    await showVplusFooter(ticket);

    return ticket;
  }

  Future<Ticket> singleOrderItemTicket(
      Order order, OrderItem orderItem, BuildContext context) async {
    /// Generate a new ticket for a single orderItem to kitchen
    final Ticket ticket = await initTicket();
    bool showPrice = false; // to kitchen do not show price

    // ticket starts here.
    // await generateStoreHeader(store, ticket);
    generateTableHeader(order, ticket, context);
    showSeparateLine(ticket);
    ticket.text(
      'Order Time:${DateTimeHelper.parseDateTimeToDateHHMM(order.orderCreateDateTimeUTC.toLocal())}',
      containsChinese: true,
      styles: PosStyles(reverse: true),
    );
    generateSingleItemTicket(orderItem, ticket, showPrice, context);
    showSeparateLine(ticket);
    await showVplusFooter(ticket);

    return ticket;
  }

  Future<Ticket> orderItemPrintTicket(
      List<OrderItemPrint> orderItemPrints, BuildContext context) async {
    final Ticket ticket = await initTicket();
    double totalAmount = 0;
    for (var item in orderItemPrints) {
      totalAmount += item.price * item.quantity;
    }
    orderItemPrints.forEach((orderItemPrint) {
      // show menuItem title
      ticket.text('${orderItemPrint.menuItemName}',
          containsChinese: true,
          styles: PosStyles(
            reverse: true,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          ));
      ticket.text(
          '${orderItemPrint.subtitle.isEmpty ? " " : orderItemPrint.subtitle}',
          containsChinese: true,
          styles: PosStyles(
            reverse: true,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          ));
      ticket.text(
          '${orderItemPrint.description.isEmpty ? " " : orderItemPrint.description}',
          containsChinese: true,
          styles: PosStyles(
            reverse: true,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          ));
      ticket.text('Total Quantity: ${orderItemPrint.quantity}',
          containsChinese: true,
          styles: PosStyles(
            reverse: true,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          ));

      // ticket.row([
      //   PosColumn(
      //     text: '${orderItemPrint.menuItemName}: ',
      //     width: 6,
      //     styles: PosStyles(align: PosAlign.left, bold: true, reverse: true),
      //   ),
      //   PosColumn(
      //     text: 'Grand Total: ${orderItemPrint.quantity}',
      //     width: 6,
      //     styles: PosStyles(align: PosAlign.left, bold: true, reverse: true),
      //   ),
      // ], );
      orderItemPrint.flavoredItems.forEach((flavoredItem) {
        showSeparateLine(ticket);
        // show flavored items title
        String addOnInfo = (flavoredItem.addOnReceipt != null &&
                flavoredItem.addOnReceipt.isNotEmpty)
            ? 'AddOns:'
            : 'No AddOn';
        ticket.row(
          [
            PosColumn(
                text: '$addOnInfo ',
                width: 6,
                styles: PosStyles(
                  align: PosAlign.left,
                ),
                containsChinese: true),
            PosColumn(
                text: 'TotalQuantity: ${flavoredItem.flavoredQuantity}',
                width: 6,
                styles: PosStyles(
                  align: PosAlign.right,
                ),
                containsChinese: true),
          ],
        );

        // show flavored item addon
        if (flavoredItem.addOnReceipt != null &&
            flavoredItem.addOnReceipt.isNotEmpty) {
          flavoredItem.addOnReceipt.forEach((receiptLine) {
            ticket.text('$receiptLine',
                containsChinese: true,
                styles: PosStyles(align: PosAlign.left, bold: true));
          });
          ticket.feed(1);
        }
        flavoredItem.tableInfoList.forEach((table) {
          // show table note if possible
          if (table.note != null && table.note.length != 0) {
            ticket.text('   ');
            ticket.text(
              'Note: ${table.note}',
              containsChinese: true,
            );
          }
          ticket.row([
            PosColumn(
                text:
                    '${DateTimeHelper.parseDateTimeToDateHHMM(table.date.toLocal())}',
                width: 6,
                styles: PosStyles(
                  align: PosAlign.left,
                ),
                containsChinese: true),
            PosColumn(
                text: 'Table Name: ${table.table}',
                width: 4,
                styles: PosStyles(
                  align: PosAlign.left,
                ),
                containsChinese: true),
            PosColumn(
                text: 'X ${table.quantity}',
                width: 2,
                styles: PosStyles(
                  align: PosAlign.left,
                ),
                containsChinese: true),
          ]);
        });
      });
      ticket.feed(1);
    });

    ticket.text('Total Order Amount: ${totalAmount.toStringAsFixed(2)}',
        containsChinese: true,
        styles: PosStyles(
          reverse: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ));
    await showVplusFooter(ticket);
    return ticket;
  }

  Ticket generateSingleItemTicket(OrderItem orderItem, Ticket ticket,
      bool showPrice, BuildContext context) {
    if (showPrice == true) {
      ticket.row([
        PosColumn(
            text: '${orderItem.menuItem.menuItemName}',
            width: 8,
            styles: PosStyles(align: PosAlign.left, underline: true),
            containsChinese: true),
        PosColumn(
            text: 'X${orderItem.quantity}',
            width: 2,
            styles: PosStyles(align: PosAlign.center, underline: true),
            containsChinese: true),
        PosColumn(
            text: '\$${orderItem.price.toStringAsFixed(2)}',
            width: 2,
            styles: PosStyles(align: PosAlign.center, underline: true),
            containsChinese: true),
      ]);
    } else {
      ticket.row([
        PosColumn(
            text: '${orderItem.menuItem.menuItemName}',
            width: 10,
            styles: PosStyles(align: PosAlign.left, underline: true),
            containsChinese: true),
        PosColumn(
            text: 'X${orderItem.quantity}',
            width: 2,
            styles: PosStyles(align: PosAlign.center, underline: true),
            containsChinese: true),
      ]);
    }
    // check TakeAway
    if (orderItem.isTakeAway != null && orderItem.isTakeAway == true) {
      ticket.text('Take-away',
          containsChinese: true, styles: PosStyles(underline: true));
    }
    // check addon
    if (orderItem.userOrderItemAddOns != null &&
        orderItem.userOrderItemAddOns.isNotEmpty) {
      List<String> addOnReceipt =
          CurrentOrderProvider().getAddOnReceiptFromBackend(orderItem);
      addOnReceipt.forEach((addOnLine) {
        ticket.text(
          '$addOnLine',
          containsChinese: true,
        );
      });
    }
    return ticket;
  }

  Future<Ticket> generateStoreHeader(
      Store store, Ticket ticket, BuildContext context) async {
    // use small image, print 128* 128 sized logo.
    final Uint8List bytes =
        await StringHelper.networkImageToByte(store.logoUrl);
    var image = decodeImage(bytes);
    // Using `ESC *` method to print img.
    ticket.image(image);
    // store name
    ticket.text(store.storeName,
        containsChinese: true,
        styles: PosStyles(
          height: PosTextSize.size2,
          width: PosTextSize.size2,
          align: PosAlign.center,
        ));
    // store location
    ticket.text(store.location,
        containsChinese: true,
        styles: PosStyles(
          align: PosAlign.center,
        ));
    // store contact info
    if (store.phone != null && store.phone.isNotEmpty) {
      ticket.text('Mobile: ${store.phone}',
          containsChinese: true,
          styles: PosStyles(
            align: PosAlign.center,
          ));
    }
    if (store.email != null && store.email.isNotEmpty) {
      ticket.text('EmailAddress: ${store.email}',
          containsChinese: true,
          styles: PosStyles(
            align: PosAlign.center,
          ));
    }
    return ticket;
  }

  Ticket generateTableHeader(Order order, Ticket ticket, BuildContext context) {
    String tableName;
    (order.orderType == OrderType.TakeAway)
        ? tableName = "Take-away" +
            CurrentOrderProvider().getTakeAwayIdShortcut(order.takeAwayId)
        : tableName = "Table Name: " + (order.table == null ? "" : order.table);

    ticket.row([
      PosColumn(
          text: '$tableName',
          width: 6,
          styles: PosStyles(align: PosAlign.left, bold: true),
          containsChinese: true),
      PosColumn(
          text: 'Order Number: ${order.userOrderId}',
          width: 6,
          styles: PosStyles(align: PosAlign.left, bold: true),
          containsChinese: true),
    ]);
    return ticket;
  }

  Ticket generateSingleExtraOrder(ExtraOrder extraOrder, Ticket ticket,
      bool showNote, bool showPrice, BuildContext context) {
    ticket.text(
        'ExtraOrderTime:${DateTimeHelper.parseDateTimeToDateHHMM(extraOrder.orderCreateDateTimeUTC.toLocal())}',
        containsChinese: true,
        styles: PosStyles(reverse: true));
    if (showNote == true && extraOrder.note != null && extraOrder.note != '') {
      ticket.text('Note ${extraOrder.note}');
    }
    extraOrder.userItems.forEach((orderItem) =>
        generateSingleItemTicket(orderItem, ticket, showPrice, context));
    return ticket;
  }

  Ticket generateSingleOriginalOrder(Order order, Ticket ticket, bool showNote,
      bool showPrice, BuildContext context) {
    ticket.text(
        'OrderTime:${DateTimeHelper.parseDateTimeToDateHHMM(order.orderCreateDateTimeUTC.toLocal())}',
        containsChinese: true,
        styles: PosStyles(reverse: true));
    if (showNote == true && order.note != null && order.note != '') {
      ticket.text(
        'Note: ${order.note}',
        containsChinese: true,
      );
    }
    order.userItems.forEach((orderItem) {
      generateSingleItemTicket(orderItem, ticket, showPrice, context);
    });
    return ticket;
  }

  Ticket showSeparateLine(Ticket ticket) {
    ticket.hr(ch: '=', linesAfter: 0);
    return ticket;
  }

  Future<Ticket> showVplusFooter(Ticket ticket) async {
    // vplus logo size to 60 * 60
    ticket.feed(1); // add a small gap
    final ByteData data =
        await rootBundle.load('assets/images/vm-icon-receipt.png');
    final Uint8List bytes = data.buffer.asUint8List();
    var image = decodeImage(bytes);
    // Using `ESC *` method to print img.
    ticket.image(image);

    ticket.text('Support:', styles: PosStyles(align: PosAlign.center));
    ticket.text('www.vplus.com.au', styles: PosStyles(align: PosAlign.center));
    ticket.feed(1);
    ticket.cut();
    return ticket;
  }

  Ticket showGSTAndTotalPrice(
      BuildContext context, Ticket ticket, double price) {
    double taxRate = Provider.of<CurrentStoresProvider>(context, listen: false)
        .getStore(context)
        .taxRate;
    double gst;
    if (taxRate == 0.0) {
      gst = 0;
    } else {
      gst = price / ((taxRate + 100.0) / 10.0);
    }
    ticket.text('SubTotal: \$${(price - gst).toStringAsFixed(2)}',
        containsChinese: true,
        styles: PosStyles(
          align: PosAlign.right,
        ));
    ticket.text(
        'GST(${taxRate.toStringAsFixed(2)}%): \$${gst.toStringAsFixed(2)}',
        containsChinese: true,
        styles: PosStyles(
          align: PosAlign.right,
        ));
    ticket.text('Total: \$${price.toStringAsFixed(2)}',
        containsChinese: true,
        styles: PosStyles(
          align: PosAlign.right,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ));
    return ticket;
  }

  Future<Ticket> dateRangeReportTicket(
    BuildContext context,
    DateTime startDate,
    DateTime endDate,
    DateRangeReport report,
  ) async {
    Store store = Provider.of<CurrentStoresProvider>(context, listen: false)
        .getStore(context);
    int totalItemsCount = 0;
    double totalItemsAmount = 0.0;

    /// Generate a date range report ticket
    final Ticket ticket = await initTicket();

    await generateStoreHeader(store, ticket, context);
    showSeparateLine(ticket);
    ticket.text('Sales Report',
        containsChinese: true,
        styles: PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ));
    showSeparateLine(ticket);

    generateReportDateRange(ticket, startDate, endDate);
    showSeparateLine(ticket);

    ticket.text('Items',
        containsChinese: true,
        styles: PosStyles(
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ));
    generateReportItemTitle(ticket, "Item name");
    showSeparateLine(ticket);
    // show category ranking
    report.categoriesRanking.forEach((CategoryRanking categoryRanking) {
      totalItemsCount += categoryRanking.menuCategoryCount;
      totalItemsAmount += categoryRanking.menuCategoryAmount;
      generateReportItem(
        ticket,
        categoryRanking.menuCategoryName,
        categoryRanking.menuCategoryCount,
        categoryRanking.menuCategoryAmount,
        bold: true,
      );
      ticket.hr(ch: '-', linesAfter: 0);
      categoryRanking.menuItemsRanking
          .forEach((MenuItemRanking menuItemRanking) {
        generateReportItem(ticket, menuItemRanking.menuItemName,
            menuItemRanking.menuItemCount, menuItemRanking.menuItemAmount);
      });
      ticket.feed(2);
      ticket.hr(ch: '-', linesAfter: 0);
    });
    // show total Summmary
    generateReportItem(ticket, "Total", totalItemsCount, totalItemsAmount,
        bold: true);
    showSeparateLine(ticket);
    ticket.feed(1);
    // show cash transaction count
    ticket.text('Transactions',
        containsChinese: true,
        styles: PosStyles(
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ));
    generateReportItemTitle(ticket, "Type");
    showSeparateLine(ticket);
    generateReportItem(ticket, "Cash transactions", report.cashTransactionCount,
        report.cashTransactionAmount);
    generateReportItem(ticket, "Card transactions", report.cardTransactionCount,
        report.cardTransactionAmount);

    await showVplusFooter(ticket);

    return ticket;
  }

  Ticket generateReportDateRange(
      Ticket ticket, DateTime startDate, DateTime endDate) {
    ticket.text(
        "Start date: ${DateTimeHelper.parseDateTimeToDateHHMM(startDate.toLocal())}",
        containsChinese: true,
        styles: PosStyles());
    ticket.text(
        "End date: ${DateTimeHelper.parseDateTimeToDateHHMM(endDate.toLocal())}",
        containsChinese: true,
        styles: PosStyles());

    return ticket;
  }

  Ticket generateReportItem(
      Ticket ticket, String itemName, int itemCount, double itemAmount,
      {bool bold: false}) {
    ticket.row([
      PosColumn(
          text: '$itemName',
          width: 6,
          styles: PosStyles(
            align: PosAlign.left,
            bold: bold,
          ),
          containsChinese: true),
      PosColumn(
          text: '$itemCount',
          width: 4,
          styles: PosStyles(
            align: PosAlign.left,
            bold: bold,
          ),
          containsChinese: true),
      PosColumn(
          text: '\$${itemAmount.toStringAsFixed(2)}',
          width: 2,
          styles: PosStyles(
            align: PosAlign.left,
            bold: bold,
          ),
          containsChinese: true),
    ]);
    return ticket;
  }

  Ticket generateReportItemTitle(
    Ticket ticket,
    String titleName,
  ) {
    ticket.row([
      PosColumn(
          text: '$titleName',
          width: 6,
          styles: PosStyles(
            align: PosAlign.left,
          ),
          containsChinese: true),
      PosColumn(
          text: 'Qty',
          width: 4,
          styles: PosStyles(
            align: PosAlign.left,
          ),
          containsChinese: true),
      PosColumn(
          text: 'Price',
          width: 2,
          styles: PosStyles(
            align: PosAlign.left,
          ),
          containsChinese: true),
    ]);
    return ticket;
  }
}

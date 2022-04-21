import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:vplus_merchant_app/helpers/apiHelper.dart';
import 'package:vplus_merchant_app/helpers/printerHelper.dart';
import 'package:vplus_merchant_app/models/Order.dart';

class CurrentPrinterProvider with ChangeNotifier {
  CurrentPrinterProvider() {
    initData();
  }
  bool isSmallPageWidth;
  int noOfCopies;
  bool isEnlargeFont;
  bool isAutoPrintOnOrderConfirmed;
  bool isAutoPrintOnPaymentMade;
  // PrinterBluetooth defaultPrinter;

  Future setPrinterDefaultSettings() async {
    isSmallPageWidth = false;
    noOfCopies = 1;
    isEnlargeFont = false;
    isAutoPrintOnOrderConfirmed = false;
    isAutoPrintOnPaymentMade = false;

    await savePrinterSettingsToBox();
  }

  Future initData() async {
    var hive = await Hive.openBox("printer");

    if (hive == null) {
    } else {
      //var printer = hive.get('defaultPrinter');
      //if (printer != null) {
      //defaultPrinter = printer;
      //}

      var settings = hive.get('settings');
      if (settings == null) {
        await setPrinterDefaultSettings();
      } else {
        isSmallPageWidth = settings['isSmallPageWidth'] ?? false;
        noOfCopies = settings['noOfCopies'] ?? 1;
        //_noOfCopiesCtrl.text = noOfCopies.toString();
        isEnlargeFont = settings['isEnlargeFont'] ?? false;
        isAutoPrintOnOrderConfirmed =
            settings['isAutoPrintOnOrderConfirmed'] ?? true;
        isAutoPrintOnPaymentMade = settings['isAutoPrintOnPaymentMade'] ?? true;
      }
    }
  }

  Future setPageWidth(bool isSmallMM) async {
    isSmallPageWidth = isSmallMM;
    var hive = await Hive.openBox("printer");

    await hive.put('settings', {
      "isSmallPageWidth": isSmallPageWidth,
      "noOfCopies": noOfCopies,
      "isEnlargeFont": isEnlargeFont,
      "isAutoPrintOnOrderConfirmed": isAutoPrintOnOrderConfirmed,
      "isAutoPrintOnPaymentMade": isAutoPrintOnPaymentMade
    });

    notifyListeners();
  }

  Future setEnlargeFont(bool enlarge) async {
    var hive = await Hive.openBox("printer");
    isEnlargeFont = enlarge;
    await hive.put('settings', {
      "isSmallPageWidth": isSmallPageWidth,
      "noOfCopies": noOfCopies,
      "isEnlargeFont": isEnlargeFont,
      "isAutoPrintOnOrderConfirmed": isAutoPrintOnOrderConfirmed,
      "isAutoPrintOnPaymentMade": isAutoPrintOnPaymentMade
    });

    notifyListeners();
  }

  Future setPrintCopy(int copy) async {
    var hive = await Hive.openBox("printer");
    noOfCopies = copy;
    await hive.put('settings', {
      "isSmallPageWidth": isSmallPageWidth,
      "noOfCopies": noOfCopies,
      "isEnlargeFont": isEnlargeFont,
      "isAutoPrintOnOrderConfirmed": isAutoPrintOnOrderConfirmed,
      "isAutoPrintOnPaymentMade": isAutoPrintOnPaymentMade
    });

    notifyListeners();
  }

  Future setAutoOrderConfirmed(bool auto) async {
    var hive = await Hive.openBox("printer");
    isAutoPrintOnOrderConfirmed = auto;
    await hive.put('settings', {
      "isSmallPageWidth": isSmallPageWidth,
      "noOfCopies": noOfCopies,
      "isEnlargeFont": isEnlargeFont,
      "isAutoPrintOnOrderConfirmed": isAutoPrintOnOrderConfirmed,
      "isAutoPrintOnPaymentMade": isAutoPrintOnPaymentMade
    });

    notifyListeners();
  }

  Future setAutoPaymentMade(bool auto) async {
    var hive = await Hive.openBox("printer");
    isAutoPrintOnPaymentMade = auto;
    await hive.put('settings', {
      "isSmallPageWidth": isSmallPageWidth,
      "noOfCopies": noOfCopies,
      "isEnlargeFont": isEnlargeFont,
      "isAutoPrintOnOrderConfirmed": isAutoPrintOnOrderConfirmed,
      "isAutoPrintOnPaymentMade": isAutoPrintOnPaymentMade
    });

    notifyListeners();
  }

  Future savePrinterSettingsToBox() async {
    var hive = await Hive.openBox("printer");

    await hive.put('settings', {
      "isSmallPageWidth": isSmallPageWidth,
      "noOfCopies": noOfCopies,
      "isEnlargeFont": isEnlargeFont,
      "isAutoPrintOnOrderConfirmed": isAutoPrintOnOrderConfirmed,
      "isAutoPrintOnPaymentMade": isAutoPrintOnPaymentMade
    });
  }

  Future autoPrintOnOrderConfirmed(BuildContext context, Order order) async {
    var hive = await Hive.openBox("printer");
    var printerSettings = hive.get('settings');
    bool toKitchen = true;
    PrinterHelper _printerHelper = PrinterHelper();
    bool isConnected = PrinterHelper.getIsPrinterConnected ?? false;
    if (isConnected) {
      if (printerSettings != null &&
          printerSettings['isAutoPrintOnOrderConfirmed']) {
        var ticket =
            await PrinterHelper().singleOrderTicket(context, order, toKitchen);
        await _printerHelper.startPrint(ticket, context);
      }
    }
  }

  Future autoPrintOnOrderPaid(
      BuildContext context, Order order, double totalAmount) async {
    // for auto print paid order function, get all isPaid FALSE order and print it out
    var hive = await Hive.openBox("printer");
    var printerSettings = hive.get('settings');
    bool toKitchen = false;
    PrinterHelper _printerHelper = PrinterHelper();
    bool isConnected = PrinterHelper.getIsPrinterConnected;
    if (isConnected) {
      if (printerSettings != null &&
          printerSettings['isAutoPrintOnPaymentMade']) {
        var ticket = await PrinterHelper()
            .singleOrderPaidPartTicket(context, order, toKitchen, totalAmount);
        await _printerHelper.startPrint(ticket, context);
      }
    }
  }

  Future getSettingFromHive() async {
    var hive = await Hive.openBox("printer");
    var printerSettings = await hive.get('settings');
    isSmallPageWidth = printerSettings['isSmallPageWidth'];
    noOfCopies = printerSettings['noOfCopies'];
    isEnlargeFont = printerSettings['isEnlargeFont'];
    isAutoPrintOnOrderConfirmed =
        printerSettings['isAutoPrintOnOrderConfirmed'];
    isAutoPrintOnPaymentMade = printerSettings['isAutoPrintOnPaymentMade'];
    // notifyListeners();
  }

  Future<bool> reconnectKnownPrinter() async {
    // auto connect known (last connected) printer
    Helper hlp = Helper();
    bool isPrinterConnected = false;
    try {
      var hive = await Hive.openBox("printer");
      var defaultPrinter = hive.get('defaultPrinter');
      if (defaultPrinter == null) return false;
      String printerMacAddr = defaultPrinter == null
          ? null
          : defaultPrinter['printerMacAddr'].toString();
      String printerName = defaultPrinter['printerName'];
      if (printerMacAddr == null) {
        // no printer connected before, give init value
        PrinterHelper.setIsPrinterConnected = false;
      } else {
        PrinterHelper _printerHelper = PrinterHelper();
        await _printerHelper.setConnect(printerMacAddr);

        PrinterHelper.setIsPrinterConnected = true;
        PrinterHelper.setCurrentPrinterMacAddr = printerMacAddr;
        PrinterHelper.setCurrentPrinterName = printerName;
      }
    } catch (e) {
      print(e);
    }
    // hlp.showToastSuccess("reconnect status: $isPrinterConnected");
    return isPrinterConnected;
  }
}

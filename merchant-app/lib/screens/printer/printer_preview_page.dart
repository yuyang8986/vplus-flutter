import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:vplus_merchant_app/helpers/apiHelper.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/helpers/printerHelper.dart';
import 'package:vplus_merchant_app/helpers/screenHelper.dart';
import 'package:vplus_merchant_app/helpers/signalrHelper.dart';
import 'package:vplus_merchant_app/helpers/sizeHelper.dart';
import 'package:vplus_merchant_app/models/Order.dart';
import 'package:vplus_merchant_app/models/OrderItemPrint.dart';
import 'package:vplus_merchant_app/providers/current_menu_provider.dart';
import 'package:vplus_merchant_app/providers/current_orderStatus_provider.dart';
import 'package:vplus_merchant_app/providers/printer_order_list_provider.dart';
import 'package:vplus_merchant_app/screens/printer/print_by_order_listtile.dart';
import 'package:vplus_merchant_app/screens/printer/printerItemStatus.dart';
import 'package:vplus_merchant_app/styles/color.dart';
import 'package:vplus_merchant_app/widgets/customAppBar.dart';
import 'package:vplus_merchant_app/widgets/emptyView.dart';

class PrinterPreviewPage extends StatefulWidget {
  @override
  _PrinterPreviewPageState createState() => _PrinterPreviewPageState();
}

class _PrinterPreviewPageState extends State<PrinterPreviewPage> {
  PrinterHelper _printerHelper = PrinterHelper();
  ScrollController scrollController;
  Order userOrder;
  int storeMenuId;
  List<OrderItemPrint> orderItemPrintList;
  List<PrintableItem> selectedPrintableItems;
  List<PrintableItem> printedPrintableItems;
  List<PrintableItem> allPrintableItems;
  bool _inAsyncCall;
  List<int> printedIds;
  @override
  void dispose() {
    // revoke signalr flag to reduce memory usage
    SignalrHelper.setIsInPrinterPreviewPage(false);
    super.dispose();
  }

  @override
  void initState() {
    userOrder =
        Provider.of<Current_OrderStatus_Provider>(context, listen: false)
            .getOrder();
    storeMenuId =
        Provider.of<CurrentMenuProvider>(context, listen: false).getStoreMenuId;

    printedPrintableItems =
        Provider.of<PrinterOrderListProvider>(context, listen: false)
            .getPrintedPrintableItem;
    _inAsyncCall = false;
    printedIds = new List<int>();
    // init signalr
    SignalrHelper.initPrinterPreviewContext(context);
    SignalrHelper.setIsInPrinterPreviewPage(true);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      updateOrderItemPrintList();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: CustomAppBar.getAppBar(
            "${AppLocalizationHelper.of(context).translate('PrintOrderByItem')}",
            false,
            context: context,
            showLogo: false),
        body: Consumer<PrinterOrderListProvider>(
          builder: (ctx, p, w) {
            // _printerBluetooth = p.defaultPrinter;
            allPrintableItems = p.getAllPrintableItems;
            orderItemPrintList = p.getOrderItemPrintList;
            printedPrintableItems = p.getPrintedPrintableItem;
            printedPrintableItems
                .forEach((pItem) {
                  printedIds.add(pItem.orderItemId);                
                });
            // after printed, reselct all printable items
            // then in the generate listtile, remove printed items from this list
            if (printedIds != null && printedIds.isNotEmpty) {
              selectedPrintableItems = p.selectedAllPrintableItem();
            }
            return ModalProgressHUD(
              inAsyncCall: _inAsyncCall,
              child: SingleChildScrollView(
                controller: scrollController,
                padding:
                    EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20)),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: ScreenUtil().setHeight(30)),
                      child: _printAllLable(),
                    ),
                    _orderItemPreview(orderItemPrintList),                   
                  ],
                ),
              ),
            );
          },
        ));
  }

  Widget _showSingleOrder(BuildContext context, OrderItemPrint itemPrint) {
    // show one orderItemPrint
    return Column(
      children: [
        _getTitle(itemPrint),
        ListView.builder(
            physics: ClampingScrollPhysics(),
            // controller: scrollController,
            shrinkWrap: true,
            itemCount: itemPrint.flavoredItems.length,
            itemBuilder: (ctx, index) {
              FlavoredOrderItem flavoredOrderItem =
                  itemPrint.flavoredItems[index];
              return _showSingleFalvoredOrderItem(flavoredOrderItem);
            })
      ],
    );
  }

  Widget _showSingleFalvoredOrderItem(FlavoredOrderItem flavoredOrderItem) {
    return Container(
      child: Column(children: [
        _getFlavoredItemTitle(flavoredOrderItem),
        ListView.builder(
          // controller: scrollController,
          physics: ClampingScrollPhysics(),
          shrinkWrap: true,
          itemCount: flavoredOrderItem.tableInfoList.length,
          itemBuilder: (ctx, index) {
            PrintableItem item = allPrintableItems.firstWhere(
                (item) =>
                    item.orderItemId ==
                    flavoredOrderItem.tableInfoList[index].userOrderItemId,
                orElse: () => null);
            PrinterItemStatus itemStatus;
            if (item == null) {
              // avoid null error
              return Container();
            } else {
              // check if item has been printed
              if (printedPrintableItems != null &&
                  printedPrintableItems.isNotEmpty &&
                  printedIds.contains(item.orderItemId)) {
                // not printed
                itemStatus = PrinterItemStatus.printed;
                // remove item fom selected list after printed
                Provider.of<PrinterOrderListProvider>(context, listen: false)
                    .removeSelectedPrintableItem(item);
              } else {
                itemStatus = PrinterItemStatus.selected;
              }
              return PrintByOrderListTile(
                itemStatus,
                printableItem: item,
              );
            }
          },
        ),
        Divider(thickness: 2),
      ]),
    );
  }

  Widget _getTitle(OrderItemPrint orderItemPrint) {
    return Container(
      height: ScreenUtil().setHeight(ScreenHelper.isLandScape(context)
          ? 200
          : 120),
      color: Color(0xffe3e8ef),
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: ScreenHelper.isLandScape(context)
                ? ScreenUtil().setWidth(SizeHelper.heightMultiplier * 1.8)
                : ScreenUtil().setWidth(40)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Text(
                  orderItemPrint.menuItemName + ': ',
                  style: GoogleFonts.lato(
                      fontSize: ScreenHelper.isLandScape(context)
                          ? 2 * SizeHelper.textMultiplier
                          : 2 * SizeHelper.textMultiplier,
                      fontWeight: FontWeight.bold),
                ),
                 Text(
                  orderItemPrint.subtitle + ': ',
                  style: GoogleFonts.lato(
                      fontSize: ScreenHelper.isLandScape(context)
                          ? 2 * SizeHelper.textMultiplier
                          : 2 * SizeHelper.textMultiplier,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Text(
              '${AppLocalizationHelper.of(context).translate('GrandTotal')}: ${orderItemPrint.quantity}',
              style: GoogleFonts.lato(
                  fontSize: ScreenHelper.isLandScape(context)
                      ? 2 * SizeHelper.textMultiplier
                      : 2 * SizeHelper.textMultiplier),
            ),
            _printSingleOrderItemButton(orderItemPrint),
          ],
        ),
      ),
    );
  }

  Widget _getFlavoredItemTitle(FlavoredOrderItem flavoredOrderItem) {
    return Container(
      height: ScreenUtil().setHeight(ScreenHelper.isLandScape(context)
          ? SizeHelper.widthMultiplier * 30
          : 180),
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: ScreenHelper.isLandScape(context)
                ? SizeHelper.heightMultiplier * 1.8
                : ScreenUtil().setWidth(40)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            (flavoredOrderItem.addOnReceipt != null &&
                    flavoredOrderItem.addOnReceipt.isNotEmpty)
                ? Container(
                    width: ScreenUtil().setWidth(300),
                    // show addon recetipt
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      itemCount: flavoredOrderItem.addOnReceipt.length,
                      itemBuilder: (context, index) {
                        return Text(
                          flavoredOrderItem.addOnReceipt[index],
                          style: GoogleFonts.lato(
                              fontSize: ScreenUtil().setSp(
                                  ScreenHelper.isLandScape(context)
                                      ? SizeHelper.textMultiplier * 2
                                      : 40),
                              fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  )
                : Container(
                    width: ScreenUtil().setWidth(300),
                    child: Text(
                      '${AppLocalizationHelper.of(context).translate('PrintPreviewPageNoAddOnNote')}',
                      style: GoogleFonts.lato(
                          fontSize: ScreenUtil().setSp(
                              ScreenHelper.isLandScape(context)
                                  ? SizeHelper.textMultiplier * 2
                                  : 40),
                          fontWeight: FontWeight.w400),
                    ),
                  ),
            Text(
              '${AppLocalizationHelper.of(context).translate('TotalQuantity')}: ${flavoredOrderItem.flavoredQuantity}',
              style: GoogleFonts.lato(
                fontSize: ScreenHelper.isLandScape(context)
                    ? SizeHelper.textMultiplier * 2
                    : 2 * SizeHelper.textMultiplier,
              ),
            ),
            WEmptyView(150),
            // if (ScreenHelper.isLandScape(context))
            //   Container(width: SizeHelper.heightMultiplier * 20),
            _printSelectedButton(flavoredOrderItem),
          ],
        ),
      ),
    );
  }

  Widget _printAllLable() {
    return Container(
      height: ScreenUtil().setHeight(ScreenHelper.isLandScape(context)
          ? SizeHelper.widthMultiplier * 20
          : SizeHelper.heightMultiplier * 15),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setSp(30)),
            child: Text(
              '${AppLocalizationHelper.of(context).translate('PrintAll')}',
              style: GoogleFonts.lato(
                  fontSize: ScreenHelper.isLandScape(context)
                      ? SizeHelper.textMultiplier * 2
                      : SizeHelper.textMultiplier * 2,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setSp(30)),
            child: _printAllButton(),
          ),
        ],
      ),
    );
  }

  Widget orderNote(String note) {
    return Container(
      margin: EdgeInsets.all(ScreenUtil().setSp(20)),
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.all(
            Radius.circular(10.0) //                 <--- border radius here
            ),
        color: orderNoteBackgroundColor,
        // color: color,
      ),
      child: Padding(
        padding: EdgeInsets.all(ScreenUtil().setSp(10)),
        child: Text(
          '${AppLocalizationHelper.of(context).translate('Note')}: ${note}',
          textAlign: TextAlign.center,
          style: GoogleFonts.lato(
            fontSize: ScreenUtil().setSp(40),
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ),
    );
  }

  // Widget _showSingleExtraOrder(ExtraOrder e) {
  //   return Container(
  //     child: Column(
  //       children: [
  //         // _getTitle(
  //         //     'Extra Order',
  //         //     DateTimeHelper.parseDateTimeToDateHHMM(
  //         //         e.orderCreateDateTimeUTC.toLocal())),
  //         (e.note != null && e.note.isNotEmpty)
  //             ? orderNote(e.note)
  //             : Container(),
  //         PrintByOrderListView(e.userItems, scrollController: scrollController),
  //       ],
  //     ),
  //   );
  // }

  Widget _printAllButton() {
    return Container(
      width: ScreenUtil().setWidth(200),
      height: ScreenUtil().setHeight(80),
      child: RaisedButton(
        onPressed: () async {
          setState(() {
            _inAsyncCall = true;
          });
          print('print test all');
          List<PrintableItem> pItems = new List<PrintableItem>();
          bool printSucceeded;
          pItems = Provider.of<PrinterOrderListProvider>(context, listen: false)
              .getAllPrintableItems;
          List<OrderItemPrint> printList =
              await Provider.of<PrinterOrderListProvider>(context,
                      listen: false)
                  .groupPrintableItems(context, pItems);
          print(printList);
          // print out
          var ticket =
              await PrinterHelper().orderItemPrintTicket(printList, context);
          printSucceeded = await _printerHelper.startPrint(ticket, context);
          if (printSucceeded) {
            // put items into printed list
            pItems.forEach((item) =>
                Provider.of<PrinterOrderListProvider>(context, listen: false)
                    .addPrintedPrintableItem(item));
          }
          updateOrderItemPrintList();
          setState(() {
            _inAsyncCall = false;
          });
        },
        textColor: Colors.black,
        color: Colors.white,
        // padding: const EdgeInsets.symmetric(
        // vertical: 5, horizontal: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '${AppLocalizationHelper.of(context).translate('Print')}',
              // textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _printSingleOrderItemButton(OrderItemPrint orderItemPrint) {
    return Container(
      width: ScreenUtil().setWidth(200),
      height: ScreenUtil().setHeight(80),
      child: RaisedButton(
        onPressed: () async {
          setState(() {
            _inAsyncCall = true;
          });
          print('print test flavored');
          List<PrintableItem> pItems = new List<PrintableItem>();
          bool printSucceeded;
          // get all selected printable items
          selectedPrintableItems =
              Provider.of<PrinterOrderListProvider>(context, listen: false)
                  .getSelectedPrintableItem();
          //filter all selectedPrintableItems within this flavor.
          orderItemPrint.flavoredItems.forEach((flavoredOrderItem) => pItems +=
              Provider.of<PrinterOrderListProvider>(context, listen: false)
                  .filterPrinterItemsByFlavoredItem(
                      flavoredOrderItem, selectedPrintableItems));
          // here goes to print
          print(pItems);
          // handle if pItems is 0
          if (pItems == null || pItems.length == 0) {
            Helper().showToastError(
                '${AppLocalizationHelper.of(context).translate('NoItemSelectedAlert')}');
          } else {
            List<OrderItemPrint> printList =
                await Provider.of<PrinterOrderListProvider>(context,
                        listen: false)
                    .groupPrintableItems(context, pItems);
            print(printList);
            // print out
            var ticket =
                await PrinterHelper().orderItemPrintTicket(printList, context);
            printSucceeded = await _printerHelper.startPrint(ticket, context);

            if (printSucceeded) {
              // put items into printed list
              pItems.forEach((item) =>
                  Provider.of<PrinterOrderListProvider>(context, listen: false)
                      .addPrintedPrintableItem(item));
            }
          }
          updateOrderItemPrintList();
          setState(() {
            _inAsyncCall = false;
          });
        },
        textColor: Colors.black,
        color: Colors.white,
        // padding: const EdgeInsets.symmetric(
        // vertical: 5, horizontal: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '${AppLocalizationHelper.of(context).translate('Print')}',
              // textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _printSelectedButton(FlavoredOrderItem flavoredOrderItem) {
    return Container(
      width: ScreenUtil().setWidth(200),
      height: ScreenUtil().setHeight(80),
      child: RaisedButton(
        onPressed: () async {
          setState(() {
            _inAsyncCall = true;
          });
          print('print test selected');
          List<PrintableItem> pItems;
          bool printSucceeded = false;
          // get all selected printable items
          selectedPrintableItems =
              Provider.of<PrinterOrderListProvider>(context, listen: false)
                  .getSelectedPrintableItem();
          //filter all selectedPrintableItems within this flavor.
          pItems = Provider.of<PrinterOrderListProvider>(context, listen: false)
              .filterPrinterItemsByFlavoredItem(
                  flavoredOrderItem, selectedPrintableItems);
          // here goes to print
          print(pItems);
          // handle if pItems is 0
          if (pItems == null || pItems.length == 0) {
            Helper().showToastError(
                '${AppLocalizationHelper.of(context).translate('NoItemSelectedAlert')}');
          } else {
            List<OrderItemPrint> printList =
                await Provider.of<PrinterOrderListProvider>(context,
                        listen: false)
                    .groupPrintableItems(context, pItems);
            print(printList);
            // print out
            var ticket =
                await PrinterHelper().orderItemPrintTicket(printList, context);
            printSucceeded = await _printerHelper.startPrint(ticket, context);
            if (printSucceeded) {
              // put items into printed list
              pItems.forEach((item) =>
                  Provider.of<PrinterOrderListProvider>(context, listen: false)
                      .addPrintedPrintableItem(item));
            }
          }
          updateOrderItemPrintList();
          setState(() {
            _inAsyncCall = false;
          });
        },
        textColor: Colors.black,
        color: Colors.white,
        // padding: const EdgeInsets.symmetric(
        // vertical: 5, horizontal: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '${AppLocalizationHelper.of(context).translate('Print')}',
              // textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _orderItemPreview(List<OrderItemPrint> orderItemPrintList) {
    double totalAmount = 0;
    for (var item in orderItemPrintList) {
      totalAmount += item.price * item.quantity;
    }
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          (orderItemPrintList == null || orderItemPrintList.isEmpty)
              ? Container(child: Text('No order to print.'))
              : ListView.builder(
                  // controller: scrollController,
                  physics: ClampingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: orderItemPrintList.length,
                  itemBuilder: (ctx, index) {
                    OrderItemPrint orderItemPrint = orderItemPrintList[index];
                    return _showSingleOrder(context, orderItemPrint);
                  }),
                Text("Total Order Amount: "+ totalAmount.toStringAsFixed(2), style: GoogleFonts.lato(
                  fontWeight: FontWeight.bold,
                  fontSize: SizeHelper.textMultiplier*3
                ),),
                VEmptyView(30)
        ],
      ),
    );
  }

  Future<void> updateOrderItemPrintList() async {
    orderItemPrintList =
        await Provider.of<PrinterOrderListProvider>(context, listen: false)
            .allActiveOrderToOrderItemPrint(context, storeMenuId);
  }
}

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:vplus_merchant_app/helpers/apiHelper.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/helpers/date_time_helper.dart';
import 'package:vplus_merchant_app/helpers/screenHelper.dart';
import 'package:vplus_merchant_app/helpers/signalrHelper.dart';
import 'package:vplus_merchant_app/helpers/sizeHelper.dart';
import 'package:vplus_merchant_app/helpers/timerHelper.dart';
import 'package:vplus_merchant_app/models/Order.dart';
import 'package:vplus_merchant_app/models/store.dart';
import 'package:vplus_merchant_app/providers/current_menu_provider.dart';
import 'package:vplus_merchant_app/providers/current_order_provider.dart';
import 'package:vplus_merchant_app/providers/current_stores_provider.dart';
import 'package:vplus_merchant_app/providers/currentuser_provider.dart';
import 'package:vplus_merchant_app/providers/orderlist_provider.dart';
import 'package:vplus_merchant_app/providers/current_orderStatus_provider.dart';
import 'package:vplus_merchant_app/screens/home/home_screen.dart';
import 'package:vplus_merchant_app/screens/order/order_list/orderStatus_Page.dart';
import 'package:vplus_merchant_app/screens/printer/printer_preview_page.dart';
import 'package:vplus_merchant_app/styles/color.dart';
import 'package:vplus_merchant_app/widgets/customAppBar.dart';
import 'package:vplus_merchant_app/widgets/custom_dialog.dart';

enum OrderListButtonType {
  ActiveOrder,
  History,
}

class OrderListButton {
  OrderListButtonType buttontype;
  String label;

  OrderListButton({this.buttontype, this.label});
}

class OrderListView_Active extends StatefulWidget {
  @override
  _OrderListView_ActiveState createState() => _OrderListView_ActiveState();
}

class _OrderListView_ActiveState extends State<OrderListView_Active>
    with TickerProviderStateMixin {
  // AnimationController _fabController;
  OrderListButtonType selected = OrderListButtonType.ActiveOrder;
  bool dialVisible = true;

  List<SpeedDialChild> fabItemsActiveOrder;
  List<SpeedDialChild> fabItemsHistoryOrder;

  bool isLoading = false;

  int _storeMenuId;

  List<Widget> historyPageContents = [];

  int activePageNumber = 1;
  int historyPageNumber = 1;

  bool isOnActiveOrderTab = true;

  DateTime _selectedDate = DateTime.now();
  bool filterByChosenDate = false;

  var activeOrderController = ScrollController();
  var historyOrderController = ScrollController();

  Order order;

  //DateTime Picker in Android
  buildMaterialDatePicker(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light(),
          child: child,
        );
      },
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
        filterByChosenDate = true;
      });
  }

  /// This builds cupertion date picker in iOS
  buildCupertinoDatePicker(BuildContext context) async {
    await showModalBottomSheet(
        context: context,
        builder: (BuildContext builder) {
          return Container(
            // height: MediaQuery.of(context).copyWith().size.height / 3,
            color: Colors.white,
            child: Column(
              children: [
                SizedBox(
                  height: SizeHelper.isMobilePortrait
                      ? 25 * SizeHelper.heightMultiplier
                      : (SizeHelper.isPortrait)
                          ? 60 * SizeHelper.widthMultiplier
                          : 35 * SizeHelper.widthMultiplier,
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    onDateTimeChanged: (_picked) {
                      if (_picked != null && _picked != _selectedDate)
                        setState(() {
                          _selectedDate = _picked;
                        });
                    },
                    initialDateTime: _selectedDate,
                    minimumYear: 2000,
                    maximumYear: DateTime.now().year,
                  ),
                ),
                CupertinoButton(
                  child: Text(
                    '${AppLocalizationHelper.of(context).translate('Confirm')}',
                    style: GoogleFonts.lato(
                      fontSize: SizeHelper.isMobilePortrait
                          ? 1.5 * SizeHelper.textMultiplier
                          : 2 * SizeHelper.textMultiplier,
                    ),
                  ),
                  onPressed: () {
                    print(
                        '${AppLocalizationHelper.of(context).translate('SelectedDate')}: ${_selectedDate}');
                    setState(() {
                      filterByChosenDate = true;
                    });
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
          );
        });
  }

  Future<void> selectDate(BuildContext context) async {
    final ThemeData theme = Theme.of(context);
    assert(theme.platform != null);
    switch (theme.platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return await buildMaterialDatePicker(context);
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return await buildCupertinoDatePicker(context);
    }
  }

  List<Order> getActiveOrders() {
    /// in Order list page, only show submitted order (order item not empty)
    /// as Active order
    List<Order> activeOrders =
        Provider.of<OrderListProvider>(context, listen: false)
            .getActiveOrderList();
    return activeOrders;
  }

  List<Order> getHistoryOrders() {
    List<Order> historyOrders =
        Provider.of<OrderListProvider>(context, listen: false)
            .getHistoryOrderList();
    return historyOrders;
  }

  Future<void> getOrderListFromAPI() async {
    Store selectedStore =
        Provider.of<CurrentStoresProvider>(context, listen: false)
            .getStore(context);

    if (selectedStore != null) {
      setState(() {
        isLoading = true;
      });

      await Provider.of<CurrentMenuProvider>(context, listen: false)
          .getMenuFromAPI(context, selectedStore.storeId);

      _storeMenuId = Provider.of<CurrentMenuProvider>(context, listen: false)
          .getStoreMenu
          .storeMenuId;

      print('Store Menu ID: ${_storeMenuId}');

      await Provider.of<OrderListProvider>(context, listen: false)
          .getOrderListFromAPI(
        context,
        _storeMenuId,
        true,
        activePageNumber,
      );

      // await Provider.of<OrderListProvider>(context, listen: false)
      //     .getOrderListFromAPI(
      //   context,
      //   _storeMenuId,
      //   false,
      //   historyPageNumber,
      // );

      // if (getActiveOrders() != null) {
      //   determineOrderStatus(getActiveOrders(), context, true);
      // }
      // if (getHistoryOrders() != null) {
      //   determineOrderStatus(getHistoryOrders(), context, false);
      // }

      setState(() {
        isLoading = false;
      });
    }
    ;
  }

  Future<void> initScrollController(ScrollController _controller) async {
    // Setup the listener.
    _controller.addListener(() async {
      if (_controller.position.atEdge) {
        int currentPage;
        if (_controller.position.pixels == 0) {
          // You're at the top.
          if (_controller == activeOrderController) {
            print('Active Order Top');
            // setState(() {
            //   isLoading = true;
            // });
            // currentPage = Provider.of<OrderListProvider>(context, listen: false)
            //     .getCurrentActivePage();
            // await Provider.of<OrderListProvider>(context, listen: false)
            //     .getOrderListFromAPI(
            //         context, _storeMenuId, isActiveOrder, currentPage);
            // setState(() {
            //   isLoading = false;
            // });
          } else {
            // print('History Order Top');
            // setState(() {
            //   isLoading = true;
            // });
            // currentPage = Provider.of<OrderListProvider>(context, listen: false)
            //     .getCurrentHistoryPage();
            // await Provider.of<OrderListProvider>(context, listen: false)
            //     .getOrderListFromAPI(context, _storeMenuId, false, currentPage);
            // setState(() {
            //   isLoading = false;
            // });
          }
        } else {
          bool hasNextPage;
          // You're at the bottom.
          setState(() {
            isLoading = true;
          });
          if (_controller == activeOrderController) {
            // print('Active Order Buttom');
            // currentPage = Provider.of<OrderListProvider>(context, listen: false)
            //     .getCurrentActivePage();
            // hasNextPage = Provider.of<OrderListProvider>(context, listen: false)
            //     .getHasNextActivePage();
            // if (hasNextPage) {
            //   currentPage += 1;
            //   activePageNumber = currentPage;
            //   await Provider.of<OrderListProvider>(context, listen: false)
            //       .getOrderListFromAPI(
            //           context, _storeMenuId, true, activePageNumber);
            // }
          } else {
            print('History Order Buttom');
            currentPage = Provider.of<OrderListProvider>(context, listen: false)
                .getCurrentHistoryPage();
            hasNextPage = Provider.of<OrderListProvider>(context, listen: false)
                .getHasNextHistoryPage();
            if (hasNextPage && !filterByChosenDate) {
              currentPage += 1;
              historyPageNumber = currentPage;
              await Provider.of<OrderListProvider>(context, listen: false)
                  .getOrderListFromAPI(
                      context, _storeMenuId, false, historyPageNumber);
              setState(() {
                historyPageContents.clear();
              });
            }
          }
          setState(() {
            isLoading = false;
          });
        }
      }
    });
  }

  @override
  void initState() {
    // // Do user role check, add admin tools
    // ApiUser _currentUser =
    //     Provider.of<CurrentUserProvider>(context, listen: false)
    //         .getloggedInUser;
    // String adminRoleKeyword = "OrganizationAdmin";
    // if (Provider.of<CurrentUserProvider>(context, listen: false)
    //     .verifyRole(adminRoleKeyword, _currentUser)) {
    //   fabItems.add(
    //     SpeedDialChild(
    //       child: Icon(
    //         Icons.exit_to_app,
    //         color: Colors.white,
    //         size: SizeHelper.isMobilePortrait
    //             ? 3.5 * SizeHelper.imageSizeMultiplier
    //             : 3.5 * SizeHelper.imageSizeMultiplier,
    //       ),
    //       backgroundColor: Color(0xff5352ec),
    //       onTap: () async =>
    //           _showResetTableDialog('Reset all tables', getActiveOrders()),
    //       label: 'Reset all tables',
    //       labelStyle: TextStyle(
    //         fontWeight: FontWeight.w500,
    //         fontSize: SizeHelper.isMobilePortrait
    //             ? 1.5 * SizeHelper.textMultiplier
    //             : 2 * SizeHelper.textMultiplier,
    //       ),
    //       labelBackgroundColor: Colors.white,
    //     ),
    //   );
    // }

    print('init order list page');

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await getOrderListFromAPI();
      // FCMHelper.initOrderListPageContext(context);
      SignalrHelper.initOrderListPageContext(context);
    });

    fabItemsActiveOrder = [
      SpeedDialChild(
        child: Icon(
          Icons.print,
          color: Colors.white,
          size: SizeHelper.isMobilePortrait
              ? 3.5 * SizeHelper.imageSizeMultiplier
              : 3.5 * SizeHelper.imageSizeMultiplier,
        ),
        backgroundColor: Color(0xff5352ec),
        onTap: () {
          pushNewScreen(
            context,
            screen: PrinterPreviewPage(),
            withNavBar: true,
            pageTransitionAnimation: PageTransitionAnimation.cupertino,
          );
        },
        label: AppLocalizationHelper.localizedStrings['PrintOrderByItem'],
        labelStyle: GoogleFonts.lato(
          fontWeight: FontWeight.w500,
          fontSize: SizeHelper.isMobilePortrait
              ? 1.5 * SizeHelper.textMultiplier
              : 1.5 * SizeHelper.textMultiplier,
        ),
        labelBackgroundColor: Colors.white,
      ),
      SpeedDialChild(
        child: Icon(
          Icons.cached,
          color: Colors.white,
          size: SizeHelper.isMobilePortrait
              ? 3.5 * SizeHelper.imageSizeMultiplier
              : 3.5 * SizeHelper.imageSizeMultiplier,
        ),
        backgroundColor: Color(0xff5352ec),
        onTap: () async {
          setState(() {
            isLoading = true;
          });
          await Provider.of<OrderListProvider>(context, listen: false)
              .getOrderListFromAPI(context, _storeMenuId, true, 1);

          setState(() {
            isLoading = false;
          });
        },
        label: AppLocalizationHelper.localizedStrings['Refresh'],
        labelStyle: GoogleFonts.lato(
          fontWeight: FontWeight.w500,
          fontSize: SizeHelper.isMobilePortrait
              ? 1.5 * SizeHelper.textMultiplier
              : 1.5 * SizeHelper.textMultiplier,
        ),
        labelBackgroundColor: Colors.white,
      ),
    ];

    fabItemsHistoryOrder = [
      SpeedDialChild(
        child: Icon(
          Icons.cached,
          color: Colors.white,
          size: SizeHelper.isMobilePortrait
              ? 3.5 * SizeHelper.imageSizeMultiplier
              : 3.5 * SizeHelper.imageSizeMultiplier,
        ),
        backgroundColor: Color(0xff5352ec),
        onTap: () async {
          setState(() {
            isLoading = true;
          });
          await Provider.of<OrderListProvider>(context, listen: false)
              .getOrderListFromAPI(context, _storeMenuId, false, 1);
          setState(() {
            isLoading = false;
          });
        },
        label: AppLocalizationHelper.localizedStrings['Refresh'],
        labelStyle: GoogleFonts.lato(
          fontWeight: FontWeight.w500,
          fontSize: SizeHelper.isMobilePortrait
              ? 1.5 * SizeHelper.textMultiplier
              : 1.5 * SizeHelper.textMultiplier,
        ),
        labelBackgroundColor: Colors.white,
      ),
    ];

    Provider.of<OrderListProvider>(context, listen: false)
        .setIsOnActiveTab(isOnActiveOrderTab);

    super.initState();

    initScrollController(activeOrderController);
    initScrollController(historyOrderController);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        width: 1080, height: 1920, allowFontScaling: false);
    var store = Provider.of<CurrentStoresProvider>(context, listen: false)
        .getStore(context);
    OrderListButton active = new OrderListButton(
        buttontype: OrderListButtonType.ActiveOrder, label: 'Active Order(s)');
    OrderListButton history = new OrderListButton(
        buttontype: OrderListButtonType.History, label: 'History');

    Widget create_text(String label, FontWeight weight, Color color) {
      return Text(
        label,
        textAlign: TextAlign.center,
        style: GoogleFonts.lato(
            fontSize: SizeHelper.isMobilePortrait
                ? 2 * SizeHelper.textMultiplier
                : (SizeHelper.isPortrait)
                    ? 2 * SizeHelper.textMultiplier
                    : 1.5 * SizeHelper.textMultiplier,
            // fontSize: ScreenUtil().setSp(ScreenHelper.isLandScape(context)?MediaQuery.of(context).size.height*0.025:MediaQuery.of(context).size.height*0.025),
            fontWeight: weight,
            color: color,
            height: 1),
      );
    }

    Widget create_container(Order order, String label1, String label2,
        Color text_color, FontWeight fontWeight, int rowNumber) {
      Color color = Colors.white;

      if (rowNumber != 1) {
        if (rowNumber == 2) {
          switch (order.userOrderStatus) {
            case UserOrderStatus.Cancelled:
              color = Colors.red;
              break;
            case UserOrderStatus.InProgress:
              color = Colors.blue;
              break;
            case UserOrderStatus.AwaitConfirm:
              color = Colors.orange;
              break;
            case UserOrderStatus.Voided:
              color = Colors.blueGrey[900];
              break;
            case UserOrderStatus.Completed:
              color = Colors.green;
              break;
            case UserOrderStatus.Started:
              color = Colors.blue;
              break;
            case UserOrderStatus.Ready:
              color = readyColor;
              break;
            default:
              color = Colors.blue;
              break;
          }
        } else {
          switch (order.paymentStatus) {
            case OrderPaymentStatus.Cancelled:
              color = Colors.red;
              break;
            case OrderPaymentStatus.Paid:
              color = Colors.green;
              break;
            case OrderPaymentStatus.Voided:
              color = Colors.blueGrey[900];
              break;
            case OrderPaymentStatus.AwaitingPayment:
              color = Colors.white;
              break;
            default:
              color = Colors.green;
          }
        }
      } else if (order.takeAwayId != null) {
        color = Colors.white;
      } else {
        if (order.isAdminReset) {
          color = Colors.grey[300];
        }
      }
      return
       Container(
        margin: const EdgeInsets.fromLTRB(0, 8, 0, 7),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: SizeHelper.isMobilePortrait
                  ? 3 * SizeHelper.heightMultiplier
                  : (SizeHelper.isPortrait)
                      ? 5 * SizeHelper.widthMultiplier
                      : 3 * SizeHelper.widthMultiplier,
              width: SizeHelper.isMobilePortrait
                  ? 45 * SizeHelper.widthMultiplier
                  : (SizeHelper.isPortrait)
                      ? 30 * SizeHelper.heightMultiplier
                      : 20 * SizeHelper.heightMultiplier,
              // height:(ScreenHelper.isLandScape(context)?MediaQuery.of(context).size.height*0.05:MediaQuery.of(context).size.height*0.025),
              // width:(ScreenHelper.isLandScape(context)?MediaQuery.of(context).size.width*0.45:MediaQuery.of(context).size.width*0.4),
              child: Row(
                children: [
                  create_text(label1, fontWeight, Colors.black),
                ],
              ),
            ),
            Container(
              height: SizeHelper.isMobilePortrait
                  ? 2.2 * SizeHelper.heightMultiplier
                  : 3.5 * SizeHelper.widthMultiplier,
              // height:(ScreenHelper.isLandScape(context)?MediaQuery.of(context).size.height*0.05:MediaQuery.of(context).size.height*0.025),
              // width:(ScreenHelper.isLandScape(context)?MediaQuery.of(context).size.height*0.45:MediaQuery.of(context).size.height*0.26),
              width: (order.takeAwayId == null)
                  ? SizeHelper.isMobilePortrait
                      ? 30 * SizeHelper.widthMultiplier
                      : 16 * SizeHelper.heightMultiplier
                  : SizeHelper.isMobilePortrait
                      ? 30 * SizeHelper.widthMultiplier
                      : 16 * SizeHelper.heightMultiplier,
              color: color,
              child: Text(
                label2,
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                    fontSize: SizeHelper.isMobilePortrait
                        ? 1.8 * SizeHelper.textMultiplier
                        : (SizeHelper.isPortrait)
                            ? 1.8 * SizeHelper.textMultiplier
                            : 1.5 * SizeHelper.textMultiplier,
                    // fontSize: ScreenUtil().setSp((ScreenHelper.isLandScape(context)?MediaQuery.of(context).size.height*0.019:MediaQuery.of(context).size.height*0.02)),
                    fontWeight: FontWeight.bold,
                    color: text_color),
              ),
            )
          ],
        ),
      );
    }

    Widget createOrder(Order order, Color _color) {
      int orderDurationTime =
          DateTime.now().difference(order.orderCreateDateTimeUTC).inMinutes;
      return Container(
        decoration: BoxDecoration(
          border: Border.all(
              color: (order.isAdminReset) ? Colors.grey[300] : Colors.white),
          color: (order.isAdminReset) ? Colors.grey[300] : _color,
          // color: Colors.white),
          // color: _color,
          // color: color,
        ),
        child: Column(
          children: [
            create_container(
                order,
                order.orderType == OrderType.PickUp
                    ? 'Pick-Up': order.orderType == OrderType.Delivery?"Delivery"
                    : (order.takeAwayId == null || order.takeAwayId == "")
                        ? '${AppLocalizationHelper.of(context).translate('Table')}:${order.table}'
                        : '${AppLocalizationHelper.of(context).translate('TakeAway')}: ${Provider.of<CurrentOrderProvider>(context, listen: false).getTakeAwayIdShortcut(order.takeAwayId)}',
                (selected == OrderListButtonType.ActiveOrder)
                    ? '(${orderDurationTime} ${AppLocalizationHelper.of(context).translate('Minutes')})'
                    : '(${order.orderCompleteDateTimeUTC.difference(order.orderCreateDateTimeUTC).inMinutes} ${AppLocalizationHelper.of(context).translate('Minutes')})',
                Colors.red,
                FontWeight.bold,
                1),
            create_container(
                order,
                '${AppLocalizationHelper.of(context).translate('OrderNumber')}:${order.userOrderId}',
                '${AppLocalizationHelper.of(context).translate(order.userOrderStatus.toString().split('.')[1].toString())}',
                Colors.white,
                FontWeight.normal,
                2),
            create_container(
                order,
                '${AppLocalizationHelper.of(context).translate('Total')}: ${(order.totalAmount - order.deliveryFee).toStringAsFixed(2)}',
                order.paymentStatus == OrderPaymentStatus.AwaitingPayment?'Not Paid' :'${AppLocalizationHelper.of(context).translate(order.paymentStatus.toString().split('.')[1].toString())}',
                order.paymentStatus == OrderPaymentStatus.AwaitingPayment? Colors.black:Colors.white,
                FontWeight.normal,
                3),
            Divider(height: 1),
          ],
        ),
      );
    }

    Widget createDateTimeBar(
        String dateTime, int completeOrder, double totalPaidAmount) {
      bool isToday = false;
      if (dateTime == DateTimeHelper.parseDateTimeToDate(DateTime.now())) {
        isToday = true;
      }
      return Container(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                height: ScreenHelper.isLandScape(context)
                    ? SizeHelper.heightMultiplier * 6
                    : SizeHelper.heightMultiplier * 5,
                color: Colors.yellow[100],
                child: Row(
                  mainAxisAlignment: (filterByChosenDate)
                      ? MainAxisAlignment.spaceBetween
                      : MainAxisAlignment.center,
                  children: [
                    (isToday)
                        ? create_text(
                            '${AppLocalizationHelper.of(context).translate('Today')}: ${dateTime}',
                            FontWeight.normal,
                            Colors.black)
                        : create_text(
                            '${dateTime}', FontWeight.normal, Colors.black),
                    if (filterByChosenDate)
                      create_text(
                          '${AppLocalizationHelper.of(context).translate('CompleteOrders')}: ${completeOrder}\n${AppLocalizationHelper.of(context).translate('TotalPaidAmount')}: ${totalPaidAmount.toStringAsFixed(2)}',
                          FontWeight.normal,
                          Colors.black),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    Color determineColor(Order order) {
      if (order.isAdminReset) {
        return Colors.grey[300];
      }

      return Colors.white;
    }

    Widget createSelectedDateBar(String dateTime) {
      return Container(
        margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            create_text(
                '${AppLocalizationHelper.of(context).translate('SelectedDate')}: ',
                FontWeight.normal,
                Colors.black),
            Container(
              width: SizeHelper.isMobilePortrait
                  ? 25 * SizeHelper.widthMultiplier
                  : (SizeHelper.isPortrait)
                      ? 20 * SizeHelper.heightMultiplier
                      : 15 * SizeHelper.heightMultiplier,
              height: ScreenHelper.isLandScape(context)
                  ? 4 * SizeHelper.heightMultiplier
                  : 8 * SizeHelper.widthMultiplier,
              color: Colors.grey[300],
              child: Center(
                child: Text(dateTime,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                      fontSize: SizeHelper.isMobilePortrait
                          ? 1.5 * SizeHelper.textMultiplier
                          : (SizeHelper.isPortrait)
                              ? 2 * SizeHelper.textMultiplier
                              : 1.5 * SizeHelper.textMultiplier,
                    )),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  filterByChosenDate = false;
                  _selectedDate = DateTime.now();
                });
              },
              child: Container(
                width: SizeHelper.isMobilePortrait
                    ? 20 * SizeHelper.widthMultiplier
                    : (SizeHelper.isPortrait)
                        ? 10 * SizeHelper.heightMultiplier
                        : 10 * SizeHelper.heightMultiplier,
                height: ScreenHelper.isLandScape(context)
                    ? 7 * SizeHelper.heightMultiplier
                    : 55,
                margin: const EdgeInsets.fromLTRB(5, 0, 0, 5),
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Colors.grey[700],
                ),
                child: create_text(
                    '${AppLocalizationHelper.of(context).translate('Reset')}',
                    FontWeight.bold,
                    Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    Widget createOrderGestureDetector(Order order) {
      // Provider.of<Current_OrderStatus_Provider>(context,listen: false).determineOrderStatus(order, isActiveOrder);

      return GestureDetector(
        onTap: () async {
          if (!ScreenHelper.isLandScape(context)) {
            Provider.of<Current_OrderStatus_Provider>(context, listen: false)
                .setOrder(context, order, isOnActiveOrderTab);
            Provider.of<Current_OrderStatus_Provider>(context, listen: false)
                .setOrderStatusType(OrderStatusPageType.orderListPortrait);
          } else {
            setState(() {
              Provider.of<Current_OrderStatus_Provider>(context, listen: false)
                  .setOrderStatusType(OrderStatusPageType.orderListLandscape);
              Provider.of<Current_OrderStatus_Provider>(context, listen: false)
                  .setOrder(context, order, isOnActiveOrderTab);
            });
          }

          setState(() {
            isLoading = true;
          });

          Provider.of<Current_OrderStatus_Provider>(context, listen: false)
              .determineOrderStatus(order, isOnActiveOrderTab);

          setState(() {
            // order = Provider.of<Current_OrderStatus_Provider>(context, listen: false).getOrder();
            isLoading = false;
          });

          if (SizeHelper.isPortrait) {
            Navigator.of(context, rootNavigator: true)
                .push(
                    MaterialPageRoute(builder: (context) => OrderStatusView()))
                .then((value) {
              setState(() {
                // Provider.of<Current_OrderStatus_Provider>(ctx,listen:false).determineOrderStatus(order[order.length-index-1]);
              });
            });
          }
        },
        child: Container(
          color: determineColor(order),
          child: SizedBox(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      createOrder(order, Colors.white),
                      if (order.isAdminReset)
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.withOpacity(0.8),
                            border: Border.all(
                              color: Colors.transparent,
                              width: 20,
                            ),
                          ),
                          child: create_text(
                              'Admin\nReset', FontWeight.bold, Colors.white),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    List<dynamic> filterCurrentDateOrder(List<Order> orders) {
      int completedOrder = 0;
      double totalPaidAmount = 0;
      orders.forEach((element) {
        if (DateTimeHelper.compareDatesIsSameDate(
            element.orderCompleteDateTimeUTC.toLocal(), _selectedDate)) {
          historyPageContents.insert(1, createOrderGestureDetector(element));
          if (element.userOrderStatus == UserOrderStatus.Completed) {
            completedOrder += 1;
          }
          if (element.paymentSuccessful != null && element.paymentSuccessful) {
            if (element.totalPaidAmount != null) {
              totalPaidAmount += element.totalPaidAmount;
            }
          }
        }
      });
      return [completedOrder, totalPaidAmount];
    }

    Widget get_orderList_orderTypeButton(OrderListButton button) {
      return Expanded(
        flex: 5,
        child: Padding(
          padding: EdgeInsets.all(
            ScreenUtil().setWidth(10),
          ),
          child: RaisedButton(
            onPressed: () async {
              setState(() {
                selected = button.buttontype;
                (selected == OrderListButtonType.ActiveOrder)
                    ? isOnActiveOrderTab = true
                    : isOnActiveOrderTab = false;
              });
              Provider.of<OrderListProvider>(context, listen: false)
                  .setIsOnActiveTab(isOnActiveOrderTab);
              // if (ScreenHelper.isLandScape(context)) {
              //   Provider.of<Current_OrderStatus_Provider>(context,
              //           listen: false)
              //       .setResetTable(true);
              // }

              // after tab swiched, order detail should be null
              Provider.of<Current_OrderStatus_Provider>(context, listen: false)
                  .setOrder(context, null, isOnActiveOrderTab);
              if (button.buttontype == OrderListButtonType.History) {
                setState(() {
                  isLoading = true;
                });
                await Provider.of<OrderListProvider>(context, listen: false)
                    .getOrderListFromAPI(
                  context,
                  _storeMenuId,
                  false,
                  historyPageNumber,
                );
                setState(() {
                  isLoading = false;
                });
              }
            },
            textColor:
                (selected == button.buttontype) ? Colors.white : Colors.black,
            color: (selected == button.buttontype)
                ? Color(0xff5352ec)
                : Color(0xffdde4ec),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Row(
              mainAxisAlignment:
                  (button.buttontype == OrderListButtonType.History)
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  AppLocalizationHelper.of(context)
                      .translate(button.label)
                      .toString(),
                  style: GoogleFonts.lato(
                    fontSize: SizeHelper.isMobilePortrait
                        ? 2 * SizeHelper.textMultiplier
                        : 1.7 * SizeHelper.textMultiplier,
                    fontWeight: (selected == button.buttontype)
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                if (button.buttontype == OrderListButtonType.History)
                  SizedBox(
                    height: SizeHelper.isMobilePortrait
                        ? 4 * SizeHelper.heightMultiplier
                        : 4 * SizeHelper.widthMultiplier,
                    child: IconButton(
                      onPressed: () async {
                        if (!isOnActiveOrderTab) {
                          print('Open Calender');
                          await selectDate(context);

                          historyPageContents.clear();

                          setState(() {
                            isLoading = true;
                          });

                          String dateTime = DateTimeHelper.parseDateTimeToDate(
                              _selectedDate.toLocal());

                          historyPageContents
                              .add(createSelectedDateBar(dateTime));

                          List<Order> nextOrders = List.from(await Provider.of<
                                  OrderListProvider>(context, listen: false)
                              .getHistoryOrdersByDate(
                                  context,
                                  DateTimeHelper.parseDateTimeToDate(
                                      _selectedDate.add(new Duration(days: 1))),
                                  _storeMenuId));

                          List<Order> currentOrders = List.from(
                              await Provider.of<OrderListProvider>(context,
                                      listen: false)
                                  .getHistoryOrdersByDate(
                                      context,
                                      DateTimeHelper.parseDateTimeToDate(
                                          _selectedDate),
                                      _storeMenuId));

                          List<Order> previousOrders = List.from(
                              await Provider.of<OrderListProvider>(context,
                                      listen: false)
                                  .getHistoryOrdersByDate(
                                      context,
                                      DateTimeHelper.parseDateTimeToDate(
                                          _selectedDate
                                              .subtract(new Duration(days: 1))),
                                      _storeMenuId));

                          int completedOrder = 0;
                          double totalPaidAmount = 0;
                          List<dynamic> output;

                          setState(() {
                            output = filterCurrentDateOrder(previousOrders);
                            completedOrder += output[0] as int;
                            totalPaidAmount += output[1] as double;

                            output = filterCurrentDateOrder(currentOrders);
                            completedOrder += output[0] as int;
                            totalPaidAmount += output[1] as double;

                            output = filterCurrentDateOrder(nextOrders);
                            completedOrder += output[0] as int;
                            totalPaidAmount += output[1] as double;

                            historyPageContents.insert(
                                1,
                                createDateTimeBar(
                                    dateTime, completedOrder, totalPaidAmount));

                            isLoading = false;
                          });
                        }
                      },
                      icon: Icon(Icons.calendar_today,
                          size: SizeHelper.isMobilePortrait
                              ? 4 * SizeHelper.imageSizeMultiplier
                              : 2.5 * SizeHelper.imageSizeMultiplier)
                      // size: ScreenUtil().setSp(ScreenHelper.isLandScape(context)?MediaQuery.of(context).size.height*0.025:MediaQuery.of(context).size.height*0.025),
                      ,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    Widget createHistoryOrderView(List<Order> orders) {
      isOnActiveOrderTab = false;

      if (historyPageContents != null &&
          historyPageContents.length != 0 &&
          !filterByChosenDate) {
        historyPageContents.clear();
        print('Build History Orders');
      }

      if (!filterByChosenDate) {
        var data = Provider.of<OrderListProvider>(context, listen: false)
            .historyByDateMap;

        List<dynamic> keys;

        if (data != null) {
          keys = data.keys.toList();

          keys.forEach((key) {
            if (data[key] != null)
              historyPageContents
                  .add(createDateTimeBar(key.toString(), null, null));

            if (data[key] != null)
              data[key].forEach((entry) {
                historyPageContents
                    .add(createOrderGestureDetector((entry['order'] as Order)));
              });
          });
        }
      } else {}

      return (orders == null || orders.length == 0)
          ? Expanded(
              child: Center(
                child: create_text(
                    AppLocalizationHelper.of(context)
                        .translate('NoHistoryOrderNote'),
                    FontWeight.normal,
                    Colors.black),
              ),
            )
          : Expanded(
              child: ListView.builder(
                controller: historyOrderController,
                shrinkWrap: true,
                itemCount: historyPageContents.length,
                itemBuilder: (context, index) {
                  return historyPageContents[index];
                },
              ),
            );
    }

    Widget createActiveOrderView(List<Order> order) {
      return (order == null || order.length == 0)
          ? Expanded(
              child: Container(
                child: Center(
                  child: create_text(
                      AppLocalizationHelper.of(context)
                          .translate('NoActiveOrdersNote'),
                      FontWeight.normal,
                      Colors.black),
                ),
              ),
            )
          : Expanded(
              child: ListView.builder(
                  //controller: activeOrderController,
                  shrinkWrap: true,
                  itemCount: order.length,
                  itemBuilder: (ctx, index) {
                    // if (order[index].userItems == null ||
                    //     order[index].userItems.length == 0) {
                    //   return Container();
                    // }
                    return GestureDetector(
                      onTap: () async {
                        await tapOrderFromOrderList(ctx, order, index);
                      },
                      child: Container(
                        child: SizedBox(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: Column(
                              children: [
                                createOrder(order[index], Colors.white),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
            );
    }

    Widget portraitUI() {
      return Container(
        child: Column(
          children: [
            ListTile(
                title: Row(
              children: <Widget>[
                get_orderList_orderTypeButton(active),
                get_orderList_orderTypeButton(history),
              ],
            )),
            Container(
              child: Consumer<OrderListProvider>(
                builder: (context, provider, widget) {
                  var activeOrders = provider.getActiveOrderList();
                  return selected == OrderListButtonType.ActiveOrder
                      ? createActiveOrderView(activeOrders)
                      : createHistoryOrderView(getHistoryOrders());
                },
              ),
            ),
          ],
        ),
      );
    }

    Widget landScapeUI() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 145 * SizeHelper.heightMultiplier,
            width: ScreenHelper.isLandScape(context)
                ? 67 * SizeHelper.widthMultiplier
                : 85 * SizeHelper.widthMultiplier,
            child: portraitUI(),
          ),
          // Divider(
          //   thickness: 2,
          //   height: 2,
          //   color: Colors.grey,
          // ),
          Expanded(
            child: OrderStatusView(),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: CustomAppBar.getAppBar(
        AppLocalizationHelper.of(context).translate('OrderList'),
        true,
        context: context,
        rightButtonIcon: store.logoUrl == null
            ? Container(
                width: ScreenUtil().setWidth(80),
                height: ScreenUtil().setHeight(80),
                decoration: BoxDecoration(shape: BoxShape.circle),
                child: CircleAvatar(
                  child: Text(
                    store.storeName.substring(0, 1),
                    style: TextStyle(
                        color: Colors.white, fontSize: ScreenUtil().setSp(40)),
                  ),
                  backgroundColor: Color(
                      int.tryParse(store.backgroundColorHex) ??
                          Colors.grey.value),
                ))
            : Container(
                width: ScreenUtil().setWidth(80),
                height: ScreenUtil().setHeight(80),
                decoration: BoxDecoration(shape: BoxShape.circle),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(store.logoUrl),
                  backgroundColor: Color(
                      int.tryParse(store.backgroundColorHex) ??
                          Colors.grey.value),
                ),
              ),
        screenPage:
            Provider.of<CurrentUserProvider>(context, listen: false).isAdmin()
                ? CustomAppBar.storeMainPage
                : CustomAppBar.staffPage,
      ),
      body: ModalProgressHUD(
        // callback: () async {
        //   await Provider.of<OrderListProvider>(context, listen: false)
        //       .getOrderListFromAPI(context, _storeMenuId, true, 1);
        // },
        inAsyncCall: isLoading,
        child: OrientationBuilder(builder: (context, orientation) {
          if (!ScreenHelper.isLandScape(context)) {
            SizeHelper.landScapeHomePage = false;
            return portraitUI();
          } else {
            SizeHelper.landScapeHomePage = true;
            return landScapeUI();
          }
        }),
      ),
      floatingActionButton: buildSpeedDial(),
    );
  }

  SpeedDial buildSpeedDial() {
    return SpeedDial(
        marginRight: (SizeHelper.isPortrait)
            ? 20
            : MediaQuery.of(context).size.width * 0.75,
        //marginRight: 165,
        backgroundColor: Color(0xff5352ec),
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: IconThemeData(
            size: SizeHelper.isMobilePortrait
                ? 5 * SizeHelper.imageSizeMultiplier
                : 2.5 * SizeHelper.imageSizeMultiplier
            // size: ScreenUtil().setSp(ScreenHelper.isLandScape(context)?MediaQuery.of(context).size.height*0.025:MediaQuery.of(context).size.height*0.025),
            ),

        // child: Icon(Icons.add),
        // onOpen: () => print('OPENING DIAL'),
        // onClose: () => print('DIAL CLOSED'),
        // visible: dialVisible,
        curve: Curves.bounceIn,
        children: (selected == OrderListButtonType.ActiveOrder)
            ? fabItemsActiveOrder
            : fabItemsHistoryOrder);
  }

  void setDialVisible(bool value) {
    setState(() {
      dialVisible = value;
    });
  }

  void _showResetTableDialog(String label, List<Order> orders) {
    // reset one order or reset all orders
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(
          title: label,
          insideButtonList: [
            CustomDialogInsideButton(
                buttonName: "No",
                buttonColor: Colors.grey,
                buttonEvent: () {
                  Navigator.of(context).pop();
                }),
            CustomDialogInsideButton(
                buttonName: "Yes",
                buttonEvent: () async {
                  await Provider.of<Current_OrderStatus_Provider>(context,
                          listen: false)
                      .hardResetOrder(orders, context);

                  orders.forEach((element) {
                    Provider.of<OrderListProvider>(context, listen: false)
                        .addHistoryOrder(element);
                  });
                  // remove from active orders
                  if (orders.length == 1) {
                    Provider.of<OrderListProvider>(context, listen: false)
                        .removeItemFromActiveOrder(orders[0]);
                    orders = [];
                  }
                  while (orders.length >= 1) {
                    Provider.of<OrderListProvider>(context, listen: false)
                        .removeItemFromActiveOrder(orders[0]);
                  }
                  await Provider.of<OrderListProvider>(context, listen: false)
                      .getOrderListFromAPI(
                          context, _storeMenuId, true, activePageNumber);
                  // await Provider.of<OrderListProvider>(context, listen: false)
                  //     .getOrderListFromAPI(
                  //         context, _storeMenuId, false, historyPageNumber);
                  Navigator.of(context).pop();
                })
          ],
          child: Text(
            "Proceed to ${label}?",
            style: GoogleFonts.lato(
              fontSize: SizeHelper.isMobilePortrait
                  ? 2 * SizeHelper.textMultiplier
                  : 2 * SizeHelper.textMultiplier,
              // fontSize: ScreenUtil().setSp(ScreenHelper.isLandScape(context)?MediaQuery.of(context).size.height*0.025:MediaQuery.of(context).size.height*0.025),
            ),
          ),
        );
      },
    );
  }

  tapOrderFromOrderList(ctx, order, index) async {
    Provider.of<Current_OrderStatus_Provider>(context, listen: false)
        .setOrderStatusType(ScreenHelper.isLandScape(ctx)
            ? OrderStatusPageType.orderListLandscape
            : OrderStatusPageType.orderListPortrait);
    Provider.of<Current_OrderStatus_Provider>(ctx, listen: false)
        .setOrder(ctx, order[index], true);

    setState(() {
      isLoading = true;
    });

    Provider.of<Current_OrderStatus_Provider>(ctx, listen: false)
        .determineOrderStatus(order[index], isOnActiveOrderTab);

    setState(() {
      isLoading = false;
    });

    if (SizeHelper.isPortrait) {
      Provider.of<Current_OrderStatus_Provider>(context, listen: false)
          .setIsResetByOtherDevice(false);
      Navigator.of(context, rootNavigator: true)
          .push(MaterialPageRoute(builder: (context) => OrderStatusView()))
          .then((value) {
        setState(() {
          // Provider.of<Current_OrderStatus_Provider>(ctx,listen:false).determineOrderStatus(order[order.length-index-1]);
        });
      });
    }
  }
}

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:vplus_merchant_app/helpers/apiHelper.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/helpers/date_time_helper.dart';
import 'package:vplus_merchant_app/helpers/screenHelper.dart';
import 'package:vplus_merchant_app/helpers/printerHelper.dart';
import 'package:vplus_merchant_app/helpers/signalrHelper.dart';
import 'package:vplus_merchant_app/helpers/sizeHelper.dart';
import 'package:vplus_merchant_app/models/ExtraOrder.dart';
import 'package:vplus_merchant_app/models/Order.dart';
import 'package:vplus_merchant_app/models/OrderItem.dart';
import 'package:vplus_merchant_app/providers/current_menu_provider.dart';
import 'package:vplus_merchant_app/providers/current_printer_provider.dart';
import 'package:vplus_merchant_app/providers/current_stores_provider.dart';
import 'package:vplus_merchant_app/providers/kds_provider.dart';
import 'package:vplus_merchant_app/providers/orderlist_provider.dart';
import 'package:vplus_merchant_app/providers/current_orderStatus_provider.dart';
import 'package:vplus_merchant_app/providers/current_order_provider.dart';
import 'package:vplus_merchant_app/styles/color.dart';
import 'package:vplus_merchant_app/widgets/components.dart';
import 'package:vplus_merchant_app/widgets/custom_dialog.dart';
import 'package:vplus_merchant_app/widgets/emptyView.dart';
import 'package:vplus_merchant_app/widgets/network_error.dart';

enum OrderStatus_ButtonType {
  CancelOrder,
  Pay,
  CancelItem,
  ServeItem,
  ReturnItem,
  ResetTable,
  Back,
  CashPayment,
  CardPayment,
  Discount_Percent,
  Discount_Dollar,
  Confirm_All,
  Confirm_Single,
  ServeAll,
  ReturnAll,
  Ready,
}

class OrderStatus_Button {
  OrderStatus_ButtonType buttonType;
  String label;

  OrderStatus_Button({this.buttonType, this.label});
}

class OrderStatusView extends StatefulWidget {
  @override
  _OrderStatusViewState createState() => _OrderStatusViewState();
}

class _OrderStatusViewState extends State<OrderStatusView> {
  Order order;

  int orderId;

  bool isActiveOrder;

  bool hasExtraOrder = false;
  bool hasCurrentOrder = false;

  // String extraOrderNotes = "";

  bool hasReseted = false;
  bool atPaymentPage = false;
  bool has_confirm_all = false;
  bool has_confirm_one = false;

  bool hasServedAll = false;
  bool hasServedOne = false;

  bool hasReturnedAll = false;
  bool hasReturnedOne = false;

  String _discount_percent = "0";
  bool allowCashDiscount = true;
  bool allowPercentDiscount = true;
  bool discount_been_made = false;

  double cash_payment_amount = 0;
  bool iscashPayment = false;
  double card_payment_amount = 0;
  bool iscardPayment = false;

  double order_totalAmount_copy = 0;
  double currentDiscount = 0;

  bool callReturnAPI = false;
  bool callCancelAPI = false;
  bool callServeAPI = false;
  bool calllConfirmAPI = false;
  bool callCheckOutAPI = false;
  bool callResetTableAPI = false;
  bool callReadyAPI = false;
  bool callCancelOrderAPI = false;

  bool closeWindow = false;

  List<OrderItem> _orderItems = [];

  // bool payment_successsful=false;

  String dollarSign = String.fromCharCodes(new Runes('\u0024'));

  final TextEditingController textFiledController = new TextEditingController();
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  PrinterHelper _printerHelper = PrinterHelper();

  bool _inAsyncCall;

  bool hasKitchenInStore;
  int storeId;

  @override
  void initState() {
    resetVariables();
    SignalrHelper.initOrderStatusContext(context);
    hasKitchenInStore =
        Provider.of<CurrentStoresProvider>(context, listen: false)
            .hasKitchenInStore;
    _inAsyncCall = false;
    storeId = Provider.of<CurrentStoresProvider>(context, listen: false)
        .getSelectedStoreId;
    super.initState();
  }

  @override
  void dispose() {
    textFiledController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget create_dialog_content(
        OrderStatus_Button button, String label, IconData _icon) {
      if (button.buttonType == OrderStatus_ButtonType.CancelItem ||
          button.buttonType == OrderStatus_ButtonType.ReturnItem ||
          button.buttonType == OrderStatus_ButtonType.Discount_Dollar ||
          button.buttonType == OrderStatus_ButtonType.Discount_Percent ||
          button.buttonType == OrderStatus_ButtonType.CashPayment ||
          button.buttonType == OrderStatus_ButtonType.CardPayment ||
          button.buttonType == OrderStatus_ButtonType.ReturnAll ||
          button.buttonType == OrderStatus_ButtonType.CancelOrder) {
        if (button.buttonType == OrderStatus_ButtonType.CashPayment ||
            button.buttonType == OrderStatus_ButtonType.CardPayment) {
          textFiledController.text =
              (getOutStandingPayment(order) - currentDiscount).toString();
        } else {
          textFiledController.text = "";
        }

        return Form(
          key: formkey,
          child: Column(
            children: [
              Container(
                height: ScreenHelper.isLandScape(context)
                    ? 10 * SizeHelper.widthMultiplier
                    : 10 * SizeHelper.heightMultiplier,
                child: TextField(
                  controller: textFiledController,
                  keyboardType: (button.buttonType ==
                              OrderStatus_ButtonType.CashPayment ||
                          button.buttonType ==
                              OrderStatus_ButtonType.CardPayment ||
                          button.buttonType ==
                              OrderStatus_ButtonType.Discount_Percent ||
                          button.buttonType ==
                              OrderStatus_ButtonType.Discount_Dollar)
                      ? TextInputType.numberWithOptions(decimal: true)
                      : TextInputType.text,
                  decoration: InputDecoration(
                    prefixIcon: (_icon != null &&
                            (button.buttonType ==
                                    OrderStatus_ButtonType.CashPayment ||
                                button.buttonType ==
                                    OrderStatus_ButtonType.CardPayment))
                        ? Icon(
                            _icon,
                            color: Colors.black,
                            size: ScreenHelper.isLandScape(context)
                                ? SizeHelper.imageSizeMultiplier * 2
                                : SizeHelper.imageSizeMultiplier * 3,
                          )
                        : null,
                    suffixIcon: (_icon != null &&
                            (button.buttonType !=
                                    OrderStatus_ButtonType.CashPayment &&
                                button.buttonType !=
                                    OrderStatus_ButtonType.CardPayment))
                        ? Icon(
                            _icon,
                            color: Colors.black,
                            size: ScreenHelper.isLandScape(context)
                                ? SizeHelper.imageSizeMultiplier * 2
                                : SizeHelper.imageSizeMultiplier * 4,
                          )
                        : null,
                    isDense: true,
                    border: OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    hintText: label,
                  ),
                  style: GoogleFonts.lato(
                    fontSize: ScreenHelper.isLandScape(context)
                        ? SizeHelper.textMultiplier * 2
                        : SizeHelper.textMultiplier * 2,
                    fontWeight: FontWeight.normal,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        return Text(
          '${button.label}',
          style: GoogleFonts.lato(
            fontSize: ScreenHelper.isLandScape(context)
                ? SizeHelper.textMultiplier * 2
                : SizeHelper.textMultiplier * 2,
            fontWeight: FontWeight.normal,
            color: Colors.black,
          ),
        );
      }
    }

    Widget create_alert_msg() {
      return Text(
        "${AppLocalizationHelper.of(context).translate('ModifyOrder')}",
        style: GoogleFonts.lato(
          fontSize: ScreenHelper.isLandScape(context)
              ? SizeHelper.textMultiplier * 2
              : SizeHelper.textMultiplier * 2,
          fontWeight: FontWeight.normal,
          color: Colors.red,
        ),
      );
    }

    Widget create_checkBox(String label, BuildContext context,
        OrderItem orderItem, OrderStatus_Button button) {
      bool isChecked = false;
      return Container(
        padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
        child: StatefulBuilder(
          builder: (context, _setState) => CheckboxListTile(
            title: Text(
              "${AppLocalizationHelper.of(context).translate(label)}",
              style: GoogleFonts.lato(
                fontSize: SizeHelper.isMobilePortrait
                    ? 2 * SizeHelper.textMultiplier
                    : 2 * SizeHelper.textMultiplier,
                // fontSize: ScreenUtil().setSp(60),
              ),
            ),
            value: isChecked,
            onChanged: (newValue) {
              _setState(() {
                isChecked = newValue;
                if (isChecked) {
                  if (orderItem.returnCancelStatus == null)
                    orderItem.returnCancelStatus = [];
                  switch (label) {
                    case 'Out of stock':
                      orderItem.returnCancelStatus
                          .add(ReturnCancelStatus.OutofStock);
                      break;
                    case 'Customer requests':
                      orderItem.returnCancelStatus
                          .add(ReturnCancelStatus.CustomerRequest);
                      break;
                    case 'Exchange':
                      print('Exchanged checked');
                      orderItem.returnCancelStatus
                          .add(ReturnCancelStatus.Exchange);
                      break;
                    case 'Spolied':
                      orderItem.returnCancelStatus
                          .add(ReturnCancelStatus.Spoiled);
                      break;
                  }
                } else {
                  switch (label) {
                    case 'Out of stock':
                      orderItem.returnCancelStatus
                          .remove(ReturnCancelStatus.OutofStock);
                      break;
                    case 'Customer requests':
                      orderItem.returnCancelStatus
                          .remove(ReturnCancelStatus.CustomerRequest);
                      break;
                    case 'Exchange':
                      orderItem.returnCancelStatus
                          .remove(ReturnCancelStatus.Exchange);
                      break;
                    case 'Spolied':
                      orderItem.returnCancelStatus
                          .remove(ReturnCancelStatus.Spoiled);
                      break;
                  }
                }
              });
            },
            activeColor: Colors.blue,
            checkColor: Colors.white,
          ),
        ),
      );
    }

    void mark_all_itemPreparing(List<OrderItem> order) {
      for (int i = 0; i < order.length; i++) {
        order[i].itemStatus = ItemStatus.Preparing;
      }
    }

    UserOrderStatus check_all_item_been_cancelled_or_returned(
        UserOrderStatus input, List<OrderItem> order) {
      int cancel_count = 0;
      int return_count = 0;
      for (int i = 0; i < order.length; i++) {
        if (order[i].itemStatus == ItemStatus.Cancelled) {
          cancel_count++;
        }
        if (order[i].itemStatus == ItemStatus.Returned) {
          return_count++;
        }
      }

      if ((cancel_count + return_count == order.length &&
              return_count != 0 &&
              cancel_count != 0) ||
          return_count == order.length) {
        return UserOrderStatus.Voided;
      }
      if (cancel_count == order.length) {
        return UserOrderStatus.Cancelled;
      }
      return input;
    }

    bool check_all_item_beenConfirmed(List<OrderItem> order) {
      for (int i = 0; i < order.length; i++) {
        if (order[i].itemStatus == ItemStatus.AwaitConfirm) {
          return false;
        }
      }
      return true;
    }

    bool markAsSuccessfulPayment(
        double paidAmount, PaymentMethodType paymentMethodType) {
      double mod = pow(10.0, 2);
      print(
          '${paymentMethodType.toString().split('.')[1]} payment ${paidAmount}');
      if (paidAmount >=
          (((getOutStandingPayment(order) - currentDiscount) * mod)
                  .round()
                  .toDouble() /
              mod)) {
        print('Payment Successful');

        if (order.userExtraOrders != null &&
            order.userExtraOrders.length != 0) {
          order.userExtraOrders.forEach((element) {
            element.isPaid = true;
          });
        }

        Provider.of<Current_OrderStatus_Provider>(context, listen: false)
            .setPaymentSuccessful(context, true);
        Provider.of<Current_OrderStatus_Provider>(context, listen: false)
            .setPaymentStatus(context, OrderPaymentStatus.Paid);

        order.paymentSuccessful = true;
        order.paymentStatus = OrderPaymentStatus.Paid;
        order.paymentMethod = paymentMethodType;

        if (order.totalPaidAmount == null) {
          order.totalPaidAmount = 0;
        }

        order.totalPaidAmount += paidAmount;
        order.discount += currentDiscount;
        callCheckOutAPI = true;
        atPaymentPage = false;
        return true;
      }
      Helper().showToastError(
          '${AppLocalizationHelper.of(context).translate('InsufficientAmountAlert')}');
      return false;
    }

    Future<void> callAPI(List<int> orderItems, String returnCancelNotes) async {
      if (callReturnAPI) {
        await Provider.of<Current_OrderStatus_Provider>(context, listen: false)
            .updateReturnItemToAPI(orderItems, returnCancelNotes, context);
      }

      if (calllConfirmAPI) {
        await Provider.of<Current_OrderStatus_Provider>(context, listen: false)
            .updateConfirmItemToAPI(orderItems, context);
      }

      if (callServeAPI) {
        await Provider.of<Current_OrderStatus_Provider>(context, listen: false)
            .updateServeItemToAPI(orderItems, context);
      }

      if (callCancelAPI && !callCancelOrderAPI) {
        await Provider.of<Current_OrderStatus_Provider>(context, listen: false)
            .updateCancelItemToAPI(orderItems, returnCancelNotes, context);
      } else if (callCancelOrderAPI) {
        await Provider.of<CurrentOrderProvider>(context, listen: false)
            .cancelUserOrderByOrderId(context, orderId);
      }

      if (callCheckOutAPI) {
        await Provider.of<Current_OrderStatus_Provider>(context, listen: false)
            .updateCheckoutToAPI(order, context);
      }

      if (callResetTableAPI) {
        await Provider.of<Current_OrderStatus_Provider>(context, listen: false)
            .updateResetTableToAPI(order, context);
      }

      if (callReadyAPI) {
        var signalr = SignalrHelper();
        List<int> orderItemIds =
            order.userItems.map((e) => e.userOrderItemId).toList();
        bool hasUpdated = await Provider.of<Current_OrderStatus_Provider>(
                context,
                listen: false)
            .setOrderItemReady(context, orderItemIds);
        // if (hasUpdated) {
        await signalr.sendUserOrder(
            SignalrHelper.readyOrderEvent, storeId, order.userOrderId);

        int storeMenuId;
        storeMenuId = Provider.of<CurrentMenuProvider>(context, listen: false)
            .getStoreMenuId;
        await Provider.of<OrderListProvider>(context, listen: false)
            .getOrderListFromAPI(context, storeMenuId, true, 1);
        if (SizeHelper.isPortrait) {
          Navigator.pop(context);
        } else {
          Provider.of<Current_OrderStatus_Provider>(context, listen: false)
              .setOrder(context, null, false);
        }

        // await Provider.of<CurrentOrderProvider>(context, listen: false)
        //     .getOrderByOrderId(context, order.userOrderId);
        //}
      }

      callReturnAPI = false;
      callCancelAPI = false;
      callCancelOrderAPI = false;
      callServeAPI = false;
      calllConfirmAPI = false;
      callCheckOutAPI = false;
      callResetTableAPI = false;
      callReadyAPI = false;
    }

    List<int> getUserItemsId(Order oder, ItemStatus itemStatus) {
      List<int> orderItemsId = [];

      _orderItems.forEach((element) {
        print('Expected: ${itemStatus}');
        print(element.itemStatus);
        if (element.itemStatus == itemStatus) {
          print('check');
          orderItemsId.add(element.userOrderItemId);
        }
      });

      print(orderItemsId.length);

      return orderItemsId;
    }

    ConfirmationDialog(OrderItem orderItem, OrderStatus_Button button,
        String label, IconData icon) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomDialog(
                title: button.label,
                insideButtonList: [
                  CustomDialogInsideButton(
                      buttonName:
                          AppLocalizationHelper.of(context).translate('Cancel'),
                      buttonColor: Colors.grey,
                      buttonEvent: () {
                        Navigator.pop(context);
                      }),
                  CustomDialogInsideButton(
                      buttonName: AppLocalizationHelper.of(context)
                          .translate('Confirm'),
                      buttonEvent: () async {
                        List<int> orderItemsId = [];
                        double outStandingPayment = 0;
                        // auto print after paid
                        if (button.buttonType ==
                                OrderStatus_ButtonType.CashPayment ||
                            button.buttonType ==
                                OrderStatus_ButtonType.CardPayment) {
                          try {
                            outStandingPayment = getOutStandingPayment(order);
                            await Provider.of<CurrentPrinterProvider>(context,
                                    listen: false)
                                .autoPrintOnOrderPaid(context, order,
                                    getOutStandingPayment(order));
                          } catch (e) {
                            print(e);
                          }
                        }
                        String returnCancelNotes;
                        if (button.buttonType ==
                            OrderStatus_ButtonType.Confirm_All) {
                          // Order printOrder =
                          //     Provider.of<Current_OrderStatus_Provider>(context,
                          //             listen: false)
                          //         .order;
                          await Provider.of<CurrentPrinterProvider>(context,
                                  listen: false)
                              .autoPrintOnOrderConfirmed(context, order);
                        }

                        if (button.buttonType ==
                            OrderStatus_ButtonType.Confirm_Single) {
                          var ticket = await PrinterHelper()
                              .singleOrderItemTicket(order, orderItem, context);
                          await _printerHelper.startPrint(ticket, context);
                        }

                        setState(() {
                          bool cancel_order = false;
                          bool reset = false;
                          double mod = pow(10.0, 2);
                          switch (button.buttonType) {
                            case OrderStatus_ButtonType.Ready:
                              callReadyAPI = true;
                              break;
                            case OrderStatus_ButtonType.Confirm_All:
                              orderItemsId = List.from(getUserItemsId(
                                  order, ItemStatus.AwaitConfirm));
                              order.userOrderStatus =
                                  UserOrderStatus.InProgress;
                              has_confirm_all = true;
                              mark_all_itemPreparing(_orderItems);
                              calllConfirmAPI = true;

                              break;
                            case OrderStatus_ButtonType.Confirm_Single:
                              orderItemsId = [orderItem.userOrderItemId];
                              orderItem.itemStatus = ItemStatus.Preparing;
                              if (check_all_item_beenConfirmed(_orderItems)) {
                                order.userOrderStatus =
                                    UserOrderStatus.InProgress;
                              }

                              /// for QR order, once an item has been confirmed
                              /// order should be in progress
                              if (order.orderType == OrderType.QR &&
                                  order.userOrderStatus ==
                                      UserOrderStatus.AwaitConfirm) {
                                order.userOrderStatus =
                                    UserOrderStatus.InProgress;
                              }
                              has_confirm_one = true;
                              calllConfirmAPI = true;

                              break;
                            case OrderStatus_ButtonType.CashPayment:
                              try {
                                cash_payment_amount = double.parse(
                                    textFiledController.text.toString());
                              } catch (e) {
                                cash_payment_amount = -1;
                              }
                              iscashPayment = true;
                              if (atPaymentPage) {
                                order.paymentSuccessful =
                                    markAsSuccessfulPayment(cash_payment_amount,
                                        PaymentMethodType.Cash);
                              }
                              // setState(() {
                              //   order.paymentSuccessful=markAsSuccessfulPayment(cash_payment_amount, PaymentMethodType.Cash);
                              //   Provider.of<Current_OrderStatus_Provider>(context,listen:false).setPaymentSuccessful(true);
                              // });
                              break;
                            case OrderStatus_ButtonType.CardPayment:
                              //TODO: credit card payment
                              try {
                                card_payment_amount = double.parse(
                                    textFiledController.text.toString());
                              } catch (e) {
                                card_payment_amount = -1;
                              }

                              iscardPayment = true;
                              if (atPaymentPage) {
                                order.paymentSuccessful =
                                    markAsSuccessfulPayment(card_payment_amount,
                                        PaymentMethodType.Card);
                              }
                              // setState(() {
                              //   order.paymentSuccessful=markAsSuccessfulPayment(cash_payment_amount, PaymentMethodType.Cash);
                              //   Provider.of<Current_OrderStatus_Provider>(context,listen:false).setPaymentSuccessful(true);
                              // });
                              break;
                            case OrderStatus_ButtonType.Discount_Percent:
                              print(textFiledController.text);
                              double value;
                              try {
                                value = getOutStandingPayment(order) *
                                    (double.parse(textFiledController.text
                                            .toString()) /
                                        100);
                              } catch (e) {
                                value = -1;
                              }

                              value = ((value * mod).round().toDouble() / mod);
                              currentDiscount += (value);
                              allowCashDiscount = false;
                              discount_been_made = true;
                              _discount_percent =
                                  textFiledController.text.toString();
                              order_totalAmount_copy = order.totalAmount;
                              break;
                            case OrderStatus_ButtonType.Discount_Dollar:
                              print(textFiledController.text);
                              double value;
                              try {
                                value = (double.parse(
                                    textFiledController.text.toString()));
                              } catch (e) {
                                value = 0;
                              }
                              currentDiscount += value;
                              allowPercentDiscount = false;
                              discount_been_made = true;
                              order_totalAmount_copy = order.totalAmount;
                              break;
                            case OrderStatus_ButtonType.ServeItem:
                              orderItemsId = [orderItem.userOrderItemId];
                              orderItem.itemStatus = ItemStatus.Served;
                              order.itemBeenServed = true;
                              hasServedOne = true;
                              hasServedAll = checkAllServed(order);
                              if (hasServedOne && !hasServedAll) {
                                serveAll.label = 'Serve Item(s)';
                              }
                              callServeAPI = true;
                              break;
                            case OrderStatus_ButtonType.CancelItem:
                              // here for cancel single orderitem
                              orderItemsId = [orderItem.userOrderItemId];
                              orderItem.itemStatus = ItemStatus.Cancelled;
                              calculate_order_totalAmount();
                              order.userOrderStatus =
                                  check_all_item_been_cancelled_or_returned(
                                      order.userOrderStatus, _orderItems);

                              if (textFiledController.text != null) {
                                orderItem.cancelReason =
                                    textFiledController.text;
                              }

                              orderItem.cancelReason =
                                  create_checkBoxText(orderItem, false);

                              returnCancelNotes = orderItem.cancelReason;

                              callCancelAPI = true;
                              break;
                            case OrderStatus_ButtonType.ReturnItem:
                              orderItemsId = [orderItem.userOrderItemId];
                              orderItem.itemStatus = ItemStatus.Returned;
                              hasReturnedOne = true;
                              if (hasReturnedOne && !hasReturnedAll) {
                                returnAll.label = 'Return Item(s)';
                              }
                              calculate_order_totalAmount();
                              order.userOrderStatus =
                                  check_all_item_been_cancelled_or_returned(
                                      order.userOrderStatus, _orderItems);

                              if (order.userOrderStatus ==
                                  UserOrderStatus.Voided) {
                                order.paymentStatus = OrderPaymentStatus.Voided;
                              }

                              callReturnAPI = true;

                              if (textFiledController.text != null) {
                                orderItem.returnReason =
                                    textFiledController.text;
                              }

                              orderItem.returnReason =
                                  create_checkBoxText(orderItem, true);

                              returnCancelNotes = orderItem.returnReason;

                              break;
                            case OrderStatus_ButtonType.Pay:
                              if (!atPaymentPage) {
                                atPaymentPage = true;
                                order_totalAmount_copy = order.totalAmount;
                              }
                              break;
                            case OrderStatus_ButtonType.Back:
                              atPaymentPage = false;
                              currentDiscount = 0;
                              _discount_percent = "0";
                              allowCashDiscount = true;
                              allowPercentDiscount = true;
                              discount_been_made = false;
                              break;
                            case OrderStatus_ButtonType.CancelOrder:
                              // here for cancel all order
                              orderItemsId = List.from(getUserItemsId(
                                  order, ItemStatus.AwaitConfirm));
                              order.userOrderStatus = UserOrderStatus.Cancelled;
                              cancel_order = true;
                              callCancelAPI = true;
                              callCancelOrderAPI = true;
                              if (textFiledController.text != null) {
                                orderItem.cancelReason =
                                    textFiledController.text;
                              }
                              orderItem.cancelReason =
                                  create_checkBoxText(orderItem, true);
                              _orderItems.forEach((element) {
                                if (element.itemStatus ==
                                    ItemStatus.AwaitConfirm) {
                                  element.itemStatus = ItemStatus.Cancelled;
                                  element.cancelReason = orderItem.cancelReason;
                                }
                              });
                              returnCancelNotes = orderItem.cancelReason;
                              break;
                            case OrderStatus_ButtonType.ResetTable:
                              if (order.userOrderStatus !=
                                      UserOrderStatus.Cancelled &&
                                  order.userOrderStatus !=
                                      UserOrderStatus.Voided &&
                                  order.userOrderStatus ==
                                      UserOrderStatus.InProgress)
                                order.userOrderStatus =
                                    UserOrderStatus.Completed;

                              reset = true;

                              callResetTableAPI = true;
                              break;
                            case OrderStatus_ButtonType.ServeAll:
                              orderItemsId = (hasKitchenInStore == false)
                                  ? List.from(getUserItemsId(
                                      order, ItemStatus.Preparing))
                                  : List.from(
                                      getUserItemsId(order, ItemStatus.Ready));
                              // _orderItems.forEach((element) {
                              //   if (element.itemStatus ==
                              //       ItemStatus.Preparing) {
                              //     element.itemStatus = ItemStatus.Served;
                              //   }
                              // });
                              hasServedAll = true;
                              callServeAPI = true;
                              break;
                            case OrderStatus_ButtonType.ReturnAll:
                              orderItemsId = List.from(
                                  getUserItemsId(order, ItemStatus.Served));
                              if (textFiledController.text != null) {
                                orderItem.returnReason =
                                    textFiledController.text;
                              }
                              orderItem.returnReason =
                                  create_checkBoxText(orderItem, true);
                              _orderItems.forEach((element) {
                                if (element.itemStatus == ItemStatus.Served) {
                                  element.itemStatus = ItemStatus.Returned;
                                  element.returnReason = orderItem.returnReason;
                                }
                              });

                              returnCancelNotes = orderItem.returnReason;

                              order.userOrderStatus = UserOrderStatus.Voided;

                              _discount_percent = "0";
                              allowCashDiscount = true;
                              allowPercentDiscount = true;
                              discount_been_made = false;

                              cash_payment_amount = 0;
                              iscashPayment = false;
                              card_payment_amount = 0;
                              iscardPayment = false;

                              callReturnAPI = true;
                              break;
                          }

                          // if (textFiledController.text != null &&
                          //     !cancel_order &&
                          //     !atPaymentPage)
                          //   orderItem.note = textFiledController.text;
                          // if (!cancel_order && !atPaymentPage)
                          //   orderItem.note = create_checkBoxText(orderItem);

                          if (order.userOrderStatus ==
                              UserOrderStatus.Cancelled) {
                            order.paymentStatus = OrderPaymentStatus.Cancelled;
                            // Provider.of<Current_OrderStatus_Provider>(context,listen:false).setPaymentStatus(context,OrderPaymentStatus.Cancelled);
                          }

                          if (order.userOrderStatus == UserOrderStatus.Voided) {
                            order.paymentStatus = OrderPaymentStatus.Voided;
                            // Provider.of<Current_OrderStatus_Provider>(context,listen:false).setPaymentStatus(context,OrderPaymentStatus.Voided);
                          }

                          if (reset) {
                            print('reset table');
                            if (isActiveOrder) {
                              // isActiveOrder = false;
                              order.userOrderStatus = UserOrderStatus.Completed;
                              Provider.of<Current_OrderStatus_Provider>(context,
                                      listen: false)
                                  .setIsActive(false);
                              order.orderCompleteDateTimeUTC =
                                  DateTime.now().toUtc();
                              Provider.of<OrderListProvider>(context,
                                      listen: false)
                                  .removeItemFromActiveOrder(order);
                              Provider.of<OrderListProvider>(context,
                                      listen: false)
                                  .addHistoryOrder(order);
                              hasReseted = true;
                            }
                          }
                        });

                        // if(orderItem.returnReason!=null){
                        //   returnCancelNoes=orderItem.returnReason;
                        // }
                        // if(orderItem.cancelReason!=null){
                        //   returnCancelNotes=orderItem.cancelReason;
                        // }

                        Navigator.pop(context);

                        if (order.paymentSuccessful &&
                            textFiledController.text.length > 0)
                          await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                double paidAmount = 0;
                                try {
                                  paidAmount =
                                      double.parse(textFiledController.text);
                                } catch (e) {
                                  return Container();
                                }
                                return CustomDialog(
                                  title:
                                      '${AppLocalizationHelper.of(context).translate('PaymentSuccessful')}',
                                  insideButtonList: [
                                    CustomDialogInsideButton(
                                        buttonName:
                                            '${AppLocalizationHelper.of(context).translate('Confirm')}',
                                        buttonColor: appThemeColor,
                                        buttonEvent: () {
                                          textFiledController.clear();

                                          Navigator.pop(context);
                                        }),
                                  ],
                                  child: Container(
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                        Text(
                                          '${AppLocalizationHelper.of(context).translate('PaidAmount')}: \$${paidAmount.toStringAsFixed(2)}',
                                          // textAlign: TextAlign.center,
                                          style: GoogleFonts.lato(
                                              fontWeight: FontWeight.normal,
                                              color: Colors.black,
                                              height: 2,
                                              textStyle: GoogleFonts.lato(
                                                fontSize: SizeHelper
                                                        .isMobilePortrait
                                                    ? 2 *
                                                        SizeHelper
                                                            .textMultiplier
                                                    : (SizeHelper.isPortrait)
                                                        ? 2 *
                                                            SizeHelper
                                                                .textMultiplier
                                                        : 2.5 *
                                                            SizeHelper
                                                                .textMultiplier,
                                              )),
                                        ),
                                        Text(
                                          '${AppLocalizationHelper.of(context).translate('Changes')}: \$${(paidAmount - outStandingPayment + currentDiscount).toStringAsFixed(2)}',
                                          // textAlign: TextAlign.center,
                                          style: GoogleFonts.lato(
                                              fontWeight: FontWeight.normal,
                                              color: Colors.black,
                                              height: 2,
                                              textStyle: GoogleFonts.lato(
                                                fontSize: SizeHelper
                                                        .isMobilePortrait
                                                    ? 2 *
                                                        SizeHelper
                                                            .textMultiplier
                                                    : (SizeHelper.isPortrait)
                                                        ? 2 *
                                                            SizeHelper
                                                                .textMultiplier
                                                        : 2.5 *
                                                            SizeHelper
                                                                .textMultiplier,
                                              )),
                                        ),
                                      ])),
                                );
                              });

                        textFiledController.clear();

                        if (order.paymentSuccessful) {
                          setState(() {
                            currentDiscount = 0;
                            _discount_percent = "0";
                            allowCashDiscount = true;
                            allowPercentDiscount = true;
                            discount_been_made = false;
                          });
                        }

                        await callAPI(orderItemsId, returnCancelNotes);
                      })
                ],
                child: Container(
                  child: Column(children: [
                    create_alert_msg(),
                    create_dialog_content(button, label, icon),
                    if (button.buttonType ==
                            OrderStatus_ButtonType.CancelItem ||
                        button.buttonType == OrderStatus_ButtonType.CancelOrder)
                      create_checkBox(
                          'Out of stock', context, orderItem, button),
                    if (button.buttonType ==
                            OrderStatus_ButtonType.CancelItem ||
                        button.buttonType == OrderStatus_ButtonType.CancelOrder)
                      create_checkBox(
                          'Customer requests', context, orderItem, button),
                    if (button.buttonType ==
                            OrderStatus_ButtonType.ReturnItem ||
                        button.buttonType == OrderStatus_ButtonType.ReturnAll)
                      create_checkBox('Exchange', context, orderItem, button),
                    if (button.buttonType ==
                            OrderStatus_ButtonType.ReturnItem ||
                        button.buttonType == OrderStatus_ButtonType.ReturnAll)
                      create_checkBox('Spolied', context, orderItem, button),
                  ]),
                ));
          });
    }

    Widget create_button(Order order, OrderItem orderItem,
        OrderStatus_Button button, Color color) {
      return Container(
        // height:(ScreenHelper.isLandScape(context)?MediaQuery.of(context).size.height*0.08:MediaQuery.of(context).size.height*0.07),
        // width:(ScreenHelper.isLandScape(context)?MediaQuery.of(context).size.width*0.5:MediaQuery.of(context).size.width*0.5),
        child: Expanded(
          flex: 5,
          child: Padding(
            padding: EdgeInsets.all(ScreenUtil().setWidth(10)),
            child: RaisedButton(
              onPressed: () {
                setState(() {
                  ConfirmationDialog(orderItem, button, null, null);
                });
              },
              textColor: Colors.white,
              color: color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "${button.label}",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                        fontSize: SizeHelper.isMobilePortrait
                            ? 2 * SizeHelper.textMultiplier
                            : (SizeHelper.isPortrait)
                                ? 2.5 * SizeHelper.textMultiplier
                                : 1.5 * SizeHelper.textMultiplier,
                        // fontSize: ScreenUtil().setSp(60),
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    }

    Widget create_main_content(Order order, OrderItem orderItem) {
      // if (order.userOrderStatus == UserOrderStatus.Cancelled) {
      //   orderItem.itemStatus = ItemStatus.Cancelled;
      //   order.paymentStatus = OrderPaymentStatus.Cancelled;
      //   // Provider.of<Current_OrderStatus_Provider>(context,listen:false).setPaymentStatus(context,OrderPaymentStatus.Cancelled);
      // }

      // if (order.userOrderStatus == UserOrderStatus.AwaitingConfirmation &&
      //     !has_confirm_one) {
      //   orderItem.itemStatus = ItemStatus.AwaitingConfirmation;
      // }

      String dollarSign = String.fromCharCodes(new Runes('\u0024'));

      Color text_color = Colors.black;
      TextDecoration textDecoration = null;

      if (order.userOrderStatus == UserOrderStatus.Cancelled) {
        orderItem.itemStatus = ItemStatus.Cancelled;
      }

      if (orderItem.itemStatus == ItemStatus.Cancelled) {
        text_color = Colors.red;
        textDecoration = TextDecoration.lineThrough;
      }

      if (orderItem.itemStatus == ItemStatus.Returned) {
        text_color = Colors.purple[400];
        textDecoration = TextDecoration.lineThrough;
      }

      // bool hasReturnReason = false;
      // bool hasCancelReason = false;

      String note;

      if (orderItem.returnReason != null && orderItem.returnReason.length > 0) {
        // hasReturnReason = true;
        // hasCancelReason = false;
        note = orderItem.returnReason;
      }
      if (orderItem.cancelReason != null && orderItem.cancelReason.length > 0) {
        // hasCancelReason = true;
        // hasReturnReason = false;
        note = orderItem.cancelReason;
      }

      return Container(
        padding: EdgeInsets.fromLTRB(10, 10, 0, 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              // mainAxisSize: MainAxisSize.min,
              children: [
                // Item name, quantity and price: e.g: Coke x2 $6.0
                if (orderItem.menuItem != null &&
                    orderItem.menuItem.menuItemName != null)
                  Container(
                    alignment: Alignment.centerLeft,
                    width: ScreenHelper.isLandScape(context)
                        ? SizeHelper.textMultiplier * 20
                        : SizeHelper.textMultiplier * 20,
                    child: create_text('${orderItem.menuItem.menuItemName}',
                        FontWeight.normal, text_color, textDecoration),
                  ),
                if (orderItem.price != null)
                  Container(
                    child: create_text('x${orderItem.quantity.toString()}',
                        FontWeight.normal, text_color, textDecoration),
                  ),

                WEmptyView(250),
                if (orderItem.price != null && orderItem.quantity != null)
                  Container(
                    // width: ScreenUtil().setWidth(200),
                    child: create_text(
                        '${dollarSign}${orderItem.price.toStringAsFixed(2)}',
                        FontWeight.normal,
                        text_color,
                        textDecoration),
                  ),

                //OrderItem progress bar
                // if (orderItem.menuItem != null)
                //   Column(
                //     children: [
                //       Container(
                //         margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                //         // height: ScreenUtil().setSp((ScreenHelper.isLandScape(
                //         //         context)
                //         //     ? MediaQuery.of(context).size.height * 0.025
                //         //     : (SizeHelper.isMobilePortrait)
                //         //         ? MediaQuery.of(context).size.height * 0.065
                //         //         : MediaQuery.of(context).size.height * 0.03)),
                //         width: (ScreenHelper.isLandScape(context)
                //             ? 47 * SizeHelper.widthMultiplier * 0.33
                //             : (SizeHelper.isMobilePortrait)
                //                 ? MediaQuery.of(context).size.width * 0.3
                //                 : MediaQuery.of(context).size.width * 0.2),
                //         color: determine_status_color(
                //             null, orderItem), //Container color
                //         child: Text(
                //           // TODO change text here
                //           '${AppLocalizationHelper.of(context).translate('ItemStatus' + orderItem.itemStatus.toString().split('.')[1])}',
                //           textAlign: TextAlign.center,
                //           style: GoogleFonts.lato(
                //             fontSize: SizeHelper.isMobilePortrait
                //                 ? 2 * SizeHelper.textMultiplier
                //                 : (SizeHelper.isPortrait)
                //                     ? 2 * SizeHelper.textMultiplier
                //                     : 1.5 * SizeHelper.textMultiplier,
                //             // fontSize: ScreenUtil().setSp((ScreenHelper.isLandScape(context)?MediaQuery.of(context).size.height*0.019:MediaQuery.of(context).size.height*0.02)),
                //             fontWeight: FontWeight.bold,
                //             color: Colors.white,
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (orderItem.menuItem != null &&
                    orderItem.menuItem.menuItemName != null)
                  Container(
                    alignment: Alignment.centerLeft,
                    width: ScreenHelper.isLandScape(context)
                        ? SizeHelper.textMultiplier * 20
                        : SizeHelper.textMultiplier * 20,
                    child: create_text('${orderItem.menuItem.subtitle}',
                        FontWeight.normal, text_color, textDecoration),
                  ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Add-on items
                Container(
                  margin: const EdgeInsets.fromLTRB(42, 0, 0, 0),
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: Text(
                    create_addon_text(orderItem),
                    style: GoogleFonts.lato(
                        fontSize: ScreenUtil()
                            .setSp(ScreenHelper.isLandScape(context) ? 20 : 30),
                        fontWeight: FontWeight.normal,
                        color: text_color,
                        textStyle: TextStyle(
                          decoration: (orderItem.itemStatus ==
                                      ItemStatus.Cancelled ||
                                  orderItem.itemStatus == ItemStatus.Returned)
                              ? TextDecoration.lineThrough
                              : null,
                        )),
                  ),
                ),

                // Row(
                //   mainAxisAlignment: MainAxisAlignment.end,
                //   children: [
                //     /// item operation button here
                //     /// eg: Serve Print
                //     if (order.userOrderStatus != UserOrderStatus.Cancelled &&
                //         order.userOrderStatus != UserOrderStatus.Voided &&
                //         orderItem.itemStatus == ItemStatus.AwaitConfirm &&
                //         isActiveOrder &&
                //         Provider.of<Current_OrderStatus_Provider>(context,
                //                 listen: false)
                //             .isAllowUpdateOrder)
                //       Container(
                //         child: Row(
                //           children: [
                //             // if (orderItem.itemStatus != ItemStatus.Preparing &&
                //             //     order.orderType != OrderType.PickUp)
                //             //   GestureDetector(
                //             //     onTap: () {
                //             //       print('Cancel Item');
                //             //       ConfirmationDialog(
                //             //           orderItem,
                //             //           new OrderStatus_Button(
                //             //               buttonType:
                //             //                   OrderStatus_ButtonType.CancelItem,
                //             //               label: 'Cancel Item'),
                //             //           '${AppLocalizationHelper.of(context).translate('EnterReturnCancelReason')}',
                //             //           null);
                //             //     },
                //             //     child: Container(
                //             //       margin: const EdgeInsets.fromLTRB(0, 0, 1, 0),
                //             //       height: SizeHelper.isMobilePortrait
                //             //           ? 4 * SizeHelper.heightMultiplier
                //             //           : 3.6 * SizeHelper.widthMultiplier,
                //             //       width: SizeHelper.isMobilePortrait
                //             //           ? 13 * SizeHelper.widthMultiplier
                //             //           : (SizeHelper.isPortrait)
                //             //               ? 10 * SizeHelper.heightMultiplier
                //             //               : 6.5 * SizeHelper.heightMultiplier,
                //             //       decoration: BoxDecoration(
                //             //           border: Border.all(color: Colors.white),
                //             //           borderRadius:
                //             //               BorderRadius.all(Radius.circular(8)),
                //             //           color: Colors.grey),
                //             //       child: Center(
                //             //         child: Text(
                //             //           AppLocalizationHelper.of(context)
                //             //               .translate('Cancel'),
                //             //           textAlign: TextAlign.center,
                //             //           style: GoogleFonts.lato(
                //             //             fontSize: SizeHelper.isMobilePortrait
                //             //                 ? 2 * SizeHelper.textMultiplier
                //             //                 : 1.5 * SizeHelper.textMultiplier,
                //             //             // fontSize: ScreenUtil().setSp(60),
                //             //             fontWeight: FontWeight.bold,
                //             //             color: Colors.white,
                //             //           ),
                //             //         ),
                //             //       ),
                //             //     ),
                //             //   ),

                //           ],
                //         ),
                //       ),
                //     if (orderItem.itemStatus == ItemStatus.AwaitConfirm &&
                //         order.orderType != OrderType.PickUp)
                //       // GestureDetector(
                //       //   onTap: () {
                //       //     ConfirmationDialog(
                //       //         orderItem,
                //       //         new OrderStatus_Button(
                //       //             buttonType:
                //       //                 OrderStatus_ButtonType.Confirm_Single,
                //       //             label: 'Confirm this item'),
                //       //         null,
                //       //         null);
                //       //   },
                //       //   child: Container(
                //       //     margin: (orderItem.itemStatus == ItemStatus.Preparing)
                //       //         ? const EdgeInsets.fromLTRB(0, 0, 3, 0)
                //       //         : const EdgeInsets.fromLTRB(0, 0, 7, 0),

                //       //     height: SizeHelper.isMobilePortrait
                //       //         ? 4 * SizeHelper.heightMultiplier
                //       //         : (SizeHelper.isPortrait)
                //       //             ? 2 * SizeHelper.widthMultiplier
                //       //             : 4 * SizeHelper.widthMultiplier,
                //       //     width: SizeHelper.isMobilePortrait
                //       //         ? 15 * SizeHelper.widthMultiplier
                //       //         : (SizeHelper.isPortrait)
                //       //             ? 6.5 * SizeHelper.heightMultiplier
                //       //             : 6.5 * SizeHelper.heightMultiplier,
                //       //     // height:(ScreenHelper.isLandScape(context)?MediaQuery.of(context).size.height*0.045:MediaQuery.of(context).size.height*0.025),
                //       //     // width:(ScreenHelper.isLandScape(context)?MediaQuery.of(context).size.width*0.125:MediaQuery.of(context).size.width*0.13),
                //       //     decoration: BoxDecoration(
                //       //       border: Border.all(color: Colors.white),
                //       //       borderRadius: BorderRadius.all(Radius.circular(8)),
                //       //       color: Colors.green,
                //       //     ),
                //       //     child: Center(
                //       //       child: Text(
                //       //         AppLocalizationHelper.of(context)
                //       //             .translate('Confirm'),
                //       //         textAlign: TextAlign.center,
                //       //         style: GoogleFonts.lato(
                //       //           fontSize: SizeHelper.isMobilePortrait
                //       //               ? 2 * SizeHelper.textMultiplier
                //       //               : 1.5 * SizeHelper.textMultiplier,
                //       //           // fontSize: ScreenUtil().setSp(60),
                //       //           fontWeight: FontWeight.bold,
                //       //           color: Colors.white,
                //       //         ),
                //       //       ),
                //       //     ),
                //       //   ),
                //       // ),

                //     // if ((orderItem.itemStatus == ItemStatus.Ready &&
                //     //         order.orderType != OrderType.PickUp) ||
                //     //     (orderItem.itemStatus == ItemStatus.Preparing &&
                //     //         hasKitchenInStore == false))
                //     //   GestureDetector(
                //     //     onTap: () {
                //     //       ConfirmationDialog(
                //     //           orderItem,
                //     //           new OrderStatus_Button(
                //     //               buttonType: OrderStatus_ButtonType.ServeItem,
                //     //               label: 'Serve Item'),
                //     //           null,
                //     //           null);
                //     //     },
                //     //     child: Container(
                //     //       margin: const EdgeInsets.fromLTRB(0, 0, 7, 0),

                //     //       height: SizeHelper.isMobilePortrait
                //     //           ? 4 * SizeHelper.heightMultiplier
                //     //           : (SizeHelper.isPortrait)
                //     //               ? 2 * SizeHelper.widthMultiplier
                //     //               : 4 * SizeHelper.widthMultiplier,
                //     //       width: SizeHelper.isMobilePortrait
                //     //           ? 12 * SizeHelper.widthMultiplier
                //     //           : (SizeHelper.isPortrait)
                //     //               ? 6.5 * SizeHelper.heightMultiplier
                //     //               : 6.5 * SizeHelper.heightMultiplier,
                //     //       // height:(ScreenHelper.isLandScape(context)?MediaQuery.of(context).size.height*0.045:MediaQuery.of(context).size.height*0.025),
                //     //       // width:(ScreenHelper.isLandScape(context)?MediaQuery.of(context).size.width*0.125:MediaQuery.of(context).size.width*0.13),
                //     //       decoration: BoxDecoration(
                //     //         border: Border.all(color: Colors.white),
                //     //         borderRadius: BorderRadius.all(Radius.circular(8)),
                //     //         color: Colors.green,
                //     //       ),
                //     //       child: Center(
                //     //         child: Text(
                //     //           AppLocalizationHelper.of(context)
                //     //               .translate('Serve'),
                //     //           textAlign: TextAlign.center,
                //     //           style: GoogleFonts.lato(
                //     //             fontSize: SizeHelper.isMobilePortrait
                //     //                 ? 2 * SizeHelper.textMultiplier
                //     //                 : 1.5 * SizeHelper.textMultiplier,
                //     //             // fontSize: ScreenUtil().setSp(60),
                //     //             fontWeight: FontWeight.bold,
                //     //             color: Colors.white,
                //     //           ),
                //     //         ),
                //     //       ),
                //     //     ),
                //     //   ),

                //     // if ((orderItem.itemStatus == ItemStatus.Preparing) &&
                //     //     Provider.of<Current_OrderStatus_Provider>(context,
                //     //             listen: false)
                //     //         .isAllowUpdateOrder)
                //     //   GestureDetector(
                //     //     onTap: () async {
                //     //       setState(() {
                //     //         _inAsyncCall = true;
                //     //       });
                //     //       print('Open Print Single Item Page');
                //     //       var ticket = await PrinterHelper()
                //     //           .singleOrderItemTicket(order, orderItem, context);
                //     //       await _printerHelper.startPrint(ticket, context);
                //     //       setState(() {
                //     //         _inAsyncCall = false;
                //     //       });
                //     //     },
                //     //     child: Container(
                //     //       margin: const EdgeInsets.fromLTRB(0, 0, 7, 0),
                //     //       height: SizeHelper.isMobilePortrait
                //     //           ? 3.5 * SizeHelper.heightMultiplier
                //     //           : (SizeHelper.isPortrait)
                //     //               ? 3 * SizeHelper.widthMultiplier
                //     //               : 3.6 * SizeHelper.widthMultiplier,
                //     //       width: SizeHelper.isMobilePortrait
                //     //           ? 10 * SizeHelper.widthMultiplier
                //     //           : (SizeHelper.isPortrait)
                //     //               ? 10 * SizeHelper.heightMultiplier
                //     //               : (SizeHelper.isPortrait)
                //     //                   ? 6.5 * SizeHelper.heightMultiplier
                //     //                   : 5.5 * SizeHelper.heightMultiplier,
                //     //       decoration: BoxDecoration(
                //     //         border: Border.all(color: Colors.grey),
                //     //         borderRadius: BorderRadius.all(Radius.circular(8)),
                //     //         color: Colors.white,
                //     //       ),
                //     //       child: Center(
                //     //         child: Text(
                //     //           AppLocalizationHelper.of(context)
                //     //               .translate('Print'),
                //     //           textAlign: TextAlign.center,
                //     //           style: GoogleFonts.lato(
                //     //             fontSize: SizeHelper.isMobilePortrait
                //     //                 ? 1.5 * SizeHelper.textMultiplier
                //     //                 : 1.5 * SizeHelper.textMultiplier,
                //     //             // fontSize: SizeHelper.isMobilePortrait?1.8*SizeHelper.textMultiplier:SizeHelper.textMultiplier,
                //     //             // fontSize: ScreenUtil().setSp(60),
                //     //             fontWeight: FontWeight.bold,
                //     //             color: Colors.black,
                //     //           ),
                //     //         ),
                //     //       ),
                //     //     ),
                //     //   ),

                //   //  if (
                //     // order.userOrderStatus != UserOrderStatus.Voided &&
                //     //   order.userOrderStatus != UserOrderStatus.Cancelled &&
                //     // orderItem.itemStatus == ItemStatus.Served &&
                //     //     order.userOrderStatus == UserOrderStatus.InProgress &&
                //     //     isActiveOrder &&
                //     //     !callResetTableAPI &&
                //     //     order.orderType != OrderType.PickUp &&
                //     //     Provider.of<Current_OrderStatus_Provider>(context,
                //     //             listen: false)
                //     //         .isAllowUpdateOrder)
                //     //   Container(
                //     //       child: Row(
                //     //     children: [
                //     //       GestureDetector(
                //     //         onTap: () {
                //     //           print('Return Item');
                //     //           ConfirmationDialog(
                //     //               orderItem,
                //     //               new OrderStatus_Button(
                //     //                   buttonType:
                //     //                       OrderStatus_ButtonType.ReturnItem,
                //     //                   label: 'Return Item'),
                //     //               '${AppLocalizationHelper.of(context).translate('EnterReturnCancelReason')}',
                //     //               null);
                //     //         },
                //     //         child: Container(
                //     //           margin: const EdgeInsets.fromLTRB(0, 0, 7, 0),
                //     //           height: SizeHelper.isMobilePortrait
                //     //               ? 3 * SizeHelper.heightMultiplier
                //     //               : 3.6 * SizeHelper.widthMultiplier,
                //     //           width: (SizeHelper.isMobilePortrait
                //     //               ? 20 * SizeHelper.widthMultiplier
                //     //               : 22 * SizeHelper.widthMultiplier),
                //     //           // height:(ScreenHelper.isLandScape(context)?MediaQuery.of(context).size.height*0.045:MediaQuery.of(context).size.height*0.025),
                //     //           // width:(ScreenHelper.isLandScape(context)?MediaQuery.of(context).size.width*0.255:MediaQuery.of(context).size.width*0.265),
                //     //           decoration: BoxDecoration(
                //     //             border: Border.all(color: Colors.white),
                //     //             borderRadius:
                //     //                 BorderRadius.all(Radius.circular(8)),
                //     //             color: Colors.purple[400],
                //     //           ),
                //     //           child: Center(
                //     //             child: Text(
                //     //               AppLocalizationHelper.of(context)
                //     //                   .translate('Return'),
                //     //               textAlign: TextAlign.center,
                //     //               style: GoogleFonts.lato(
                //     //                 fontSize: SizeHelper.isMobilePortrait
                //     //                     ? 1.8 * SizeHelper.textMultiplier
                //     //                     : 1.5 * SizeHelper.textMultiplier,
                //     //                 // fontSize: ScreenUtil().setSp(60),
                //     //                 fontWeight: FontWeight.bold,
                //     //                 color: Colors.white,
                //     //               ),
                //     //             ),
                //     //           ),
                //     //         ),
                //     //       ),
                //     //     ],
                //     //   )),

                //     if (orderItem.itemStatus == ItemStatus.Returned ||
                //         orderItem.itemStatus == ItemStatus.Cancelled)
                //       Container(
                //         margin: const EdgeInsets.fromLTRB(0, 9, 10, 10),
                //         padding: const EdgeInsets.fromLTRB(0, 6, 0, 0),
                //         height: ((note != null && note.length > 10) ||
                //                 (note != null &&
                //                     ScreenHelper.isLandScape(context)))
                //             ? MediaQuery.of(context).size.height * 0.10
                //             : MediaQuery.of(context).size.height * 0.1,
                //         width: ScreenHelper.isLandScape(context)
                //             ? 11 * SizeHelper.textMultiplier
                //             : (SizeHelper.isMobilePortrait)
                //                 ? 15 * SizeHelper.textMultiplier
                //                 : 20 * SizeHelper.textMultiplier,
                //         color: Colors.grey[300], //Container color
                //         child: Row(
                //           mainAxisAlignment: MainAxisAlignment.center,
                //           // crossAxisAlignment: CrossAxisAlignment.center,
                //           children: [
                //             Text(
                //               (note == null) ? "" : '${note}',
                //               textAlign: TextAlign.center,
                //               style: GoogleFonts.lato(
                //                 fontSize: SizeHelper.isMobilePortrait
                //                     ? 2.0 * SizeHelper.textMultiplier
                //                     : 1.2 * SizeHelper.textMultiplier,
                //                 // fontSize: ScreenUtil().setSp(60),
                //                 fontWeight: FontWeight.normal,
                //                 color: Colors.black87,
                //               ),
                //             ),
                //           ],
                //         ),
                //       ),

                //   ],
                // )
              ],
            ),
          ],
        ),
      );
    }

    Widget createExtraOrderContainer(ExtraOrder extraOrder) {
      return Container(
        // padding: const EdgeInsets.fromLTRB(20,10,0,20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            create_datetime_bar(
                '${AppLocalizationHelper.of(context).translate('ExtraOrderTitle')}:',
                null,
                extraOrder),
            create_note_container(extraOrder.note),
            for (int i = extraOrder.userItems.length - 1; i >= 0; i--)
              if (extraOrder.userItems[i] != null)
                create_main_content(order, extraOrder.userItems[i]),
          ],
        ),
      );
    }

    Widget create_payment_container(Order order, OrderItem orderItem,
        OrderStatus_Button button, String label, Color color) {
      return InkWell(
        onTap: () {
          //TODO: Cash/Card payment
          print(label);
          switch (label) {
            case 'Discount %':
              if (allowPercentDiscount && !discount_been_made)
                ConfirmationDialog(
                    orderItem, button, "", FontAwesomeIcons.percent);
              break;
            case 'Discount \$':
              if (allowCashDiscount && !discount_been_made)
                ConfirmationDialog(
                    orderItem, button, "", FontAwesomeIcons.dollarSign);
              break;
            case 'Cash':
              ConfirmationDialog(
                  orderItem, button, "", FontAwesomeIcons.dollarSign);
              break;
            case 'Card':
              ConfirmationDialog(
                  orderItem, button, "", FontAwesomeIcons.creditCard);
              break;
          }
        },
        child: Container(
          width: SizeHelper.isMobilePortrait
              ? 20 * SizeHelper.heightMultiplier
              : SizeHelper.isPortrait
                  ? 40 * SizeHelper.widthMultiplier
                  : 35 * SizeHelper.widthMultiplier,
          height: SizeHelper.isMobilePortrait
              ? 10 * SizeHelper.heightMultiplier
              : SizeHelper.isPortrait
                  ? 20 * SizeHelper.widthMultiplier
                  : 15 * SizeHelper.widthMultiplier,
          margin: const EdgeInsets.fromLTRB(10, 0, 0, 10),
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: color,
          ),
          child: Text(
            '${AppLocalizationHelper.of(context).translate(label)}',
            style: GoogleFonts.lato(
              fontSize: SizeHelper.isMobilePortrait
                  ? 2 * SizeHelper.textMultiplier
                  : (SizeHelper.isPortrait)
                      ? 2 * SizeHelper.textMultiplier
                      : 2 * SizeHelper.textMultiplier,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1,
            ),
          ),
          // child: InkWell(
          //   onTap: () {
          //     //TODO: Cash/Card payment
          //     print(label);
          //     switch (label) {
          //       case 'Discount %':
          //         if (percent_discount && !discount_been_made)
          //           ConfirmationDialog(
          //               orderItem, button, "", FontAwesomeIcons.percent);
          //         break;
          //       case 'Discount \$':
          //         if (cash_discount && !discount_been_made)
          //           ConfirmationDialog(
          //               orderItem, button, "", FontAwesomeIcons.dollarSign);
          //         break;
          //       case 'Cash':
          //         ConfirmationDialog(
          //             orderItem, button, "", FontAwesomeIcons.dollarSign);
          //         break;
          //       case 'Card':
          //         ConfirmationDialog(
          //             orderItem, button, "", FontAwesomeIcons.creditCard);
          //         break;
          //     }
          //   },
          // child: Text(
          //   label,
          //   style: GoogleFonts.lato(
          //     fontSize: ScreenUtil().setSp(SizeHelper.isMobilePortrait
          //         ? 6 * SizeHelper.textMultiplier
          //         : (SizeHelper.isPortrait)
          //             ? 2 * SizeHelper.textMultiplier
          //             : 2 * SizeHelper.textMultiplier),
          //     fontWeight: FontWeight.bold,
          //     color: Colors.white,
          //     height: 1,
          //   ),
          // ),
          // ),
        ),
      );
    }

    Widget orderStatusListView(Current_OrderStatus_Provider provider) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (!atPaymentPage)
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //Order Number Container
                Container(
                  margin: EdgeInsets.fromLTRB(
                      10, ScreenHelper.isLandScape(context) ? 0 : 10, 10, 0),
                  height: SizeHelper.isMobilePortrait
                      ? 5 * SizeHelper.heightMultiplier
                      : 10 * SizeHelper.widthMultiplier,
                  child: create_text(
                      '${AppLocalizationHelper.of(context).translate('OrderNumber')}: ${order.userOrderId}',
                      FontWeight.bold,
                      Colors.black,
                      null),
                ),
                //Status Container
                if (order.userOrderStatus != UserOrderStatus.InProgress)
                  Container(
                    margin: EdgeInsets.fromLTRB(
                        0, 0, 10, ScreenHelper.isLandScape(context) ? 0 : 15),
                    // height: ScreenUtil().setSp(
                    //     SizeHelper.isMobilePortrait
                    //         ? 10 * SizeHelper.heightMultiplier
                    //         : 3 * SizeHelper.widthMultiplier),
                    width: SizeHelper.isMobilePortrait
                        ? 25 * SizeHelper.widthMultiplier
                        : (SizeHelper.isPortrait)
                            ? 13 * SizeHelper.heightMultiplier
                            : 12 * SizeHelper.heightMultiplier,
                    // height:(ScreenHelper.isLandScape(context)?MediaQuery.of(context).size.height*0.05:MediaQuery.of(context).size.height*0.025),
                    // width:(ScreenHelper.isLandScape(context)?MediaQuery.of(context).size.width*0.45:MediaQuery.of(context).size.width*0.26),
                    color:
                        determine_status_color(order, null), //Container color
                    child: Center(
                      child: Text(
                        '${AppLocalizationHelper.of(context).translate(order.userOrderStatus.toString().split('.')[1])}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(
                          fontSize: SizeHelper.isMobilePortrait
                              ? 1.8 * SizeHelper.textMultiplier
                              : 1.5 * SizeHelper.textMultiplier,
                          // fontSize: ScreenUtil().setSp((ScreenHelper.isLandScape(context)?MediaQuery.of(context).size.height*0.019:MediaQuery.of(context).size.height*0.02)),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                if (order.userOrderStatus == UserOrderStatus.InProgress)
                  Container(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.fromLTRB(0, 0, 10, 10),
                          height: SizeHelper.isMobilePortrait
                              ? 3 * SizeHelper.heightMultiplier
                              : (SizeHelper.isPortrait)
                                  ? 3.5 * SizeHelper.widthMultiplier
                                  : 4 * SizeHelper.widthMultiplier,
                          width: (SizeHelper.isMobilePortrait
                              ? 17 * SizeHelper.widthMultiplier
                              : (SizeHelper.isPortrait)
                                  ? 13 * SizeHelper.heightMultiplier
                                  : 10 * SizeHelper.heightMultiplier),
                          // height:(ScreenHelper.isLandScape(context)?MediaQuery.of(context).size.height*0.04:MediaQuery.of(context).size.height*0.025),
                          // width:(ScreenHelper.isLandScape(context)?MediaQuery.of(context).size.width*0.2:MediaQuery.of(context).size.width*0.26),
                          color: determine_status_color(
                              order, null), //Container color
                          child: Center(
                            child: Text(
                              '${AppLocalizationHelper.of(context).translate(order.userOrderStatus.toString().split('.')[1])}',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lato(
                                fontSize: SizeHelper.isMobilePortrait
                                    ? 1.5 * SizeHelper.textMultiplier
                                    : (SizeHelper.isPortrait)
                                        ? 2 * SizeHelper.textMultiplier
                                        : 1.5 * SizeHelper.textMultiplier,
                                // fontSize: ScreenUtil().setSp(60),
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        if (!hasServedAll && provider.isAllowUpdateOrder)
                          GestureDetector(
                            onTap: () async {
                              setState(() {
                                _inAsyncCall = true;
                              });
                              print('Open Print Current Order Page');
                              bool toKitchen = true;
                              var ticket = await PrinterHelper()
                                  .singleOrderTicket(context, order, toKitchen);
                              await _printerHelper.startPrint(ticket, context);
                              setState(() {
                                _inAsyncCall = false;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.fromLTRB(0, 0, 7, 15),
                              height: SizeHelper.isMobilePortrait
                                  ? 3 * SizeHelper.heightMultiplier
                                  : (SizeHelper.isPortrait)
                                      ? 3.5 * SizeHelper.widthMultiplier
                                      : 4 * SizeHelper.widthMultiplier,
                              width: SizeHelper.isMobilePortrait
                                  ? 15 * SizeHelper.widthMultiplier
                                  : 8 * SizeHelper.heightMultiplier,
                              // height:(ScreenHelper.isLandScape(context)?MediaQuery.of(context).size.height*0.04:MediaQuery.of(context).size.height*0.025),
                              // width:(ScreenHelper.isLandScape(context)?MediaQuery.of(context).size.width*0.1:MediaQuery.of(context).size.width*0.1),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                color: Colors.white,
                              ),
                              child: Center(
                                child: Text(
                                  AppLocalizationHelper.of(context)
                                      .translate('Print'),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.lato(
                                    fontSize: SizeHelper.isMobilePortrait
                                        ? 1.8 * SizeHelper.textMultiplier
                                        : 1.5 * SizeHelper.textMultiplier,
                                    // fontSize: ScreenUtil().setSp(60),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
              ],
            ),
          ),
          Container(
                  margin: EdgeInsets.fromLTRB(
                      10, ScreenHelper.isLandScape(context) ? 0 : 10, 10, 0),
                  height: SizeHelper.isMobilePortrait
                      ? 12 * SizeHelper.heightMultiplier
                      : 10 * SizeHelper.widthMultiplier,
                  child: create_text(
                      'Contact: ${order.user?.userName} ${order.user?.phone}',
                      FontWeight.bold,
                      Colors.black,
                      null),
                ),
        Container(
          margin: EdgeInsets.fromLTRB(
              10, ScreenHelper.isLandScape(context) ? 0 : 10, 10, 0),
          height: SizeHelper.isMobilePortrait
              ? 5 * SizeHelper.heightMultiplier
              : 10 * SizeHelper.widthMultiplier,
          child: create_text(
              'Contact: ${order.user?.userName} ${order.user?.phone}',
              FontWeight.bold,
              Colors.black,
              null),
        ),
        if (hasExtraOrder && !atPaymentPage)
          for (int i = order.userExtraOrders.length - 1; i >= 0; i--)
            createExtraOrderContainer(order.userExtraOrders[i]),
        if (hasCurrentOrder && !atPaymentPage)
          create_datetime_bar(
              '${AppLocalizationHelper.of(context).translate('Orignial Order Title')}:',
              order,
              null),
        if (hasCurrentOrder && !atPaymentPage)
            create_note_container(order.note),
        if (hasCurrentOrder && !atPaymentPage)
          for (int i = order.userItems.length - 1; i >= 0; i--)
            create_main_content(order, order.userItems[i]),
        if (atPaymentPage && provider.isAllowUpdateOrder)
          Container(
            // alignment: Alignment.center,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                // Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Container(),
                    if (!order.paymentSuccessful)
                      create_text(
                          "${AppLocalizationHelper.of(context).translate('Outstanding Payment')}:",
                          FontWeight.bold,
                          Colors.black,
                          null),
                    if (!order.paymentSuccessful)
                      Container(
                        padding: (discount_been_made)
                            ? EdgeInsets.fromLTRB(
                                0,
                                0,
                                ScreenHelper.isLandScape(context)
                                    ? SizeHelper.heightMultiplier * 2.8
                                    : SizeHelper.widthMultiplier * 6,
                                0)
                            : EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: create_text(
                            "\t${dollarSign} ${getOutStandingPayment(order).toStringAsFixed(2)}",
                            FontWeight.bold,
                            Colors.black,
                            null),
                      ),
                  ],
                ),
                if (currentDiscount != 0 &&
                    !order.paymentSuccessful &&
                    provider.isAllowUpdateOrder)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      (allowCashDiscount)
                          ? create_text(
                              "${AppLocalizationHelper.of(context).translate('Discount')}:",
                              FontWeight.bold,
                              Colors.red,
                              null)
                          : create_text(
                              "${AppLocalizationHelper.of(context).translate('Discount')} ${_discount_percent}%:",
                              FontWeight.bold,
                              Colors.red,
                              null),
                      Row(
                        children: [
                          create_text(
                              "-${dollarSign} ${order.discount.toStringAsFixed(2)}",
                              FontWeight.bold,
                              Colors.red,
                              null),
                          if (!order.paymentSuccessful &&
                              provider.isAllowUpdateOrder)
                            Container(
                              height: ScreenHelper.isLandScape(context)
                                  ? 4 * SizeHelper.imageSizeMultiplier
                                  : 6 * SizeHelper.imageSizeMultiplier,
                              width: ScreenHelper.isLandScape(context)
                                  ? 4 * SizeHelper.imageSizeMultiplier
                                  : 6 * SizeHelper.imageSizeMultiplier,
                              padding: const EdgeInsets.fromLTRB(5, 5, 0, 0),
                              child: ClipOval(
                                child: Material(
                                  color: Colors.red, // button color
                                  child: InkWell(
                                    // splashColor: Colors.red, // inkwell color
                                    child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: Icon(
                                            FontAwesomeIcons.windowClose,
                                            color: Colors.white,
                                            size: ScreenHelper.isLandScape(
                                                    context)
                                                ? 2 *
                                                    SizeHelper
                                                        .imageSizeMultiplier
                                                : 13)),
                                    onTap: () {
                                      setState(() {
                                        currentDiscount = 0;
                                        _discount_percent = "0";
                                        allowCashDiscount = true;
                                        allowPercentDiscount = true;
                                        discount_been_made = false;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            )
                        ],
                      ),
                      // Container(
                      //   margin: (!order.paymentSuccessful)
                      //       ? const EdgeInsets.fromLTRB(0, 0, 5, 0)
                      //       : const EdgeInsets.fromLTRB(0, 0, 25, 0),
                      // ),
                    ],
                  ),

                if (currentDiscount != 0 &&
                    !order.paymentSuccessful &&
                    provider.isAllowUpdateOrder)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      create_text(
                          "${AppLocalizationHelper.of(context).translate('Grand Total(incl GST)')}:",
                          FontWeight.bold,
                          Colors.black,
                          null),
                      Container(
                        padding: (discount_been_made)
                            ? EdgeInsets.fromLTRB(
                                0,
                                0,
                                ScreenHelper.isLandScape(context)
                                    ? SizeHelper.heightMultiplier * 2.8
                                    : SizeHelper.widthMultiplier * 6,
                                0)
                            : EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: create_text(
                            "${dollarSign} ${(getOutStandingPayment(order) - currentDiscount).toStringAsFixed(2)}",
                            FontWeight.bold,
                            Colors.black,
                            null),
                      ),
                    ],
                  ),
              ],
            ),
          ),
      ]);
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: Provider.of<Current_OrderStatus_Provider>(context, listen: false)
              .showAppBar
          ? AppBar(
              leading: GestureDetector(
                onTap: () {
                  Provider.of<Current_OrderStatus_Provider>(context,
                          listen: false)
                      .setOrder(context, null, false);
                  Provider.of<Current_OrderStatus_Provider>(context,
                          listen: false)
                      .setOrderStatusType(OrderStatusPageType.none);
                  Navigator.pop(context);
                },
                child: Icon(
                  Icons.arrow_back,
                  size: SizeHelper.isMobilePortrait
                      ? 3 * SizeHelper.textMultiplier
                      : 3 * SizeHelper.textMultiplier,
                ),
              ),
              iconTheme: IconThemeData(
                color: Colors.black,
              ),
              title: Text(
                (!atPaymentPage)
                    ? AppLocalizationHelper.of(context)
                        .translate('OrderStatusTitle')
                    : AppLocalizationHelper.of(context)
                        .translate('PaymentTitle'),
                style: GoogleFonts.lato(
                    fontSize: ScreenHelper.isLandScape(context)
                        ? SizeHelper.textMultiplier * 2.5
                        : SizeHelper.textMultiplier * 2.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              centerTitle: true,
              backgroundColor: Colors.grey[50],
            )
          : null,
      body: ModalProgressHUD(
        inAsyncCall: _inAsyncCall,
        child: OrientationBuilder(builder: (context, orientation) {
          if (callResetTableAPI) {
            callResetTableAPI = false;
            Provider.of<Current_OrderStatus_Provider>(context, listen: false)
                .setOrderAndNotNotify(context, null, false);
            return noOrderSelectedView();
          }

          return Consumer<Current_OrderStatus_Provider>(
            builder: (context, provider, widget) {
              order = provider.getOrder();

              if (provider.getIsResetByOtherDevice()) {
                provider.setIsResetByOtherDevice(false);
                provider.setOrderAndNotNotify(context, null, false);
                return noOrderSelectedView();
              }

              if (order != null) {
                if (order.userOrderId != orderId) {
                  resetVariables();
                  orderId = order.userOrderId;
                  provider.setIsResetByOtherDevice(false);
                }

                isActiveOrder = Provider.of<Current_OrderStatus_Provider>(
                        context,
                        listen: false)
                    .getisActive();

                Provider.of<Current_OrderStatus_Provider>(context,
                        listen: false)
                    .determineOrderStatus(order, isActiveOrder,
                        updateView: false);

                hasExtraOrder = Provider.of<Current_OrderStatus_Provider>(
                        context,
                        listen: false)
                    .getHasExtraOrder();

                _orderItems = Provider.of<Current_OrderStatus_Provider>(context,
                        listen: false)
                    .getOrderItemList(order);

                //calculate_order_totalAmount();

                (order.userItems != null && order.userItems.length != 0)
                    ? hasCurrentOrder = true
                    : hasCurrentOrder = false;

                if (order.userOrderStatus != UserOrderStatus.AwaitConfirm) {
                  has_confirm_all = true;
                  has_confirm_one = true;
                }
              }

              if ((order != null)) {
                return SingleChildScrollView(
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      if (atPaymentPage)
                        VEmptyView((SizeHelper.isMobilePortrait)
                            ? 50 * SizeHelper.heightMultiplier
                            : SizeHelper.isPortrait
                                ? 50 * SizeHelper.widthMultiplier
                                : 10 * SizeHelper.widthMultiplier),
                      if (!atPaymentPage)
                        Container(
                          margin: const EdgeInsets.fromLTRB(20, 15, 20, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              (order.takeAwayId == null)
                                  ? create_text(
                                      order.orderType == OrderType.PickUp
                                          ? 'Pick-Up'
                                          : order.orderType ==
                                                  OrderType.Delivery
                                              ? "Delivery"
                                              : '${AppLocalizationHelper.of(context).translate('Table')}: ${order.table.toString()}',
                                      FontWeight.bold,
                                      Colors.black,
                                      null)
                                  : create_text(
                                      '${AppLocalizationHelper.of(context).translate('TakeAway')}: ${Provider.of<CurrentOrderProvider>(context, listen: false).getTakeAwayIdShortcut(order.takeAwayId.toString())}',
                                      FontWeight.bold,
                                      Colors.black,
                                      null),
                              SizedBox(width: 20),
                              create_text(
                                  '(${DateTime.now().difference(order.orderCreateDateTimeUTC).inMinutes} ${AppLocalizationHelper.of(context).translate('Minutes')})',
                                  FontWeight.normal,
                                  Colors.red,
                                  null),
                              Spacer(),
                              if (!order.paymentSuccessful)
                                create_text(
                                    "${AppLocalizationHelper.of(context).translate('Total')}: ${dollarSign} ${(((order.totalAmount - order.deliveryFee) * pow(10.0, 2)).round().toDouble() / pow(10.0, 2))}",
                                    FontWeight.bold,
                                    Colors.black,
                                    null),
                            ],
                          ),
                        ),

                      //Only display this part when payment successful
                      if (order.paymentSuccessful || !isActiveOrder)
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                margin: EdgeInsets.fromLTRB(20, 0, 10, 5),
                                // padding:
                                //     const EdgeInsets.fromLTRB(0, 5, 0, 0),
                                height: ScreenUtil().setHeight(75),
                                width: ScreenUtil().setWidth(290),
                                color: determine_payment_status_color(
                                    order), //Container color
                                child: Center(
                                  child: Text(
                                    (order.paymentSuccessful != null &&
                                            order.paymentMethod != null)
                                        ? (order.userOrderStatus !=
                                                    UserOrderStatus.Cancelled &&
                                                order.userOrderStatus !=
                                                    UserOrderStatus.Voided)
                                            ? "${AppLocalizationHelper.of(context).translate(order.paymentStatus.toString().split('.')[1])}"
                                            : "${AppLocalizationHelper.of(context).translate(order.paymentStatus.toString().split('.')[1])}"
                                        : (isActiveOrder)
                                            ? '${AppLocalizationHelper.of(context).translate(OrderPaymentStatus.AwaitingPayment.toString().split('.')[1])}'
                                            : "${AppLocalizationHelper.of(context).translate(order.paymentStatus.toString().split('.')[1])}",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.lato(
                                      fontSize: SizeHelper.isMobilePortrait
                                          ? 2 * SizeHelper.textMultiplier
                                          : (SizeHelper.isPortrait)
                                              ? 2 * SizeHelper.textMultiplier
                                              : 1.5 * SizeHelper.textMultiplier,
                                      // fontSize: ScreenUtil().setSp(60),
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              if (order.paymentSuccessful &&
                                  provider.isAllowUpdateOrder)
                                GestureDetector(
                                  onTap: () async {
                                    setState(() {
                                      _inAsyncCall = true;
                                    });
                                    print('Open Print Recepit');
                                    var ticket = await PrinterHelper()
                                        .singleOrderTicket(
                                            context, order, false);
                                    await _printerHelper.startPrint(
                                        ticket, context);
                                    setState(() {
                                      _inAsyncCall = false;
                                    });
                                  },
                                  child: Container(
                                    margin:
                                        const EdgeInsets.fromLTRB(0, 0, 30, 0),
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    height: SizeHelper.isMobilePortrait
                                        ? 3 * SizeHelper.heightMultiplier
                                        : (SizeHelper.isPortrait)
                                            ? 4.5 * SizeHelper.widthMultiplier
                                            : 4.5 * SizeHelper.widthMultiplier,
                                    width: SizeHelper.isMobilePortrait
                                        ? 20 * SizeHelper.widthMultiplier
                                        : (SizeHelper.isPortrait)
                                            ? 20 * SizeHelper.heightMultiplier
                                            : 20 * SizeHelper.heightMultiplier,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8)),
                                      color: Colors.white,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${AppLocalizationHelper.of(context).translate('PrintRceipt')}',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.lato(
                                          fontSize: ScreenUtil().setSp(
                                              SizeHelper.isPortrait ? 33 : 20),
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                      //Only display this part when payment successful
                      if (order.paymentSuccessful || !isActiveOrder)
                        Container(
                          margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                          padding: const EdgeInsets.fromLTRB(10, 5, 10, 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.all(Radius.circular(
                                    10.0) //                 <--- border radius here
                                ),
                            color: Colors.grey[300],
                            // color: color,
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  create_text(
                                      '${AppLocalizationHelper.of(context).translate('Total')}:',
                                      FontWeight.normal,
                                      Colors.black,
                                      null),
                                  create_text(
                                      '\$ ${((order.totalAmount) - order.deliveryFee).toStringAsFixed(2)}',
                                      FontWeight.normal,
                                      Colors.black,
                                      null)
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  create_text(
                                      "${AppLocalizationHelper.of(context).translate('TotalDiscount')}:",
                                      FontWeight.normal,
                                      Colors.red,
                                      null),
                                  create_text(
                                      (order.totalAmount <= 0)
                                          ? '-${dollarSign} 0'
                                          : '-${dollarSign} ${order.discount.toStringAsFixed(2)}',
                                      FontWeight.normal,
                                      Colors.red,
                                      null),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  create_text(
                                      "${AppLocalizationHelper.of(context).translate('Grand Total(incl GST)')}:",
                                      FontWeight.bold,
                                      Colors.black,
                                      null),
                                  create_text(
                                      (order.totalAmount <= 0)
                                          ? '${dollarSign} 0'
                                          : '${dollarSign} ${(order.totalAmount - order.discount - order.deliveryFee).toStringAsFixed(2)}',
                                      FontWeight.normal,
                                      Colors.black,
                                      null),
                                ],
                              ),
                            ],
                          ),
                        ),

                      // if (order.paymentSuccessful || !isActiveOrder)
                      //   Container(
                      //     margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                      //     padding: const EdgeInsets.fromLTRB(10, 5, 10, 10),
                      //     decoration: BoxDecoration(
                      //       border: Border.all(color: Colors.white),
                      //       borderRadius: BorderRadius.all(Radius.circular(
                      //               10.0) //                 <--- border radius here
                      //           ),
                      //       color: Colors.grey[300],
                      //       // color: color,
                      //     ),
                      //     child: Column(
                      //       children: [
                      //         // Row(
                      //         //   mainAxisAlignment:
                      //         //       MainAxisAlignment.spaceBetween,
                      //         //   children: [
                      //         //     create_text(
                      //         //         '${AppLocalizationHelper.of(context).translate('TotalPaidAmount')}:',
                      //         //         FontWeight.normal,
                      //         //         Colors.black,
                      //         //         null),
                      //         //     create_text(
                      //         //         '\$ ${order.totalPaidAmount.toStringAsFixed(2)}',
                      //         //         FontWeight.normal,
                      //         //         Colors.black,
                      //         //         null)
                      //         //   ],
                      //         // ),
                      //         // Row(
                      //         //   mainAxisAlignment:
                      //         //       MainAxisAlignment.spaceBetween,
                      //         //   children: [
                      //         //     create_text(
                      //         //         '${AppLocalizationHelper.of(context).translate('TotalChanges')}:',
                      //         //         FontWeight.normal,
                      //         //         Colors.black,
                      //         //         null),
                      //         //     create_text(
                      //         //         (order.totalAmount <= 0)
                      //         //             ? '\$ ${(order.totalPaidAmount).toStringAsFixed(2)}'
                      //         //             : '\$ ${(order.totalPaidAmount - order.totalAmount + order.discount).toStringAsFixed(2)}',
                      //         //         FontWeight.normal,
                      //         //         Colors.black,
                      //         //         null)
                      //         //   ],
                      //         // ),
                      //       ],
                      //     ),
                      //   ),

                      (!atPaymentPage)
                          ? Container(
                              margin: EdgeInsets.fromLTRB(5, 10, 5, 10),
                              padding: EdgeInsets.fromLTRB(0, 10, 0, 20),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                              // child: ListView.builder(
                              //   shrinkWrap: true,
                              //   itemCount: components.length,
                              //   itemBuilder: (context, index) {
                              //     return components[index];
                              //   },
                              // ),
                              child: orderStatusListView(provider),
                            )
                          : Container(
                              margin: EdgeInsets.fromLTRB(
                                  SizeHelper.isMobilePortrait
                                      ? 5 * SizeHelper.heightMultiplier
                                      : SizeHelper.isPortrait
                                          ? 20 * SizeHelper.widthMultiplier
                                          : 10 * SizeHelper.widthMultiplier,
                                  20,
                                  SizeHelper.isMobilePortrait
                                      ? 4 * SizeHelper.heightMultiplier
                                      : SizeHelper.isPortrait
                                          ? 20 * SizeHelper.widthMultiplier
                                          : 10 * SizeHelper.widthMultiplier,
                                  20),
                              padding: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                              child:
                                  Center(child: orderStatusListView(provider)),
                            ),
                      if (atPaymentPage &&
                          !order.paymentSuccessful &&
                          provider.isAllowUpdateOrder &&
                          ScreenHelper.isLandScape(context))
                        VEmptyView(SizeHelper.widthMultiplier * 10),

                      if (atPaymentPage &&
                          !order.paymentSuccessful &&
                          provider.isAllowUpdateOrder)
                        Container(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  create_payment_container(
                                      order,
                                      new OrderItem(),
                                      cash_payment,
                                      'Cash',
                                      Colors.green),
                                  create_payment_container(
                                      order,
                                      new OrderItem(),
                                      card_payment,
                                      'Card',
                                      Colors.green),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  (allowPercentDiscount && !discount_been_made)
                                      ? create_payment_container(
                                          order,
                                          new OrderItem(),
                                          discount_percent,
                                          'Discount %',
                                          Colors.blue)
                                      : create_payment_container(
                                          order,
                                          new OrderItem(),
                                          discount_percent,
                                          'Discount %',
                                          Colors.grey),
                                  (allowCashDiscount && !discount_been_made)
                                      ? create_payment_container(
                                          order,
                                          new OrderItem(),
                                          discount_dollar,
                                          'Discount ${dollarSign}',
                                          Colors.blue)
                                      : create_payment_container(
                                          order,
                                          new OrderItem(),
                                          discount_dollar,
                                          'Discount ${dollarSign}',
                                          Colors.grey),
                                ],
                              ),
                            ],
                          ),
                        ),

                      if (atPaymentPage &&
                          !order.paymentSuccessful &&
                          provider.isAllowUpdateOrder &&
                          ScreenHelper.isLandScape(context))
                        VEmptyView(SizeHelper.widthMultiplier * 10),

                      Row(
                        children: [
                          if (checkAllServed(order) &&
                              order.userOrderStatus ==
                                  UserOrderStatus.InProgress &&
                              isActiveOrder &&
                              !callResetTableAPI &&
                              (!atPaymentPage || order.paymentSuccessful) &&
                              order.orderType != OrderType.PickUp &&
                              provider.isAllowUpdateOrder)
                            create_button(order, new OrderItem(), returnAll,
                                Colors.purple[400]),
                          if (!checkAllReady(order) &&
                              order.userOrderStatus ==
                                  UserOrderStatus.InProgress &&
                              (order.orderType == OrderType.PickUp ||
                                  order.orderType == OrderType.Delivery) &&
                              provider.isAllowUpdateOrder)
                            create_button(
                                order, new OrderItem(), ready, Colors.green),
                          if (!checkAllServed(order) &&
                              checkAllReady(order) &&
                              order.userOrderStatus ==
                                  UserOrderStatus.InProgress &&
                              isActiveOrder &&
                              (!atPaymentPage || order.paymentSuccessful) &&
                              provider.isAllowUpdateOrder)
                            create_button(
                                order, new OrderItem(), serveAll, Colors.green),
                          if (provider.isAllowUpdateOrder &&
                                  order.isPaid &&
                                  (!has_confirm_all &&
                                      order.userOrderStatus !=
                                          UserOrderStatus.Completed &&
                                      order.userOrderStatus !=
                                          UserOrderStatus.Cancelled &&
                                      isActiveOrder &&
                                      !atPaymentPage &&
                                      !order.itemBeenServed &&
                                      !order.paymentSuccessful) ||
                              order.userOrderStatus ==
                                  UserOrderStatus.AwaitConfirm)
                            create_button(order, new OrderItem(), cancelOrder,
                                Colors.grey),
                          if (atPaymentPage &&
                              !order.paymentSuccessful &&
                              provider.isAllowUpdateOrder)
                            create_button(
                                order, new OrderItem(), back, Colors.grey),
                          if (order.userOrderStatus ==
                                  UserOrderStatus.AwaitConfirm &&
                              provider.isAllowUpdateOrder &&
                              order.isPaid)
                            create_button(order, new OrderItem(), confirm_all,
                                Colors.green),
                          if (order.userOrderStatus != UserOrderStatus.Voided &&
                              order.userOrderStatus !=
                                  UserOrderStatus.AwaitConfirm &&
                              order.userOrderStatus !=
                                  UserOrderStatus.Completed &&
                              order.userOrderStatus !=
                                  UserOrderStatus.Cancelled &&
                              isActiveOrder &&
                              !order.paymentSuccessful &&
                              !atPaymentPage &&
                              provider.isAllowUpdateOrder &&
                              order.orderType !=
                                  OrderType
                                      .PickUp) // for pick-up order, use customer side payment instead of merchant payment
                            create_button(
                                order, new OrderItem(), pay, Color(0xff5352ec)),
                          if ((order.userOrderStatus ==
                                      UserOrderStatus.Cancelled ||
                                  order.userOrderStatus ==
                                      UserOrderStatus.Completed ||
                                  order.userOrderStatus ==
                                      UserOrderStatus.Voided ||
                                  order.paymentStatus ==
                                      OrderPaymentStatus.Paid) &&
                              isActiveOrder &&
                              !hasReseted &&
                              checkAllServed(order) &&
                              order.orderType != OrderType.PickUp &&
                              provider.isAllowUpdateOrder)
                            create_button(order, new OrderItem(), resetTable,
                                Color(0xff5352ec))
                        ],
                      ),

                      RoundedVplusLongButton(
                          text: "Update Order",
                          callBack: () {
                            showDialog(
                                context: context,
                                builder: (ctx) {
                                  return CustomDialog(
                                    child: Column(
                                      // crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          constraints: BoxConstraints(
                                              maxHeight:
                                                  SizeHelper.heightMultiplier *
                                                      50),
                                          child: order.userItems == null
                                              ? Text("No Items to change")
                                              : ListView.builder(
                                                  itemCount:
                                                      order.userItems.length,
                                                  itemBuilder: (ctx, index) {
                                                    var item = order
                                                                .userItems ==
                                                            null
                                                        ? null
                                                        : order
                                                            .userItems[index];
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceAround,
                                                        children: [
                                                          Text(item.menuItem
                                                              .menuItemName),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: [
                                                              Text(item.quantity
                                                                  .toString()),
                                                            ],
                                                          ),
                                                          Container(
                                                            width: SizeHelper
                                                                    .widthMultiplier *
                                                                10,
                                                            child: TextField(
                                                              decoration:
                                                                  InputDecoration(
                                                                      contentPadding:
                                                                          EdgeInsets.all(
                                                                              10.0),
                                                                      border:
                                                                          OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(15.0),
                                                                      )),
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                              onSubmitted:
                                                                  (v) async {
                                                                await Provider.of<
                                                                            Current_OrderStatus_Provider>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .setItemQuatityFromOrder(
                                                                        item
                                                                            .userOrderItemId,
                                                                        int.parse(
                                                                            v),
                                                                        context);
                                                              },
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }),
                                        ),
                                      ],
                                    ),
                                    insideButtonList: [
                                      CustomDialogInsideButton(
                                          buttonName: "Back",
                                          buttonEvent: () {
                                            Navigator.pop(context);
                                          })
                                    ],
                                    title: "Update Order",
                                  );
                                });
                          })
                    ],
                  ),
                );
              }
              return noOrderSelectedView();
            },
          );
        }),
      ),
    );
  }

  double calculate_order_totalAmount() {
    double result = 0.0;

    if (_orderItems != null && _orderItems.length != 0)
      _orderItems.forEach((element) {
        if (element.itemStatus != ItemStatus.Cancelled &&
            element.itemStatus != ItemStatus.Returned) result += element.price;
      });

    order.totalAmount = result;
    return result;
  }

  void resetVariables() {
    orderId = null;

    isActiveOrder = false;

    hasExtraOrder = false;
    hasCurrentOrder = false;

    // String extraOrderNotes = "";

    hasReseted = false;
    atPaymentPage = false;
    has_confirm_all = false;
    has_confirm_one = false;

    hasServedAll = false;
    hasServedOne = false;

    hasReturnedAll = false;
    hasReturnedOne = false;

    _discount_percent = "0";
    allowCashDiscount = true;
    allowPercentDiscount = true;
    discount_been_made = false;

    cash_payment_amount = 0;
    iscashPayment = false;
    card_payment_amount = 0;
    iscardPayment = false;

    order_totalAmount_copy = 0;
    currentDiscount = 0;

    callReturnAPI = false;
    callCancelAPI = false;
    callServeAPI = false;
    calllConfirmAPI = false;
    callCheckOutAPI = false;
    callResetTableAPI = false;

    _orderItems = [];
  }

  updateOrderStatus() {
    order = Provider.of<Current_OrderStatus_Provider>(context, listen: false)
        .getOrder();

    if (order != null) {
      orderId = order.userOrderId;
      isActiveOrder =
          Provider.of<Current_OrderStatus_Provider>(context, listen: false)
              .getisActive();

      Provider.of<Current_OrderStatus_Provider>(context, listen: false)
          .determineOrderStatus(order, isActiveOrder);

      hasExtraOrder =
          Provider.of<Current_OrderStatus_Provider>(context, listen: false)
              .getHasExtraOrder();

      _orderItems =
          Provider.of<Current_OrderStatus_Provider>(context, listen: false)
              .getOrderItemList(order);

      calculate_order_totalAmount();

      (order.userItems != null && order.userItems.length != 0)
          ? hasCurrentOrder = true
          : hasCurrentOrder = false;

      if (order.userOrderStatus != UserOrderStatus.AwaitConfirm) {
        has_confirm_all = true;
        has_confirm_one = true;
      }
    }
  }

  double getOutStandingPayment(Order order) {
    return Provider.of<Current_OrderStatus_Provider>(context, listen: false)
        .calculateOutstandingPayment(order);
  }

  bool checkAllServed(Order order) {
    bool result = true;
    if (order != null) {
      _orderItems.forEach((element) {
        if (
            // element.itemStatus != ItemStatus.Ready &&
            element.itemStatus != ItemStatus.Served &&
                element.itemStatus != ItemStatus.Cancelled &&
                element.itemStatus != ItemStatus.Returned &&
                element.itemStatus != ItemStatus.Voided) {
          result = false;
        }
      });
    }
    return result;
  }

  bool checkAllReady(Order order) {
    // if (hasKitchenInStore == false) {
    //   return true;
    // }
    bool result = true;
    if (order != null) {
      _orderItems.forEach((element) {
        if (element.itemStatus == ItemStatus.AwaitConfirm ||
            element.itemStatus == ItemStatus.Preparing) {
          result = false;
          return result;
        }
      });
    }
    return result;
  }

  Color determine_payment_status_color(Order order) {
    Color color = Colors.green;

    switch (order.paymentStatus) {
      case OrderPaymentStatus.Cancelled:
        color = Colors.red;
        break;
      case OrderPaymentStatus.Paid:
        color = Colors.green;
        break;
      case OrderPaymentStatus.AwaitingPayment:
        color = Colors.orange;
        break;
      case OrderPaymentStatus.Voided:
        color = Colors.blueGrey[900];
        break;
    }

    return color;
  }

  Color determine_status_color(Order order, OrderItem orderItem) {
    Color color = Colors.blue;

    if (order != null)
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
      }

    if (orderItem != null)
      switch (orderItem.itemStatus) {
        case ItemStatus.Cancelled:
          color = Colors.red;
          break;
        case ItemStatus.Preparing:
          color = Colors.blue;
          break;
        case ItemStatus.AwaitConfirm:
          color = Colors.orange;
          break;
        case ItemStatus.Voided:
          color = Colors.blueGrey[900];
          break;
        case ItemStatus.Served:
          color = Colors.green;
          break;
        case ItemStatus.Returned:
          color = Colors.purple[400];
          break;
        case ItemStatus.Ready:
          color = readyColor;
          break;
      }

    return color;
  }

  Widget noOrderSelectedView() {
    return Container(
        // margin: EdgeInsets.only(
        //     top: (ScreenHelper.isLandScape(context))
        //         ? MediaQuery.of(context).size.height / 30
        //         : MediaQuery.of(context).size.height / 2),
        child: Center(
      child: Text(
        '\n\n\n${AppLocalizationHelper.of(context).translate('NoOrderSelectedNote')}',
        textAlign: TextAlign.center,
        style: GoogleFonts.lato(
            fontSize: SizeHelper.isMobilePortrait
                ? 2 * SizeHelper.textMultiplier
                : (SizeHelper.isPortrait)
                    ? 2 * SizeHelper.textMultiplier
                    : 2 * SizeHelper.textMultiplier,
            // fontSize: ScreenUtil().setSp(ScreenHelper.isLandScape(context)?MediaQuery.of(context).size.height*0.025:MediaQuery.of(context).size.height*0.025),
            fontWeight: FontWeight.normal,
            color: Colors.black,
            height: 1),
      ),
    ));
  }

  Widget create_text(String label, FontWeight weight, Color color,
      TextDecoration textDecoration) {
    return Text(
      label,
      textAlign: TextAlign.center,
      // textAlign: TextAlign.center,
      style: GoogleFonts.lato(
          fontSize: SizeHelper.isMobilePortrait
              ? 2.5 * SizeHelper.textMultiplier
              : (SizeHelper.isPortrait)
                  ? 1.8 * SizeHelper.textMultiplier
                  : 2.5 * SizeHelper.textMultiplier,
          // fontSize: ScreenUtil().setSp(60),
          fontWeight: weight,
          color: color,
          // height: 2,
          textStyle: GoogleFonts.lato(
            decoration: textDecoration,
          )),
    );
  }

  Widget create_datetime_bar(String label, Order order, ExtraOrder extraOrder) {
    //Order datetime row
    return Container(
      height: SizeHelper.isMobilePortrait
          ? 3.5 * SizeHelper.heightMultiplier
          : 4 * SizeHelper.widthMultiplier,
      // height:(ScreenHelper.isLandScape(context)?MediaQuery.of(context).size.height*0.05:MediaQuery.of(context).size.height*0.025),
      // width:(ScreenHelper.isLandScape(context)?MediaQuery.of(context).size.width*0.45:MediaQuery.of(context).size.width*0.26),
      child: Row(
        children: [
          Expanded(
            child: Container(
                height: ScreenUtil().setHeight(80),
                // alignment: Alignment.center,
                color: Colors.grey[350],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      '${label}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                          fontSize: SizeHelper.isMobilePortrait
                              ? 2 * SizeHelper.textMultiplier
                              : (SizeHelper.isPortrait)
                                  ? 2 * SizeHelper.textMultiplier
                                  : 1.7 * SizeHelper.textMultiplier,
                          // fontSize: ScreenUtil().setSp((ScreenHelper.isLandScape(context)?MediaQuery.of(context).size.height*0.019:MediaQuery.of(context).size.height*0.02)),
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      (order != null)
                          ? '${DateTimeHelper.parseDateTimeToDateHHMM(order.orderCreateDateTimeUTC.toLocal())}'
                          : '${DateTimeHelper.parseDateTimeToDateHHMM(extraOrder.orderCreateDateTimeUTC.toLocal())}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                          fontSize: SizeHelper.isMobilePortrait
                              ? 2 * SizeHelper.textMultiplier
                              : (SizeHelper.isPortrait)
                                  ? 2 * SizeHelper.textMultiplier
                                  : 2 * SizeHelper.textMultiplier,
                          // fontSize: ScreenUtil().setSp((ScreenHelper.isLandScape(context)?MediaQuery.of(context).size.height*0.019:MediaQuery.of(context).size.height*0.02)),
                          fontWeight: FontWeight.normal,
                          color: Colors.black),
                    ),
                    Spacer(),
                  ],
                )),
          )
        ],
      ),
    );
  }

  Widget create_note_container(String note) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          child: Container(
            margin: const EdgeInsets.fromLTRB(15, 15, 15, 0),
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.all(Radius.circular(
                      10.0) //                 <--- border radius here
                  ),
              color: Color(0xFFFFE2E2),
              // color: color,
            ),
            child: Text(
                (note!=null)
                    ? '${AppLocalizationHelper.of(context).translate('Note')}: ${note}'
                    : "There are no notes provided :) ",
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: SizeHelper.isMobilePortrait
                    ? 3 * SizeHelper.textMultiplier
                    : 2 * SizeHelper.textMultiplier,
                // fontSize: ScreenUtil().setSp(60),
                fontWeight: FontWeight.normal,
                color: Colors.grey[800],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String create_addon_text(OrderItem orderItem) {
    String output;
    (orderItem.isTakeAway)
        ? output =
            '${AppLocalizationHelper.of(context).translate('TakeAway')}\n'
        : output = "";
    List<String> addons =
        Provider.of<CurrentOrderProvider>(context, listen: false)
            .getAddOnReceiptFromBackend(orderItem);
    if (addons != null)
      addons.forEach((element) {
        if (element.contains(':')) {
          output += element.split(':')[0];
          output += ':\n';
          element.split(':')[1].split(' ').forEach((string) {
            output += string;
            output += '\n';
          });
        } else {
          element.split(' ').forEach((string) {
            output += string;
            output += '\n';
          });
        }
      });
    return output;
  }

  String create_checkBoxText(OrderItem orderItem, bool isReturn) {
    String output = "";
    if (orderItem.returnCancelStatus != null) {
      for (int i = 0; i < orderItem.returnCancelStatus.length; i++) {
        output += '${orderItem.returnCancelStatus[i].toString().split('.')[1]}';
        if (i != orderItem.returnCancelStatus.length - 1) output += '\n';
      }
      orderItem.returnCancelStatus.clear();
    }
    if (isReturn) {
      if (orderItem.returnReason != null) {
        output += '\n${orderItem.returnReason}';
      }
    } else {
      if (orderItem.cancelReason != null) {
        output += '\n${orderItem.cancelReason}';
      }
    }
    if (output.length == 0) output = "Customer\nRequest";
    return output;
  }

  OrderStatus_Button cancelOrder = new OrderStatus_Button(
      buttonType: OrderStatus_ButtonType.CancelOrder, label: 'Cancel Order');
  OrderStatus_Button pay = new OrderStatus_Button(
      buttonType: OrderStatus_ButtonType.Pay, label: 'Pay');
  OrderStatus_Button resetTable = new OrderStatus_Button(
      buttonType: OrderStatus_ButtonType.ResetTable, label: 'Reset Table');
  OrderStatus_Button back = new OrderStatus_Button(
      buttonType: OrderStatus_ButtonType.Back, label: 'Back');
  OrderStatus_Button cash_payment = new OrderStatus_Button(
      buttonType: OrderStatus_ButtonType.CashPayment, label: 'Cash Payment');
  OrderStatus_Button card_payment = new OrderStatus_Button(
      buttonType: OrderStatus_ButtonType.CardPayment, label: 'Card Payment');
  OrderStatus_Button discount_percent = new OrderStatus_Button(
      buttonType: OrderStatus_ButtonType.Discount_Percent, label: 'Discount %');
  OrderStatus_Button discount_dollar = new OrderStatus_Button(
      buttonType: OrderStatus_ButtonType.Discount_Dollar, label: 'Discount \$');
  OrderStatus_Button confirm_all = new OrderStatus_Button(
      buttonType: OrderStatus_ButtonType.Confirm_All, label: 'Confirm All');
  OrderStatus_Button confirm_single = new OrderStatus_Button(
      buttonType: OrderStatus_ButtonType.Confirm_Single, label: 'Confirm');
  OrderStatus_Button serveAll = new OrderStatus_Button(
      buttonType: OrderStatus_ButtonType.ServeAll, label: 'Serve All');
  OrderStatus_Button ready = new OrderStatus_Button(
      buttonType: OrderStatus_ButtonType.Ready, label: 'Ready');
  OrderStatus_Button returnAll = new OrderStatus_Button(
      buttonType: OrderStatus_ButtonType.ReturnAll, label: 'Return All');
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:geocoder/model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vplus/config/config.dart';
import 'package:vplus/helper/apiHelper.dart';
import 'package:vplus/helper/appLocalizationHelper.dart';
import 'package:vplus/helper/locationHelper.dart';
import 'package:vplus/helper/order_helper.dart';
import 'package:vplus/helper/screenHelper.dart';
import 'package:vplus/helper/sizeHelper.dart';
import 'package:vplus/models/Order.dart';
import 'package:vplus/models/OrderItem.dart';
import 'package:vplus/models/coupon.dart';
import 'package:vplus/models/fees.dart';
import 'package:vplus/models/store.dart';
import 'package:vplus/models/user.dart';
import 'package:vplus/models/userSavedAddress.dart';
import 'package:vplus/providers/coupon_provider.dart';
import 'package:vplus/providers/current_order_provider.dart';
import 'package:vplus/providers/current_store_provider.dart';
import 'package:vplus/providers/currentuser_provider.dart';
import 'package:vplus/providers/order_list_provider.dart';
import 'package:vplus/providers/payment_provider.dart';
import 'package:vplus/providers/user_address_provider.dart';
import 'package:vplus/screens/account/address_manage.dart';
import 'package:vplus/screens/account/payment_manage.dart';
import 'package:vplus/screens/order/payment/default_payment_method_list_tile.dart';
import 'package:vplus/screens/order/payment/payment_method_select.dart';
import 'package:vplus/screens/order/payment/payment_success_page.dart';
import 'package:vplus/screens/order/table_bottom_bar/bottom_bar_order_confirmation_listtile.dart';
import 'package:vplus/screens/stores/addNewUserLoctionPage.dart';
import 'package:vplus/styles/color.dart';
import 'package:vplus/widgets/address_list_tile.dart';
import 'package:vplus/widgets/appBar.dart';
import 'package:vplus/widgets/components.dart';
import 'package:vplus/widgets/custom_dialog.dart';
import 'package:vplus/widgets/emptyView.dart';

class PaymentConfirmPage extends StatefulWidget {
  PaymentConfirmPage({Key key}) : super(key: key);
  PaymentConfirmPageState createState() => PaymentConfirmPageState();
}

class PaymentConfirmPageState extends State<PaymentConfirmPage> {
  Order order;
  bool termsAgreed;
  double amountsPayable;
  ScrollController cashierController;
  TextEditingController TextController = TextEditingController();
  User user;
  Store store;
  Coupon coupon;
  bool isLoading;
  bool isCouponAdded = false;
  CustomerPaymentMethod selectedPaymentMethod;
  bool isDeliveryOrder;
  //double deliveryFee;
  UserSavedAddress userChoosenAddress;
  //Fees deliveryFee;
  //double deliveryFeeDiscount = 0;
  @override
  void initState() {
    termsAgreed = false;
    cashierController = new ScrollController();
    store = Provider.of<CurrentStoreProvider>(context, listen: false)
        .getCurrentStore;
    if (store == null)
      store = Provider.of<OrderListProvider>(context, listen: false)
          .getSelectedOrderWithStore
          .store;
    isLoading = false;
    isDeliveryOrder = true;
    //deliveryFee = 0;
    var userId = Provider.of<CurrentUserProvider>(context, listen: false)
        .getloggedInUser
        .userId;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await Provider.of<UserAddressProvider>(context, listen: false)
          .getUserAddressByUserId(context, userId);
      await Provider.of<CurrentOrderProvider>(context, listen: false)
          .getFees(context);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar.getAppBar(
            "${AppLocalizationHelper.of(context).translate("Cashier")}", false,
            context: context, showLeftBackButton: true),
        body: ModalProgressHUD(
          inAsyncCall: isLoading,
          child: Consumer<CurrentOrderProvider>(builder: (ctx, p, w) {
            if (p.getdeliveryFee == null) return Container();
            order = p.getOrderWithDiscountApplied(context);
            amountsPayable = order.totalAmount;
            //amountsPayable += isDeliveryOrder ? deliveryFee.fixedAmount : 0.0;
            return (order == null)
                ? errorNotice()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          controller: cashierController,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Padding(
                              //     padding: EdgeInsets.symmetric(
                              //         vertical:
                              //             SizeHelper.heightMultiplier * 1,
                              //         horizontal:
                              //             SizeHelper.widthMultiplier * 2),
                              //     child: Text(
                              //       "${AppLocalizationHelper.of(context).translate("orderTypeSelection")}",
                              //       style: GoogleFonts.lato(
                              //           fontSize:
                              //               SizeHelper.textMultiplier * 2.5),
                              //     )),
                              // pick up and delivery selector
                              // Row(
                              //   mainAxisAlignment: MainAxisAlignment.start,
                              //   children: [
                              //     WEmptyView(30),
                              //     Checkbox(
                              //         value: !isDeliveryOrder,
                              //         onChanged: (v) {
                              //           setState(() {
                              //             isDeliveryOrder = !v;
                              //           });
                              //         }),
                              //     Text(
                              //         "${AppLocalizationHelper.of(context).translate("pickUp")}",
                              //         style: GoogleFonts.lato(
                              //             fontSize:
                              //                 SizeHelper.textMultiplier *
                              //                     2.2)),
                              //     Checkbox(
                              //         value: isDeliveryOrder,
                              //         onChanged: (v) {
                              //           if (v) {
                              //             /// calculate delivery fee based on
                              //             /// distance
                              //             Coordinates usrCoord = Provider.of<
                              //                         CurrentUserProvider>(
                              //                     context,
                              //                     listen: false)
                              //                 .getUserCoord;
                              //             double deliveryDistance =
                              //                 LocationHelper
                              //                     .calcualteDistanceInMeter(
                              //                         usrCoord.latitude,
                              //                         usrCoord.longitude,
                              //                         store.coordinate[0],
                              //                         store.coordinate[1]);
                              //             deliveryFee = OrderHelper
                              //                 .calculateDeliveryFee(
                              //                     deliveryDistance);
                              //           }
                              //           setState(() {
                              //             isDeliveryOrder = v;
                              //           });
                              //         }),
                              //     Text(
                              //         "${AppLocalizationHelper.of(context).translate("delivery")}",
                              //         style: GoogleFonts.lato(
                              //             fontSize:
                              //                 SizeHelper.textMultiplier *
                              //                     2.2)),
                              //   ],
                              // ),

                              VEmptyView(50),
                              Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: SizeHelper.heightMultiplier * 1,
                                      horizontal:
                                          SizeHelper.widthMultiplier * 3.5),
                                  child: Text(
                                    "${AppLocalizationHelper.of(context).translate("orderItems")}",
                                    style: GoogleFonts.lato(
                                        fontSize:
                                            SizeHelper.textMultiplier * 2.5),
                                  )),

                              VEmptyView(50),
                              getOrderConfirmationListView(
                                  order.userItems, context),

                              Divider(thickness: 2),
                              VEmptyView(20),
                              isDeliveryOrder ? getAddressTitle() : Container(),
                              isDeliveryOrder
                                  ? getAddresses(context)
                                  : Container(),
                              VEmptyView(20),
                              addCoupon(),
                              VEmptyView(20),

                              payableAmountInfo(
                                  amountsPayable, order.userOrderId),

                              getAmountSummary(context),

                              Divider(
                                thickness: 2,
                              ),
                              cashierPaymentSelect(),
                              if (selectedPaymentMethod ==
                                  CustomerPaymentMethod.credit_card)
                                cardPaymentMethodSelect(),
                              VEmptyView(100)
                            ],
                          ),
                        ),
                      ),
                      confirmFooter(),
                    ],
                  );
          }),
        ));
  }

  Consumer<CouponProvider> getAmountSummary(BuildContext context) {
    return Consumer<CouponProvider>(builder: (ctx, p, w) {
      return Container(
        color: Colors.white,
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: SizeHelper.textMultiplier * 2),
          child: Table(
            // defaultColumnWidth: FixedColumnWidth(
            //     SizeHelper.textMultiplier * 40),
            children: [
              _getTotalRow(
                  "Subtotal",
                  null,
                  Provider.of<CurrentOrderProvider>(context, listen: false)
                      .calculateOrderOrignalPrice(order)),
              _getTotalRow(
                  "Delivery Fee",
                  null,
                  Provider.of<CurrentOrderProvider>(context, listen: false)
                          .getdeliveryFee
                          ?.fixedAmount ??
                      0),
              _getTotalRow(
                  "Delivery Fee Promo",
                  null,
                  -Provider.of<CurrentOrderProvider>(context, listen: false)
                      .getDeliveryDiscount),
              _getTotalRow(
                  "Card Fee",
                  null,
                  (Provider.of<CurrentOrderProvider>(context, listen: false)
                              .calculateOrderOrignalPrice(order) *
                          0.019 +
                      0.3)),
              _getTotalRow(
                  "Card Fee Promo",
                  null,
                  -(Provider.of<CurrentOrderProvider>(context, listen: false)
                              .calculateOrderOrignalPrice(order) *
                          0.019 +
                      0.3)),
              if (Provider.of<CurrentOrderProvider>(context, listen: false)
                      .getDeliveryDiscount ==
                  0)
                _getTotalRow(
                    "(Delivery Discount is not appied, min spend \$35)",
                    null,
                    null),
              if (coupon != null)
                _getTotalRow("Coupon Discount", null, -p.getCoupon.amountOff),
              if (coupon == null)
                _getTotalRow(
                    "Total",
                    null,
                    order.totalAmount +
                        (Provider.of<CurrentOrderProvider>(context,
                                    listen: false)
                                .getdeliveryFee
                                ?.fixedAmount ??
                            0) -
                        Provider.of<CurrentOrderProvider>(context,
                                listen: false)
                            .getDeliveryDiscount)
              else
                _getTotalRow(
                    "Total",
                    null,
                    order.totalAmount +
                        (Provider.of<CurrentOrderProvider>(context,
                                    listen: false)
                                .getdeliveryFee
                                ?.fixedAmount ??
                            0) -
                        Provider.of<CurrentOrderProvider>(context,
                                listen: false)
                            .getDeliveryDiscount -
                        p.coupon.amountOff)
            ],
          ),
        ),
      );
    });
  }

  Padding getAddressTitle() {
    return Padding(
        padding: EdgeInsets.symmetric(
            vertical: SizeHelper.heightMultiplier * 1,
            horizontal: SizeHelper.widthMultiplier * 3.5),
        child: Text(
          "Please choose your delivery address:",
          style: GoogleFonts.lato(fontSize: SizeHelper.textMultiplier * 2.5),
        ));
  }

  Container getAddresses(BuildContext context) {
    return Container(
        // height: SizeHelper.heightMultiplier * 30,
        child: Consumer<UserAddressProvider>(builder: (ctx, p, w) {
      var addressList = p.getUserSavedAddressList;
      return Container(
        child: (addressList == null || addressList.isEmpty)
            ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                OutlinedButton(
                  child: Text(
                    "Add New Delivery Address",
                    style: new TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => addNewUserLocationPage()));
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: appThemeColor,
                  ),
                )
              ])
            : SingleChildScrollView(
                controller: cashierController,
                child: Column(
                  children: <Widget>[
                    ListView.builder(
                        itemCount: addressList.length,
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (ctx, idx) {
                          UserSavedAddress address = addressList[idx];
                          return Padding(
                            padding:
                                EdgeInsets.all(SizeHelper.heightMultiplier),
                            child: AddressListTile(
                              address: address,
                              allowRemove: false,
                              isChosen: userChoosenAddress == null
                                  ? false
                                  : address.userAddressId ==
                                      userChoosenAddress.userAddressId,
                              onHit: (address) {
                                setState(() {
                                  userChoosenAddress = address;
                                });
                              },
                            ),
                          );
                        }),
                  ],
                ),
              ),
      );
    }));
  }

  Widget getOrderConfirmationListView(
      List<OrderItem> orderItems, BuildContext context) {
    return new Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: orderItems
            .map((orderItem) => new TableOrderConfirmationListTile(
                  orderItem: orderItem,
                ))
            .toList());
  }

  Widget errorNotice() {
    return Column(children: [
      Icon(Icons.error, size: SizeHelper.textMultiplier * 10),
      Text("Error occured, please try again",
          style: GoogleFonts.lato(fontSize: SizeHelper.textMultiplier * 5))
    ]);
  }

  Widget payableAmountInfo(double amountsPayable, int orderId) {
    return Container(
      color: Colors.white,
      width: double.infinity,
      child: Column(
        children: [
          // Padding(
          //   padding: EdgeInsets.all(SizeHelper.textMultiplier),
          //   child: Text("\$${amountsPayable.toStringAsFixed(2)}AUD",
          //       style: GoogleFonts.lato(
          //           fontSize: SizeHelper.textMultiplier * 3,
          //           fontWeight: FontWeight.bold)),
          // ),
          // if (isDeliveryOrder)
          //   Padding(
          //     padding: EdgeInsets.all(SizeHelper.textMultiplier),
          //     child: Text("* Delivery fee (\$${deliveryFee.fixedAmount}) included",
          //         style: GoogleFonts.lato(
          //             fontSize: SizeHelper.textMultiplier * 1.8,
          //             fontWeight: FontWeight.bold)),
          //   ),
          Divider(
            thickness: 2,
          )
          // Container(
          //   decoration: BoxDecoration(
          //       border: Border.all(color: cornerRadiusContainerBorderColor),
          //       borderRadius: BorderRadius.circular(15)),
          //   child: Padding(
          //     padding: EdgeInsets.all(SizeHelper.textMultiplier * 0.7),
          //     child: Text(
          //         "${AppLocalizationHelper.of(context).translate("orderNumber")}" +
          //             "$orderId",
          //         style: GoogleFonts.lato(
          //             fontSize: SizeHelper.textMultiplier * 2.3)),
          //   ),
          // ),
          // Padding(
          //   padding: EdgeInsets.all(SizeHelper.textMultiplier * 2),
          //   child: Text(
          //       "${AppLocalizationHelper.of(context).translate("vplusPayRule")}",
          //       style: GoogleFonts.lato(color: cancelButtonColor)),
          // )
        ],
      ),
    );
  }

  _getTotalRow(String title, int quantity, double price) {
    return TableRow(children: [
      TableCell(
        child: Text(
          title,
          style: GoogleFonts.lato(
            fontSize: ScreenHelper.isLandScape(context)
                ? SizeHelper.textMultiplier * 1.5
                : SizeHelper.textMultiplier * 1.8,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      TableCell(
        child: Container(
          alignment: Alignment.centerRight,
          child: Text(
            (price == null) ? "" : "\$${price.toStringAsFixed(2)}",
            style: GoogleFonts.lato(
              fontSize: (ScreenHelper.isLandScape(context)
                  ? SizeHelper.textMultiplier * 1.5
                  : SizeHelper.textMultiplier * 1.8),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ]);
  }

  Widget confirmFooter() {
    return Container(
        color: Colors.white,
        child: Column(
          children: [
            termsCheckBox(),
            Padding(
              padding: EdgeInsets.only(bottom: SizeHelper.heightMultiplier * 2),
              child: RoundedVplusLongButton(
                  callBack: () async {
                    submitPayment();
                  },
                  text:
                      "${AppLocalizationHelper.of(context).translate("paymentConfirmBtn")}"),
            )
          ],
        ));
  }

  Widget termsCheckBox() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Checkbox(
            activeColor: appThemeColor,
            value: termsAgreed,
            onChanged: (v) {
              setState(() {
                termsAgreed = v;
              });
            }),
        Text(
            "${AppLocalizationHelper.of(context).translate("conditionAccept")}",
            style: GoogleFonts.lato()),
        InkWell(
          onTap: () {
            launch(
                "https://www.vplus.com.au/terms"); // TODO double check this link
          },
          child: Text("Vplus Terms and Conditions",
              style: GoogleFonts.lato(
                  textStyle: TextStyle(decoration: TextDecoration.underline))),
        )
      ],
    );
  }

  tncNotCheckedNotice() {
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: appThemeColor,
        padding: EdgeInsets.symmetric(
            vertical: SizeHelper.heightMultiplier,
            horizontal: SizeHelper.widthMultiplier * 1.5),
        content: Text(
            "${AppLocalizationHelper.of(context).translate("conditionAcceptError")}",
            textAlign: TextAlign.center,
            style: GoogleFonts.lato())));
  }

  paymentMethodNotCheckedNotice() {
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: appThemeColor,
        padding: EdgeInsets.symmetric(
            vertical: SizeHelper.heightMultiplier,
            horizontal: SizeHelper.widthMultiplier * 1.5),
        content: Text("Please Select Payment Method",
            textAlign: TextAlign.center, style: GoogleFonts.lato())));
  }

  addressNotCheckedNotice() {
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: appThemeColor,
        padding: EdgeInsets.symmetric(
            vertical: SizeHelper.heightMultiplier,
            horizontal: SizeHelper.widthMultiplier * 1.5),
        content: Text("Delivery address is not selected.",
            textAlign: TextAlign.center, style: GoogleFonts.lato())));
  }

  Widget cashierPaymentSelect() {
    List<String> methods = [];
    methods.add("Card");
    if (Platform.isIOS) {
      methods.add("Apple Pay");
    } else if (Platform.isAndroid) {
     // methods.add("Google Pay");
    }
    // The widget displays a list of all payment method
    // allow user to select one payment method as callback.
    return Container(
        color: Colors.white,
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
                padding: EdgeInsets.symmetric(
                    vertical: SizeHelper.heightMultiplier * 1,
                    horizontal: SizeHelper.widthMultiplier * 2),
                child: Text(
                  "${AppLocalizationHelper.of(context).translate("paymentSelection")}",
                  style: GoogleFonts.lato(
                      fontSize: SizeHelper.textMultiplier * 2.5),
                )),
            PaymentMethodSelect(
              userPaymentMethods: methods, // List of string for card info
              scrollController: cashierController,
              onItemSelected: (idx) {
                setState(() {
                  selectedPaymentMethod = (idx == 0)
                      ? CustomerPaymentMethod.credit_card
                      : CustomerPaymentMethod.native_pay;
                });
              },
            ),
          ],
        ));
  }

  Widget addCoupon() {
    return Consumer<CouponProvider>(builder: (ctx, p, w) {
      return Container(
          color: Colors.white,
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: SizeHelper.heightMultiplier * 1,
                      horizontal: SizeHelper.widthMultiplier * 3.5),
                  child: Text(
                    "${AppLocalizationHelper.of(context).translate("couponAdd")}",
                    style: GoogleFonts.lato(
                        fontSize: SizeHelper.textMultiplier * 2.5),
                  )),
              Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: SizeHelper.heightMultiplier * 1,
                      horizontal: SizeHelper.widthMultiplier * 3.5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: SizeHelper.heightMultiplier * 30,
                        child: TextField(
                          controller: TextController,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(10.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              )),
                        ),
                      ),
                      FlatButton(
                          onPressed: () async {
                            await p.getCouponInfoByCouponCode(
                                context, TextController.text);
                            (p.isCouponAdded)
                                ? (amountsPayable > p.getCoupon.minimumSpend)
                                    ? couponAddedSuccess(p.coupon)
                                    : couponDoesNotMeetMinFail()
                                : couponNotExitFail();
                          },
                          textColor: Colors.white,
                          color: Color(0xff5352ec),
                          child: Text(
                              "${AppLocalizationHelper.of(context).translate("couponApply")}",
                              style: GoogleFonts.lato(
                                fontWeight: FontWeight.bold,
                                fontSize: 2 * SizeHelper.textMultiplier,
                              )))
                    ],
                  )),
            ],
          ));
    });
  }

  Widget cardPaymentMethodSelect() {
    return Consumer<CurrentUserProvider>(
      builder: (ctx, p, w) {
        user = p.getloggedInUser;
        return Container(
            color: Colors.white,
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: SizeHelper.widthMultiplier * 4,
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    VEmptyView(20),
                    Divider(),
                    Text(
                      "${AppLocalizationHelper.of(context).translate("paymentMethodMsg")}",
                      style: GoogleFonts.lato(
                          fontSize: SizeHelper.textMultiplier * 2.5),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: SizeHelper.heightMultiplier * 1),
                      child: DefaultPaymentMethodListTile(
                          userPaymentMethod: user.userPaymentMethod,
                          onSelected: () {
                            pushNewScreen(
                              context,
                              screen: PaymentManageScreen(),
                              withNavBar: false,
                              pageTransitionAnimation:
                                  PageTransitionAnimation.cupertino,
                            );
                          }),
                    ),
                    // Text(
                    //   "*tap the payment method to change",
                    //   textAlign: TextAlign.center,
                    //   style: GoogleFonts.lato(
                    //     fontSize: SizeHelper.textMultiplier * 1.8,
                    //   ),
                    // ),
                  ]),
            ));
      },
    );
  }

  Widget couponNotExitFail() {
    TextController.clear();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(
              "${AppLocalizationHelper.of(context).translate("couponNotExist")}"),
          actions: <Widget>[
            FlatButton(
              color: Colors.white,
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget couponAddedSuccess(Coupon coupon) {
    this.coupon = coupon;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(
              "${AppLocalizationHelper.of(context).translate("couponAddedSuccess")}"),
          actions: <Widget>[
            FlatButton(
              color: Colors.white,
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget couponDoesNotMeetMinFail() {
    TextController.clear();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(
              "${AppLocalizationHelper.of(context).translate("couponCantUse")}"),
          actions: <Widget>[
            FlatButton(
              color: Colors.white,
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void submitPayment() async {
    if (isDeliveryOrder && userChoosenAddress == null) {
      addressNotCheckedNotice();
      return;
    }
    if (selectedPaymentMethod == null) {
      paymentMethodNotCheckedNotice();
    } else if (termsAgreed) {
      setState(() {
        isLoading = true;
      });
      // submit order first
      // if its a delivery order, change order type to delivery and add transaction fee
      if (isDeliveryOrder) {
        if (coupon != null) {
          order.discount = coupon.amountOff;
          Provider.of<CurrentOrderProvider>(context, listen: false)
              .setDiscount = coupon.amountOff;
        }
        order = OrderHelper.tranformOrderToDeliveryOrder(
            order,
            (Provider.of<CurrentOrderProvider>(context, listen: false)
                    .getdeliveryFee
                    .fixedAmount -
                Provider.of<CurrentOrderProvider>(context, listen: false)
                    .getDeliveryDiscount));
        order.userAddressId = userChoosenAddress.userAddressId;
      }
      // check payment method type
      bool hasSubmitted = false;
      if (selectedPaymentMethod == CustomerPaymentMethod.credit_card) {
        hasSubmitted = await submitCreditCardPayment();
      } else if (selectedPaymentMethod == CustomerPaymentMethod.native_pay) {
        hasSubmitted = await submitNativePayment();
      }
      if (hasSubmitted) {
        if (coupon != null) {
          order.discount = coupon.amountOff;
          Provider.of<CurrentOrderProvider>(context, listen: false)
              .setDiscount = coupon.amountOff;
        }
        bool ok =
            await Provider.of<CurrentOrderProvider>(context, listen: false)
                .submitOrder(context, order);
        if (ok) {
          setState(() {
            isLoading = false;
          });
          Navigator.push(context, MaterialPageRoute(builder: (ctx) {
            return PaymentSuccessPage();
            //PaymentPendingPage();
          }));
        } else {
          setState(() {
            isLoading = false;
          });
          Helper().showToastError("Order Submission Failed.");
        }
      } else {
        setState(() {
          isLoading = false;
        });
        Helper().showToastError("Payment Submission Failed.");
      }
    } else {
      setState(() {
        isLoading = false;
      });
      tncNotCheckedNotice();
    }
  }

  Future<bool> submitCreditCardPayment() async {
    Order order =
        Provider.of<CurrentOrderProvider>(context, listen: false).order;
    try {
      String paymentIntentId =
          await Provider.of<PaymentProvider>(context, listen: false)
              .initPaymentIntent(
                  context,
                  (order.totalAmount - order.discount),
                  "order: ${order.userOrderId}",
                  store.storeId,
                  order.userOrderId,
                  coupon?.code);
      if (paymentIntentId == null) {
        return false;
      }
      return true;
    } catch (e) {
      return false;
    }
    // bool paymentStatus =
    //     await Provider.of<PaymentProvider>(context, listen: false)
    //         .submitPaymentIntent(context, paymentIntentId);
  }

  Future<bool> submitNativePayment() async {
    try {
      List<ApplePayItem> items = [];
      Order order =
          Provider.of<CurrentOrderProvider>(context, listen: false).order;

      items.add(ApplePayItem(
        label: 'Vplus Order: ${order.userOrderId}',
        amount: '${order.totalAmount - order.discount}',
      ));

      PaymentMethod paymentMethod = PaymentMethod();

      Token token = await StripePayment.paymentRequestWithNativePay(
        androidPayOptions: AndroidPayPaymentRequest(
          totalPrice: '${order.totalAmount}',
          currencyCode: APP_CURRENCY_CODE,
        ),
        applePayOptions: ApplePayPaymentOptions(
          countryCode: APP_COUNTRY_CODE,
          currencyCode: APP_CURRENCY_CODE,
          items: items,
        ),
      );

      paymentMethod = await StripePayment.createPaymentMethod(
        PaymentMethodRequest(
          card: CreditCard(
            token: token.tokenId,
          ),
        ),
      );
      StripePayment.completeNativePayRequest();

      assert(paymentMethod != null);
      String paymentIntentId =
          await Provider.of<PaymentProvider>(context, listen: false)
              .initPaymentIntent(
                  context,
                  (order.totalAmount - order.discount),
                  "order: ${order.userOrderId}",
                  store.storeId,
                  order.userOrderId,
                  coupon?.code,
                  paymentMethodId: paymentMethod.id);
      // bool paymentStatus =
      //     await Provider.of<PaymentProvider>(context, listen: false)
      //         .submitPaymentIntent(context, paymentIntentId);
      return true;
    } catch (e) {
      return false;
    }
  }
}

enum CustomerPaymentMethod {
  credit_card,
  native_pay,
}

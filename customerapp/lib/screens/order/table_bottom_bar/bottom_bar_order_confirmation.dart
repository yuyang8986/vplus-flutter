import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:vplus/helper/apiHelper.dart';
import 'package:vplus/helper/appLocalizationHelper.dart';
import 'package:vplus/helper/order_helper.dart';
import 'package:vplus/helper/screenHelper.dart';
import 'package:vplus/helper/sizeHelper.dart';
import 'package:vplus/models/Order.dart';
import 'package:vplus/models/OrderItem.dart';
import 'package:vplus/models/store.dart';
import 'package:vplus/providers/current_menu_provider.dart';
import 'package:vplus/providers/current_order_provider.dart';
import 'package:vplus/providers/current_store_provider.dart';
import 'package:vplus/providers/currentuser_provider.dart';
import 'package:vplus/providers/groceries_item_provider.dart';
import 'package:vplus/providers/order_list_provider.dart';
import 'package:vplus/screens/order/payment/payment_confirm_page.dart';
import 'package:vplus/widgets/components.dart';
import 'package:vplus/widgets/custom_dialog.dart';
import 'package:vplus/widgets/emptyView.dart';
import 'bottom_bar_order_confirmation_listtile.dart';
import 'bottom_bar_utils.dart';

class TableOrderConfirmation extends StatefulWidget {
  final bool isStoreOrdering;

  TableOrderConfirmation({this.isStoreOrdering});

  @override
  _TableOrderConfirmationState createState() => _TableOrderConfirmationState();
}

class _TableOrderConfirmationState extends State<TableOrderConfirmation> {
  ScrollController scrollController1 = ScrollController();
  TextEditingController _extraOrderNoteCtl = TextEditingController();
  TextEditingController _orderNoteCtl = TextEditingController();
  List<Widget> extraOrderList;
  List<Widget> orderList;
  Order userorder;
  Store currentStore;
  bool isloading = false;
  double rawPrice; // price without discount
  int userId;
  @override
  void initState() {
    userorder =
        Provider.of<CurrentOrderProvider>(context, listen: false).getOrder;
    currentStore = Provider.of<CurrentStoreProvider>(context, listen: false)
        .getCurrentStore;
    userId = Provider.of<CurrentUserProvider>(context, listen: false)
        .getloggedInUser
        .userId;

    super.initState();
    _initWidget();
  }

  @override
  Widget build(BuildContext context) {
    return isloading
        ? Container()
        : Dialog(
            backgroundColor: Color.fromRGBO(0, 0, 0, 0),
            child: Container(
              constraints: BoxConstraints(maxHeight: SizeHelper.heightMultiplier * 100),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(
                  width: 1,
                  color: Colors.grey,
                ),
                color: Colors.white,
              ),
              child: Padding(
                  padding: EdgeInsets.all(ScreenUtil().setSp(50)),
                  child: _getPopupBody()),
            ),
          );
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

  Widget _getPopupBody() {
    return Consumer<CurrentOrderProvider>(builder: (ctx, p, w) {
      userorder = p.getOrderWithDiscountApplied(context);
      int numberOfItems = p.countOrderItemNumbers();
      rawPrice = p.calculateOrderOrignalPrice(userorder);

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            fit: FlexFit.loose,
            child: SingleChildScrollView(
              child: Column(children: [
                Padding(
                  padding: EdgeInsets.only(
                    bottom: ScreenHelper.isLandScape(context)
                        ? 10 * SizeHelper.widthMultiplier
                        : 30,
                  ),
                  child: Text(
                    "${AppLocalizationHelper.of(context).translate("OrderToConfirmation")}",
                    style: GoogleFonts.lato(
                      fontSize: ScreenHelper.isLandScape(context)
                          ? SizeHelper.textMultiplier * 3
                          : SizeHelper.textMultiplier * 3,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Divider(
                  height: 2,
                  thickness: 2,
                ),
                if (ScreenHelper.isLandScape(context))
                  VEmptyView(SizeHelper.heightMultiplier),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (ScreenHelper.isLandScape(context))
                        VEmptyView(SizeHelper.heightMultiplier),
                      Container(
                          child: getOrderConfirmationListView(
                              userorder.userItems, context)),
                      //_getNoteTextField(_orderNoteCtl),
                      Divider(thickness: 2,),
                      _getTotalRow('Sub-total: ', numberOfItems, rawPrice),
                      // _getTotalRow(
                      //     "${AppLocalizationHelper.of(context).translate("TransactionFee")}",
                      //     null,
                      //     getFee(userorder.totalAmount)),
                      // _getTotalRow(
                      //     "${AppLocalizationHelper.of(context).translate("VplusPromotion")}",
                      //     null,
                      //     0 - getFee(userorder.totalAmount)),
                      // _getTotalRow(
                      //     "${AppLocalizationHelper.of(context).translate("Discount")}",
                      //     null,
                      //     userorder.discount),
                    ],
                  ),
                ),
                _getTotalRow(
                    "${AppLocalizationHelper.of(context).translate("TotalAmount")}",
                    numberOfItems,
                    userorder.totalAmount),
              ]),
            ),
          ),
          Row(
            children: [
              CustomDialogInsideCancelButton(callBack: () {
                Navigator.pop(context);
              }).getButton(context),
              CustomDialogInsideButton(
                buttonName:
                    "${AppLocalizationHelper.of(context).translate("Checkout")}",
                buttonEvent: () async {
                  setState(() {
                    isloading = true;
                  });
                  bool hasOrderSubmitted = false;
                  if (widget.isStoreOrdering) {
                    hasOrderSubmitted = await _storeOrderingConfirmEvent();
                  } else {
                    hasOrderSubmitted = await _confirmEvent();
                  }
                  if (hasOrderSubmitted ?? false) {
                    // // update this order order in order list
                    // await Provider.of<OrderListProvider>(context, listen: false)
                    //     .getOrderListByUserId(context, userId, 1);
                    // go to payment confirmation page
                    pushNewScreen(context,
                        screen: PaymentConfirmPage(), withNavBar: false);
                  }
                  setState(() {
                    isloading = false;
                  });
                },
              ).getButton(context),
            ],
          )
        ],
      );
    });
  }

  double getFee(amount) {
    // get transaction fee
    return amount * 0.029 + 0.3;
  }

  void _initWidget() {
    //TODO init list here
    extraOrderList = [
      TableOrderConfirmationListTile(),
      TableOrderConfirmationListTile(),
    ];
    orderList = [
      TableOrderConfirmationListTile(),
      TableOrderConfirmationListTile(),
      TableOrderConfirmationListTile(),
      TableOrderConfirmationListTile(),
      TableOrderConfirmationListTile(),
      TableOrderConfirmationListTile(),
      TableOrderConfirmationListTile(),
    ];
  }

  Future<bool> _storeOrderingConfirmEvent() async {
    // For pickup order, when user click confirm order button.
    // Init an order from backend first to get the order number
    // Then do submit order.
    int storeMenuId;
    var menu =
        Provider.of<GroceriesItemProvider>(context, listen: false).getStoreMenu;

    if (menu != null) {
      storeMenuId = menu.storeMenuId;
    } else {
      storeMenuId = Provider.of<CurrentMenuProvider>(context, listen: false)
          .getStoreMenuId;
    }

    Store currnetStore =
        Provider.of<CurrentStoreProvider>(context, listen: false)
            .getCurrentStore;
    Order initedOrder = await Provider.of<CurrentOrderProvider>(context,
            listen: false)
        .initOrder(context, storeMenuId, null, OrderType.pickup.index, userId);
    // put temp orderItem into the initedOrder
    initedOrder.userItems = userorder.userItems;
    initedOrder.numberOfItems = userorder.numberOfItems;
    initedOrder.totalAmount = userorder.totalAmount;
    // check campaign discount if exists
    if (currnetStore?.campaign != null) {
      initedOrder = OrderHelper.applyCampaignDiscountToOrder(
          context, initedOrder, currnetStore.campaign);
    }
    // update
    userorder = initedOrder;
    Provider.of<CurrentOrderProvider>(context, listen: false)
        .setOrder(initedOrder);
    // bool hasOrderSubmitted =
    //     await Provider.of<CurrentOrderProvider>(context, listen: false)
    //         .submitOrder(context, initedOrder);
    return (initedOrder != null);
  }

  Future<bool> _confirmEvent() async {
    bool hasOrderSubmitted = false;
    userorder.note = _orderNoteCtl.text;
    setState(() {
      isloading = true;
    });
    try {
      hasOrderSubmitted =
          await Provider.of<CurrentOrderProvider>(context, listen: false)
              .submitOrder(context, userorder);
      // Provider.of<CurrentOrderProvider>(context, listen: false)
      //     .setHasOrderSubmittedThisSession(true);
      // pop confirmation dialog
      Navigator.pop(context);
      setState(() {
        isloading = false;
      });
      // TODO if QR order
      if (userorder.orderType == OrderType.QR) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return CustomDialog(
                  insideButtonList: [
                    CustomDialogInsideButton(
                        buttonName: "Okay",
                        buttonEvent: () {
                          Navigator.of(context).pop();
                        })
                  ],
                  child: Text('Order placed',
                      style: GoogleFonts.lato(
                          fontWeight: FontWeight.bold,
                          fontSize: ScreenUtil().setSp(
                              ScreenHelper.isLandScape(context)
                                  ? SizeHelper.textMultiplier * 1.5
                                  : 64))));
            });
      } else {
        await Provider.of<CurrentOrderProvider>(context, listen: false)
            .getOrderByOrderId(context, userorder.userOrderId);
      }
    } catch (e) {
      Navigator.pop(context);
      Helper().showToastError("Failed to submit order");
      setState(() {
        isloading = false;
      });
      print(e);
    }
    return hasOrderSubmitted;
  }

  Widget _getTitle(String title) {
    return Container(
      // height: ScreenUtil().setHeight(ScreenHelper.isLandScape(context)
      //     ? SizeHelper.widthMultiplier * 8
      //     : SizeHelper.heightMultiplier * 6),
      color: Colors.white,
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setSp(ScreenHelper.isLandScape(context)
                    ? SizeHelper.widthMultiplier
                    : 0)),
            child: Text(
              title,
              textAlign: TextAlign.start,
              style: GoogleFonts.lato(
                fontSize: ScreenUtil().setSp(ScreenHelper.isLandScape(context)
                    ? SizeHelper.textMultiplier * 1.5
                    : SizeHelper.textMultiplier * 7),
                fontWeight: FontWeight.bold,
                color: BottomBarUtils.getThemeColor(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getNoteTextField(TextEditingController teCtl) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 1.5 * SizeHelper.textMultiplier),
      child: TextField(
        controller: teCtl,
        keyboardType: TextInputType.multiline,
        maxLines: 3,
        decoration: CustomTextBox(
          context: context,
          icon: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setHeight(20),
            ),
            child: Text(
              "${AppLocalizationHelper.of(context).translate("OrderConfirmationNote")}",
              style: GoogleFonts.lato(
                  fontSize: ScreenHelper.isLandScape(context)
                      ? 1.5 * SizeHelper.textMultiplier
                      : 1.5 * SizeHelper.textMultiplier,
                  fontWeight: FontWeight.bold,
                  color: Color(0xfff61a36),
                  letterSpacing: 1),
            ),
          ),
        ).getTextboxDecoration(),
      ),
    );
  }

  Widget _getTotalRow(String title, int quantity, double price) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: ScreenUtil().setHeight(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (!ScreenHelper.isLandScape(context)) WEmptyView(100),
          Text(
            title,
            style: GoogleFonts.lato(
              fontSize: ScreenHelper.isLandScape(context)
                  ? SizeHelper.textMultiplier * 1.5
                  : SizeHelper.textMultiplier * 1.8,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (!ScreenHelper.isLandScape(context)) WEmptyView(80),
          Text(
            (quantity == null) ? "" : quantity.toString(),
            style: GoogleFonts.lato(
              fontSize: ScreenHelper.isLandScape(context)
                  ? SizeHelper.textMultiplier * 1.5
                  : SizeHelper.textMultiplier * 1.8,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (!ScreenHelper.isLandScape(context)) WEmptyView(100),
          Text(
            (price == null) ? "" : price.toStringAsFixed(2),
            style: GoogleFonts.lato(
              fontSize: (ScreenHelper.isLandScape(context)
                  ? SizeHelper.textMultiplier * 1.5
                  : SizeHelper.textMultiplier * 1.8),
              fontWeight: FontWeight.bold,
            ),
          ),
          WEmptyView(50)
        ],
      ),
    );
  }
}

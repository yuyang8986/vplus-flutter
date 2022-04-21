// import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'package:vplus/config/secret.dart';
import 'package:vplus/helper/apiHelper.dart';
import 'package:vplus/helper/screenHelper.dart';
import 'package:vplus/helper/sizeHelper.dart';
import 'package:vplus/models/Order.dart';
import 'package:vplus/models/OrderItem.dart';
import 'package:vplus/models/menuCategory.dart';
import 'package:vplus/models/menuItem.dart';
import 'package:vplus/models/store.dart';
import 'package:vplus/models/userOrderItemAddOn.dart';
import 'package:vplus/providers/current_menu_provider.dart';
import 'package:vplus/providers/current_order_provider.dart';
import 'package:vplus/providers/current_store_provider.dart';
import 'package:vplus/screens/order/table_bottom_bar/bottom_bar_floating_button.dart';
import 'package:vplus/screens/order/table_bottom_bar/bottom_bar_shopping_cart_popup.dart';
import 'package:vplus/styles/color.dart';
import 'package:vplus/widgets/components.dart';
import 'package:vplus/widgets/custom_dialog.dart';
import 'package:vplus/widgets/customized_switch_with_text.dart';
import 'package:vplus/widgets/emptyView.dart';
import 'package:vplus/widgets/itemCounter.dart';
import 'order_popup_addon_listtile.dart';
import 'order_table_status_page/order_table_status_page.dart';
import 'order_type_bar.dart';
import 'table_bottom_bar/bottom_bar_utils.dart';

class OrderTablesPage extends StatefulWidget {
  final String tableNumber;
  final int storeId;
  final bool isTakeAway;

  OrderTablesPage(
    this.storeId,
    this.tableNumber,
    this.isTakeAway,
  );
  @override
  OrderTablesPageState createState() => OrderTablesPageState();
}

class OrderTablesPageState extends State<OrderTablesPage>
    with TickerProviderStateMixin {
  //Store selectedStore;
  //Order userOrder;
  ListButtonType _selectedType;
  int selectedCategoryId = 0;
  ScrollController _menuItemCtrl = new ScrollController();
  OrderItem selectedOrderItem;
  String takeAwayIdShortcut;
  Store store;

  bool isDialogConfirmed;
  // GlobalKey<RewardsScreenState> globalKey = GlobalKey();

  List<OrderItem> userItems;
  CurrentOrderProvider _orderProviderInstance;
  bool isCartPoped;

  AnimationController orderTimeoutController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    _orderProviderInstance =
        Provider.of<CurrentOrderProvider>(context, listen: false);

    if (widget.isTakeAway && _orderProviderInstance.checkIsQRTakeAwayOrder()) {
      // currently using table number for takeaway id
      takeAwayIdShortcut = _orderProviderInstance.getOrder.takeAwayId;
    }

    _selectedType = ListButtonType.Order;
    isDialogConfirmed = false;
    isCartPoped = false;
    store = Provider.of<CurrentStoreProvider>(context, listen: false)
        .getCurrentStore;

    super.initState();

    _fabHeight = _initFabHeight;
  }

  @override
  void dispose() {
    /// cannot trigger dispose widget if switch tab & enter new url.
    /// dispose widget in a new way.
    webDispose();
    super.dispose();
  }

  final double _initFabHeight = ScreenUtil().setHeight(50);
  double _fabHeight;
  double _panelHeightOpen;
  double _panelHeightClosed = ScreenUtil().setHeight(130);
  PanelController _panelController = PanelController();
  bool _isInAsyncCall = false;

  Widget _body(BuildContext context) {
    if (isCartPoped ?? false) return orderMenuBlur();
    return ModalProgressHUD(
      inAsyncCall: _isInAsyncCall,
      opacity: 0.5,
      progressIndicator: CircularProgressIndicator(),
      child: Column(
        children: [
          if (_orderProviderInstance.getOrder.orderType != OrderType.TakeAway &&
              _orderProviderInstance.getOrder.orderType != OrderType.DineIn)
            storeBanner(store),
          MenuListTypeBar(
            menuListTypeButton: ListButtonType.values.map((e) {
              return ListTypeButton(
                isSelectedType: _selectedType,
                buttonType: e,
                buttonEvent: () {
                  setState(() {
                    _selectedType = e;
                  });
                },
              );
            }).toList(),
          ),
          _selectedType == ListButtonType.Order
              ? orderRow()
              // : Expanded(child: OrderStatusView())
              : Expanded(child: OrderTableStatusPage()),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        width: 1080, height: 1920, allowFontScaling: false);
    //if (userOrder == null) return Center(child: CircularProgressIndicator());
    //var store = selectedStore;
    int count = 0;
    if (count < 1)
      _panelHeightOpen = ScreenUtil().setHeight(140);
    else if (count >= 1 &&
        count * ScreenUtil().setHeight(225) + ScreenUtil().setHeight(260) <
            MediaQuery.of(context).size.height * .75)
      _panelHeightOpen =
          count * ScreenUtil().setHeight(225) + ScreenUtil().setHeight(260);
    else
      _panelHeightOpen = MediaQuery.of(context).size.height * .75;

    Provider.of<BottomBarEventProvider>(context, listen: false)
        .setPanelController(_panelController);
    return Consumer<CurrentOrderProvider>(
      builder: (context, p, child) {
        Order userOrder = p.getOrder;
        if (userOrder == null || store == null)
          return Center(child: CircularProgressIndicator());
        int count = Provider.of<CurrentOrderProvider>(context, listen: false)
                .getOrder
                .userItems
                ?.length ??
            0;
        if (count < 1)
          _panelHeightOpen = ScreenUtil().setHeight(140);
        else if (count >= 1 &&
            count * ScreenUtil().setHeight(225) + ScreenUtil().setHeight(260) <
                MediaQuery.of(context).size.height * .75)
          _panelHeightOpen =
              count * ScreenUtil().setHeight(225) + ScreenUtil().setHeight(260);
        else
          _panelHeightOpen = MediaQuery.of(context).size.height * .75;

        Provider.of<BottomBarEventProvider>(context, listen: false)
            .setPanelController(_panelController);
        return Scaffold(
            appBar: AppBar(
              backgroundColor: appThemeColor,
              leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  }),
              title: Text("Order"),
              centerTitle: true,
            ),
            backgroundColor: Colors.white,
            body: Stack(
              children: [
                _body(context),
                SlidingUpPanel(
                  maxHeight: _panelHeightOpen,
                  controller: _panelController,
                  minHeight: _panelHeightClosed,
                  panelBuilder: (sc) => TableShoppingCartDetails(
                      scrollController: sc, isStoreOrdering: false),
                  borderRadius: BottomBarUtils.bottomBarRadius(),
                  isDraggable: count < 1 ? false : true,
                  onPanelSlide: (double pos) => setState(() {
                    _fabHeight = pos * (_panelHeightOpen - _panelHeightClosed) +
                        _initFabHeight;
                    // print(_fabHeight);
                    if (_fabHeight > _panelHeightOpen / 2) {
                      setState(() {
                        isCartPoped = true;
                      });
                    }
                  }),
                  onPanelClosed: () {
                    setState(() {
                      isCartPoped = false;
                    });
                  },
                ),
                TableFloatingButton(
                  buttonPosition: _fabHeight,
                  isPopUp: isCartPoped, // TODO change this
                ),
                TableFloatingCloseButton(
                  buttonPosition: _fabHeight,
                  isPopUp: isCartPoped, // TODO change this
                ),
              ],
            ));
      },
    );
  }

  Widget storeBanner(Store s) {
    return Padding(
      padding: EdgeInsets.all(ScreenUtil().setSp(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: ScreenUtil()
                .setWidth(ScreenHelper.isLandScape(context) ? 100 : 250),
            height: ScreenUtil().setHeight(300),
            decoration: BoxDecoration(shape: BoxShape.circle),
            child: Padding(
                padding: EdgeInsets.all(ScreenUtil()
                    .setSp(ScreenHelper.isLandScape(context) ? 0 : 20)),
                child: s.logoUrl == null
                    ? CircleAvatar(
                        child: Center(
                          child: Text(
                            s.storeName.substring(0, 1),
                            style: GoogleFonts.lato(
                                color: Colors.white,
                                fontSize: ScreenUtil().setSp(
                                    ScreenHelper.isLandScape(context)
                                        ? SizeHelper.textMultiplier * 3
                                        : 105)),
                          ),
                        ),
                        backgroundColor: Color(
                            int.tryParse(s.backgroundColorHex) ??
                                Colors.grey.value),
                      )
                    : SquareFadeInImage(s.logoUrl)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.storeName,
                  textAlign: TextAlign.start,
                  style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold,
                      fontSize: ScreenUtil().setSp(40)),
                ),
                VEmptyView(ScreenUtil()
                    .setSp(ScreenHelper.isLandScape(context) ? 0 : 40)),
                Text(
                  s.location,
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.normal,
                    fontSize: SizeHelper.isMobilePortrait
                        ? 2 * SizeHelper.textMultiplier
                        : 2 * SizeHelper.textMultiplier,
                  ),
                ),
                VEmptyView(ScreenUtil()
                    .setSp(ScreenHelper.isLandScape(context) ? 0 : 40)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _orderProviderInstance.checkIsQRTakeAwayOrder()
                          ? 'Take-away: ${takeAwayIdShortcut}'
                          : 'Table: ${_orderProviderInstance.getOrder.table}',
                      style: GoogleFonts.lato(
                        fontWeight: FontWeight.bold,
                        fontSize: SizeHelper.isMobilePortrait
                            ? 2 * SizeHelper.textMultiplier
                            : 2 * SizeHelper.textMultiplier,
                      ),
                    ),
                    // Icon(
                    //   Icons.search,
                    //   size: SizeHelper.isMobilePortrait
                    //       ? 3 * SizeHelper.textMultiplier
                    //       : 3 * SizeHelper.textMultiplier,
                    // ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget orderRow() {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: menuListCategories(),
          ),
          Expanded(
            flex: 6,
            child: menuItemList(),
          ),
        ],
      ),
    );
  }

  Widget menuListCategories() {
    return Consumer<CurrentMenuProvider>(builder: (ctx, p, w) {
      List<MenuCategory> categories =
          p?.getStoreMenu?.menuCategories ?? new List<MenuCategory>();
      // if (categories.isNotEmpty && selectedCategoryId == 0) {
      //   // goes to the first category by default
      //   selectedCategoryId = categories.first.menuCategoryId;
      // }
      return ListView.builder(
        padding: EdgeInsets.only(bottom: ScreenUtil().setSp(200)),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(ScreenUtil().setSp(0)),
                border: Border.all(
                  color: Colors.grey,
                  width: ScreenUtil().setSp(1),
                ),
              ),
              height: ScreenUtil().setSp(ScreenHelper.isLandScape(context)
                  ? SizeHelper.widthMultiplier * 9
                  : (ScreenHelper.isLargeScreen(context))
                      ? SizeHelper.heightMultiplier * 10
                      : SizeHelper.heightMultiplier * 30),
              child: ListTile(
                title: Container(
                  constraints:
                      BoxConstraints(maxHeight: ScreenUtil().setSp(200)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        constraints:
                            BoxConstraints(maxWidth: ScreenUtil().setSp(220)),
                        // maxWidth: ScreenUtil().setSp(
                        //     ScreenHelper.isLandScape(context)
                        //         ? 220
                        //         : SizeHelper.widthMultiplier * 80)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${categories[index].menuCategoryName}',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lato(
                                fontWeight: selectedCategoryId ==
                                        categories[index].menuCategoryId
                                    ? FontWeight.bold
                                    : null,
                                fontSize: SizeHelper.isMobilePortrait
                                    ? 2 * SizeHelper.textMultiplier
                                    : 2 * SizeHelper.textMultiplier,
                              ),
                            ),
                            if (categories[index].menuSubtitle != null &&
                                categories[index].menuSubtitle.length > 0)
                              Text(
                                '${categories[index].menuSubtitle}',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.lato(
                                  fontStyle: FontStyle.italic,
                                  fontSize: SizeHelper.isMobilePortrait
                                      ? 2 * SizeHelper.textMultiplier
                                      : 2 * SizeHelper.textMultiplier,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: () async {
                  setState(() {
                    selectedCategoryId = categories[index].menuCategoryId;
                  });
                  await Provider.of<CurrentMenuProvider>(context, listen: false)
                      .setCurrentCategoryId(selectedCategoryId);
                },
              ));
        },
      );
    });
  }

  Widget menuItemList() {
    return (selectedCategoryId == 0 || selectedCategoryId == null)
        ? emptyMenuItemListNotice()
        : Consumer<CurrentMenuProvider>(
            builder: (ctx, p, w) {
              List<MenuItem> menuItems =
                  p?.getSelectedMenuItems ?? new List<MenuItem>();

              return (menuItems == null || menuItems.isEmpty)
                  ? emptyMenuItemListNotice()
                  : ListView.builder(
                      padding: EdgeInsets.only(bottom: ScreenUtil().setSp(200)),
                      itemCount: menuItems.length,
                      itemBuilder: (context, itemIndex) {
                        var menuItem = menuItems[itemIndex];
                        return Container(
                          key: ValueKey(menuItems[itemIndex].menuItemId),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(ScreenUtil().setSp(0)),
                            border: Border.all(
                              color: Colors.grey,
                              width: ScreenUtil().setSp(1),
                            ),
                          ),
                          child: ListTile(
                            title: ConstrainedBox(
                              constraints: BoxConstraints(
                                  maxHeight: ScreenUtil().setHeight(ScreenHelper
                                          .isLandScape(context)
                                      ? (menuItem.subtitle != null &&
                                              menuItem.subtitle.length > 0)
                                          ? SizeHelper.heightMultiplier * 45
                                          : SizeHelper.heightMultiplier * 40
                                      : SizeHelper.isMobilePortrait
                                          ? (menuItem.subtitle != null &&
                                                  menuItem.subtitle.length > 0)
                                              ? (ScreenHelper.isLargeScreen(
                                                      context))
                                                  ? 45 *
                                                      SizeHelper
                                                          .heightMultiplier
                                                  : 65 *
                                                      SizeHelper
                                                          .heightMultiplier
                                              : (ScreenHelper.isLargeScreen(
                                                      context))
                                                  ? 45 *
                                                      SizeHelper
                                                          .heightMultiplier
                                                  : 60 *
                                                      SizeHelper
                                                          .heightMultiplier
                                          : SizeHelper.isPortrait
                                              ? (menuItem.subtitle != null &&
                                                      menuItem.subtitle.length >
                                                          0)
                                                  ? 45 *
                                                      SizeHelper
                                                          .heightMultiplier
                                                  : 40 *
                                                      SizeHelper
                                                          .heightMultiplier
                                              : 27 *
                                                  SizeHelper.heightMultiplier)),
                              child: Container(
                                // height:(ScreenHelper.isLandScape(context)?MediaQuery.of(context).size.height*0.8:MediaQuery.of(context).size.height*0.025),
                                // width:(ScreenHelper.isLandScape(context)?MediaQuery.of(context).size.width*0.45:MediaQuery.of(context).size.width*0.26),
                                margin: EdgeInsets.symmetric(
                                    vertical: ScreenUtil().setWidth(5)),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    //img
                                    itemImage(menuItems, menuItem, itemIndex),
                                    WEmptyView(20),
                                    // text and tool
                                    itemTitleAndDecr(menuItem)
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      });
            },
          );
  }

  Widget emptyMenuItemListNotice() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(Icons.inbox, size: ScreenUtil().setSp(180)),
          Text('No items in this category.\nPlease select another category.',
              textAlign: TextAlign.center, style: GoogleFonts.lato())
        ],
      ),
    );
  }

  Widget _soldOutLabel() {
    return Center(
      child: Container(
        width: ScreenUtil().setWidth(180),
        height: ScreenUtil()
            .setHeight(ScreenHelper.isLargeScreen(context) ? 120 : 110),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(ScreenUtil().setSp(18)),
          border: Border.all(
            color: Colors.red,
            width: ScreenUtil().setSp(4),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          'Sold Out',
          textAlign: TextAlign.center,
          style: GoogleFonts.lato(
            color: Colors.pink,
            fontSize: ScreenUtil().setSp(ScreenHelper.isLandScape(context)
                ? ScreenHelper.getResponsiveTitleFontSize(context)
                : SizeHelper.textMultiplier * 6),
          ),
        ),
      ),
    );
  }

  Widget itemButtons(MenuItem menuItem) {
    bool isTakeAway = false;
    bool itemExists = false;
    OrderItem orderItem;
    // bool initFlag = true;
    return Consumer<CurrentOrderProvider>(builder: (ctx, p, w) {
      itemExists = p.checkIfItemInOrder(menuItem);
      int itemQuantity = 0;
      if (itemExists == true) {
        orderItem = p.getOrderItemByMenuItemId(menuItem.menuItemId);
        itemQuantity = p.getOrderItemByMenuItemId(menuItem.menuItemId).quantity;
      }
      return (menuItem.isSoldOut == true)
          ? Container()
          : (menuItem.hasAddOns == false)
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ItemCounter(
                      initNumber: itemQuantity,
                      counterCallback: (v) async {
                        itemExists = p.checkIfItemInOrder(menuItem);
                        if (v == 1 && itemExists == false) {
                          orderItem = await initOrderItem(menuItem);
                          Provider.of<CurrentOrderProvider>(context,
                                  listen: false)
                              .addOrderItem(orderItem);
                          setState(() {
                            itemExists = true;
                          });
                        } else if (v == 0) {
                          Provider.of<CurrentOrderProvider>(context,
                                  listen: false)
                              .removeOrderItem(orderItem);
                          setState(() {
                            itemExists = false;
                            itemQuantity = 0;
                          });
                        } else {
                          orderItem.quantity = v;
                          // orderItem.isTakeAway = isTakeAway;
                          Provider.of<CurrentOrderProvider>(context,
                                  listen: false)
                              .updateOrderItem(orderItem);
                        }
                      },
                    ),
                    VEmptyView(ScreenUtil().setSp(40)),
                    Consumer<CurrentOrderProvider>(builder: (ctx, p, w) {
                      bool itemExists = p.checkIfItemInOrder(menuItem);
                      if (itemExists) {
                        orderItem =
                            p.getOrderItemByMenuItemId(menuItem.menuItemId);
                      }
                      return (_orderProviderInstance.checkIsQRTakeAwayOrder())
                          ? Container()
                          : (itemExists == true)
                              ? Center(
                                  child: CustomSwitchWithText(
                                    // value: !isTakeAway,
                                    orderItem: orderItem,
                                    disabledText: 'Dine-in',
                                    enabledText: 'Take-away',
                                    onChanged: (val) {
                                      setState(() {
                                        orderItem.isTakeAway = val;
                                      });
                                    },
                                  ),
                                )
                              : Container();
                    }),
                  ],
                )
              : itemAddOnButton(menuItem);
    });
  }

  Widget itemAddOnButton(MenuItem menuItem) {
    return Consumer<CurrentOrderProvider>(builder: (ctx, p, w) {
      bool hasThisInOrder = p.checkIfItemInOrder(menuItem);
      int itemQuantity;
      if (hasThisInOrder == true) {
        itemQuantity = p.getOrderItemByMenuItemId(menuItem.menuItemId).quantity;
      }
      return Container(
          child: ButtonTheme(
        padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        minWidth: ScreenUtil().setWidth(20), //wraps child's width
        height: ScreenUtil().setWidth(70), //wraps child's height
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            (hasThisInOrder == true)
                ? Container(
                    width: ScreenUtil().setWidth(50),
                    height: ScreenUtil().setHeight(50),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.red),
                    child: Text(itemQuantity.toString(),
                        style: GoogleFonts.lato(color: Colors.white),
                        textAlign: TextAlign.center))
                : Container(),
            Container(
              height: SizeHelper.isMobilePortrait
                  ? 4 * SizeHelper.heightMultiplier
                  : 5 * SizeHelper.widthMultiplier,
              width: SizeHelper.isMobilePortrait
                  ? 15 * SizeHelper.widthMultiplier
                  : 8 * SizeHelper.heightMultiplier,
              // height:(ScreenHelper.isLandScape(context)?MediaQuery.of(context).size.height*0.05:MediaQuery.of(context).size.height*0.025),
              // width:(ScreenHelper.isLandScape(context)?MediaQuery.of(context).size.width*0.1:MediaQuery.of(context).size.width*0.1),
              child: FlatButton(
                onPressed: () {
                  _showAddOnPopUp(menuItem);
                },
                child: Text(
                  'Add-On',
                  style: GoogleFonts.lato(
                    color: Colors.white,
                    fontSize: SizeHelper.isMobilePortrait
                        ? 1.5 * SizeHelper.textMultiplier
                        : 1.5 * SizeHelper.textMultiplier,
                  ),
                ),
                color: Color(0xff5352ec),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: borderColor,
                    width: 0,
                    style: BorderStyle.solid,
                  ),
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ), //your original button
      ));
    });
  }

  Widget getAddOnReceipt(List<String> strings, BuildContext context) {
    return new Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: strings
            .map((item) => new Text(
                  item,
                  style: GoogleFonts.lato(
                      fontSize: SizeHelper.isMobilePortrait
                          ? 2.5 * SizeHelper.textMultiplier
                          : 1.5 * SizeHelper.textMultiplier),
                  // style: GoogleFonts.lato(
                  //   fontSize: SizeHelper.isMobilePortrait?2*SizeHelper.textMultiplier:SizeHelper.textMultiplier
                  // ),
                ))
            .toList());
  }

  _showAddOnPopUp(MenuItem menuItem) async {
    // Provider.of<OrderTablesPageProvider>(context, listen: false)
    //     .setIsLoadingSubmitOrder(true);
    OrderItem orderItem = await initOrderItem(menuItem);
    selectedOrderItem = orderItem;
    // addOnItemReceipt = (o.userOrderItemAddOnReceipt == null )? List<String>();
    // Provider.of<OrderTablesPageProvider>(context, listen: false)
    //     .setIsLoadingSubmitOrder(false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (ctx, setItemState) {
          return CustomDialog(
              title: orderItem.menuItem.menuItemName,
              outsideButtonList: (isDialogConfirmed == false)
                  ? [
                      CustomDialogOutsideButton(
                          isCloseButton: true,
                          buttonEvent: () {
                            Navigator.of(context).pop();
                          }),
                    ]
                  : [
                      CustomDialogOutsideButton(
                          isCloseButton: true,
                          buttonEvent: () {
                            isDialogConfirmed = false;
                            Navigator.of(context).pop();
                          }),
                      CustomDialogOutsideButton(
                          isCloseButton: false,
                          buttonEvent: () {
                            if (orderItem.quantity == 0) {
                              Helper()
                                  .showToastError("Please select quantity.");
                            } else {
                              Provider.of<CurrentOrderProvider>(context,
                                      listen: false)
                                  .addOrderItem(orderItem);
                              isDialogConfirmed = false;
                              Navigator.of(context).pop();
                            }
                          })
                    ],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(
                    thickness: ScreenUtil().setSp(2),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setSp(20)),
                    height: ScreenUtil().setSp(ScreenHelper.isLandScape(context)
                        ? orderItem.menuItem.menuAddOns.length * 110
                        : orderItem.menuItem.menuAddOns.length * 220),
                    child: ListView.builder(
                      // padding: EdgeInsets.only(bottom: ScreenUtil().setSp(200)),
                      // shrinkWrap: true,
                      itemBuilder: (ctx, addOnIndex) {
                        var singleMenuAddOn =
                            orderItem.menuItem.menuAddOns[addOnIndex];

                        return AddOnPopUpListTile(
                            singleMenuAddOn: singleMenuAddOn,
                            onCallBack: (v) {
                              setItemState(
                                () {
                                  // reset to false first so
                                  singleMenuAddOn.menuAddOnOptions.forEach(
                                      (option) => option.isSelected = false);
                                  for (int id in v) {
                                    singleMenuAddOn.menuAddOnOptions
                                        .firstWhere((option) =>
                                            option.menuAddOnOptionId == id)
                                        .isSelected = true;
                                  }
                                  selectedOrderItem.userOrderItemAddOnReceipt =
                                      Provider.of<CurrentOrderProvider>(context,
                                              listen: false)
                                          .getAddOnReceipt(selectedOrderItem);
                                  selectedOrderItem.userOrderItemAddOns =
                                      Provider.of<CurrentOrderProvider>(context,
                                              listen: false)
                                          .getMenuAddOnOptionIds(
                                              selectedOrderItem);
                                  selectedOrderItem.price =
                                      Provider.of<CurrentOrderProvider>(context,
                                              listen: false)
                                          .calculateItemPrice(
                                              selectedOrderItem);
                                },
                              );
                            });
                      },

                      itemCount: orderItem.menuItem.menuAddOns.length,
                    ),
                  ),
                  // take away switch
                  _orderProviderInstance.checkIsQRTakeAwayOrder()
                      ? Container()
                      : ConstrainedBox(
                          constraints: BoxConstraints(
                              maxHeight: ScreenUtil().setHeight(70)),
                          child: Row(
                            children: [
                              Text(
                                'Take away:',
                                style: GoogleFonts.lato(
                                    fontSize: SizeHelper.isMobilePortrait
                                        ? 3 * SizeHelper.textMultiplier
                                        : 1.5 * SizeHelper.textMultiplier
                                    // fontSize: ScreenUtil().setSp((ScreenHelper.isLandScape(context)?MediaQuery.of(context).size.height*0.019:MediaQuery.of(context).size.height*0.02)),
                                    ),
                              ),
                              WEmptyView(ScreenUtil().setSp(70)),
                              Switch(
                                value: orderItem.isTakeAway,
                                onChanged: (v) {
                                  setItemState(
                                    () {
                                      orderItem.isTakeAway = v;
                                    },
                                  );
                                },
                                activeColor: Colors.blue[500],
                                activeTrackColor: Colors.blue[300],
                                inactiveTrackColor: Colors.grey[300],
                                inactiveThumbColor: Colors.grey[500],
                              ),
                              Divider(
                                thickness: ScreenUtil().setSp(2),
                              ),
                            ],
                          ),
                        ),
                  VEmptyView(
                      ScreenUtil().setSp(SizeHelper.widthMultiplier * 2)),
                  Text(
                      '${orderItem.menuItem.menuItemName} (\$${orderItem.menuItem.price})',
                      style: GoogleFonts.lato(
                          fontWeight: FontWeight.bold,
                          fontSize: SizeHelper.isMobilePortrait
                              ? 2.5 * SizeHelper.textMultiplier
                              : 1.5 * SizeHelper.textMultiplier
                          // fontSize: ScreenUtil().setSp(ScreenHelper.isLandScape(context)?MediaQuery.of(context).size.height*0.025:MediaQuery.of(context).size.height*0.025),
                          )),
                  getAddOnReceipt(orderItem.userOrderItemAddOnReceipt, context),
                  VEmptyView(
                      ScreenUtil().setSp(SizeHelper.widthMultiplier * 2)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Total:',
                            style: GoogleFonts.lato(
                                fontSize: SizeHelper.isMobilePortrait
                                    ? 2.5 * SizeHelper.textMultiplier
                                    : 2 * SizeHelper.textMultiplier
                                // fontSize: ScreenUtil().setSp(ScreenHelper.isLandScape(context)?MediaQuery.of(context).size.height*0.025:MediaQuery.of(context).size.height*0.02),
                                ),
                          ),
                          Text(' \$ ${orderItem.price.toStringAsFixed(2)}',
                              style: GoogleFonts.lato(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: SizeHelper.isMobilePortrait
                                      ? 2.5 * SizeHelper.textMultiplier
                                      : 2 * SizeHelper.textMultiplier
                                  // fontSize: ScreenUtil().setSp(ScreenHelper.isLandScape(context)?MediaQuery.of(context).size.height*0.025:MediaQuery.of(context).size.height*0.02),
                                  )),
                        ],
                      ),
                      (isDialogConfirmed == false)
                          ? Container(
                              height: SizeHelper.isMobilePortrait
                                  ? 4 * SizeHelper.heightMultiplier
                                  : 3 * SizeHelper.widthMultiplier,
                              width: SizeHelper.isMobilePortrait
                                  ? 20 * SizeHelper.widthMultiplier
                                  : 8 * SizeHelper.heightMultiplier,
                              // height:(ScreenHelper.isLandScape(context)?MediaQuery.of(context).size.height*0.05:MediaQuery.of(context).size.height*0.025),
                              // width:(ScreenHelper.isLandScape(context)?MediaQuery.of(context).size.width*0.1:MediaQuery.of(context).size.width*0.1),
                              child: FlatButton(
                                onPressed: () {
                                  setItemState(() {
                                    isDialogConfirmed = true;
                                  });
                                },
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        ScreenUtil().setSp(20)),
                                    side: BorderSide(color: Color(0xff5352ec))),
                                color: Color(0xff5352ec),
                                textColor: Colors.white,
                                child: Center(
                                  child: Text(
                                    'Next',
                                    style: GoogleFonts.lato(
                                        fontSize: SizeHelper.isMobilePortrait
                                            ? 3 * SizeHelper.textMultiplier
                                            : 1.5 * SizeHelper.textMultiplier
                                        // fontSize: ScreenUtil().setSp(ScreenHelper.isLandScape(context)?MediaQuery.of(context).size.height*0.020:MediaQuery.of(context).size.height*0.015),
                                        ),
                                  ),
                                ),
                              ),
                            )
                          : ItemCounter(
                              initNumber: orderItem.quantity,
                              isFirstVisit: true,
                              counterCallback: (v) {
                                setItemState(() {
                                  orderItem.quantity = v;
                                  orderItem.price =
                                      Provider.of<CurrentOrderProvider>(context,
                                              listen: false)
                                          .calculateItemPrice(orderItem);
                                });
                              },
                            )
                    ],
                  ),
                ],
              ));
        });
      },
    );
  }

  // _generateSingleMenuAddOn(
  //     ctx, MenuAddOn singleMenuAddOn, Function setItemState) {
  //   return Column(
  //     mainAxisAlignment: MainAxisAlignment.spaceAround,
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Padding(
  //         padding: EdgeInsets.symmetric(vertical: ScreenUtil().setSp(10)),
  //         child: Text(
  //           singleMenuAddOn.menuAddOnName + ':',
  //           textAlign: TextAlign.start,
  //           style: GoogleFonts.lato(
  //               fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(42)),
  //         ),
  //       ),
  //       Container(
  //         // width: ScreenUtil().setSp(800),
  //         height: ScreenUtil().setSp(100),
  //         child: ListView.builder(
  //           // padding: EdgeInsets.only(bottom: ScreenUtil().setSp(200)),
  //           // shrinkWrap: true,
  //           scrollDirection: Axis.horizontal,
  //           itemBuilder: (ctx, index) {
  //             var singleMenuAddOnOption =
  //                 singleMenuAddOn.menuAddOnOptions[index];

  //             singleMenuAddOnOption.isSelected ==
  //                     singleMenuAddOnOption.isSelected ??
  //                 false;
  //             return _generateSingleMenuAddOnOption(
  //                 ctx, singleMenuAddOnOption, singleMenuAddOn, setItemState);
  //           },
  //           itemCount: singleMenuAddOn.menuAddOnOptions.length,
  //         ),
  //       ),
  //       Divider(
  //         thickness: ScreenUtil().setSp(2),
  //       ),
  //     ],
  //   );
  // }

  // _generateSingleMenuAddOnOption(ctx, MenuAddOnOption singleMenuAddOnOption,
  //     MenuAddOn singleMenuAddOn, setItemState) {
  //   return StatefulBuilder(builder: (ctx, setInnerState) {
  //     return Container(
  //       padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setSp(20)),
  //       child: ButtonTheme(
  //         padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setSp(40)),
  //         materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  //         minWidth: ScreenUtil().setWidth(20), //wraps child's width

  //         height: ScreenUtil().setWidth(20), //wraps child's height
  //         child: FlatButton(
  //           onPressed: () async {
  //             if (singleMenuAddOn.isMulti == true) {
  //               // multi-select

  //               setItemState(() {
  //                 setInnerState(() {
  //                   singleMenuAddOnOption.isSelected =
  //                       !singleMenuAddOnOption.isSelected;
  //                   selectedOrderItem.price = Provider.of<CurrentOrderProvider>(
  //                           context,
  //                           listen: false)
  //                       .calculateItemPrice(selectedOrderItem);
  //                   selectedOrderItem.userOrderItemAddOnReceipt =
  //                       Provider.of<CurrentOrderProvider>(context,
  //                               listen: false)
  //                           .getAddOnReceipt(selectedOrderItem);
  //                 });
  //               });
  //             } else {
  //               // single select

  //               if (singleMenuAddOn.menuAddOnOptions
  //                   .any((option) => option.isSelected)) {
  //                 int selectedId = singleMenuAddOn.menuAddOnOptions
  //                     .firstWhere((option) => option.isSelected)
  //                     .menuAddOnOptionId;
  //                 setItemState(() {
  //                   setInnerState(() {
  //                     if (singleMenuAddOnOption.menuAddOnOptionId ==
  //                         selectedId) {
  //                       singleMenuAddOnOption.isSelected = false;
  //                     } else {
  //                       singleMenuAddOn.menuAddOnOptions
  //                           .every((option) => option.isSelected = false);
  //                       singleMenuAddOnOption.isSelected =
  //                           !singleMenuAddOnOption.isSelected;
  //                       selectedOrderItem.price =
  //                           Provider.of<CurrentOrderProvider>(context,
  //                                   listen: false)
  //                               .calculateItemPrice(selectedOrderItem);
  //                       selectedOrderItem.userOrderItemAddOnReceipt =
  //                           Provider.of<CurrentOrderProvider>(context,
  //                                   listen: false)
  //                               .getAddOnReceipt(selectedOrderItem);
  //                     }
  //                   });
  //                 });
  //               } else {
  //                 setItemState(() {
  //                   setInnerState(() {
  //                     singleMenuAddOnOption.isSelected =
  //                         !singleMenuAddOnOption.isSelected;
  //                     selectedOrderItem.price =
  //                         Provider.of<CurrentOrderProvider>(context,
  //                                 listen: false)
  //                             .calculateItemPrice(selectedOrderItem);
  //                     selectedOrderItem.userOrderItemAddOnReceipt =
  //                         Provider.of<CurrentOrderProvider>(context,
  //                                 listen: false)
  //                             .getAddOnReceipt(selectedOrderItem);
  //                   });
  //                 });
  //               }
  //             }
  //           },
  //           child: Text(
  //             singleMenuAddOnOption.optionName,
  //             style: GoogleFonts.lato(
  //                 color: singleMenuAddOnOption.isSelected == true
  //                     ? Color(0xff5352ec)
  //                     : Colors.black),
  //           ),
  //           color: Colors.white,
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(20),
  //             side: BorderSide(
  //                 color: singleMenuAddOnOption.isSelected == true
  //                     ? Color(0xff5352ec)
  //                     : Colors.black,
  //                 width: 1,
  //                 style: BorderStyle.solid),
  //           ),
  //           materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  //         ), //your original button
  //       ),
  //     );
  //   });
  // }
  Future<OrderItem> initOrderItem(MenuItem menuItem) async {
    OrderItem orderItem = new OrderItem();
    orderItem.menuItem = menuItem;
    orderItem.menuItemId = menuItem.menuItemId;
    orderItem.price = menuItem.price;
    orderItem.quantity = 1;
    orderItem.isTakeAway = false;
    orderItem.isExtraOrdered = false;
    orderItem.userOrderItemAddOnReceipt = new List<String>();
    orderItem.userOrderItemAddOns = [new UserOrderItemAddOn()];
    if (menuItem.hasAddOns == true) {
      orderItem.menuItem.menuAddOns =
          await Provider.of<CurrentMenuProvider>(context, listen: false)
              .getMenuAddOnsByMenuitemId(context, menuItem.menuItemId);
    }
    orderItem.itemStatus = ItemStatus.AwaitingConfirmation;
    return orderItem;
  }

  itemImage(menuItems, menuItem, itemIndex) {
    return
        // width: ScreenUtil().setWidth(200),
        //height: ScreenUtil().setHeight(220),
        Container(
      width: ScreenUtil().setWidth(ScreenHelper.isLargeScreen(context)
          ? 180
          : SizeHelper.widthMultiplier * 60),
      height: ScreenUtil().setHeight(ScreenHelper.isLandScape(context)
          ? SizeHelper.widthMultiplier * 50
          : SizeHelper.heightMultiplier * 40),
      decoration: BoxDecoration(
          borderRadius:
              BorderRadius.all(Radius.circular(ScreenUtil().setSp(14)))),
      child: Stack(
        children: [
          menuItem.imageUrl == null
              ? Center(
                  child: CircleAvatar(
                    radius:
                        ScreenUtil().setSp(SizeHelper.imageSizeMultiplier * 30),
                    child: Center(
                      child: Text(
                        menuItems[itemIndex].menuItemName.substring(0, 1),
                        style: GoogleFonts.lato(
                          color: Colors.white,
                          fontSize: SizeHelper.isMobilePortrait
                              ? 5 * SizeHelper.textMultiplier
                              : 5 * SizeHelper.textMultiplier,
                        ),
                      ),
                    ),
                    backgroundColor: Color(0xff5352ec),
                  ),
                )
              : Center(child: SquareFadeInImage(menuItem.imageUrl)),
          menuItem.isSoldOut == true ? _soldOutLabel() : Container(),
        ],
      ),
    );
  }

  itemTitleAndDecr(menuItem) {
    return Expanded(
      child: Container(
        // height:(ScreenHelper.isLandScape(context)?MediaQuery.of(context).size.height*0.1:MediaQuery.of(context).size.height*0.025),
        // width:(ScreenHelper.isLandScape(context)?MediaQuery.of(context).size.width*0.45:MediaQuery.of(context).size.width*0.26),
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setSp(2)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            //title
            Padding(
              padding: EdgeInsets.only(bottom: ScreenUtil().setHeight(1)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${menuItem.menuItemName}',
                    maxLines: 1,
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold,
                      fontSize: SizeHelper.isMobilePortrait
                          ? 2.5 * SizeHelper.textMultiplier
                          : 2 * SizeHelper.textMultiplier,
                    ),
                    overflow: TextOverflow.clip,
                    textAlign: TextAlign.left,
                  ),
                  if (menuItem.subtitle != null && menuItem.subtitle.length > 0)
                    Text(
                      '${menuItem.subtitle}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                        fontStyle: FontStyle.italic,
                        fontSize: SizeHelper.isMobilePortrait
                            ? 2.5 * SizeHelper.textMultiplier
                            : 2 * SizeHelper.textMultiplier,
                      ),
                    ),
                ],
              ),
            ),
            // desc and tool
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: ScreenUtil().setHeight(
                        MediaQuery.of(context).orientation ==
                                Orientation.landscape
                            ? 220
                            : 200),
                    maxWidth: ScreenUtil().setWidth(200),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        constraints: BoxConstraints(
                            maxWidth: ScreenUtil().setWidth(200)),
                        child: Text(
                          '${menuItem.description}',
                          maxLines: 2,
                          softWrap: true,
                          overflow: TextOverflow.clip,
                          style: GoogleFonts.lato(
                            fontStyle: FontStyle.italic,
                            fontSize: SizeHelper.isMobilePortrait
                                ? 2.5 * SizeHelper.textMultiplier
                                : 1.5 * SizeHelper.textMultiplier,
                          ),
                        ),
                      ),
                      Text('\$${menuItem.price}',
                          style: GoogleFonts.lato(
                              textStyle: TextStyle(
                            fontSize: SizeHelper.isMobilePortrait
                                ? 2.5 * SizeHelper.textMultiplier
                                : 2 * SizeHelper.textMultiplier,
                          ))),
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.centerRight,
                  child: itemButtons(menuItem),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget orderMenuBlur() {
    return Container(
        // child: Center(
        //   child: Column(
        //     mainAxisAlignment: MainAxisAlignment.start,
        //     crossAxisAlignment: CrossAxisAlignment.center,
        //     children: [
        //       Padding(
        //         padding:
        //             EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(50)),
        //         child: Icon(
        //           Icons.shopping_cart,
        //           size: ScreenUtil().setSp(100),
        //         ),
        //       ),
        //       Text('Swipe down to close the shopping cart.',
        // style: GoogleFonts.lato(
        //   fontSize: ScreenUtil().setSp(48),
        // ))
        //     ],
        //   ),
        // ),
        );
  }

  webDispose() {
    /// here defines the method for widget dispose.

    _orderProviderInstance.clearOrder();
    //_orderProviderInstance.cleanOrderItem();
  }
}

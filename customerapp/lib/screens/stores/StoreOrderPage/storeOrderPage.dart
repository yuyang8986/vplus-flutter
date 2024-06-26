import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:vplus/config/config.dart';
import 'package:vplus/helper/DateTimeHelper.dart';
import 'package:vplus/helper/apiHelper.dart';
import 'package:vplus/helper/appLocalizationHelper.dart';
import 'package:vplus/helper/estimatedTimeHelper.dart';
import 'package:vplus/helper/locationHelper.dart';
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
import 'package:vplus/providers/currentuser_provider.dart';
import 'package:vplus/screens/order/order_popup_addon_listtile.dart';
import 'package:vplus/screens/order/table_bottom_bar/bottom_bar_floating_button.dart';
import 'package:vplus/screens/order/table_bottom_bar/bottom_bar_shopping_cart_popup.dart';
import 'package:vplus/screens/order/table_bottom_bar/bottom_bar_utils.dart';
import 'package:vplus/screens/stores/storeLocationPage.dart';
import 'package:vplus/screens/stores/store_campaign_badge.dart';
import 'package:vplus/styles/color.dart';
import 'package:vplus/widgets/components.dart';
import 'package:vplus/widgets/custom_dialog.dart';
import 'package:vplus/widgets/customized_switch_with_text.dart';
import 'package:vplus/widgets/emptyView.dart';
import 'package:vplus/widgets/itemCounter.dart';

class StoreOrderPage extends StatefulWidget {
  StoreOrderPage({Key key}) : super(key: key);

  @override
  _StoreOrderPageState createState() => _StoreOrderPageState();
}

class _StoreOrderPageState extends State<StoreOrderPage> {
  int selectedCategoryId;
  ScrollController _menuItemCtrl = new ScrollController();
  OrderItem selectedOrderItem;
  String takeAwayIdShortcut;
  Store store;

  bool isDialogConfirmed;

  List<OrderItem> userItems;
  CurrentOrderProvider _orderProviderInstance;
  bool isCartPoped;

  AnimationController orderTimeoutController;

  bool initMenuSuccess = false;

  final double _initFabHeight = ScreenUtil().setHeight(50);
  double _fabHeight;
  double _panelHeightOpen;
  double _panelHeightClosed = ScreenUtil().setHeight(130);
  PanelController _panelController = PanelController();
  bool _isInAsyncCall = false;
  bool outOfOrderRange;
  bool notInOpeningHour;
  bool storeIsNotAvailable;
  double newPricePercentage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    _orderProviderInstance =
        Provider.of<CurrentOrderProvider>(context, listen: false);
    store = Provider.of<CurrentStoreProvider>(context, listen: false)
        .getCurrentStore;
    outOfOrderRange = checkStoreOutOfOrderRange();
    notInOpeningHour = !checkStoreInOpeningHours();
    storeIsNotAvailable = (outOfOrderRange || notInOpeningHour);
    Provider.of<CurrentOrderProvider>(context, listen: false).setOrder(null);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      var menu = await Provider.of<CurrentMenuProvider>(context, listen: false)
          .getMenuFromAPI(context, store.storeId);
      newPricePercentage = menu.priceAdjust / 100;
      if (menu != null) {
        setState(() {
          initMenuSuccess = true;
        });
        selectedCategoryId = menu.menuCategories.first.menuCategoryId;
        print("menu is:" + selectedCategoryId.toString());
        Provider.of<CurrentOrderProvider>(context, listen: false).setOrder(
            new Order(
                storeMenuId: menu.storeMenuId,
                userItems: [],
                totalAmount: 0,
                numberOfItems: 0));
        if (menu.priceAdjust != 0.0) {
          Provider.of<CurrentMenuProvider>(context, listen: false)
              .getSelectedMenuItems
              .forEach((item) {
            item.price *= (1 + newPricePercentage);
            item.ifChanged = true;
          });
        }
        isDialogConfirmed = false;
        isCartPoped = false;
        print(_orderProviderInstance.getOrder);
      }
    });

    isDialogConfirmed = false;
    isCartPoped = false;
    super.initState();

    _fabHeight = _initFabHeight;
  }

  @override
  void dispose() {
    // webDispose();
    super.dispose();
  }

  Widget _body(BuildContext context) {
    if (isCartPoped ?? false) return orderMenuBlur();
    return ModalProgressHUD(
      inAsyncCall: _isInAsyncCall,
      opacity: 0.5,
      progressIndicator: CircularProgressIndicator(),
      child: Column(
        children: [orderRow()],
      ),
    );
  }

  Widget loadingMenuFailedNote() {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: appThemeColor,
          leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
              }),
          title: Text("Order"),
          centerTitle: true,
        ),
        backgroundColor: Colors.white,
        body: Container(
          child: Center(child: Text("Loading", style: GoogleFonts.lato())),
        ));
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
      builder: (context, value, child) {
        Order userOrder = value.getOrder;
        if (userOrder == null || store == null)
          return Center(
              child: (initMenuSuccess)
                  ? CircularProgressIndicator()
                  : loadingMenuFailedNote());
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
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(SizeHelper.heightMultiplier * 30),
              child: AppBar(
                automaticallyImplyLeading: false,
                flexibleSpace: storeBanner(store),
                backgroundColor: Colors.white,
                elevation: 0,
                // title: storeBanner(store),
              ),
            ),
            backgroundColor: Colors.white,
            body: (storeIsNotAvailable)
                ? _body(context)
                : Stack(
                    children: [
                      _body(context),
                      SlidingUpPanel(
                        maxHeight: _panelHeightOpen,
                        controller: _panelController,
                        minHeight: _panelHeightClosed,
                        panelBuilder: (sc) => TableShoppingCartDetails(
                            scrollController: sc, isStoreOrdering: true),
                        borderRadius: BottomBarUtils.bottomBarRadius(),
                        isDraggable: count < 1 ? false : true,
                        onPanelSlide: (double pos) => setState(() {
                          _fabHeight =
                              pos * (_panelHeightOpen - _panelHeightClosed) +
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
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              fit: BoxFit.cover,
              image: NetworkImage(s.coverImageUrl ??
                  'https://vplus-merchants.s3-ap-southeast-2.amazonaws.com/default/cuisines/bubble_tea.PNG'))),
      // margin: EdgeInsets.all(2),
      child: Padding(
        padding: EdgeInsets.all(ScreenUtil().setSp(12)),
        child: Stack(
          children: [
            Positioned(
                top: (SizeHelper.textMultiplier * 2.4),
                left: (SizeHelper.textMultiplier * .1),
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.grey,
                    size: SizeHelper.textMultiplier * 4,
                  ),
                )),
            StoreInfo(
              context: context,
              outOfOrderRange: outOfOrderRange,
              notInOpeningHour: notInOpeningHour,
              s: s,
            ),
            // InkWell(
            //   child: Column(
            //     mainAxisSize: MainAxisSize.min,
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: [
            //     new Icon(IconData(61870, fontFamily: 'MaterialIcons'), color: Colors.green),
            //   new Container(
            //     margin: const EdgeInsets.only(top: 8.0),
            //     child: new Text(
            //       'MAP',
            //       style: new TextStyle(
            //         fontSize: 12.0,
            //         fontWeight: FontWeight.w400,
            //         color: Colors.green,
            //         ),
            //       ),
            //     ),
            //   ],
            //  ),
            //   onTap:(){
            //     print('this is a map');
            //   },
            // ),
          ],
        ),
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
      return Container(
        color: Colors.grey[200],
        child: ListView.builder(
          padding: EdgeInsets.only(bottom: ScreenUtil().setSp(200)),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(ScreenUtil().setSp(0)),
                  color: selectedCategoryId == categories[index].menuCategoryId
                      ? Colors.white
                      : Colors.grey[200],
                  border: Border.all(
                    color: Colors.grey[100],
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
                    await Provider.of<CurrentMenuProvider>(context,
                            listen: false)
                        .setCurrentCategoryId(selectedCategoryId);
                    Provider.of<CurrentMenuProvider>(context, listen: false)
                        .getSelectedMenuItems
                        .forEach((item) {
                      if (item.ifChanged == false) {
                        item.price *= (1 + newPricePercentage);
                        item.ifChanged = true;
                      }
                    });
                  },
                ));
          },
        ),
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
                            title: Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: ScreenUtil().setWidth(1)),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  //img
                                  itemImage(menuItems, menuItem, itemIndex),
                                  WEmptyView(15),
                                  // text and tool
                                  itemTitleAndDecr(menuItem)
                                ],
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
          Text("${AppLocalizationHelper.of(context).translate("NoItemError")}",
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
          "${AppLocalizationHelper.of(context).translate("Sold Out")}",
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
                                    disabledText:
                                        "${AppLocalizationHelper.of(context).translate("Dine-in")}",
                                    enabledText:
                                        "${AppLocalizationHelper.of(context).translate("Take-away")}",
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
                  ? 3 * SizeHelper.heightMultiplier
                  : 5 * SizeHelper.widthMultiplier,
              width: SizeHelper.isMobilePortrait
                  ? 15 * SizeHelper.widthMultiplier
                  : 8 * SizeHelper.heightMultiplier,
              child: FlatButton(
                onPressed: () {
                  _showAddOnPopUp(menuItem);
                },
                child: Text(
                  "${AppLocalizationHelper.of(context).translate("Add-On")}",
                  style: GoogleFonts.lato(
                    color: Colors.white,
                    fontSize: SizeHelper.isMobilePortrait
                        ? 1.2 * SizeHelper.textMultiplier
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
                              // submit(); // TODO submit
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
                              // Text(
                              //   'Take away:',
                              //   style: GoogleFonts.lato(
                              //       fontSize: SizeHelper.isMobilePortrait
                              //           ? 3 * SizeHelper.textMultiplier
                              //           : 1.5 * SizeHelper.textMultiplier
                              //       // fontSize: ScreenUtil().setSp((ScreenHelper.isLandScape(context)?MediaQuery.of(context).size.height*0.019:MediaQuery.of(context).size.height*0.02)),
                              //       ),
                              // ),
                              WEmptyView(ScreenUtil().setSp(70)),
                              // Switch(
                              //   value: orderItem.isTakeAway,
                              //   onChanged: (v) {
                              //     setItemState(
                              //       () {
                              //         orderItem.isTakeAway = v;
                              //       },
                              //     );
                              //   },
                              //   activeColor: Colors.blue[500],
                              //   activeTrackColor: Colors.blue[300],
                              //   inactiveTrackColor: Colors.grey[300],
                              //   inactiveThumbColor: Colors.grey[500],
                              // ),
                              Divider(
                                thickness: ScreenUtil().setSp(2),
                              ),
                            ],
                          ),
                        ),
                  VEmptyView(SizeHelper.widthMultiplier * 2),
                  Text(
                      '${orderItem.menuItem.menuItemName} (\$${orderItem.menuItem.price})',
                      style: GoogleFonts.lato(
                          fontWeight: FontWeight.bold,
                          fontSize: SizeHelper.isMobilePortrait
                              ? 1.5 * SizeHelper.textMultiplier
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
                            "${AppLocalizationHelper.of(context).translate("TotalAmount")} ",
                            style: GoogleFonts.lato(
                                fontSize: SizeHelper.isMobilePortrait
                                    ? 2 * SizeHelper.textMultiplier
                                    : 2 * SizeHelper.textMultiplier),
                          ),
                          Text(' \$ ${orderItem.price.toStringAsFixed(2)}',
                              style: GoogleFonts.lato(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: SizeHelper.isMobilePortrait
                                      ? 2 * SizeHelper.textMultiplier
                                      : 2 * SizeHelper.textMultiplier)),
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
                                    "${AppLocalizationHelper.of(context).translate("Next")} ",
                                    style: GoogleFonts.lato(
                                        fontSize: SizeHelper.isMobilePortrait
                                            ? 1.5 * SizeHelper.textMultiplier
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
                                  // Provider.of<CurrentOrderProvider>(context,
                                  //         listen: false)
                                  //     .updateOrderItem(orderItem);
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
    double widgetWidth = ScreenHelper.isLandScape(context)
        ? 15 * SizeHelper.widthMultiplier
        : 20 * SizeHelper.widthMultiplier;
    // double widgetHeight = widgetWidth;
    return
        // width: ScreenUtil().setWidth(200),
        //height: ScreenUtil().setHeight(220),
        Container(
      // width: ScreenHelper.isLargeScreen(context)
      //     ? 180
      //     : SizeHelper.widthMultiplier * 20,
      // height: ScreenHelper.isLandScape(context)
      //     ? SizeHelper.widthMultiplier * 50
      //     : SizeHelper.heightMultiplier * 20,
      decoration: BoxDecoration(
          borderRadius:
              BorderRadius.all(Radius.circular(ScreenUtil().setSp(14)))),
      child: Stack(
        children: [
          menuItem.imageUrl == null
              ? Container(
                  // height: widgetHeight,
                  width: widgetWidth,
                  child: Container()
                  // Center(
                  //   child: CircleAvatar(
                  //     radius: SizeHelper.imageSizeMultiplier * 10,
                  //     child: Center(
                  //       child: Text(
                  //         menuItems[itemIndex].menuItemName.substring(0, 1),
                  //         style: GoogleFonts.lato(
                  //           color: Colors.white,
                  //           fontSize: SizeHelper.isMobilePortrait
                  //               ? 5 * SizeHelper.textMultiplier
                  //               : 5 * SizeHelper.textMultiplier,
                  //         ),
                  //       ),
                  //     ),
                  //     backgroundColor: Color(0xff5352ec),
                  //   ),
                  // ),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //title
            Padding(
              padding: EdgeInsets.only(bottom: ScreenUtil().setHeight(1)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${menuItem.menuItemName}',
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold,
                      fontSize: SizeHelper.isMobilePortrait
                          ? 2 * SizeHelper.textMultiplier
                          : 2 * SizeHelper.textMultiplier,
                    ),
                    overflow: TextOverflow.clip,
                    textAlign: TextAlign.left,
                  ),
                  if (menuItem.subtitle != null && menuItem.subtitle.length > 0)
                    Text(
                      '${menuItem.subtitle}',
                      textAlign: TextAlign.start,
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
                            : 190),
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
                                ? 1.8 * SizeHelper.textMultiplier
                                : 1.5 * SizeHelper.textMultiplier,
                          ),
                        ),
                      ),
                      Text('\$${menuItem.price.toStringAsFixed(2)}',
                          style: GoogleFonts.lato(
                              textStyle: TextStyle(
                            fontSize: SizeHelper.isMobilePortrait
                                ? 2 * SizeHelper.textMultiplier
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
    return Container();
  }

  bool checkStoreOutOfOrderRange() {
    // for store have no coordinates, handle it as not out of range
    if (store.coordinate == null) return false;
    Coordinates userCoord =
        Provider.of<CurrentUserProvider>(context, listen: false).getUserCoord;

    double distance = LocationHelper.calcualteDistanceInMeter(
        userCoord.latitude,
        userCoord.longitude,
        store.coordinate[0],
        store.coordinate[1]);

    return (distance > STORE_ORDER_DISTANCE);
  }

  bool checkStoreInOpeningHours() {
    // return true if store is in opening time.
    if (store.openTime == null || store.closeTime == null) return true;
    TimeOfDay currentTime = TimeOfDay.fromDateTime(DateTime.now());

    return (DateTimeHelper.compareTimeOfDays(store.openTime, currentTime) &&
        DateTimeHelper.compareTimeOfDays(currentTime, store.closeTime));
  }
}

class StoreInfo extends StatelessWidget {
  const StoreInfo(
      {Key key,
      @required this.context,
      @required this.outOfOrderRange,
      @required this.notInOpeningHour,
      @required this.s})
      : super(key: key);

  final BuildContext context;
  final bool outOfOrderRange;
  final bool notInOpeningHour;
  final Store s;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: SizeHelper.textMultiplier * 8.5,
          left: SizeHelper.textMultiplier * 2.2,
          right: SizeHelper.textMultiplier * 2.2),
      // width: SizeHelper.widthMultiplier * 240,
      // height: SizeHelper.heightMultiplier * 150,
      child: Card(
        child: Container(
          margin: EdgeInsets.only(
              top: SizeHelper.textMultiplier * 2,
              left: SizeHelper.textMultiplier * 2,
              right: SizeHelper.textMultiplier * 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${s.storeName}",
                    textAlign: TextAlign.start,
                    style: GoogleFonts.lato(
                        fontWeight: FontWeight.bold,
                        fontSize: ScreenUtil().setSp(60)),
                  ),
                  // VEmptyView(ScreenHelper.isLandScape(context) ? 0 : 20),
                  // Text(
                  //   "${s.location}",
                  //   style: GoogleFonts.lato(
                  //     fontWeight: FontWeight.normal,
                  //     fontSize: SizeHelper.isMobilePortrait
                  //         ? 2 * SizeHelper.textMultiplier
                  //         : 2 * SizeHelper.textMultiplier,
                  //   ),
                  // ),
                  VEmptyView(20),

                  Row(
                    children: <Widget>[
                      Text(
                        s.storeBusinessCategories?.first?.catName ?? "Food",
                        style: GoogleFonts.lato(
                          fontWeight: FontWeight.w500,
                          fontSize: SizeHelper.isMobilePortrait
                              ? 2 * SizeHelper.textMultiplier
                              : 1.8 * SizeHelper.textMultiplier,
                        ),
                      ),
                      WEmptyView(20),
                      if (s.campaign != null)
                        StoreCampaignBadge(
                          campaign: s.campaign,
                        ),
                    ],
                  ),
                  VEmptyView(20),

                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.access_time,
                        color: Colors.grey,
                        size: SizeHelper.textMultiplier * 2,
                      ),
                      Text(
                        "${AppLocalizationHelper.of(context).translate("OpenTime")}" +
                            "${s.openTime.hour}" +
                            (s.openTime.hour >= 12 ? "pm-" : "am-") +
                            "${s.closeTime.hour}" +
                            (s.closeTime.hour >= 12 ? "pm" : "am"),
                        style: GoogleFonts.lato(
                          fontWeight: FontWeight.w400,
                          fontSize: SizeHelper.isMobilePortrait
                              ? 1.8 * SizeHelper.textMultiplier
                              : 1.8 * SizeHelper.textMultiplier,
                        ),
                      ),
                    ],
                  ),

                  VEmptyView(10),
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.airport_shuttle_outlined,
                        color: Colors.grey,
                        size: SizeHelper.textMultiplier * 2,
                      ),
                      Text(
                        EstimatedTimeHelper.generateEstimatedDistance(
                            s.distance),
                        style: GoogleFonts.lato(
                          fontWeight: FontWeight.w400,
                          fontSize: SizeHelper.isMobilePortrait
                              ? 1.8 * SizeHelper.textMultiplier
                              : 1.8 * SizeHelper.textMultiplier,
                        ),
                      )
                    ],
                  ),

                  !notInOpeningHour && !outOfOrderRange
                      ? Container()
                      : Container(
                          margin: EdgeInsets.only(
                              top: SizeHelper.heightMultiplier * .5),
                          decoration: BoxDecoration(
                              color: orderNoteBackgroundColor,
                              borderRadius: BorderRadius.circular(
                                  SizeHelper.textMultiplier * 1)),
                          child: Padding(
                            padding: EdgeInsets.all(SizeHelper.textMultiplier),
                            child: Text((outOfOrderRange)
                                ? "${AppLocalizationHelper.of(context).translate("StoreOutRange")}"
                                : notInOpeningHour
                                    ? "${AppLocalizationHelper.of(context).translate("StoreNotOpen")}"
                                    : "${AppLocalizationHelper.of(context).translate("OpenTime")}" +
                                        "${s.openTime.format(context)} - ${s.closeTime.format(context)}"),
                          )),
                ],
              ),
              Column(
                children: [
                  Container(
                      alignment: Alignment.topRight,
                      child: SquareFadeInImage(s.logoUrl)),
                  Container(
                    alignment: Alignment.bottomRight,
                    child: InkWell(
                      child: Column(
                        children: [
                          VEmptyView(20),
                          new Icon(
                            FontAwesomeIcons.mapMarkedAlt,
                            color: Colors.green,
                            size: SizeHelper.imageSizeMultiplier * 5,
                          ),
                        ],
                      ),
                      onTap: () {
                        pushNewScreen(context,
                            screen: storeLocationPage(),
                            withNavBar: false,
                            pageTransitionAnimation:
                                PageTransitionAnimation.fade);
                      },
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

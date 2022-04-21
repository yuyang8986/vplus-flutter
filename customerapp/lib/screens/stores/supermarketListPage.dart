import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:geocoder/model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:vplus/helper/appLocalizationHelper.dart';
import 'package:vplus/helper/screenHelper.dart';
import 'package:vplus/helper/sizeHelper.dart';
import 'package:vplus/models/Order.dart';
import 'package:vplus/models/OrderItem.dart';
import 'package:vplus/models/menuCategory.dart';
import 'package:vplus/models/menuItem.dart';
import 'package:vplus/models/storeMenu.dart';
import 'package:vplus/models/userOrderItemAddOn.dart';
import 'package:vplus/providers/carousel_provider.dart';
import 'package:vplus/providers/current_order_provider.dart';
import 'package:vplus/providers/currentuser_provider.dart';
import 'package:vplus/providers/groceries_item_provider.dart';
import 'package:vplus/screens/auth/signin.dart';
import 'package:vplus/screens/order/table_bottom_bar/bottom_bar_floating_button.dart';
import 'package:vplus/screens/order/table_bottom_bar/bottom_bar_shopping_cart_popup.dart';
import 'package:vplus/screens/order/table_bottom_bar/bottom_bar_utils.dart';
import 'package:vplus/screens/stores/SearchItems/search_items_page.dart';
import 'package:vplus/screens/stores/menu_item_detail_page.dart';
import 'package:vplus/styles/color.dart';
import 'package:vplus/widgets/appBar.dart';
import 'package:vplus/widgets/components.dart';
import 'package:vplus/widgets/emptyView.dart';
import 'package:vplus/widgets/itemCounter.dart';
import 'package:vplus/widgets/silders.dart';
import 'package:vplus/widgets/userLocation_bar.dart';

import '../welcome.dart';
import 'item_category_detailed_page.dart';
import 'SearchStore/search_stores_page.dart';

class SupermarketListPage extends StatefulWidget {
  @override
  _SupermarketListPageState createState() => _SupermarketListPageState();
}

class _SupermarketListPageState extends State<SupermarketListPage>
    with WidgetsBindingObserver {
  bool isLoading = false;
  ScrollController listViewController = new ScrollController();
  Coordinates deviceCoordinates;
  //StoreMenu _currentStoreMenu;
  PanelController _panelController = PanelController();
  //bool initMenuSuccess = false;
  //List<MenuCategory> _menuCategories;
  int categoryLength;
  bool isCartPoped = false;
  OrderItem selectedOrderItem;
  bool isDialogConfirmed;
  final double _initFabHeight = ScreenUtil().setHeight(50);
  double _fabHeight;
  double _panelHeightOpen;
  double _panelHeightClosed = ScreenUtil().setHeight(130);
  CurrentOrderProvider _currentOrderProvider;
  double newPricePercentage = 0;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void initState() {
    _currentOrderProvider =
        Provider.of<CurrentOrderProvider>(context, listen: false);
    _currentOrderProvider.setOrderWithoutNotify(null);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      deviceCoordinates =
          await Provider.of<CurrentUserProvider>(context, listen: false)
              .initUserGeoInto(context);
      await Provider.of<GroceriesItemProvider>(context, listen: false)
          .getGroceriesItemListByCoordinates(
              context,
              deviceCoordinates.latitude.toString() +
                  "," +
                  deviceCoordinates.longitude.toString());

      await Provider.of<CarouselProvider>(context, listen: false)
          .getCarouselsImageUrls(context);
    });
    _fabHeight = _initFabHeight;
    Future.delayed(Duration.zero, () {
      _showCupertinoAlertDialog(
          context: context,
          title: "Note",
          content:
              "Please note orders before 7:00 pm will be scheduled for delivery next day, orders after 7:00pm will be scheduled for delivery next 48 hours. \nSupport Number: +614 1095 5639 \nWechat: vplus_au \nWhatsApp: +614 1095 5639 \nEmail: support@vplus.com.au",
          sureText: "OK");
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // if (isCartPoped ?? false) return Container();
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
    return RefreshIndicator(
      onRefresh: () async {
        deviceCoordinates =
            await Provider.of<CurrentUserProvider>(context, listen: false)
                .initUserGeoInto(context);
        await Provider.of<GroceriesItemProvider>(context, listen: false)
            .getGroceriesItemListByCoordinates(
                context,
                deviceCoordinates.latitude.toString() +
                    "," +
                    deviceCoordinates.longitude.toString());
      },
      child: Consumer<CurrentOrderProvider>(builder: (context, value, child) {
        int count = Provider.of<CurrentOrderProvider>(context, listen: false)
                .getOrder
                ?.userItems
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
            floatingActionButton:
                Provider.of<CurrentUserProvider>(context).getloggedInUser ==
                        null
                    ? Container(
                        width: SizeHelper.widthMultiplier * 20,
                        height: SizeHelper.heightMultiplier * 10,
                        child: FloatingActionButton(
                          backgroundColor: appThemeColor,
                          onPressed: () {
                            Navigator.of(context).pushAndRemoveUntil(
                              CupertinoPageRoute(
                                builder: (BuildContext context) {
                                  return SignInPage();
                                },
                              ),
                              (_) => false,
                            );
                          },
                          child: Provider.of<CurrentUserProvider>(context)
                                      .getloggedInUser ==
                                  null
                              ? CustomAppBar.signUpButton(context)
                              : Container(),
                        ),
                      )
                    : null,
            appBar: Provider.of<CurrentUserProvider>(context).getloggedInUser ==
                    null
                ? null
                : CustomAppBar.getAppBar(
                    "${AppLocalizationHelper.of(context).translate("Groceries")}",
                    true,
                    context: context,
                  ),
            body: body(context, count));
      }),
    );
  }

  @override
  void dispose() {
    // webDispose();
    super.dispose();
  }

  void _showCupertinoAlertDialog(
      {context, String title, String content, String sureText}) {
    showCupertinoDialog<int>(
        context: context,
        builder: (cxt) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: Text(content),
            actions: <Widget>[
//        CupertinoDialogAction(child: Text("取消"),onPressed: (){
//          Navigator.pop(cxt,1);
//        },),
              CupertinoDialogAction(
                child: Text(sureText),
                onPressed: () {
                  Navigator.pop(cxt, 2);
//          clockJudge();
                },
              )
            ],
          );
        });
  }

  Widget SearchItemBar(BuildContext context) {
    return Row(children: [
      Expanded(
          child: Container(
        constraints: BoxConstraints(
            minHeight: ScreenHelper.isLandScape(context)
                ? 20
                : SizeHelper.heightMultiplier * 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ScreenUtil().setSp(40)),
          // color: Colors.grey[200],
          border: Border.all(
            color: Colors.grey[300],
            width: ScreenUtil().setSp(5),
          ),
        ),
        margin: ScreenHelper.isLandScape(context)
            ? EdgeInsets.fromLTRB(10, 10, 10, 10)
            : EdgeInsets.fromLTRB(
                SizeHelper.widthMultiplier * 4,
                SizeHelper.heightMultiplier * 2,
                SizeHelper.widthMultiplier * 4,
                SizeHelper.heightMultiplier * 4),
        child: InkWell(
            key: Key('searchStoresBar'),
            onTap: () {
              pushNewScreen(context,
                  screen: SearchItemsPage(), withNavBar: false);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                WEmptyView(40),
                Icon(Icons.search,
                    color: appThemeColor, size: ScreenUtil().setSp(60)),
                WEmptyView(40),
                Text(
                    "${AppLocalizationHelper.of(context).translate("itemSearch")}",
                    style: GoogleFonts.lato(fontWeight: FontWeight.normal))
              ],
            )),
      )),
    ]);
  }

  Widget CategoryTypeBar(BuildContext context, menuCategories, menu) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setSp(15),
      ),
      child: ModalProgressHUD(
          inAsyncCall: isLoading,
          progressIndicator: CircularProgressIndicator(),
          child: Wrap(
            spacing: 2,
            runSpacing: 5,
            children: Categories(menuCategories, menu),
          )),
    );
  }

  List<Widget> Categories(List<MenuCategory> menuCategories, menu) =>
      List.generate(menuCategories.length, (index) {
        return Container(
            constraints:
                BoxConstraints(minWidth: SizeHelper.widthMultiplier * 15),
            margin: EdgeInsets.symmetric(
                horizontal: SizeHelper.widthMultiplier * 2),
            child: InkWell(
              onTap: () async {
                pushNewScreen(context,
                    screen: ItemCategoryDetailedPage(
                      itemType: menuCategories[index],
                      currentStoreMenu: menu,
                    ));
              },
              child: Container(
                  margin: EdgeInsets.only(top: SizeHelper.heightMultiplier * 1),
                  child: Column(children: [
                    (menuCategories[index].menuCategoryImageUrl == null)
                        ? ClipOval(
                            child: Image.asset("assets/images/logo-small.png",
                                width: ScreenUtil().setSp(
                                    ScreenHelper.isLandScape(context)
                                        ? 60
                                        : 100),
                                scale: 2))
                        : ClipOval(
                            child: Container(
                                width: SizeHelper.widthMultiplier * 10,
                                height: SizeHelper.heightMultiplier * 5,
                                child: SquareFadeInImage(menuCategories[index]
                                    .menuCategoryImageUrl))),
                    Text(menuCategories[index].menuCategoryName,
                        style: GoogleFonts.lato(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w600)),
                    Text(menuCategories[index].menuSubtitle,
                        style: GoogleFonts.lato(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w600))
                  ])),
            ));
      });
  Widget ItemCards(BuildContext context, menuItems) {
    List<MenuItem> popularItems = [];
    for (int i = 0; i < menuItems.length; i++) {
      if (menuItems[i].isPopular == true) {
        popularItems.add(menuItems[i]);
      }
    }
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setSp(15),
      ),
      child: ModalProgressHUD(
          inAsyncCall: isLoading,
          progressIndicator: CircularProgressIndicator(),
          child: Wrap(
            spacing: ScreenHelper.isLandScape(context)
                ? 5 * SizeHelper.widthMultiplier
                : 5 * SizeHelper.widthMultiplier,
            runSpacing: 5,
            children: Items(popularItems),
          )),
    );
  }

  List<Widget> Items(List<MenuItem> popularItems) =>
      List.generate(popularItems.length, (index) {
        return SizedBox(
            width: ScreenHelper.isLandScape(context)
                ? 145 * SizeHelper.widthMultiplier
                : 45 * SizeHelper.widthMultiplier,
          height: SizeHelper.heightMultiplier * 42,
            child: InkWell(
                onTap: () {
                  pushNewScreen(context,
                      screen: MenuItemDetailPage(item: popularItems[index]));
                },
                child: Card(
                    elevation: 2,
                    child: Padding(
                        padding: EdgeInsets.only(
                            top: 0, left: 8, right: 8, bottom: 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              width: ScreenHelper.isLandScape(context)
                                  ? 30 * SizeHelper.widthMultiplier
                                  : 45 * SizeHelper.widthMultiplier,
                              child: itemImage(
                                  popularItems, popularItems[index], index),
                            ),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        constraints: BoxConstraints(
                                            maxWidth:
                                                SizeHelper.widthMultiplier *
                                                    35),
                                        child: Text(
                                            popularItems[index].menuItemName,
                                            style: GoogleFonts.lato(
                                                fontWeight: FontWeight.bold,
                                                fontSize: ScreenHelper
                                                        .isLandScape(context)
                                                    ? SizeHelper
                                                            .textMultiplier *
                                                        3
                                                    : SizeHelper
                                                            .textMultiplier *
                                                        2)),
                                      ),
                                      Container(
                                        constraints: BoxConstraints(
                                            maxWidth:
                                                SizeHelper.widthMultiplier *
                                                    37),
                                        child: Text(
                                            popularItems[index]?.subtitle ?? "",
                                            style: GoogleFonts.lato(
                                                fontWeight: FontWeight.bold,
                                                fontSize: ScreenHelper
                                                        .isLandScape(context)
                                                    ? SizeHelper
                                                            .textMultiplier *
                                                        3
                                                    : SizeHelper
                                                            .textMultiplier *
                                                        2)),
                                      ),
                                      Text(
                                          "${AppLocalizationHelper.of(context).translate("ItemPrice")}: \$" +
                                              popularItems[index]
                                                  .price
                                                  .toStringAsFixed(2)
                                              ,
                                          style: GoogleFonts.lato(
                                              fontSize: ScreenHelper
                                                      .isLandScape(context)
                                                  ? SizeHelper.textMultiplier *
                                                      3
                                                  : SizeHelper.textMultiplier *
                                                      2)),
                                    ],
                                  ),
                                ]),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(""),
                                  itemButtons(popularItems[index])
                                ])
                          ],
                        )))));
      });

  getMainContent() {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      progressIndicator: CircularProgressIndicator(),
      child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          controller: this.listViewController,
          child: Container(child: _body())),
    );
  }

  _body() {
    return Column(children: [
      Provider.of<CurrentUserProvider>(context).getloggedInUser == null
          ? VEmptyView(100)
          : Container(),
      UserLocationBar(),
      SearchItemBar(context),
      CarouselWithIndicator(),
      VEmptyView(50),
      Consumer<GroceriesItemProvider>(builder: (ctx, p, w) {
        var storeMenu = p.getStoreMenu;
        if (storeMenu == null)
          return Container(
            margin: EdgeInsets.all(20),
            child: Center(
                child: Text(
              "${AppLocalizationHelper.of(context).translate("notInRegion")}",
              style: GoogleFonts.lato(
                  fontSize: SizeHelper.textMultiplier * 2.5,
                  fontWeight: FontWeight.bold),
            )),
          );

        if (storeMenu != null && _currentOrderProvider.getOrder == null) {
          Provider.of<CurrentOrderProvider>(context, listen: false)
              .setOrderWithoutNotify(new Order(
                  storeMenuId: storeMenu?.storeMenuId,
                  userItems: [],
                  totalAmount: 0,
                  numberOfItems: 0));
        }
        return Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(
                  left: SizeHelper.widthMultiplier * 4,
                  bottom: SizeHelper.widthMultiplier * 3),
              child: Text(
                "${AppLocalizationHelper.of(context).translate("Category")}",
                style: GoogleFonts.lato(
                  fontWeight: FontWeight.w900,
                  fontSize: SizeHelper.isMobilePortrait
                      ? 2 * SizeHelper.textMultiplier
                      : 2 * SizeHelper.textMultiplier,
                  color: Colors.black,
                ),
              ),
            ),
            VEmptyView(20),
            CategoryTypeBar(context, storeMenu.menuCategories, storeMenu),
            VEmptyView(160),
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(
                  left: SizeHelper.widthMultiplier * 4,
                  bottom: SizeHelper.widthMultiplier * 3),
              child: Text(
                "${AppLocalizationHelper.of(context).translate("Featured")}",
                style: GoogleFonts.lato(
                  fontWeight: FontWeight.w900,
                  fontSize: SizeHelper.isMobilePortrait
                      ? 2.5 * SizeHelper.textMultiplier
                      : 2 * SizeHelper.textMultiplier,
                  color: Colors.black,
                ),
              ),
            ),
            ItemCards(context, storeMenu.menuItems),
            VEmptyView(250),
          ],
        );
      })
    ]);
  }

  Widget body(BuildContext context, int count) {
    return Stack(children: [
      getMainContent(),
      if (Provider.of<GroceriesItemProvider>(context, listen: false)
                  .getStoreMenu !=
              null &&
          Provider.of<CurrentOrderProvider>(context, listen: false)
                  .getOrder
                  ?.userItems !=
              null &&
          Provider.of<CurrentUserProvider>(context, listen: false)
                  .getloggedInUser !=
              null)
        SlidingUpPanel(
          maxHeight: _panelHeightOpen,
          controller: _panelController,
          minHeight: _panelHeightClosed,
          panelBuilder: (sc) => TableShoppingCartDetails(
              scrollController: sc, isStoreOrdering: true),
          borderRadius: BottomBarUtils.bottomBarRadius(),
          isDraggable: count < 1 ? false : true,
          backdropEnabled: true,
          onPanelOpened: () {
            setState(() {
              isCartPoped = true;
            });
          },
          onPanelClosed: () {
            setState(() {
              isCartPoped = false;
            });
          },
        ),
      if (Provider.of<GroceriesItemProvider>(context, listen: false)
                  .getStoreMenu !=
              null &&
          Provider.of<CurrentOrderProvider>(context, listen: false)
                  .getOrder
                  ?.userItems !=
              null &&
          Provider.of<CurrentUserProvider>(context, listen: false)
                  .getloggedInUser !=
              null)
        TableFloatingButton(
          buttonPosition: _fabHeight - 15,
          isPopUp: isCartPoped, // TODO change this
        ),
      // TableFloatingCloseButton(
      //   buttonPosition: _panelHeightOpen - 185,
      //   isPopUp: true, // TODO change this
      // ),
    ]);
  }

  Widget itemButtons(MenuItem menuItem) {
    bool itemExists = false;
    OrderItem orderItem;
    // bool initFlag = true;
    itemExists = _currentOrderProvider.checkIfItemInOrder(menuItem);
    int itemQuantity = 0;
    if (itemExists == true) {
      orderItem =
          _currentOrderProvider.getOrderItemByMenuItemId(menuItem.menuItemId);
      itemQuantity = _currentOrderProvider
          .getOrderItemByMenuItemId(menuItem.menuItemId)
          .quantity;
    }

    return (menuItem.isSoldOut == true)
        ? Container()
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ItemCounter(
                initNumber: itemQuantity,
                counterCallback: (v) async {
                  itemExists =
                      _currentOrderProvider.checkIfItemInOrder(menuItem);
                  if (v == 1 && itemExists == false) {
                    orderItem = await initOrderItem(menuItem);
                    _currentOrderProvider.addOrderItem(orderItem);
                    setState(() {
                      itemExists = true;
                    });
                  } else if (v == 0) {
                    _currentOrderProvider.removeOrderItem(orderItem);
                    setState(() {
                      itemExists = false;
                      itemQuantity = 0;
                    });
                  } else {
                    orderItem.quantity = v;
                    // orderItem.isTakeAway = isTakeAway;
                    _currentOrderProvider.updateOrderItem(orderItem);
                  }
                },
              ),
              VEmptyView(ScreenUtil().setSp(40)),
            ],
          );
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
    orderItem.menuItem.menuAddOns = null;
    // if (menuItem.hasAddOns == true) {
    //   orderItem.menuItem.menuAddOns =
    //   await Provider.of<CurrentMenuProvider>(context, listen: false)
    //       .getMenuAddOnsByMenuitemId(context, menuItem.menuItemId);
    // }
    orderItem.itemStatus = ItemStatus.AwaitingConfirmation;
    return orderItem;
  }
}

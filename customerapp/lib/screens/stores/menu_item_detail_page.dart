import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:vplus/helper/appLocalizationHelper.dart';
import 'package:vplus/helper/screenHelper.dart';
import 'package:vplus/helper/sizeHelper.dart';
import 'package:vplus/models/OrderItem.dart';
import 'package:vplus/models/menuItem.dart';
import 'package:vplus/models/userOrderItemAddOn.dart';
import 'package:vplus/providers/current_order_provider.dart';
import 'package:vplus/providers/currentuser_provider.dart';
import 'package:vplus/providers/groceries_item_provider.dart';
import 'package:vplus/screens/order/table_bottom_bar/bottom_bar_floating_button.dart';
import 'package:vplus/screens/order/table_bottom_bar/bottom_bar_shopping_cart_popup.dart';
import 'package:vplus/screens/order/table_bottom_bar/bottom_bar_utils.dart';
import 'package:vplus/styles/color.dart';
import 'package:vplus/widgets/components.dart';
import 'package:vplus/widgets/emptyView.dart';
import 'package:vplus/widgets/itemCounter.dart';

class MenuItemDetailPage extends StatefulWidget {
  final MenuItem item;

  MenuItemDetailPage({this.item});

  @override
  _MenuItemDetailPageState createState() => _MenuItemDetailPageState();
}

class _MenuItemDetailPageState extends State<MenuItemDetailPage> {
  bool isLoading = false;
  ScrollController listViewController = new ScrollController();
  final double _initFabHeight = ScreenUtil().setHeight(50);
  double _fabHeight;
  double _panelHeightOpen;
  double _panelHeightClosed = ScreenUtil().setHeight(130);
  PanelController _panelController = PanelController();
  bool isCartPoped = false;

  @override
  void initState() {
    _fabHeight = _initFabHeight;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentOrderProvider>(builder: (context, value, child) {
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
          appBar: AppBar(
            backgroundColor: Colors.white,
            leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            title: Text("${widget.item.menuItemName}",
                style: GoogleFonts.lato(
                    color: Colors.black, fontWeight: FontWeight.normal)),
            centerTitle: true,
          ),
          body: Stack(
            children: [
              ModalProgressHUD(
                inAsyncCall: isLoading,
                progressIndicator: CircularProgressIndicator(),
                child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    controller: this.listViewController,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: ScreenHelper.isLandScape(context)
                                ? 30 * SizeHelper.widthMultiplier
                                : 100 * SizeHelper.widthMultiplier,
                            child: AspectRatio(
                                //上面的宽高比模块
                                aspectRatio: 1.0 / 1.0, //宽高比为2/1
                                child: SquareFadeInImage(widget.item.imageUrl)),
                          ),
                          Divider(
                            thickness: 2,
                          ),
                          Container(
                            constraints: BoxConstraints(
                                maxWidth: SizeHelper.widthMultiplier * 70),
                            child: Text("${widget.item.menuItemName}",
                                style: GoogleFonts.lato(
                                    fontWeight: FontWeight.bold,
                                    fontSize: ScreenHelper.isLandScape(context)
                                        ? SizeHelper.textMultiplier * 3
                                        : SizeHelper.textMultiplier * 3)),
                          ),
                          Container(
                            constraints: BoxConstraints(
                                maxWidth: SizeHelper.widthMultiplier * 70),
                            child: Text("${widget.item.subtitle}",
                                style: GoogleFonts.lato(
                                    fontWeight: FontWeight.bold,
                                    fontSize: ScreenHelper.isLandScape(context)
                                        ? SizeHelper.textMultiplier * 3
                                        : SizeHelper.textMultiplier * 3)),
                          ),
                          Text("\$${widget.item.price.toStringAsFixed(2)}",
                              style: GoogleFonts.lato(
                                  fontSize: ScreenHelper.isLandScape(context)
                                      ? SizeHelper.textMultiplier * 3
                                      : SizeHelper.textMultiplier * 2.5)),
                          VEmptyView(50),
                          VEmptyView(50),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  width: ScreenHelper.isLandScape(context)
                                      ? 30 * SizeHelper.widthMultiplier
                                      : 25 * SizeHelper.widthMultiplier,
                                  child: itemButtons(widget.item))
                            ],
                          ),
                          Text(
                              "${AppLocalizationHelper.of(context).translate("ItemDescription")}: ${widget.item.description}",
                              style: GoogleFonts.lato(
                                  fontSize: ScreenHelper.isLandScape(context)
                                      ? SizeHelper.textMultiplier * 3
                                      : SizeHelper.textMultiplier * 2)),
                          VEmptyView(200)
                        ],
                      ),
                    )),
              ),
              VEmptyView(150),
              if (Provider.of<GroceriesItemProvider>(context, listen: false)
                          .getStoreMenu !=
                      null &&
                  Provider.of<CurrentOrderProvider>(context, listen: false)
                          .getOrder
                          ?.userItems !=
                      null && Provider.of<CurrentUserProvider>(context, listen: false).getloggedInUser != null)
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
                      null && Provider.of<CurrentUserProvider>(context, listen: false).getloggedInUser != null)
                TableFloatingButton(
                  buttonPosition: _fabHeight - 15,
                  isPopUp: isCartPoped, // TODO change this
                ),
            ],
          ));
    });
  }

  Widget itemButtons(MenuItem menuItem) {
    bool itemExists = false;
    OrderItem orderItem;
    CurrentOrderProvider _currentOrderProvider =
        Provider.of<CurrentOrderProvider>(context, listen: false);
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

  OrderItem initOrderItem(MenuItem menuItem) {
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

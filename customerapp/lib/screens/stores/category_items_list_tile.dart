import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:vplus/helper/appLocalizationHelper.dart';
import 'package:vplus/helper/screenHelper.dart';
import 'package:vplus/helper/sizeHelper.dart';
import 'package:vplus/models/OrderItem.dart';
import 'package:vplus/models/menuItem.dart';
import 'package:vplus/models/userOrderItemAddOn.dart';
import 'package:vplus/models/userSavedAddress.dart';
import 'package:vplus/providers/current_order_provider.dart';
import 'package:vplus/providers/user_address_provider.dart';
import 'package:vplus/screens/stores/menu_item_detail_page.dart';
import 'package:vplus/styles/color.dart';
import 'package:vplus/widgets/components.dart';
import 'package:vplus/widgets/emptyView.dart';
import 'package:vplus/widgets/itemCounter.dart';

class CategoryItemListTile extends StatefulWidget {
  final MenuItem item;
  final bool isCategory;

  CategoryItemListTile({Key key, @required this.item, this.isCategory = false})
      : super(key: key);

  @override
  _CategoryItemListTileState createState() => _CategoryItemListTileState();
}

class _CategoryItemListTileState extends State<CategoryItemListTile> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      child: ListTile(
          onTap: () {
            pushNewScreen(context,
                screen: MenuItemDetailPage(item: widget.item));
          },
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: ScreenHelper.isLandScape(context)
                        ? 30 * SizeHelper.widthMultiplier
                        : 20 * SizeHelper.widthMultiplier,
                    child: AspectRatio(
                        //上面的宽高比模块
                        aspectRatio: 1.0 / 1.0, //宽高比为2/1
                        child: itemImage(null, widget.item, null)),
                  ),
                  WEmptyView(10),
                  Container(
                    margin: EdgeInsets.only(
                        left: ScreenHelper.isLandScape(context)
                            ? 10
                            : SizeHelper.widthMultiplier * 2),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${widget.item.menuItemName}",
                              style: GoogleFonts.lato(
                                  fontWeight: FontWeight.bold,
                                  fontSize: ScreenHelper.isLandScape(context)
                                      ? SizeHelper.textMultiplier * 3
                                      : SizeHelper.textMultiplier * 2)),
                          Text("${widget.item.subtitle}",
                              style: GoogleFonts.lato(
                                  fontWeight: FontWeight.bold,
                                  fontSize: ScreenHelper.isLandScape(context)
                                      ? SizeHelper.textMultiplier * 3
                                      : SizeHelper.textMultiplier * 2)),
                          Text(
                              "${AppLocalizationHelper.of(context).translate("ItemDescription")}: ${widget.item.description}",
                              style: GoogleFonts.lato(
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.normal)),
                          Container(
                            constraints: BoxConstraints(
                              maxWidth: SizeHelper.widthMultiplier * 45,
                            ),
                            child: Text(
                                "${AppLocalizationHelper.of(context).translate("ItemPrice")}: \$${widget.item.price.toStringAsFixed(2)}",
                                style: GoogleFonts.lato(
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.normal)),
                          )
                        ]),
                  ),
                ],
              ),
              if (widget.isCategory)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  verticalDirection: VerticalDirection.down,
                  children: [itemButtons(widget.item)],
                )
            ],
          )),
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

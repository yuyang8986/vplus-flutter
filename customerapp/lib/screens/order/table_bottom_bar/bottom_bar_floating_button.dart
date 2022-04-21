import 'package:flutter/material.dart';
import 'package:badges/badges.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:provider/provider.dart';
import 'package:vplus/helper/screenHelper.dart';
import 'package:vplus/helper/sizeHelper.dart';
import 'package:vplus/providers/current_order_provider.dart';
import 'package:vplus/providers/currentuser_provider.dart';
import 'package:vplus/styles/color.dart';

import 'bottom_bar_utils.dart';

class TableFloatingCloseButton extends StatelessWidget {
  final bool isCartEmpty = false;
  final double buttonPosition;
  final bool isPopUp;

  TableFloatingCloseButton({
    this.buttonPosition,
    this.isPopUp,
  });

  PanelController panelController;

  @override
  Widget build(BuildContext context) {
    panelController =
        Provider.of<BottomBarEventProvider>(context, listen: false)
            .getPanelController;
    return Positioned(
      // padding: EdgeInsets.only(bottom: (isPopUp) ? buttonPosition : 0),
      left: ScreenHelper.isLandScape(context)
          ? MediaQuery.of(context).size.width / 2.2
          : MediaQuery.of(context).size.width / 2.5,
      bottom: ScreenHelper.isLandScape(context)
          ? buttonPosition + SizeHelper.widthMultiplier * 5
          : buttonPosition + SizeHelper.heightMultiplier * 4,
      child: Consumer<CurrentOrderProvider>(
        builder: (ctx, p, w) {
          if (!isPopUp) {
            return Container();
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FlatButton(
                onPressed: () {
                  panelController.close();
                },
                child: CircleAvatar(
                    radius: ScreenUtil().setSp(
                      ScreenHelper.isLandScape(context)
                          ? SizeHelper.imageSizeMultiplier * 3
                          : SizeHelper.imageSizeMultiplier * 12,
                    ),
                    backgroundColor: Colors.black,
                    child: Center(
                      child: Icon(Icons.close,
                          color: Colors.white, //Color(0xff343f4b),
                          size: ScreenUtil().setSp(
                            ScreenHelper.isLandScape(context)
                                ? SizeHelper.imageSizeMultiplier * 6
                                : SizeHelper.imageSizeMultiplier * 12,
                          )),
                    )),
              ),
            ],
          );
        },
      ),
    );
  }
}

class TableFloatingButton extends StatelessWidget {
  final bool isCartEmpty = false;
  final double buttonPosition;
  final bool isPopUp;

  TableFloatingButton({
    this.buttonPosition,
    this.isPopUp,
  });

  PanelController panelController;
  @override
  Widget build(BuildContext context) {
    panelController =
        Provider.of<BottomBarEventProvider>(context, listen: false)
            .getPanelController;
    return Positioned(
      left: 20.0,
      bottom: buttonPosition,
      child: Consumer<CurrentOrderProvider>(
        builder: (ctx, p, w) {
          var order = p.getOrder;
          int numberOfItems = p.countOrderItemNumbers();
          if (order?.userItems == null || order?.userItems?.length == 0
           || Provider.of<CurrentUserProvider>(context, listen: false).getloggedInUser == null
          ) {
            return _getEmptyCart(ctx);
          }
          return _getBadgeCart(ctx, numberOfItems);
        },
      ),
    );
  }

  Widget _getEmptyCart(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        floatingButtonEvent(context);
      },
      child: Icon(
        Icons.shopping_cart_outlined,
        size: ScreenHelper.isLandScape(context)
            ? 35
            : ScreenHelper.isLargeScreen(context)
                ? SizeHelper.imageSizeMultiplier * 4
                : SizeHelper.imageSizeMultiplier * 8,
      ),
      backgroundColor: Color(0xff343f4b),
    );
  }

  Widget _getBadgeCart(BuildContext context, int badgeText) {
    return FloatingActionButton(
      onPressed: () {
        floatingButtonEvent(context);
      },
      child: Badge(
        animationType: BadgeAnimationType.fade,
        animationDuration: Duration(milliseconds: 0),
        position: BadgePosition.topEnd(top: -15, end: -15),
        badgeColor: Color(0xfff61a36),
        badgeContent: Text(
          badgeText.toString(),
          style: GoogleFonts.lato(
            color: Colors.white,
            fontSize: ScreenUtil()
                .setSp(ScreenHelper.getResponsiveTitleFontSize(context)),
          ),
        ),
        child: Icon(
          Icons.shopping_cart_outlined,
          size: ScreenHelper.isLandScape(context)
              ? 35
              : ScreenHelper.isLargeScreen(context)
                  ? SizeHelper.imageSizeMultiplier * 4
                  : SizeHelper.imageSizeMultiplier * 8,
        ),
      ),
      backgroundColor: appThemeColor,
    );
  }

  void floatingButtonEvent(BuildContext context) {
    int count = Provider.of<CurrentOrderProvider>(context, listen: false)
        .getOrder
        .userItems
        .length;
    if (count < 1) return;
    if (isPopUp) {
      panelController.close();
    } else {
      panelController.open();
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/helpers/screenHelper.dart';
import 'package:vplus_merchant_app/helpers/sizeHelper.dart';
import 'package:vplus_merchant_app/styles/color.dart';
import '../../models/menuItem.dart';
import '../../widgets/components.dart';
import '../../widgets/emptyView.dart';

class OrderTableOrderMenuItemTile extends StatelessWidget {
  MenuItem menuItem;
  Widget itemButton;
  OrderTableOrderMenuItemTile(
      {@required this.menuItem, @required this.itemButton});
  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 100 * SizeHelper.heightMultiplier,
      // width: 10 * SizeHelper.widthMultiplier,
      child: _getButtonBody(context),
    );
  }

  Widget _soldOutLabel(BuildContext context) {
    return Center(
      child: Container(
        width: ScreenUtil()
            .setWidth(ScreenHelper.isLandScape(context) ? 165 : 160),
        height: ScreenUtil()
            .setHeight(ScreenHelper.isLandScape(context) ? 140 : 130),
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
          AppLocalizationHelper.of(context).translate('SoldOut'),
          textAlign: TextAlign.center,
          style: GoogleFonts.lato(
              color: Colors.pink,
              fontSize: SizeHelper.isMobilePortrait
                  ? 2 * SizeHelper.textMultiplier
                  : 2 * SizeHelper.textMultiplier),
        ),
      ),
    );
  }

  _getButtonBody(BuildContext context) {
    return Container(
      // constraints: BoxConstraints(
      //   maxHeight: 300 * SizeHelper.heightMultiplier,
      //   minWidth: ScreenUtil().setWidth(220),
      // ),

      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ScreenUtil().setSp(8),
        ),
        border: Border.all(
          color: Colors.grey,
          width: ScreenUtil().setSp(2),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(2),
        child: InkWell(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: ScreenHelper.isLandScape(context)
                    ? SizeHelper.heightMultiplier * 8
                    : ScreenHelper.isLargeScreen(context)
                        ? 165
                        : 120,
                // decoration: BoxDecoration(
                //   // color: Color(0xff5352ec),
                //   borderRadius: BorderRadius.circular(
                //     ScreenUtil().setSp(10),
                //   ),
                //   border: Border.all(
                //     color: Colors.grey,
                //     width: ScreenUtil().setSp(1),
                //   ),
                // ),
                // padding: EdgeInsets.all(ScreenUtil().setSp(2)),
                child: Stack(
                  children: [
                    menuItem.imageUrl == null
                        ? Center(
                            child: CircleAvatar(
                              radius: ScreenHelper.isLargeScreen(context)
                                  ? SizeHelper.imageSizeMultiplier * 10
                                  : SizeHelper.imageSizeMultiplier * 30,
                              child: Text(
                                menuItem.menuItemName.substring(0, 1),
                                style: GoogleFonts.lato(
                                  color: Colors.white,
                                  fontSize: SizeHelper.isMobilePortrait
                                      ? 3 * SizeHelper.textMultiplier
                                      : 5 * SizeHelper.textMultiplier,
                                ),
                              ),
                              backgroundColor: appThemeColor,
                            ),
                          )
                        : SquareFadeInImage(menuItem.imageUrl),
                    menuItem.isSoldOut == true
                        ? _soldOutLabel(context)
                        : Container(),
                  ],
                ),
                height: ScreenUtil()
                    .setHeight(ScreenHelper.isLandScape(context) ? 200 : 210),
              ),
              Text(
                menuItem.menuItemName,
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontSize: ScreenUtil().setSp(
                      ScreenHelper.getResponsiveTextBodyFontSize(context)),
                  color: Colors.black,
                ),
              ),
              // if (menuItem.subtitle != null && menuItem.subtitle.length > 0)
              //   Text(
              //     '${menuItem.subtitle}',
              //     style: GoogleFonts.lato(
              //       fontStyle: FontStyle.italic,
              //       fontSize: SizeHelper.isMobilePortrait
              //           ? 1.5 * SizeHelper.textMultiplier
              //           : 2 * SizeHelper.textMultiplier,
              //     ),
              //   ),
              // Text(
              //   '${menuItem.description}',
              //   maxLines: 2,
              //   softWrap: true,
              //   overflow: TextOverflow.clip,
              //   style: GoogleFonts.lato(
              //     fontStyle: FontStyle.italic,
              //     fontSize: SizeHelper.isMobilePortrait
              //         ? 1.5 * SizeHelper.textMultiplier
              //         : 2 * SizeHelper.textMultiplier,
              //   ),
              // ),
              Text('\$${menuItem.price}',
                  style: GoogleFonts.lato(
                      textStyle: GoogleFonts.lato(
                    fontSize: SizeHelper.isMobilePortrait
                        ? 1.5 * SizeHelper.textMultiplier
                        : 1.7 * SizeHelper.textMultiplier,
                  ))),
              Container(alignment: Alignment.center, child: itemButton),
            ],
          ),
          onTap: () {},
        ),
      ),
    );
  }
}

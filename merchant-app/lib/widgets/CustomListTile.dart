import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/helpers/screenHelper.dart';
import 'package:vplus_merchant_app/helpers/sizeHelper.dart';
import 'package:vplus_merchant_app/models/menuItem.dart';
import 'package:vplus_merchant_app/widgets/emptyView.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vplus_merchant_app/widgets/customized_switch.dart';
import 'package:vplus_merchant_app/widgets/components.dart';

class CustomListTile extends StatelessWidget {
  final MenuItem menuItem;
  final Function soldOutCallback;
  final Function editCallback;
  final bool isMenuLocked;

  CustomListTile(
      {this.menuItem,
      this.soldOutCallback,
      this.editCallback,
      this.isMenuLocked});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey(menuItem.menuItemId),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ScreenUtil().setSp(0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(1, 1), // changes position of shadow
          ),
        ],
      ),
      child: ListTile(
        title: ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: ScreenHelper.isLandScape(context)
                  ? 120
                  : SizeHelper.isMobilePortrait
                      ? (menuItem.subtitle != null &&
                              menuItem.subtitle.length > 0)
                          ? 12 * SizeHelper.heightMultiplier
                          : 12 * SizeHelper.heightMultiplier
                      : SizeHelper.isPortrait
                          ? 12 * SizeHelper.widthMultiplier
                          : 12 * SizeHelper.widthMultiplier),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: ScreenUtil().setWidth(0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: ScreenHelper.isLandScape(context)
                      ? 120
                      : SizeHelper.isMobilePortrait
                          ? 100
                          : 180,
                  height: SizeHelper.isMobilePortrait
                      ? 12 * SizeHelper.heightMultiplier
                      : 60 * SizeHelper.heightMultiplier,
                  child: Stack(
                    children: [
                      Container(
                        // width: ScreenUtil().setWidth(
                        //     ScreenHelper.isLandScape(context) ? 120 : 300),
                        // height: SizeHelper.isMobilePortrait
                        //     ? 20 * SizeHelper.heightMultiplier
                        //     : SizeHelper.isPortrait
                        //         ? 80 * SizeHelper.heightMultiplier
                        //         : 80 * SizeHelper.heightMultiplier,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(
                                14,
                              ),
                            ),
                            border: Border.all(
                              color: Colors.white,
                              width: 2.0,
                            )),
                        child: menuItem.imageUrl == null
                            ? ClipRRect(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(
                                    14,
                                  ),
                                ),
                                child: Container(
                                  color: Color(0xff5352ec),
                                  child: Center(
                                    child: Text(
                                      menuItem.menuItemName.substring(0, 1),
                                      style: GoogleFonts.lato(
                                        color: Colors.white,
                                        fontSize: ScreenUtil().setSp(55),
                                      ),
                                    ),
                                  ),
                                ),
                                // backgroundColor: Color(0xff5352ec),
                              )
                            : SquareFadeInImage(menuItem.imageUrl),
                      ),
                      menuItem.isSoldOut ? _soldOutLabel(context) : Container(),
                    ],
                  ),
                ),
                Expanded(
                  flex: ScreenHelper.isLandScape(context) ? 10 : 8,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: ScreenUtil().setHeight(0),
                        horizontal: ScreenUtil().setWidth(20)),
                    child: Container(
                      height: ScreenHelper.isLargeScreen(context)
                          ? (menuItem.subtitle != null &&
                                  menuItem.subtitle.length > 0)
                              ? SizeHelper.heightMultiplier * 32
                              : SizeHelper.heightMultiplier * 32
                          : !(menuItem.subtitle != null &&
                                  menuItem.subtitle.length > 0)
                              ? SizeHelper.isMobilePortrait
                                  ? 32 * SizeHelper.heightMultiplier
                                  : SizeHelper.isPortrait
                                      ? 20 * SizeHelper.widthMultiplier
                                      : 22 * SizeHelper.widthMultiplier
                              : SizeHelper.isMobilePortrait
                                  ? 32 * SizeHelper.heightMultiplier
                                  : SizeHelper.isPortrait
                                      ? 12 * SizeHelper.widthMultiplier
                                      : 22 * SizeHelper.widthMultiplier,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${menuItem.menuItemName}',
                            maxLines: 1,
                            style: GoogleFonts.lato(
                              fontWeight: FontWeight.bold,
                              fontSize: ScreenUtil().setSp(
                                  ScreenHelper.getResponsiveTextBodyFontSize(
                                      context)),
                            ),
                            overflow: TextOverflow.clip,
                            textAlign: TextAlign.left,
                          ),
                          Container(
                            constraints: BoxConstraints(
                              minHeight: ScreenUtil().setHeight(100),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                if (menuItem.subtitle != null &&
                                    menuItem.subtitle.length > 0)
                                  Text(
                                    '${menuItem.subtitle}',
                                    maxLines: 2,
                                    softWrap: true,
                                    overflow: TextOverflow.clip,
                                    style: GoogleFonts.lato(
                                      fontStyle: FontStyle.italic,
                                      fontSize: ScreenUtil().setSp(ScreenHelper
                                          .getResponsiveTextBodySmallFontSize(
                                              context)),
                                    ),
                                  ),
                                Text(
                                  '${menuItem.description}',
                                  maxLines: 2,
                                  softWrap: true,
                                  overflow: TextOverflow.clip,
                                  style: GoogleFonts.lato(
                                    fontStyle: FontStyle.italic,
                                    fontSize: ScreenUtil().setSp(ScreenHelper
                                        .getResponsiveTextBodySmallFontSize(
                                            context)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '\$${menuItem.price.toStringAsFixed(2).toString()}',
                            style: GoogleFonts.lato(
                                fontSize: ScreenUtil().setSp(
                                    ScreenHelper.getResponsiveTextBodyFontSize(
                                        context))),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: ScreenHelper.isLandScape(context) ? 2 : 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomizedSwitch(
                        menuItem: menuItem,
                        activeColor: Color(0xff5352ec),
                        onChanged: soldOutSwithEvent,
                      ),
                    //  if (isMenuLocked == false)
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: ScreenUtil().setHeight(15)),
                          child: ButtonTheme(
                            // padding: EdgeInsets.symmetric(
                            //     vertical: 4.0, horizontal: 8.0),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            minWidth:
                                ScreenUtil().setWidth(70), //wraps child's width
                            height: ScreenUtil().setHeight(100),
                            child: FlatButton(
                              onPressed: () {
                                editCallback(menuItem.menuItemId);
                              },
                              child: Icon(
                                FontAwesomeIcons.solidEdit,
                                color: Color(0xff5352ec),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> soldOutSwithEvent(bool value) async {
    print("VALUE : $value");
    bool isChanged = await soldOutCallback(menuItem.menuItemId, value);
    return isChanged;
  }

  Widget _soldOutLabel(context) {
    return Center(
        child: Container(
      width: ScreenUtil().setWidth(180),
      height: ScreenHelper.isLandScape(context)
          ? 4 * SizeHelper.heightMultiplier
          : 3 * SizeHelper.heightMultiplier,
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
          fontSize: ScreenUtil().setSp(
            ScreenHelper.getResponsiveTextBodyFontSize(context),
          ),
        ),
      ),
    ));
  }
}

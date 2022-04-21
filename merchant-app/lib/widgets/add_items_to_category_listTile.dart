import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vplus_merchant_app/helpers/screenHelper.dart';
import 'package:vplus_merchant_app/helpers/sizeHelper.dart';
import 'package:vplus_merchant_app/models/menuItem.dart';
import 'package:vplus_merchant_app/providers/current_menu_provider.dart';
import 'package:vplus_merchant_app/widgets/emptyView.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vplus_merchant_app/widgets/customized_switch.dart';
import 'package:vplus_merchant_app/widgets/components.dart';

class AddItemsToCategoryListTile extends StatelessWidget {
  final MenuItem menuItem;
  final Function toggleCheckCallBack;

  AddItemsToCategoryListTile(
      {@required this.menuItem, @required this.toggleCheckCallBack});

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentMenuProvider>(
        builder: (ctx, p, w) {
        return Container(
          key: ValueKey(menuItem.menuItemId),
          child: ListTile(
            title: Center(
              // constraints: BoxConstraints(
              //     maxHeight: ScreenHelper.isLandScape(context)
              //         ? (menuItem.subtitle != null && menuItem.subtitle.length > 0)
              //             ? SizeHelper.heightMultiplier * 20
              //             : SizeHelper.heightMultiplier * 15
              //         : 250),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: ScreenUtil().setWidth(17),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: ScreenUtil()
                          .setWidth(ScreenHelper.isLandScape(context) ? 100 : 280),
                      height: ScreenUtil()
                          .setHeight(ScreenHelper.isLandScape(context) ? 280 : 280),
                      child: Stack(
                        children: [
                          Container(
                            // width: ScreenUtil().setWidth(200),
                            // height: ScreenUtil().setHeight(200),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(
                                    14,
                                  ),
                                ),
                                border: Border.all(
                                  color: borderColor,
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
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: ScreenUtil().setSp(60),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // backgroundColor: Color(0xff5352ec),
                                  )
                                : SquareFadeInImage(menuItem.imageUrl),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: ScreenUtil().setWidth(20)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          // mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${menuItem.menuItemName}',
                              maxLines: 1,
                              textAlign: TextAlign.start,
                              style: GoogleFonts.lato(
                                fontWeight: FontWeight.bold,
                                fontSize: ScreenUtil().setSp(
                                    ScreenHelper.getResponsiveTitleFontSize(
                                        context)),
                              ),
                              overflow: TextOverflow.clip,
                            ),
                            Container(
                              constraints: BoxConstraints(
                                minHeight: ScreenUtil().setHeight(
                                    ScreenHelper.isLandScape(context) ? 80 : 80),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (menuItem.subtitle != null &&
                                      menuItem.subtitle.length > 0)
                                    Text(
                                      '${menuItem.subtitle}',
                                      maxLines: 2,
                                      softWrap: true,
                                      overflow: TextOverflow.clip,
                                      textAlign: TextAlign.start,
                                      style: GoogleFonts.lato(
                                        fontStyle: FontStyle.italic,
                                        fontSize: ScreenUtil().setSp(ScreenHelper
                                            .getResponsiveTextBodyFontSize(
                                                context)),
                                      ),
                                    ),
                                  Text(
                                    '${menuItem.description}',
                                    maxLines: 2,
                                    softWrap: true,
                                    overflow: TextOverflow.clip,
                                    textAlign: TextAlign.start,
                                    style: GoogleFonts.lato(
                                      fontStyle: FontStyle.italic,
                                      fontSize: ScreenUtil().setSp(ScreenHelper
                                          .getResponsiveTextBodyFontSize(context)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '\$${menuItem.price.toStringAsFixed(2).toString()}',
                              textAlign: TextAlign.start,
                              style: GoogleFonts.lato(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _toggleCheck(p.getSelectedMenuItems,p.getStoreMenu.menuItems),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _toggleCheck(selectedMenuItems,unselectedMenuItems) {
    return Center(
      child: Container(
          width: ScreenUtil().setWidth(180),
          height: ScreenUtil().setHeight(60),
          alignment: Alignment.center,
          child: Checkbox(
              value: menuItem.isSelectedForCategory ?? false,
              onChanged: (bool v) {
                toggleCheckCallBack(v, menuItem,selectedMenuItems,unselectedMenuItems);
              })),
    );
  }
}

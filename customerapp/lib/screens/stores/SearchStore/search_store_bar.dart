import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:vplus/helper/appLocalizationHelper.dart';
import 'package:vplus/helper/screenHelper.dart';
import 'package:vplus/helper/sizeHelper.dart';
import 'package:vplus/screens/stores/SearchStore/search_stores_page.dart';
import 'package:vplus/styles/color.dart';
import 'package:vplus/widgets/emptyView.dart';

class SearchStoreBar extends StatefulWidget {
  @override
  _SearchStoreBarState createState() => _SearchStoreBarState();
}

class _SearchStoreBarState extends State<SearchStoreBar> {
  @override
  Widget build(BuildContext context) {
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
                  screen: SearchStoresPage(),
                  withNavBar: false,
                  pageTransitionAnimation: PageTransitionAnimation.fade);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                WEmptyView(40),
                Icon(Icons.search,
                    color: appThemeColor, size: ScreenUtil().setSp(60)),
                WEmptyView(40),
                Text("${AppLocalizationHelper.of(context).translate("storeSearch")}",
                    style: GoogleFonts.lato(fontWeight: FontWeight.normal))
              ],
            )),
      )),
    ]);
  }
}

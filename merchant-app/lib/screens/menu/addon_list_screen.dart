import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:vplus_merchant_app/helpers/apiHelper.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/helpers/screenHelper.dart';
import 'package:vplus_merchant_app/helpers/sizeHelper.dart';
import 'package:vplus_merchant_app/models/menuAddOn.dart';
import 'package:vplus_merchant_app/providers/current_menu_provider.dart';
import 'package:vplus_merchant_app/providers/orderlist_provider.dart';
import 'package:vplus_merchant_app/screens/menu/edit_addon_screen.dart';
import 'package:vplus_merchant_app/screens/menu/new_addon_screen.dart';
import 'package:vplus_merchant_app/screens/menu/new_item_screen.dart';

class AddonListScreen extends StatefulWidget {
  @override
  _AddonListScreenState createState() => _AddonListScreenState();
}

class _AddonListScreenState extends State<AddonListScreen> {
  ScrollController _categoriesCtl = new ScrollController();

  Helper hlp = Helper();

  var organizationId;

  var _saving = false;
  int selectedCategoryId = 0;

  bool isMenuLocked;

  @override
  void initState() {
    isMenuLocked = Provider.of<OrderListProvider>(context, listen: false)
        .isMenuLocked(context);
    super.initState();
  }

  // @override
  // void didChangeDependencies() {
  //   isMenuLocked = Provider.of<OrderListProvider>(context, listen: true)
  //       .isMenuLocked(context);
  //   super.didChangeDependencies();
  // }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        width: 1080, height: 1920, allowFontScaling: false);
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
         newAddonButton(),
          getAddonList(),
        ],
      ),
    );
  }

  Widget newAddonButton() {
    return Container(
      height:
          ScreenUtil().setHeight(ScreenHelper.isLandScape(context) ? 140 : 100),
      margin: EdgeInsets.symmetric(
          vertical: ScreenUtil().setSp(20), horizontal: ScreenUtil().setSp(50)),
      width: double.infinity,
      child: RaisedButton(
        onPressed: () {
          pushNewScreen(
            context,
            screen: NewAddon(),
            withNavBar: false,
            pageTransitionAnimation: PageTransitionAnimation.cupertino,
          );
        },
        textColor: Colors.white,
        color: Color(0xff5352EC),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              AppLocalizationHelper.of(context).translate('NewAddOn'),
              style: GoogleFonts.lato(
                fontWeight: FontWeight.bold,
                fontSize: SizeHelper.textMultiplier *
                    (ScreenHelper.isLandScape(context) ? 2 : 2),
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getAddonList() {
    return Consumer<CurrentMenuProvider>(
      builder: (ctx, p, w) {
        List<MenuAddOn> menuAddOns =
            p.getStoreMenu?.menuAddOns ?? List<MenuAddOn>();
        return Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: menuAddOns.length,
            itemBuilder: (ctx, index) {
              return generateAddonItem(menuAddOns[index]);
            },
          ),
        );
      },
    );
  }

  Widget generateAddonItem(MenuAddOn a) {
    return Container(
      key: ValueKey(a.menuAddOnId),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ScreenUtil().setSp(0)),
        border: Border.all(
          color: Colors.grey,
          width: ScreenUtil().setSp(1),
        ),
      ),
      child: ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    '${a.menuAddOnName} ',
                    style: GoogleFonts.lato(
                        fontWeight: FontWeight.bold,
                        fontSize: ScreenUtil().setSp(
                            ScreenHelper.getResponsiveTextBodyFontSize(
                                context))),
                  ),
                  if (a.subtitle != null && a.subtitle.length > 0)
                    Text(
                      '${a.subtitle} ',
                      style: GoogleFonts.lato(
                          fontStyle: FontStyle.italic,
                          fontSize: ScreenUtil().setSp(
                              ScreenHelper.getResponsiveTextBodyFontSize(
                                  context))),
                    ),
                  Text(
                    '(${a.note}):',
                    style: GoogleFonts.lato(
                        fontWeight: FontWeight.bold,
                        fontSize: ScreenUtil().setSp(
                            ScreenHelper.getResponsiveTextBodyFontSize(
                                context))),
                  ),
                ],
              ),
              InkWell(
                  onTap: () {
                    // TODO set selected addon id to the provider
                    pushNewScreen(
                      context,
                      screen: EditAddon(a, isMenuLocked),
                      withNavBar: false,
                      pageTransitionAnimation:
                          PageTransitionAnimation.cupertino,
                    );
                  },
                  child: Icon(Icons.edit,
                      size: ScreenHelper.isLandScape(context)
                          ? SizeHelper.imageSizeMultiplier * 4
                          : SizeHelper.imageSizeMultiplier * 5)),
            ],
          ),
          onTap: () {}),
    );
  }
}

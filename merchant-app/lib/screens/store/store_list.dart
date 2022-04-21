import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/helpers/permissionHelper.dart';
import 'package:vplus_merchant_app/helpers/screenHelper.dart';
import 'package:vplus_merchant_app/helpers/sizeHelper.dart';
import 'package:vplus_merchant_app/models/apiUser.dart';
import 'package:vplus_merchant_app/models/store.dart';
import 'package:vplus_merchant_app/providers/current_stores_provider.dart';
import 'package:vplus_merchant_app/styles/color.dart';
import 'package:vplus_merchant_app/widgets/components.dart';
import 'package:vplus_merchant_app/widgets/customAppBar.dart';
import 'package:vplus_merchant_app/widgets/custom_dialog.dart';
import 'package:vplus_merchant_app/widgets/emptyView.dart';
import 'package:vplus_merchant_app/widgets/storeDisabledDialog.dart';

class StoreList extends StatefulWidget {
  @override
  _StoreListState createState() => _StoreListState();
}

class _StoreListState extends State<StoreList> {
  bool isLoading = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      setState(() {
        isLoading = true;
      });
      await Provider.of<CurrentStoresProvider>(context, listen: false)
          .getStoreFromAPI(context);
      setState(() {
        isLoading = false;
      });

      // await PermissionHelper.checkMissingPermission(context);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        width: 1080, height: 1920, allowFontScaling: false);
    ScreenHelper.lockOrientation(context);
    return SafeArea(
      bottom: false,
      top: true,
      child: Scaffold(
        //resizeToAvoidBottomInset: true,f
        appBar: CustomAppBar.getAppBar(
          AppLocalizationHelper.of(context).translate("StoreList"),
          true,
          context: context,
          screenPage: CustomAppBar.organizationMainPage,
        ),
        body: ModalProgressHUD(
          inAsyncCall: isLoading,
          child: _storeList(context),
        ),

        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: SpeedDial(
          marginRight: 20,
          backgroundColor: Colors.white,
          foregroundColor: appThemeColor,
          animatedIcon: AnimatedIcons.menu_close,
          animatedIconTheme: IconThemeData(
              size: SizeHelper.isMobilePortrait
                  ? 5 * SizeHelper.imageSizeMultiplier
                  : 4 * SizeHelper.imageSizeMultiplier),
          curve: Curves.bounceIn,
          children: [
            SpeedDialChild(
              onTap: () {
                Navigator.pushNamed(context, "StoreConfig");
              },
              child: Icon(
                Icons.add,
                size: SizeHelper.isMobilePortrait
                    ? 5 * SizeHelper.heightMultiplier
                    : 4 * SizeHelper.widthMultiplier,
              ),
              backgroundColor: appThemeColor,
              shape: CircleBorder(
                  side: BorderSide(color: appThemeColor, width: 4.0)),
              label: AppLocalizationHelper.of(context).translate("StoreConfig"),
              labelStyle: GoogleFonts.lato(
                fontWeight: FontWeight.w500,
                fontSize: SizeHelper.isMobilePortrait
                    ? 1.5 * SizeHelper.textMultiplier
                    : 2 * SizeHelper.textMultiplier,
              ),
              labelBackgroundColor: Colors.white,
            ),
            SpeedDialChild(
              child: Icon(Icons.cached,
                  color: Colors.white,
                  size: SizeHelper.isMobilePortrait
                      ? 5 * SizeHelper.imageSizeMultiplier
                      : 4 * SizeHelper.imageSizeMultiplier),
              backgroundColor: appThemeColor,
              onTap: () async {
                setState(() {
                  isLoading = true;
                });
                await Provider.of<CurrentStoresProvider>(context, listen: false)
                    .getStoreFromAPI(context);
                setState(() {
                  isLoading = false;
                });
              },
              label: AppLocalizationHelper.of(context).translate("Refresh"),
              labelStyle: GoogleFonts.lato(
                fontWeight: FontWeight.w500,
                fontSize: SizeHelper.isMobilePortrait
                    ? 1.5 * SizeHelper.textMultiplier
                    : 2 * SizeHelper.textMultiplier,
              ),
              labelBackgroundColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  _storeList(BuildContext context) {
    return Consumer<CurrentStoresProvider>(builder: (ctx, p, w) {
      var stores = p.getCurrentStores;
      if (stores == null || stores.length == 0) {
        return Container();
      }
      return ListView.builder(
        padding: EdgeInsets.only(
            left: ScreenUtil()
                .setSp(ScreenHelper.isLandScape(context) ? 200 : 100),
            bottom: ScreenUtil().setSp(200)),
        //shrinkWrap: true,
        itemBuilder: (ctx, index) {
          var store = stores[index];
          return _storeListItem(store, ctx);
        },
        itemCount: stores.length,
      );
    });
  }
}

_storeListItem(Store store, BuildContext context) {
  return Padding(
    padding: EdgeInsets.only(
      top: ScreenUtil().setSp(30),
      left: ScreenUtil().setSp(30),
    ),
    child: InkWell(
      onTap: () async {
        if (store.isActive) {
          Provider.of<CurrentStoresProvider>(context, listen: false)
              .setSelectedStore(store.storeId);
          await Provider.of<CurrentStoresProvider>(context, listen: false)
              .getSingleStoreFromAPI(context, store.storeId);

          Navigator.of(context).pushNamed('HomePage');
        } else {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return StoreDisabledDialog(
                  canPopup: true,
                );
              });
        }
      },
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
                width: 20 * SizeHelper.widthMultiplier,
                height: 10 * SizeHelper.heightMultiplier,
                decoration: BoxDecoration(shape: BoxShape.circle),
                child: store.logoUrl == null
                    ? CircleAvatar(
                        child: Text(
                          store.storeName.substring(0, 1),
                          style: GoogleFonts.lato(
                              color: Colors.white,
                              fontSize: ScreenUtil().setSp(55)),
                        ),
                        backgroundColor: Color(
                            int.tryParse(store.backgroundColorHex) ??
                                Colors.grey.value),
                      )
                    : RoundFadeInImage(store.logoUrl)),
            WEmptyView(40),
            Container(
              width: ScreenHelper.isLandScape(context)
                  ? 70 * SizeHelper.widthMultiplier
                  : 50 * SizeHelper.widthMultiplier,
              height: ScreenHelper.isLandScape(context)
                  ? 10 * SizeHelper.heightMultiplier
                  : 10 * SizeHelper.heightMultiplier,
              decoration: BoxDecoration(
                  color: int.tryParse(store.backgroundColorHex) == null
                      ? Colors.pink
                      : Color(int.tryParse(store.backgroundColorHex)),
                  border: Border.all(
                    color: Colors.transparent,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(7))),
              child: Padding(
                padding: EdgeInsets.only(left: ScreenUtil().setSp(40)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${store.storeName}",
                      textAlign: TextAlign.left,
                      style: GoogleFonts.lato(
                        textStyle: TextStyle(
                            color: Colors.white,
                            fontSize: ScreenHelper.isLandScape(context)
                                ? 2 * SizeHelper.textMultiplier
                                : 2 * SizeHelper.textMultiplier,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      "${AppLocalizationHelper.of(context).translate("StoreCode")}: ${store.storeCode}",
                      textAlign: TextAlign.left,
                      style: GoogleFonts.lato(
                        fontSize: ScreenHelper.isLandScape(context)
                            ? 2 * SizeHelper.textMultiplier
                            : 2 * SizeHelper.textMultiplier,
                        fontWeight: FontWeight.bold,
                        textStyle: TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

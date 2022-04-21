import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/helpers/screenHelper.dart';
import 'package:vplus_merchant_app/helpers/sizeHelper.dart';
import 'package:vplus_merchant_app/models/store.dart';
import 'package:vplus_merchant_app/providers/current_menu_provider.dart';
import 'package:vplus_merchant_app/providers/current_stores_provider.dart';
import 'package:vplus_merchant_app/providers/currentuser_provider.dart';
import 'package:vplus_merchant_app/providers/report_provider.dart';
import 'package:vplus_merchant_app/screens/report/report_admin.dart';
import 'package:vplus_merchant_app/screens/report/report_page_l.dart';
import 'package:vplus_merchant_app/screens/report/report_page_p.dart';
import 'package:vplus_merchant_app/widgets/customAppBar.dart';

class ReportScreen extends StatefulWidget {
  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  int storeMenuId;
  bool isLoading = false;

  Store store;

  ScrollController scrollController = new ScrollController();

  @override
  void initState() {
    storeMenuId =
        Provider.of<CurrentMenuProvider>(context, listen: false).getStoreMenuId;
    store = Provider.of<CurrentStoresProvider>(context, listen: false)
        .getStore(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        width: 1080, height: 1920, allowFontScaling: false);
    return SafeArea(
      bottom: false,
      top: true,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.refresh_rounded),
          onPressed: () async {
            await Provider.of<ReportProvider>(context, listen: false)
                .getDateRangeReportFromAPI(
                    context,
                    Provider.of<ReportProvider>(context, listen: false)
                        .selectedStartDate,
                    Provider.of<ReportProvider>(context, listen: false)
                        .selectedEndDate,
                    storeMenuId);
          },
        ),
        backgroundColor: Colors.white,
        appBar: CustomAppBar.getAppBar(
          '${AppLocalizationHelper.of(context).translate('ReportPageTitle')}',
          true,
          showLogo: true,
          context: context,
          screenPage: CustomAppBar.storeMainPage,
          rightButtonIcon: store.logoUrl == null
              ? Container(
                  width: ScreenUtil().setWidth(70),
                  height: ScreenUtil().setHeight(70),
                  decoration: BoxDecoration(shape: BoxShape.circle),
                  child: CircleAvatar(
                    child: Text(
                      store.storeName.substring(0, 1),
                      style: GoogleFonts.lato(
                          color: Colors.white,
                          fontSize: ScreenUtil().setSp(
                              ScreenHelper.getResponsiveTitleFontSize(
                                  context))),
                    ),
                    backgroundColor: Color(
                        int.tryParse(store.backgroundColorHex) ??
                            Colors.grey.value),
                  ))
              : Container(
                  width: ScreenUtil().setWidth(70),
                  height: ScreenUtil().setHeight(70),
                  decoration: BoxDecoration(shape: BoxShape.circle),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(store.logoUrl),
                    backgroundColor: Color(
                        int.tryParse(store.backgroundColorHex) ??
                            Colors.grey.value),
                  ),
                ),
        ),
        body: OrientationBuilder(
          builder: (context, orientation) {
            if (Provider.of<CurrentUserProvider>(context).isSuperAdmin())
              return AdminReportPagePortrait();

            if (!ScreenHelper.isLandScape(context)) {
              SizeHelper.landScapeHomePage = false;
              return ReportPagePortrait(storeMenuId);
            } else {
              SizeHelper.landScapeHomePage = true;
              return ReportPageLandscape(storeMenuId);
            }
          },
        ),
      ),
    );
  }
}

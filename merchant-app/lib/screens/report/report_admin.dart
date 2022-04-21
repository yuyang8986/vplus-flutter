import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:vplus_merchant_app/helpers/apiHelper.dart';
import 'package:vplus_merchant_app/helpers/date_time_helper.dart';
import 'package:vplus_merchant_app/helpers/printerHelper.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/helpers/sizeHelper.dart';
import 'package:vplus_merchant_app/models/Order.dart';
import 'package:vplus_merchant_app/models/report/adminReport/adminReport.dart';
import 'package:vplus_merchant_app/models/report/categoryRanking.dart';
import 'package:vplus_merchant_app/models/report/dateRangeReport.dart';
import 'package:vplus_merchant_app/models/report/menuItemRanking.dart';
import 'package:vplus_merchant_app/models/store.dart';
import 'package:vplus_merchant_app/providers/current_menu_provider.dart';
import 'package:vplus_merchant_app/providers/current_stores_provider.dart';
import 'package:vplus_merchant_app/providers/report_provider.dart';
import 'package:vplus_merchant_app/styles/color.dart';
import 'package:vplus_merchant_app/widgets/components.dart';
import 'package:vplus_merchant_app/widgets/date_range_selector.dart';
import 'package:vplus_merchant_app/widgets/emptyView.dart';

class AdminReportPagePortrait extends StatefulWidget {
  AdminReportPagePortrait();
  @override
  State<StatefulWidget> createState() => AdminReportPagePortraitState();
}

class AdminReportPagePortraitState extends State<AdminReportPagePortrait> {
  AdminReport report;

  // DateTime selectedStartDate;
  //DateTime selectedEndDate;

  DateTime defaultStartDate;
  DateTime defaultEndDate;
  PrinterHelper _printerHelper;

  bool _inPrintingAsync;
  Store _selectedStore;
  int _selectedMenuId;

  ScrollController _controller;

  List<Store> storeAll = [];

  Future _initStoreData(context) async {
    Helper hlp = new Helper();
    var response =
        await hlp.getData('api/stores/all', context: context, hasAuth: true);
    if (response.isSuccess) {
      storeAll =
          List.from(response.data).map((e) => Store.fromJson(e)).toList();
    }
    return storeAll;
  }

  @override
  void initState() {
    /// by default, should display today from 00:00 to 23:59
    DateTime now = new DateTime.now();
    defaultStartDate = DateTime(now.year, now.month, now.day);
    defaultEndDate = DateTime(now.year, now.month, now.day);

    // Provider.of<ReportProvider>(context, listen: false)
    //     .setStartDate(defaultStartDate);
    // Provider.of<ReportProvider>(context, listen: false)
    //     .setEndDate(defaultEndDate);

    _printerHelper = PrinterHelper();

    _inPrintingAsync = false;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await _initStoreData(context);
      setState(() {
        storeAll = storeAll;
      });
      // await Provider.of<ReportProvider>(context, listen: false)
      //     .getDateRangeReportAdminFromAPI(
      //         context,
      //         Provider.of<ReportProvider>(context, listen: false)
      //             .selectedStartDate,
      //         Provider.of<ReportProvider>(context, listen: false)
      //             .selectedEndDate,
      //         storeMenuId);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        controller: _controller,
        child: Column(
          children: [
            VEmptyView(100),
            SearchableDropdown.single(
              // label: "Stores",
              // searchFn: (value){
              //   return storeAll.where((element) => element == value).toList();
              // },
              items: storeAll
                  .map(
                      (e) => DropdownMenuItem(value: e, child: Text(e.storeName)))
                  .toList(),
              value: _selectedStore,
              hint: "Select Store",
              searchHint: "Search Store",
              onChanged: (value) async {
                _selectedStore = value;
                if (value != null) {
                  await Provider.of<CurrentMenuProvider>(context, listen: false)
                      .getMenuFromAPI(context, _selectedStore.storeId);
                  setState(() {
                    _selectedMenuId =
                        Provider.of<CurrentMenuProvider>(context, listen: false)
                            .getStoreMenuId;
                  });
                }
              },
            ),
            Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  DateRangeSelector(
                    (startDate, endDate) async {
                      setState(() {
                        Provider.of<ReportProvider>(context, listen: false)
                            .setStartDate(startDate);
                        Provider.of<ReportProvider>(context, listen: false)
                            .setEndDate(endDate);
                      });
                      await Provider.of<ReportProvider>(context, listen: false)
                          .getDateRangeReportAdminFromAPI(
                              context,
                              Provider.of<ReportProvider>(context,
                                      listen: false)
                                  .selectedStartDate,
                              Provider.of<ReportProvider>(context,
                                      listen: false)
                                  .selectedEndDate,
                              _selectedMenuId);
                    },
                    defaultStartDate: defaultStartDate,
                    defaultEndDate: defaultEndDate,
                  ),
                  reportContent(context)
                ]),
          ],
        ),
      ),
    );
  }

  Widget emptyContentNotices() {
    return Column(children: [
      VEmptyView(SizeHelper.heightMultiplier * 40),
      Icon(Icons.inbox, size: SizeHelper.imageSizeMultiplier * 14),
      Text(
        "${AppLocalizationHelper.of(context).translate('NoReportDateAlert')}",
        softWrap: true,
        style: GoogleFonts.lato(fontSize: SizeHelper.textMultiplier * 3),
        textAlign: TextAlign.center,
      ),
      VEmptyView(SizeHelper.heightMultiplier * 40),
    ]);
  }

  Widget reportContent(BuildContext context) {
    return Consumer<ReportProvider>(builder: (ctx, p, w) {
      report = p.adminReport;
      if (report == null) return Center(child: Container());
      return portraitUiTransactionListTile(
          "Total Paid",
          report?.totalAmountPaidInPeriod,
          report?.totalCommission,
          report?.totalNetPayableToMerchant);
    });
  }

  Widget portraitUiTransactionListTile(String listTileLabel, double totalAmount,
      double totalCommission, double totalNetPayableToMerchant) {
    return Container(
      // constraints: BoxConstraints(minHeight: SizeHelper.heightMultiplier * 15),
      margin: EdgeInsets.fromLTRB(SizeHelper.widthMultiplier * 5,
          SizeHelper.widthMultiplier * 10, SizeHelper.widthMultiplier * 5, 0),
      padding: EdgeInsets.symmetric(horizontal: SizeHelper.widthMultiplier * 5),
      decoration: BoxDecoration(
        border: Border.all(color: cornerRadiusContainerBorderColor),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    VEmptyView(30),
                    Text(
                      "Total Paid Amount \$${totalAmount.toStringAsFixed(2)}",
                      // textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                          fontSize: 2.5 * SizeHelper.textMultiplier,
                          fontWeight: FontWeight.normal,
                          //color: totalAmountColor,
                          textStyle: GoogleFonts.lato(
                            decoration: null,
                          )),
                    ),
                    Text(
                      "Total Commision: ${totalCommission.toStringAsFixed(2)}",
                      // textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                          fontSize: 2 * SizeHelper.textMultiplier,
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                          textStyle: GoogleFonts.lato(
                            decoration: null,
                          )),
                    ),
                    Text(
                      "Total Amount Payable: ${totalNetPayableToMerchant.toStringAsFixed(2)}",
                      // textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                          fontSize: 3 * SizeHelper.textMultiplier,
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                          textStyle: GoogleFonts.lato(
                            decoration: null,
                          )),
                    ),
                  ]),
            ),
            transactionsListView(
                context,
                Provider.of<ReportProvider>(context, listen: false)
                    .adminReport
                    .userOrders)
          ]),
    );
  }

  Widget transactionsListView(BuildContext context, List<Order> orders) {
    return (orders.length == 0)
        ? emptyContentNotices()
        : ListView.builder(
          controller: _controller,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: orders.length,
            itemBuilder: (ctx, index) {
              return orderListTile(orders[index]);
            },
          );
  }

  Widget orderListTile(Order order) {
    return orderNameListTile(
      DateTimeHelper.parseDateTimeToDateHHMM(
              order.orderCompleteDateTimeUTC.toLocal())
          .toString(),
      order.totalPaidAmount,
    );
  }

  Widget orderNameListTile(String orderDate, double orderAmount) {
    return Row(children: [
      Expanded(
        flex: 8,
        child: Text(
          orderDate,
          // textAlign: TextAlign.center,
          style: GoogleFonts.lato(
              fontSize: 2.3 * SizeHelper.textMultiplier,
              fontWeight: FontWeight.bold,
              color: reportCategoriesStatTileColor,
              textStyle: GoogleFonts.lato(
                decoration: null,
              )),
        ),
      ),
      Expanded(
        flex: 4,
        child: Text(
          "$orderAmount",
          // textAlign: TextAlign.center,
          style: GoogleFonts.lato(
              fontSize: 2.3 * SizeHelper.textMultiplier,
              fontWeight: FontWeight.normal,
              color: reportCategoriesStatTileColor,
              textStyle: GoogleFonts.lato(
                decoration: null,
              )),
        ),
      ),
    ]);
  }
}

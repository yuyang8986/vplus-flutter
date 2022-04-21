import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:vplus_merchant_app/helpers/printerHelper.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/helpers/sizeHelper.dart';
import 'package:vplus_merchant_app/models/report/categoryRanking.dart';
import 'package:vplus_merchant_app/models/report/dateRangeReport.dart';
import 'package:vplus_merchant_app/models/report/menuItemRanking.dart';
import 'package:vplus_merchant_app/providers/report_provider.dart';
import 'package:vplus_merchant_app/styles/color.dart';
import 'package:vplus_merchant_app/widgets/components.dart';
import 'package:vplus_merchant_app/widgets/date_range_selector.dart';
import 'package:vplus_merchant_app/widgets/emptyView.dart';

class ReportPagePortrait extends StatefulWidget {
  ReportPagePortrait(this.storeMenuId);
  final int storeMenuId;
  @override
  State<StatefulWidget> createState() => ReportPagePortraitState();
}

class ReportPagePortraitState extends State<ReportPagePortrait> {
  int storeMenuId;

  DateRangeReport report;

  // DateTime selectedStartDate;
  //DateTime selectedEndDate;

  DateTime defaultStartDate;
  DateTime defaultEndDate;
  PrinterHelper _printerHelper;

  bool _inPrintingAsync;

  @override
  void initState() {
    storeMenuId = this.widget.storeMenuId;

    /// by default, should display today from 00:00 to 23:59
    DateTime now = new DateTime.now();
    defaultStartDate = DateTime(now.year, now.month, now.day);
    defaultEndDate = DateTime(now.year, now.month, now.day);

    Provider.of<ReportProvider>(context, listen: false)
        .setStartDate(defaultStartDate);
    Provider.of<ReportProvider>(context, listen: false)
        .setEndDate(defaultEndDate);

    _printerHelper = PrinterHelper();

    _inPrintingAsync = false;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await Provider.of<ReportProvider>(context, listen: false)
          .getDateRangeReportFromAPI(
              context,
              Provider.of<ReportProvider>(context, listen: false)
                  .selectedStartDate,
              Provider.of<ReportProvider>(context, listen: false)
                  .selectedEndDate,
              storeMenuId);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
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
                    .getDateRangeReportFromAPI(
                        context,
                        Provider.of<ReportProvider>(context, listen: false)
                            .selectedStartDate,
                        Provider.of<ReportProvider>(context, listen: false)
                            .selectedEndDate,
                        storeMenuId);
              },
              defaultStartDate: defaultStartDate,
              defaultEndDate: defaultEndDate,
            ),
            reportContent(context)
          ]),
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
      report = p.getDateRangeReport;
      if (report == null) return Center(child: CircularProgressIndicator());
      return Column(children: [
        portraitUiTransactionListTile(
            "${AppLocalizationHelper.of(context).translate('CashTransaction')}",
            report?.cashTransactionAmount,
            report?.cashTransactionCount,
            reportCashTransactionsNumberColor),
        portraitUiTransactionListTile(
            "${AppLocalizationHelper.of(context).translate('CardTransaction')}",
            report?.cardTransactionAmount,
            report?.cardTransactionCount,
            reportCardTransactionsNumberColor),
        categoriesRankingListView(context, report?.categoriesRanking),
      ]);
    });
  }

  Widget portraitUiTransactionListTile(String listTileLabel, double totalAmount,
      int numberOfTransactions, Color totalAmountColor) {
    return Container(
      constraints: BoxConstraints(minHeight: SizeHelper.heightMultiplier * 15),
      margin: EdgeInsets.fromLTRB(SizeHelper.widthMultiplier * 5,
          SizeHelper.widthMultiplier * 10, SizeHelper.widthMultiplier * 5, 0),
      padding: EdgeInsets.symmetric(horizontal: SizeHelper.widthMultiplier * 5),
      decoration: BoxDecoration(
        border: Border.all(color: cornerRadiusContainerBorderColor),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: Text(
                listTileLabel,
                // textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                    fontSize: 2 * SizeHelper.textMultiplier,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    textStyle: GoogleFonts.lato(
                      decoration: null,
                    )),
              ),
            ),
            Container(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "\$${totalAmount.toStringAsFixed(2)}",
                      // textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                          fontSize: 3 * SizeHelper.textMultiplier,
                          fontWeight: FontWeight.bold,
                          color: totalAmountColor,
                          textStyle: GoogleFonts.lato(
                            decoration: null,
                          )),
                    ),
                    Text(
                      "${AppLocalizationHelper.of(context).translate('TotalTransaction')}: $numberOfTransactions",
                      // textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                          fontSize: 2 * SizeHelper.textMultiplier,
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                          textStyle: GoogleFonts.lato(
                            decoration: null,
                          )),
                    ),
                  ]),
            ),
          ]),
    );
  }

  Widget categoriesRankingListView(
      BuildContext context, List<CategoryRanking> categoriesRanking) {
    return Container(
      margin: EdgeInsets.fromLTRB(SizeHelper.widthMultiplier * 5,
          SizeHelper.widthMultiplier * 10, SizeHelper.widthMultiplier * 5, 0),
      padding: EdgeInsets.symmetric(horizontal: SizeHelper.widthMultiplier * 5),
      decoration: BoxDecoration(
        border: Border.all(color: cornerRadiusContainerBorderColor),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                  vertical: SizeHelper.widthMultiplier * 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    child: Text(
                      "${AppLocalizationHelper.of(context).translate('CategoriesStatistics')}",
                      // textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                          fontSize: 3 * SizeHelper.textMultiplier,
                          fontWeight: FontWeight.bold,
                          color: reportCategoriesStatTitleColor,
                          textStyle: GoogleFonts.lato(
                            decoration: null,
                          )),
                    ),
                  ),
                  ModalProgressHUD(
                    inAsyncCall: _inPrintingAsync,
                    child: RoundedSelectButton(
                        '${AppLocalizationHelper.of(context).translate('Print')}',
                        () async {
                      print("print category stat to printer");
                      setState(() {
                        _inPrintingAsync = true;
                      });
                      var ticket = await _printerHelper.dateRangeReportTicket(
                          context,
                          Provider.of<ReportProvider>(context, listen: false)
                              .selectedStartDate,
                          Provider.of<ReportProvider>(context, listen: false)
                              .selectedEndDate,
                          report);
                      await _printerHelper.startPrint(ticket, context);
                      setState(() {
                        _inPrintingAsync = false;
                      });
                    }),
                  )
                ],
              ),
            ),
            Divider(color: cornerRadiusContainerBorderColor, thickness: 1.5),
            VEmptyView(SizeHelper.heightMultiplier * 8),
            (categoriesRanking.length == 0)
                ? emptyContentNotices()
                : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: categoriesRanking.length,
                    itemBuilder: (ctx, index) {
                      return categoryRankingListTile(categoriesRanking[index]);
                    },
                  ),
          ]),
    );
  }

  Widget categoryRankingListTile(CategoryRanking singleCategoryRanking) {
    return Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      categoryNameListTile(
        singleCategoryRanking.menuCategoryName,
        singleCategoryRanking.menuCategoryCount,
        singleCategoryRanking.menuCategoryAmount,
      ),
      VEmptyView(SizeHelper.heightMultiplier * 2),
      ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: singleCategoryRanking.menuItemsRanking.length,
        itemBuilder: (ctx, index) {
          MenuItemRanking singleMenuItemRanking =
              singleCategoryRanking.menuItemsRanking[index];
          return rankingItemListTile(
              singleMenuItemRanking.menuItemName,
              singleMenuItemRanking.menuItemCount,
              singleMenuItemRanking.menuItemAmount);
        },
      ),
      VEmptyView(SizeHelper.heightMultiplier * 8),
    ]);
  }

  Widget rankingItemListTile(
    String itemName,
    int itemCount,
    double itemAmount, {
    Color color: Colors.black,
  }) {
    return Row(children: [
      Expanded(
        flex: 7,
        child: Text(
          itemName,
          // textAlign: TextAlign.center,
          style: GoogleFonts.lato(
              fontSize: 2 * SizeHelper.textMultiplier,
              fontWeight: FontWeight.bold,
              color: color,
              textStyle: GoogleFonts.lato(
                decoration: null,
              )),
        ),
      ),
      Expanded(
        flex: 2,
        child: Text(
          "$itemCount",
          // textAlign: TextAlign.center,
          style: GoogleFonts.lato(
              fontSize: 2 * SizeHelper.textMultiplier,
              fontWeight: FontWeight.normal,
              color: color,
              textStyle: GoogleFonts.lato(
                decoration: null,
              )),
        ),
      ),
      Expanded(
        flex: 3,
        child: Text(
          "\$${itemAmount.toStringAsFixed(2)}",
          // textAlign: TextAlign.center,
          style: GoogleFonts.lato(
              fontSize: 2 * SizeHelper.textMultiplier,
              fontWeight: FontWeight.normal,
              color: color,
              textStyle: GoogleFonts.lato(
                decoration: null,
              )),
        ),
      ),
    ]);
  }

  Widget categoryNameListTile(
      String itemName, int itemCount, double itemAmount) {
    return Row(children: [
      Expanded(
        flex: 7,
        child: Text(
          itemName,
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
        flex: 2,
        child: Text(
          "$itemCount",
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
      Expanded(
        flex: 3,
        child: Text(
          "\$${itemAmount.toStringAsFixed(2)}",
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

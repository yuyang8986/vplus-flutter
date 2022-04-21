import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:vplus_merchant_app/helpers/apiHelper.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/helpers/printerHelper.dart';
import 'package:vplus_merchant_app/helpers/screenHelper.dart';
import 'package:vplus_merchant_app/helpers/sizeHelper.dart';
import 'package:vplus_merchant_app/providers/current_printer_provider.dart';
import 'package:vplus_merchant_app/widgets/components.dart';
import 'package:vplus_merchant_app/widgets/customAppBar.dart';
import 'package:vplus_merchant_app/widgets/custom_dialog.dart';
import 'package:vplus_merchant_app/widgets/emptyView.dart';

class PrinterSettingsPage extends StatefulWidget {
  @override
  _PrinterSettingsPageState createState() => _PrinterSettingsPageState();
}

class _PrinterSettingsPageState extends State<PrinterSettingsPage> {
  PrinterHelper _printerHelper = PrinterHelper();
  TextEditingController _noOfCopiesCtrl = TextEditingController();
  CurrentPrinterProvider _currentPrinterProvider;

  bool _isSmallPageWidth;
  int noOfCopies;
  bool _isEnlargeFont;
  bool _isAutoPrintOnOrderConfirmed;
  bool _isAutoPrintOnPaymentMade;
  bool _inAsyncCall;
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    _currentPrinterProvider =
        Provider.of<CurrentPrinterProvider>(context, listen: false);
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
    //   await _currentPrinterProvider.initData();
    // });
    _inAsyncCall = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar.getAppBar(
          "${AppLocalizationHelper.of(context).translate('PrinterSetting')}",
          false,
          context: context,
          showLogo: false),
      body: Consumer<CurrentPrinterProvider>(
        builder: (ctx, p, w) {
          _isSmallPageWidth = p.isSmallPageWidth;
          _isAutoPrintOnOrderConfirmed = p.isAutoPrintOnOrderConfirmed;
          _isAutoPrintOnPaymentMade = p.isAutoPrintOnPaymentMade;
          _isEnlargeFont = p.isEnlargeFont;
          noOfCopies = p.noOfCopies;
          _noOfCopiesCtrl.text = _currentPrinterProvider.noOfCopies.toString();
          return ModalProgressHUD(
            inAsyncCall: _inAsyncCall,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  PrinterHelper.getIsPrinterConnected == true
                      ? Container()
                      : Column(
                          children: [
                            VEmptyView(100),
                            Icon(
                              Icons.bluetooth_audio,
                              size: ScreenUtil().setSp(100),
                            ),
                            VEmptyView(50),
                            Text(
                              "${AppLocalizationHelper.of(context).translate('ScanPrinterlabel')}",
                              style: GoogleFonts.lato(
                                  textStyle: GoogleFonts.lato(
                                      fontSize: ScreenUtil().setSp(50))),
                            ),
                          ],
                        ),
                  VEmptyView(50),
                  PrinterHelper.getIsPrinterConnected == true
                      ? printerSettingsView()
                      : RoundedVplusLongButton(
                          callBack: () async {
                            List printers = await _printerHelper.getBluetooth();
                            await showDialog(
                                context: context,
                                builder: (ctx) {
                                  return CustomDialog(
                                    title: ("Select Printer"),
                                    child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: printers.length,
                                        itemBuilder: (ctx, index) {
                                          String singlePrinter =
                                              printers[index];
                                          List printer =
                                              singlePrinter.split("#");
                                          String printerName = printer[0];
                                          String printerMacAddr = printer[1];
                                          return ListTile(
                                            title: Text(
                                              printerName,
                                              style: GoogleFonts.lato(),
                                            ),
                                            onTap: () async {
                                              setState(() {
                                                PrinterHelper
                                                        .setCurrentPrinterName =
                                                    printerName;
                                                PrinterHelper
                                                        .setCurrentPrinterMacAddr =
                                                    printerMacAddr;
                                                PrinterHelper
                                                        .setIsPrinterConnected =
                                                    true;
                                              });
                                              Navigator.of(context,
                                                      rootNavigator: true)
                                                  .pop();
                                              // save it to default printer

                                              var hive =
                                                  await Hive.openBox("printer");

                                              await hive.put('defaultPrinter', {
                                                "printerName": printerName,
                                                "printerMacAddr":
                                                    printerMacAddr,
                                              });

                                              bool isConnected =
                                                  await _printerHelper
                                                      .setConnect(
                                                          printerMacAddr);
                                              if (isConnected) {
                                                Helper().showToastSuccess(
                                                    "${AppLocalizationHelper.of(context).translate('SuccessfulConnectPrinterAlert')}");
                                              } else {
                                                Helper().showToastError(
                                                    "${AppLocalizationHelper.of(context).translate('FailedToConnectPrinterAlert')}");
                                              }
                                            },
                                          );
                                        }),
                                  );
                                });
                          },
                          text:
                              "${AppLocalizationHelper.of(context).translate('Scan')}",
                        ),
                  PrinterHelper.getIsPrinterConnected == true
                      ? Column(
                          children: [
                            if (ScreenHelper.isLandScape(context))
                              VEmptyView(5 * SizeHelper.heightMultiplier),
                            RoundedVplusLongButton(
                                callBack: () async {
                                  setState(() {
                                    _inAsyncCall = true;
                                  });
                                  await _printerHelper.startPrint(
                                      await PrinterHelper().testTicket(),
                                      context);
                                  setState(() {
                                    _inAsyncCall = false;
                                  });
                                },
                                text: "Test Print"),
                            if (ScreenHelper.isLandScape(context))
                              VEmptyView(2 * SizeHelper.heightMultiplier),
                            RoundedVplusLongButton(
                              callBack: () async {
                                // disconnect device
                                setState(() {
                                  PrinterHelper.setCurrentPrinterName = null;
                                  PrinterHelper.setCurrentPrinterMacAddr = null;
                                  PrinterHelper.setIsPrinterConnected = false;
                                });

                                await _printerHelper.setConnect(null);
                              },
                              text: "Turn off",
                              color: Colors.red,
                            ),
                            if (ScreenHelper.isLandScape(context))
                              VEmptyView(5 * SizeHelper.heightMultiplier),
                          ],
                        )
                      : Container()
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  printerSettingsView() {
    return Container(
      margin: EdgeInsets.fromLTRB(
          ScreenUtil().setSp(80),
          ScreenHelper.isLandScape(context) ? 0 : ScreenUtil().setSp(80),
          ScreenHelper.isLandScape(context) ? 0 : ScreenUtil().setSp(80),
          ScreenHelper.isLandScape(context) ? 0 : ScreenUtil().setSp(80)),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "${AppLocalizationHelper.of(context).translate('PrinterNameLabel')}: ",
                style: GoogleFonts.lato(
                    textStyle:
                        GoogleFonts.lato(fontSize: ScreenUtil().setSp(35))),
              ),
              Text(
                PrinterHelper.getCurrentPrinterName,
                style: GoogleFonts.lato(
                    textStyle: GoogleFonts.lato(
                        fontWeight: FontWeight.bold,
                        fontSize: ScreenUtil().setSp(35))),
              )
            ],
          ),
          VEmptyView(70),
          Row(
            children: [
              Text(
                "${AppLocalizationHelper.of(context).translate('PrinterConnectionStatus')}: ",
                style: GoogleFonts.lato(
                    textStyle:
                        GoogleFonts.lato(fontSize: ScreenUtil().setSp(35))),
              ),
              Text(
                PrinterHelper.getIsPrinterConnected == false
                    ? "${AppLocalizationHelper.of(context).translate('Disconnected')}"
                    : "${AppLocalizationHelper.of(context).translate('Connected')}",
                style: GoogleFonts.lato(
                    textStyle: GoogleFonts.lato(
                        fontWeight: FontWeight.bold,
                        fontSize: ScreenUtil().setSp(35))),
              ),
            ],
          ),
          VEmptyView(70),
          Container(
            //height: ScreenUtil().setHeight(550), //each row 120
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(0.0),
                  child: Text(
                    '${AppLocalizationHelper.of(context).translate('PageWidth')}:',
                    style: GoogleFonts.lato(
                      fontSize: ScreenUtil().setSp(35),
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Flexible(
                      fit: FlexFit.loose,
                      child: RadioListTile(
                          title: Text(
                            "58mm",
                            style: GoogleFonts.lato(
                                fontSize: ScreenUtil().setSp(35)),
                          ),
                          value: true,
                          groupValue: _isSmallPageWidth,
                          onChanged: (selected) async {
                            setState(() {
                              _isSmallPageWidth = selected;
                            });
                            await _currentPrinterProvider
                                .setPageWidth(_isSmallPageWidth);
                          }),
                    ),
                    Flexible(
                      fit: FlexFit.loose,
                      child: RadioListTile(
                        title: Text(
                          "80mm",
                          style: GoogleFonts.lato(
                              fontSize: ScreenUtil().setSp(35)),
                        ),
                        value: false,
                        groupValue: _isSmallPageWidth,
                        onChanged: (selected) async {
                          setState(() {
                            _isSmallPageWidth = selected;
                          });
                          await _currentPrinterProvider
                              .setPageWidth(_isSmallPageWidth);
                        },
                      ),
                    ),
                  ],
                ),
                VEmptyView(30),
              ],
            ),
          ),
          // VEmptyView(70),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "${AppLocalizationHelper.of(context).translate('EnlargeFont')}: ",
                style: GoogleFonts.lato(
                    textStyle:
                        GoogleFonts.lato(fontSize: ScreenUtil().setSp(35))),
              ),
              Expanded(
                child: SwitchListTile(
                    value: _isEnlargeFont,
                    onChanged: (v) async {
                      setState(() {
                        _isEnlargeFont = !_isEnlargeFont;
                      });
                      await _currentPrinterProvider
                          .setEnlargeFont(_isEnlargeFont);
                    }),
              )
            ],
          ),
          VEmptyView(70),
          Row(
            children: [
              Text(
                "${AppLocalizationHelper.of(context).translate('PrinterCopy')}:  ",
                style: GoogleFonts.lato(
                    textStyle:
                        GoogleFonts.lato(fontSize: ScreenUtil().setSp(35))),
              ),
              Container(
                  alignment: Alignment.center,
                  width: ScreenUtil().setWidth(180),
                  height: ScreenUtil().setHeight(80),
                  child: TextField(
                    textAlignVertical: TextAlignVertical.center,
                    textAlign: TextAlign.center,
                    textInputAction: TextInputAction.go,
                    controller: _noOfCopiesCtrl,
                    keyboardType: TextInputType.number,
                    onChanged: (v) {
                      noOfCopies = int.parse(_noOfCopiesCtrl.text);
                      _currentPrinterProvider.setPrintCopy(noOfCopies);
                    },
                    decoration: InputDecoration(border: OutlineInputBorder()),
                  ))
            ],
          ),
          VEmptyView(70),
          Row(
            children: [
              Text(
                "${AppLocalizationHelper.of(context).translate('OrderConfirmedAutoPrint')}: ",
                style: GoogleFonts.lato(
                    textStyle:
                        GoogleFonts.lato(fontSize: ScreenUtil().setSp(35))),
              ),
              Expanded(
                child: SwitchListTile(
                    value: _isAutoPrintOnOrderConfirmed,
                    onChanged: (v) {
                      setState(() {
                        _isAutoPrintOnOrderConfirmed =
                            !_isAutoPrintOnOrderConfirmed;
                      });
                      _currentPrinterProvider
                          .setAutoOrderConfirmed(_isAutoPrintOnOrderConfirmed);
                    }),
              )
            ],
          ),
          Row(
            children: [
              Text(
                "${AppLocalizationHelper.of(context).translate('paymentMadeAutoPrint')}: ",
                style: GoogleFonts.lato(
                    textStyle:
                        GoogleFonts.lato(fontSize: ScreenUtil().setSp(35))),
              ),
              Expanded(
                child: SwitchListTile(
                    value: _isAutoPrintOnPaymentMade,
                    onChanged: (v) {
                      setState(() {
                        _isAutoPrintOnPaymentMade = !_isAutoPrintOnPaymentMade;
                      });
                      _currentPrinterProvider
                          .setAutoPaymentMade(_isAutoPrintOnPaymentMade);
                    }),
              )
            ],
          ),
        ],
      ),
    );
  }
}

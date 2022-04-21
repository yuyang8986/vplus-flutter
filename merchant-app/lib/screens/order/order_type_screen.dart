import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vplus_merchant_app/helpers/apiHelper.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/helpers/permissionHelper.dart';
import 'package:vplus_merchant_app/providers/current_menu_provider.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:vplus_merchant_app/helpers/formValidationHelper.dart';
import 'package:vplus_merchant_app/helpers/screenHelper.dart';
import 'package:vplus_merchant_app/helpers/sizeHelper.dart';
import 'package:vplus_merchant_app/models/Order.dart';
import 'package:vplus_merchant_app/providers/current_order_provider.dart';
import 'package:vplus_merchant_app/providers/current_stores_provider.dart';
import 'package:vplus_merchant_app/providers/currentuser_provider.dart';
import 'package:vplus_merchant_app/providers/order_type_screen_provider.dart';
import 'package:vplus_merchant_app/providers/orderlist_provider.dart';
import 'package:vplus_merchant_app/screens/order/order_tables_page.dart';
import 'package:vplus_merchant_app/styles/labelText.dart';
import 'package:vplus_merchant_app/styles/regex.dart';
import 'package:vplus_merchant_app/widgets/components.dart';
import 'package:vplus_merchant_app/widgets/customAppBar.dart';
import 'package:vplus_merchant_app/widgets/custom_dialog.dart';

import 'package:vplus_merchant_app/screens/order/order_main_screen/table_listview.dart';
import 'package:vplus_merchant_app/widgets/order_type_bar.dart';

class OrderTypeScreen extends StatefulWidget {
  @override
  _OrderTypeScreenState createState() => _OrderTypeScreenState();
}

class _OrderTypeScreenState extends State<OrderTypeScreen> {
  final GlobalKey<FormState> _orderTableNumberKey = GlobalKey<FormState>();
  TextEditingController _tableNumberCtrl = new TextEditingController();
  int storeMenuId;
  OrderButtonType _selectedType = OrderButtonType.DineIn;
  bool isLoading = false;
  @override
  void initState() {
    // int storeId = Provider.of<CurrentStoresProvider>(context, listen: false)
    //     .getStoreId(context);
    //WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
    storeMenuId =
        Provider.of<CurrentMenuProvider>(context, listen: false).getStoreMenuId;
    // });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      // await PermissionHelper.checkMissingPermission(context);
    });

    super.initState();
  }

  Widget portraitUI() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        orderTypeButtons(),
        OrderTypeBar(
          orderTypeButtons: OrderButtonType.values.map((e) {
            return OrderTypeButton(
              isSelectedType: _selectedType,
              buttonType: e,
              buttonEvent: () {
                setState(() {
                  _selectedType = e;
                });
              },
            );
          }).toList(),
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: scrollController,
            child: (_selectedType == OrderButtonType.DineIn)
                ? TableListView(
                    isTakeaway: false,
                    callBackSetLoading: (bool val) {
                      setState(() {
                        isLoading = val;
                      });
                    }
                    // scrollController: dineInScrollController,
                    )
                : hasTakeaway
                    ? TableListView(
                        isTakeaway: true,
                        callBackSetLoading: (bool val) {
                          setState(() {
                            isLoading = val;
                          });
                        }
                        // scrollController: takeawayScrollController,
                        )
                    : Container(),
          ),
        ),
      ],
    );
  }

  Widget landScapeUI() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          height: 80 * SizeHelper.heightMultiplier,
          width: (ScreenHelper.isLandScape(context))
              ? 18 * SizeHelper.heightMultiplier
              : 14 * SizeHelper.heightMultiplier,
          child: Row(
            children: [
              Container(
                height: 100 * SizeHelper.widthMultiplier,
                width: 15 * SizeHelper.heightMultiplier,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: ScreenUtil().setSp(20),
                      horizontal: ScreenUtil().setSp(20)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        height: (ScreenHelper.isLandScape(context))
                            ? 15 * SizeHelper.heightMultiplier
                            : 10 * SizeHelper.widthMultiplier,
                        width: (ScreenHelper.isLandScape(context))
                            ? 25 * SizeHelper.widthMultiplier
                            : 15 * SizeHelper.heightMultiplier,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(ScreenUtil().setSp(8)),
                          border: Border.all(
                            color: Colors.grey,
                            width: ScreenUtil().setSp(2),
                          ),
                        ),
                        child: Center(
                          child: Container(
                            // padding: EdgeInsets.symmetric(
                            //     horizontal: ScreenUtil().setSp(
                            //         ScreenHelper.isLandScape(context) ? 0 : 15),
                            //     vertical: ScreenUtil().setSp(1)),
                            child: InkWell(
                              child: Container(
                                height: 10 * SizeHelper.widthMultiplier,
                                width: 15 * SizeHelper.widthMultiplier,
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/images/order/dine_in.png',
                                      height: 4 * SizeHelper.widthMultiplier,
                                      width: 5 * SizeHelper.widthMultiplier,
                                      scale: ScreenHelper.isLandScape(context)
                                          ? 1
                                          : 2,
                                    ),
                                    // VEmptyView(ScreenUtil().setSp(60)),
                                    Text(
                                        "${AppLocalizationHelper.of(context).translate("Dine In")}",
                                        style: GoogleFonts.lato(
                                          fontSize:
                                              ScreenHelper.isLandScape(context)
                                                  ? 2 *
                                                      SizeHelper.textMultiplier
                                                  : SizeHelper.textMultiplier,
                                          color: Colors.grey,
                                        )),
                                  ],
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  _selectedType = OrderButtonType.DineIn;
                                });
                                tableNumberDialog();
                              },
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: (ScreenHelper.isLandScape(context))
                            ? 15 * SizeHelper.heightMultiplier
                            : 10 * SizeHelper.widthMultiplier,
                        width: (ScreenHelper.isLandScape(context))
                            ? 20 * SizeHelper.widthMultiplier
                            : 15 * SizeHelper.heightMultiplier,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(ScreenUtil().setSp(8)),
                          border: Border.all(
                            color: Colors.grey,
                            width: ScreenUtil().setSp(2),
                          ),
                        ),
                        child: Center(
                          child: Container(
                            // padding: EdgeInsets.symmetric(
                            //     horizontal: ScreenUtil().setSp(
                            //         ScreenHelper.isLandScape(context) ? 0 : 10),
                            //     vertical: ScreenUtil().setSp(5)),
                            child: InkWell(
                              child: Container(
                                height: 10 * SizeHelper.widthMultiplier,
                                width: 16 * SizeHelper.widthMultiplier,
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                        'assets/images/order/take_away.png',
                                        // width: MediaQuery.of(context).size.width,
                                        height: 5 * SizeHelper.widthMultiplier,
                                        width: 5 * SizeHelper.widthMultiplier,
                                        scale: ScreenHelper.isLandScape(context)
                                            ? 1
                                            : 2),
                                    // VEmptyView(ScreenUtil().setSp(60)),
                                    Text(
                                        '${AppLocalizationHelper.of(context).translate('Take-away')}',
                                        style: GoogleFonts.lato(
                                          fontSize: ScreenHelper.isLandScape(
                                                  context)
                                              ? 1.7 * SizeHelper.textMultiplier
                                              : 1.7 * SizeHelper.textMultiplier,
                                          color: Colors.grey,
                                        )),
                                  ],
                                ),
                              ),
                              onTap: () async {
                                setState(() {
                                  _selectedType = OrderButtonType.TakeAway;
                                });
                                try {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  var response =
                                      await Provider.of<CurrentOrderProvider>(
                                              context,
                                              listen: false)
                                          .initOrder(context, storeMenuId, "",
                                              OrderType.TakeAway.index);
                                  if (response) {
                                    // no table number for take away
                                    _toOrderScreen();
                                    setState(() {
                                      isLoading = false;
                                    });
                                  } else {
                                    Helper().showToastError(
                                        "${AppLocalizationHelper.of(context).translate('FailedToInitTableAlert')}");
                                    setState(() {
                                      isLoading = false;
                                    });
                                  }
                                } catch (e) {
                                  Helper().showToastError(
                                      "${AppLocalizationHelper.of(context).translate('FailedToInitTableAlert')}");
                                  setState(() {
                                    isLoading = false;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 80 * SizeHelper.heightMultiplier,
          width: 80 * SizeHelper.heightMultiplier,
          child: Column(
            children: [
              OrderTypeBar(
                orderTypeButtons: OrderButtonType.values.map((e) {
                  return OrderTypeButton(
                    isSelectedType: _selectedType,
                    buttonType: e,
                    buttonEvent: () {
                      setState(() {
                        _selectedType = e;
                      });
                    },
                  );
                }).toList(),
              ),
              Container(
                child: Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: (_selectedType == OrderButtonType.DineIn)
                        ? TableListView(
                            isTakeaway: false,
                            callBackSetLoading: (bool val) {
                              setState(() {
                                isLoading = val;
                              });
                            }
                            // scrollController: dineInScrollController,
                            )
                        : hasTakeaway
                            ? TableListView(
                                isTakeaway: true,
                                callBackSetLoading: (bool val) {
                                  setState(() {
                                    isLoading = val;
                                  });
                                }
                                // scrollController: takeawayScrollController,
                                )
                            : Container(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  SpeedDial buildSpeedDial() {
    return SpeedDial(
        marginRight: 20,
        //marginRight: 165,
        backgroundColor: Color(0xff5352ec),
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: IconThemeData(
            size: SizeHelper.isMobilePortrait
                ? 5 * SizeHelper.imageSizeMultiplier
                : 2.5 * SizeHelper.imageSizeMultiplier
            // size: ScreenUtil().setSp(ScreenHelper.isLandScape(context)?MediaQuery.of(context).size.height*0.025:MediaQuery.of(context).size.height*0.025),
            ),

        // child: Icon(Icons.add),
        // onOpen: () => print('OPENING DIAL'),
        // onClose: () => print('DIAL CLOSED'),
        // visible: dialVisible,
        curve: Curves.bounceIn,
        children: [
          SpeedDialChild(
            child: Icon(
              Icons.cached,
              color: Colors.white,
              size: SizeHelper.isMobilePortrait
                  ? 3.5 * SizeHelper.imageSizeMultiplier
                  : 3.5 * SizeHelper.imageSizeMultiplier,
            ),
            backgroundColor: Color(0xff5352ec),
            onTap: () async {
              setState(() {
                isLoading = true;
              });
              await Provider.of<OrderListProvider>(context, listen: false)
                  .getOrderListFromAPI(context, storeMenuId, true, 1);
              setState(() {
                isLoading = false;
              });
            },
            label: AppLocalizationHelper.of(context).translate("Refresh"),
            labelStyle: GoogleFonts.lato(
              fontWeight: FontWeight.w500,
              fontSize: SizeHelper.isMobilePortrait
                  ? 1.5 * SizeHelper.textMultiplier
                  : 1.5 * SizeHelper.textMultiplier,
            ),
            labelBackgroundColor: Colors.white,
          ),
        ]);
  }

  ScrollController scrollController = new ScrollController();
  // ScrollController dineInScrollController = new ScrollController();
  // ScrollController takeawayScrollController = new ScrollController();
  bool hasTakeaway = true;
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        width: 1080, height: 1920, allowFontScaling: false);
    var store = Provider.of<CurrentStoresProvider>(context, listen: false)
        .getStore(context);
    return SafeArea(
      bottom: false,
      top: true,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        appBar: CustomAppBar.getAppBar(
          '${AppLocalizationHelper.of(context).translate("Order")}',
          true,
          showLogo: true,
          context: context,
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
                              ScreenHelper.getResponsiveTextBodyFontSize(
                                  context))),
                    ),
                    backgroundColor: Color(
                        int.tryParse(store.backgroundColorHex) ??
                            Colors.grey.value),
                  ))
              : Container(
                  width: ScreenUtil().setWidth(100),
                  height: ScreenUtil().setHeight(100),
                  decoration: BoxDecoration(shape: BoxShape.circle),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(store.logoUrl),
                    backgroundColor: Color(
                        int.tryParse(store.backgroundColorHex) ??
                            Colors.grey.value),
                  ),
                ),
          screenPage:
              Provider.of<CurrentUserProvider>(context, listen: false).isAdmin()
                  ? CustomAppBar.storeMainPage
                  : CustomAppBar.staffPage,
        ),
        body: ModalProgressHUD(
          // callback: () async {
          //   await Provider.of<OrderListProvider>(context, listen: false)
          //       .getOrderListFromAPI(context, storeMenuId, true, 1);
          // },
          inAsyncCall: isLoading,
          child: OrientationBuilder(
            builder: (context, orientation) {
              if (!ScreenHelper.isLandScape(context)) {
                return portraitUI();
              } else {
                return landScapeUI();
              }
            },
          ),
        ),
        floatingActionButton: buildSpeedDial(),
      ),
    );
  }

  Widget orderTypeButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: ScreenUtil().setSp(20), horizontal: ScreenUtil().setSp(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            // width: ScreenUtil().setSp(360),
            // height: ScreenUtil().setSp(320),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(ScreenUtil().setSp(8)),
              border: Border.all(
                color: Colors.grey,
                width: ScreenUtil().setSp(2),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setSp(60),
                  vertical: ScreenUtil().setSp(20)),
              child: InkWell(
                child: Container(
                  height: SizeHelper.isMobilePortrait
                      ? 10 * SizeHelper.heightMultiplier
                      : 9 * SizeHelper.widthMultiplier,
                  width: SizeHelper.isMobilePortrait
                      ? 25 * SizeHelper.widthMultiplier
                      : 7 * SizeHelper.heightMultiplier,
                  // height: ScreenUtil().setHeight((!ScreenHelper.isLandScape(context))?MediaQuery.of(context).size.height * 0.1:MediaQuery.of(context).size.height*0.15),
                  // width: ScreenUtil().setWidth((!ScreenHelper.isLandScape(context))?MediaQuery.of(context).size.width * 0.15:MediaQuery.of(context).size.width*0.07),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/order/dine_in.png',
                        // width: MediaQuery.of(context).size.width,
                        height: SizeHelper.isMobilePortrait
                            ? 5 * SizeHelper.heightMultiplier
                            : 5 * SizeHelper.widthMultiplier,
                        width: SizeHelper.isMobilePortrait
                            ? 17 * SizeHelper.widthMultiplier
                            : 5 * SizeHelper.heightMultiplier,
                        // height: ScreenUtil().setHeight((!ScreenHelper.isLandScape(context))?MediaQuery.of(context).size.height * 0.05:MediaQuery.of(context).size.height*0.08),
                        // width: ScreenUtil().setWidth((!ScreenHelper.isLandScape(context))?MediaQuery.of(context).size.width * 0.05:MediaQuery.of(context).size.width*0.08),
                        scale: 2,
                      ),
                      // VEmptyView(ScreenUtil().setSp(60)),
                      Text(
                          AppLocalizationHelper.of(context)
                              .translate('Dine In'),
                          style: GoogleFonts.lato(
                            fontSize: ScreenUtil().setSp(
                                ScreenHelper.getResponsiveTitleFontSize(
                                    context)),
                            color: Colors.grey,
                          )),
                    ],
                  ),
                ),
                onTap: () {
                  setState(() {
                    _selectedType = OrderButtonType.DineIn;
                  });
                  tableNumberDialog();
                },
              ),
            ),
          ),
          Container(
            // width: ScreenUtil().setSp(360),
            // height: ScreenUtil().setSp(320),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(ScreenUtil().setSp(8)),
              border: Border.all(
                color: Colors.grey,
                width: ScreenUtil().setSp(2),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setSp(40),
                  vertical: ScreenUtil().setSp(20)),
              child: InkWell(
                child: Container(
                  height: SizeHelper.isMobilePortrait
                      ? 10 * SizeHelper.heightMultiplier
                      : 9 * SizeHelper.widthMultiplier,
                  width: SizeHelper.isMobilePortrait
                      ? 25 * SizeHelper.widthMultiplier
                      : 9 * SizeHelper.heightMultiplier,
                  // height: ScreenUtil().setHeight((!ScreenHelper.isLandScape(context))?MediaQuery.of(context).size.height * 0.1:MediaQuery.of(context).size.height*0.15),
                  // width: ScreenUtil().setWidth((!ScreenHelper.isLandScape(context))?MediaQuery.of(context).size.width * 0.18:MediaQuery.of(context).size.width*0.1),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/order/take_away.png',
                        // width: MediaQuery.of(context).size.width,
                        height: SizeHelper.isMobilePortrait
                            ? 5 * SizeHelper.heightMultiplier
                            : 5 * SizeHelper.widthMultiplier,
                        width: SizeHelper.isMobilePortrait
                            ? 17 * SizeHelper.widthMultiplier
                            : 5 * SizeHelper.heightMultiplier,
                        // height: ScreenUtil().setHeight((!ScreenHelper.isLandScape(context))?MediaQuery.of(context).size.height * 0.05:MediaQuery.of(context).size.height*0.08),
                        // width: ScreenUtil().setWidth((!ScreenHelper.isLandScape(context))?MediaQuery.of(context).size.width * 0.05:MediaQuery.of(context).size.width*0.08),
                        scale: 2,
                      ),
                      // VEmptyView(ScreenUtil().setSp(60)),
                      Text(
                          AppLocalizationHelper.of(context)
                              .translate('Take-away'),
                          style: GoogleFonts.lato(
                            fontSize: ScreenUtil().setSp(
                                ScreenHelper.getResponsiveTitleFontSize(
                                    context)),
                            color: Colors.grey,
                          )),
                    ],
                  ),
                ),
                onTap: () async {
                  setState(() {
                    _selectedType = OrderButtonType.TakeAway;
                  });
                  try {
                    setState(() {
                      isLoading = true;
                    });
                    var response = await Provider.of<CurrentOrderProvider>(
                            context,
                            listen: false)
                        .initOrder(
                            context, storeMenuId, "", OrderType.TakeAway.index);
                    if (response) {
                      setState(() {
                        isLoading = false;
                      });
                      // no table number for take away
                      _toOrderScreen();
                    }

                    // Helper().showToastError("Init table failed");
                    setState(() {
                      isLoading = false;
                    });
                  } catch (e) {
                    Helper().showToastError(
                        "${AppLocalizationHelper.of(context).translate('FailedToInitTableAlert')}");
                    setState(() {
                      isLoading = false;
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  tableNumberDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return isLoading
              ? Container()
              // : Dialog(
              //     backgroundColor: Color.fromRGBO(0, 0, 0, 0),
              //     child: SingleChildScrollView(
              //       child: Column(
              //           mainAxisAlignment: MainAxisAlignment.center,
              //           children: [
              //             Container(
              //               width: ScreenHelper.isLandScape(context)
              //                   ? SizeHelper.heightMultiplier * 40
              //                   : SizeHelper.heightMultiplier * 60,
              //               decoration: BoxDecoration(
              //                 borderRadius: BorderRadius.circular(10.0),
              //                 border: Border.all(
              //                   width: 1,
              //                   color: Colors.grey,
              //                 ),
              //                 color: Colors.white,
              //               ),
              //               child: Padding(
              //                 padding: EdgeInsets.all(ScreenUtil().setSp(50)),
              //                 child: Column(
              //                   children: [
              //                     Text(
              //                       'Table Name',
              //                       style: GoogleFonts.lato(
              //                         // fontSize: SizeHelper.isMobilePortrait?1.5*SizeHelper.textMultiplier:SizeHelper.textMultiplier,
              //                         fontSize: ScreenUtil().setSp(
              //                             ScreenHelper.isLandScape(context)
              //                                 ? 3 * SizeHelper.textMultiplier
              //                                 : 50),
              //                         color: Colors.black,
              //                         fontWeight: FontWeight.bold,
              //                       ),
              //                     ),
              //                   ],
              //                 ),
              //               ),
              //             ),
              //           ]),
              //     ));
              : CustomDialog(
                  title:
                      AppLocalizationHelper.of(context).translate('Table Name'),
                  insideButtonList: [
                    CustomDialogInsideButton(
                        buttonName: AppLocalizationHelper.of(context)
                            .translate('Cancel'),
                        buttonColor: Colors.grey,
                        buttonEvent: () {
                          Navigator.of(context).pop();
                        }),
                    CustomDialogInsideButton(
                        buttonName: AppLocalizationHelper.of(context)
                            .translate('Confirm'),
                        buttonEvent: () async {
                          try {
                            if (_orderTableNumberKey.currentState.validate()) {
                              setState(() {
                                isLoading = true;
                              });

                              var response =
                                  await Provider.of<CurrentOrderProvider>(
                                          context,
                                          listen: false)
                                      .initOrder(
                                          context,
                                          storeMenuId,
                                          _tableNumberCtrl.text,
                                          OrderType.DineIn.index);
                              if (response) {
                                Navigator.of(context).pop();
                                // setState(() {
                                //   isLoading = false;
                                // });
                                _toOrderScreen();
                                setState(() {
                                  isLoading = false;
                                });
                              } else {
                                Helper().showToastError(
                                    "${AppLocalizationHelper.of(context).translate('FailedToCreateTableAlert')}");
                                setState(() {
                                  isLoading = false;
                                });
                              }
                            }
                          } catch (e) {
                            Helper().showToastError(
                                "${AppLocalizationHelper.of(context).translate('FailedToInitTableAlert')}: " +
                                    e.toString());
                            setState(() {
                              isLoading = false;
                            });
                          }
                        })
                  ],
                  child: Form(
                    key: _orderTableNumberKey,
                    child: Column(
                      children: [
                        TextFieldRow(
                          isDone: true,
                          isReadOnly: false,
                          textController: _tableNumberCtrl,
                          textGlobalKey: 'organizationName',
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(
                                RegExp(spceialCharactersNotAllowWhiteSpace)),
                          ],
                          context: context,
                          isMandate: true,
                          hintText: AppLocalizationHelper.of(context)
                              .translate('Table Name'),
                          textValidator: FormValidateService(context)
                              .validateOrderTableName,
                          onChanged: (value) {},
                        ).textFieldRow(),
                      ],
                    ),
                  ),
                );
        });
  }

  _toOrderScreen() {
    pushNewScreen(
      context,
      screen: OrderTablesPage(),
      withNavBar: false,
      pageTransitionAnimation: PageTransitionAnimation.cupertino,
    );
  }
}

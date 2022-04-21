import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vplus_merchant_app/helpers/apiHelper.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/helpers/screenHelper.dart';
import 'package:vplus_merchant_app/helpers/sizeHelper.dart';
import 'package:vplus_merchant_app/models/StoreKitchen.dart';
import 'package:vplus_merchant_app/models/menuAddOn.dart';
import 'package:vplus_merchant_app/models/menuItem.dart';
import 'package:vplus_merchant_app/providers/current_menu_provider.dart';
import 'package:vplus_merchant_app/providers/current_stores_provider.dart';
import 'package:vplus_merchant_app/styles/regex.dart';
import 'package:vplus_merchant_app/widgets/emptyView.dart';
import 'package:vplus_merchant_app/widgets/components.dart';
import 'package:vplus_merchant_app/helpers/formValidationHelper.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vplus_merchant_app/widgets/pic_selection.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vplus_merchant_app/widgets/custom_dialog.dart';
import 'package:vplus_merchant_app/models/menuAddOnOption.dart';
import 'package:provider/provider.dart';
import 'package:vplus_merchant_app/widgets/new_item_addons_selection.dart';
import 'package:vplus_merchant_app/widgets/store_kitchen_select.dart';

class MenuItemForm extends StatefulWidget {
  final MenuItem initMenuItem;
  final Function submitCallBack;
  final Function deleteCallBack;

  MenuItemForm({this.submitCallBack, this.initMenuItem, this.deleteCallBack});
  @override
  _MenuItemFormState createState() => _MenuItemFormState();
}

class _MenuItemFormState extends State<MenuItemForm> {
  int menuItemID;
  bool _isSoldOut = false;
  bool _isPop = false;
  String image64; //base64
  String imageURL;
  List<MenuAddOn> selectedAddOnsObjects = [];

  List<MenuAddOn> allAddOns;

  ScrollController _addonsItemCtrl = new ScrollController();
  final GlobalKey<FormState> _createItemKey = GlobalKey<FormState>();

  TextEditingController _itemNameCtrl = new TextEditingController();
  TextEditingController _itemSubNameCtrl = new TextEditingController();
  TextEditingController _itemDescrCtrl = new TextEditingController();
  TextEditingController _itemPriceCtrl = new TextEditingController();
  TextEditingController _itemKitchenIdCtrl = new TextEditingController();
  FormValidateService _formValidateService;
  MenuItem initMenuItem;

  @override
  void initState() {
    super.initState();
    allAddOns = Provider.of<CurrentMenuProvider>(context, listen: false)
        .getStoreMenu
        .menuAddOns;
    initMenuItem = widget.initMenuItem;
    if (initMenuItem != null) {
      menuItemID = initMenuItem.menuItemId;
      _isSoldOut = initMenuItem.isSoldOut;
      _itemNameCtrl.text = initMenuItem.menuItemName;
      _isPop = initMenuItem.isPopular;
      if (initMenuItem.subtitle != null)
        _itemSubNameCtrl.text = initMenuItem.subtitle;
      _itemPriceCtrl.text = initMenuItem.price.toString();
      _itemDescrCtrl.text = initMenuItem.description;
      imageURL = initMenuItem.imageUrl;
      if (initMenuItem.storeKitchenId != null)
        _itemKitchenIdCtrl.text = initMenuItem.storeKitchenId.toString();
    }
    _formValidateService = FormValidateService(context);
  }

  @override
  void didChangeDependencies() {
    // Provider.of<CurrentMenuProvider>(context, listen: false)
    //     .setSelectedAddons(widget.initMenuItem.menuAddOns);

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _createItemKey,
      child: Padding(
        padding: EdgeInsets.only(
          top: ScreenUtil().setHeight(50),
          bottom: ScreenUtil().setHeight(150),
          left: ScreenUtil().setWidth(30),
          right: ScreenUtil().setWidth(30),
        ),
        child: Container(
          alignment: Alignment.center,
          width: SizeHelper.isMobilePortrait
              ? 200 * SizeHelper.widthMultiplier
              : SizeHelper.isPortrait
                  ? 50 * SizeHelper.heightMultiplier
                  : 50 * SizeHelper.heightMultiplier,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              PicSelection(
                (v) {
                  setState(() {
                    image64 = v;
                  });
                },
                componentHeight: ScreenHelper.isLandScape(context)
                    ? 40 * SizeHelper.heightMultiplier
                    : 40 * SizeHelper.heightMultiplier,
                isComponentBorder: false,
                picFlex: 2,
                isChildCirclePic: false,
                childHeight: ScreenHelper.isLandScape(context)
                    ? 70 * SizeHelper.heightMultiplier
                    : SizeHelper.isMobilePortrait
                        ? 80 * SizeHelper.heightMultiplier
                        : 40 * SizeHelper.heightMultiplier,
                childWidth: ScreenHelper.isLandScape(context)
                    ? 35 * SizeHelper.widthMultiplier
                    : SizeHelper.isMobilePortrait
                        ? 45 * SizeHelper.heightMultiplier
                        : 45 * SizeHelper.heightMultiplier,
                child: widget.initMenuItem == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                              AppLocalizationHelper.of(context)
                                  .translate('Upload'),
                              style: GoogleFonts.lato(
                                color: Colors.black,
                                fontSize: SizeHelper.textMultiplier *
                                    (ScreenHelper.isLandScape(context) ? 2 : 2),
                              )),
                          Text(
                            AppLocalizationHelper.of(context)
                                .translate('Image'),
                            style: GoogleFonts.lato(
                                color: Colors.black,
                                fontSize: SizeHelper.textMultiplier *
                                    (ScreenHelper.isLandScape(context)
                                        ? 2
                                        : 2)),
                          ),
                        ],
                      )
                    : imageURL == null
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
                                  widget.initMenuItem.menuItemName
                                      .substring(0, 1),
                                  style: GoogleFonts.lato(
                                    color: Colors.white,
                                    fontSize: ScreenUtil().setSp(55),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : SquareFadeInImage(imageURL),
              ),
              VEmptyView(40),
              TextFieldRow(
                isReadOnly: false,
                textController: _itemNameCtrl,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(
                      RegExp(spceialCharactersAllowWhiteSpace)),
                ],
                textGlobalKey: 'Item Name',
                context: context,
                isMandate: true,
                hintText:
                    AppLocalizationHelper.of(context).translate('ItemName'),
                icon: ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: ScreenUtil().setHeight(
                          ScreenHelper.isLandScape(context) ? 300 : 210)),
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: ScreenUtil().setWidth(10)),
                        child: Text(
                          AppLocalizationHelper.of(context).translate('Name'),
                          style: GoogleFonts.lato(
                              fontSize: ScreenUtil().setSp(ScreenHelper
                                  .getResponsiveTextBodySmallFontSize(context)),
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                textValidator: _formValidateService.validateMenuItemName,
                onChanged: (value) {},
              ).textFieldRow(),
              VEmptyView(40),
              TextFieldRow(
                isReadOnly: false,
                textController: _itemSubNameCtrl,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(
                      RegExp(spceialCharactersAllowWhiteSpace)),
                ],
                textGlobalKey: 'Item Sub Name',
                context: context,
                isMandate: false,
                hintText:
                    AppLocalizationHelper.of(context).translate('Subtitle'),
                icon: ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth: ScreenUtil().setHeight(
                            ScreenHelper.isLandScape(context) ? 300 : 210)),
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: ScreenUtil().setWidth(10)),
                          child: Text(
                            AppLocalizationHelper.of(context)
                                .translate('Subtitle'),
                            style: GoogleFonts.lato(
                                fontSize: ScreenUtil().setSp(ScreenHelper
                                    .getResponsiveTextBodySmallFontSize(
                                        context)),
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    )),
                textValidator: _formValidateService.validateMenuItemSubtitle,
                onChanged: (value) {},
              ).textFieldRow(),
              VEmptyView(40),
              Container(
                child: TextFieldRow(
                  isReadOnly: false,
                  textController: _itemDescrCtrl,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(
                        RegExp(spceialCharactersAllowWhiteSpace)),
                  ],
                  textGlobalKey: 'Item Description',
                  context: context,
                  isMandate: true,
                  hintText: AppLocalizationHelper.of(context)
                      .translate('ItemDescription'),
                  icon: ConstrainedBox(
                      constraints: BoxConstraints(
                          maxWidth: ScreenUtil().setHeight(
                              ScreenHelper.isLandScape(context) ? 300 : 210)),
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: ScreenUtil().setWidth(10)),
                            child: Text(
                              AppLocalizationHelper.of(context)
                                  .translate('ItemDescription'),
                              style: GoogleFonts.lato(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: ScreenUtil().setSp(ScreenHelper
                                      .getResponsiveTextBodySmallFontSize(
                                          context))),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      )),
                  textValidator:
                      _formValidateService.validateMenuItemDescription,
                  onChanged: (value) {},
                ).textFieldRow(),
              ),
              VEmptyView(40),
              TextFieldRow(
                isReadOnly: false,
                textController: _itemPriceCtrl,
                textGlobalKey: 'Price',
                context: context,
                isMandate: true,
                hintText:
                    AppLocalizationHelper.of(context).translate('ItemPrice'),
                inputFormatters: [DecimalTextInputFormatter(decimalRange: 2)],
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                icon: ConstrainedBox(
                  constraints: BoxConstraints(
                      minWidth: ScreenUtil().setHeight(
                          ScreenHelper.isLandScape(context) ? 300 : 210)),
                  child: Icon(
                    FontAwesomeIcons.dollarSign,
                    color: Colors.black,
                  ),
                ),
                textValidator: _formValidateService.validatePrice,
                onChanged: (value) {},
              ).textFieldRow(),
              VEmptyView(40),
              StoreKitchenSelection((v) {
                setState(() {
                  _itemKitchenIdCtrl.text = v.toString();
                });
              },
                  defaultKitchenId: (initMenuItem?.storeKitchenId == null)
                      ? null
                      : initMenuItem.storeKitchenId),
              VEmptyView(40),
              Container(
                width: double.infinity,
                // decoration: BoxDecoration(
                //     borderRadius: BorderRadius.circular(10.0),
                //     border: Border.all(
                //       color: borderColor,
                //       width: 2.0,
                //     )),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(
                          ScreenHelper.isLandScape(context) ? 0 : 8),
                      child: Text(
                        AppLocalizationHelper.of(context).translate('Add-On'),
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(
                              ScreenHelper.getResponsiveTextBodyFontSize(
                                  context)),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Divider(
                    //   thickness: 2,
                    //   height: 1,
                    // ),
                    Container(
                      child: Consumer<CurrentMenuProvider>(
                        builder: (ctx, p, w) {
                          var allAddOns = p.getSelectedAddOns;
                          if (allAddOns == null || allAddOns.length == 0) {
                            return Container();
                          }
                          selectedAddOnsObjects = allAddOns;
                          List<Widget> elements = selectedAddOnsObjects
                              .map((e) =>
                                  getAddOnsRow(e, _deletedSelectedAddOns))
                              .toList();
                          return Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(
                                  color: borderColor,
                                  width: ScreenUtil().setSp(4),
                                )),
                            constraints: BoxConstraints(
                                minHeight:
                                    (elements == null || elements.length == 0)
                                        ? 0
                                        : SizeHelper.isMobilePortrait
                                            ? SizeHelper.heightMultiplier * 20
                                            : SizeHelper.heightMultiplier * 40),
                            height: (elements == null || elements.length == 0)
                                ? 0
                                : SizeHelper.isMobilePortrait
                                    ? SizeHelper.heightMultiplier * 20
                                    : SizeHelper.heightMultiplier * 40,
                            child: ReorderableListView(
                              scrollController: _addonsItemCtrl,
                              children: elements,
                              onReorder: (oldIndex, newIndex) {
                                print(
                                    'oldIndex: $oldIndex , newIndex: $newIndex');
                                setState(() {
                                  if (newIndex ==
                                      selectedAddOnsObjects.length) {
                                    newIndex = selectedAddOnsObjects.length - 1;
                                  }
                                  var item =
                                      selectedAddOnsObjects.removeAt(oldIndex);
                                  selectedAddOnsObjects.insert(newIndex, item);
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    // Divider(
                    //   thickness: 2,
                    //   height: 1,
                    // ),
                    Center(
                      child: FlatButton(
                        onPressed: _addAddOnsButton,
                        child: Icon(
                          Icons.add_circle_outlined,
                          color: Color(0xff24a56a),
                          size: 30,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              VEmptyView(20),
              Row(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizationHelper.of(context).translate('SoldOut'),
                        maxLines: 2,
                        softWrap: true,
                        overflow: TextOverflow.clip,
                        style: GoogleFonts.lato(
                          fontSize: ScreenHelper.isLandScape(context)
                              ? SizeHelper.heightMultiplier * 2
                              : SizeHelper.heightMultiplier * 2,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Switch(
                        value: _isSoldOut,
                        onChanged: (value) {
                          setState(() {
                            _isSoldOut = value;
                          });
                        },
                        activeColor: Colors.white,
                        activeTrackColor: Color(0xff47d00a),
                        inactiveTrackColor: Color(0xffdde4ec),
                        inactiveThumbColor: Colors.white,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "Popular",
                        maxLines: 2,
                        softWrap: true,
                        overflow: TextOverflow.clip,
                        style: GoogleFonts.lato(
                          fontSize: ScreenHelper.isLandScape(context)
                              ? SizeHelper.heightMultiplier * 2
                              : SizeHelper.heightMultiplier * 2,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Switch(
                        value: _isPop,
                        onChanged: (value) async{
                          if(initMenuItem!=null) {
                            Provider.of<CurrentMenuProvider>(
                                context, listen: false).setItemIsPopular(
                                context, initMenuItem.menuItemId, value);
                          }
                          setState(() {
                            _isPop = value;
                          });
                        },
                        activeColor: Colors.white,
                        activeTrackColor: Color(0xff47d00a),
                        inactiveTrackColor: Color(0xffdde4ec),
                        inactiveThumbColor: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
              VEmptyView(20),
              Row(
                children: [
                  widget.initMenuItem != null
                      ? Expanded(
                          child: Container(
                            width: double.infinity,
                            height: ScreenUtil().setHeight(120),
                            child: RaisedButton(
                              onPressed: _deleteButton,
                              textColor: Colors.white,
                              color: Color(0xfff61a36),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    AppLocalizationHelper.of(context)
                                        .translate('Delete'),
                                    style: GoogleFonts.lato(
                                      fontWeight: FontWeight.bold,
                                      fontSize: ScreenUtil().setSp(ScreenHelper
                                          .getResponsiveTitleFontSize(context)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : Container(),
                  widget.initMenuItem != null ? WEmptyView(70) : Container(),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      height: ScreenUtil().setHeight(120),
                      child: RaisedButton(
                        onPressed: _saveButton,
                        textColor: Colors.white,
                        color: Color(0xff5352ec),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              AppLocalizationHelper.of(context)
                                  .translate('Save'),
                              style: GoogleFonts.lato(
                                fontWeight: FontWeight.bold,
                                fontSize: ScreenUtil().setSp(
                                    ScreenHelper.getResponsiveTitleFontSize(
                                        context)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _deletedSelectedAddOns(MenuAddOn menuAddOn) {
    return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              AppLocalizationHelper.of(context).translate('ConfirmDelete'),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                      '${AppLocalizationHelper.of(context).translate('PleaseConfirmToDelete')} '),
                  Text(
                      '${AppLocalizationHelper.of(context).translate('AddOnOption')}: ${menuAddOn.menuAddOnName}'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  AppLocalizationHelper.of(context).translate('Cancel'),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text(
                  AppLocalizationHelper.of(context).translate('Delete'),
                ),
                onPressed: () {
                  setState(() {
                    selectedAddOnsObjects.removeWhere(
                        (e) => e.menuAddOnId == menuAddOn.menuAddOnId);
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  _detailAddOns(MenuAddOn menuAddOn) {
    List<MenuAddOnOption> listOpt = allAddOns
        .firstWhere((e) => e.menuAddOnId == menuAddOn.menuAddOnId)
        .menuAddOnOptions;
    return showDialog<void>(
        context: (context),
        builder: (context) => CustomDialog(
              title:
                  AppLocalizationHelper.of(context).translate('AddOnDetails'),
              child: Column(
                children: [
                  Text(
                    menuAddOn.menuAddOnName,
                    style: GoogleFonts.lato(
                        fontSize: ScreenUtil().setSp(
                            ScreenHelper.getResponsiveTextBodyFontSize(
                                context)),
                        fontWeight: FontWeight.bold),
                  ),
                  if (menuAddOn.subtitle != null &&
                      menuAddOn.subtitle.length > 0)
                    Text(
                      menuAddOn.subtitle,
                      style: GoogleFonts.lato(
                          fontStyle: FontStyle.italic,
                          fontSize: ScreenUtil().setSp(
                              ScreenHelper.getResponsiveTextBodyFontSize(
                                  context)),
                          fontWeight: FontWeight.normal),
                    ),
                  listOpt != null
                      ? getMenuAddOnsOptionsList(listOpt)
                      : Container(),
                ],
              ),
              insideButtonList: [
                CustomDialogInsideButton(
                    buttonName:
                        AppLocalizationHelper.of(context).translate('Confirm'),
                    buttonEvent: () {
                      Navigator.pop(context);
                    }),
              ],
            ));
  }

  Widget getMenuAddOnsOptionsList(List<MenuAddOnOption> opts) {
    return Column(
      children: opts
          .map(
            (opt) => opt.isActive == true
                ? Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: ScreenUtil().setHeight(20),
                      horizontal: ScreenUtil().setWidth(30),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 8,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                opt.optionName,
                                style: GoogleFonts.lato(
                                  fontSize: ScreenUtil().setSp(
                                      ScreenHelper.isLandScape(context)
                                          ? SizeHelper.textMultiplier * 2
                                          : 45),
                                ),
                              ),
                              if (opt.optionSubtitle != null &&
                                  opt.optionSubtitle.length > 0)
                                Text(
                                  opt.optionSubtitle,
                                  style: GoogleFonts.lato(
                                      fontStyle: FontStyle.italic,
                                      fontSize: ScreenUtil().setSp(ScreenHelper
                                          .getResponsiveTextBodyFontSize(
                                              context)),
                                      fontWeight: FontWeight.normal),
                                ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            opt.extraCostOptionViewModel.extraCostType == 0
                                ? '(Free)'
                                : opt.extraCostOptionViewModel.extraCostType ==
                                        2
                                    ? '(\$' +
                                        opt.extraCostOptionViewModel.fixedAmount
                                            .toString() +
                                        ')'
                                    : '(' +
                                        opt.extraCostOptionViewModel.percent
                                            .toString() +
                                        '%)',
                            style: GoogleFonts.lato(
                              fontSize: ScreenUtil().setSp(
                                  ScreenHelper.isLandScape(context)
                                      ? SizeHelper.textMultiplier * 2
                                      : 45),
                            ),
                          ),
                        ),
                        opt.imageUrl != null
                            ? Container(
                                constraints: BoxConstraints(
                                  maxHeight: ScreenUtil().setHeight(100),
                                  maxWidth: ScreenUtil().setWidth(100),
                                ),
                                child: SquareFadeInImage(opt.imageUrl))
                            : Container(),
                      ],
                    ),
                  )
                : Container(),
          )
          .toList(),
    );
  }

  Widget getAddOnsRow(MenuAddOn menuAddOn, Function deleteCallBack) {
    return Container(
      key: ValueKey(menuAddOn.menuAddOnId),
      height: ScreenUtil().setSp(ScreenHelper.isLandScape(context) ? 100 : 130),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          // borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
        color: borderColor,
        width: ScreenUtil().setSp(2),
      )),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        menuAddOn.menuAddOnName,
                        style: GoogleFonts.lato(
                            fontSize: ScreenUtil().setSp(
                                ScreenHelper.getResponsiveTextBodyFontSize(
                                    context))),
                      ),
                      if (menuAddOn.subtitle != null &&
                          menuAddOn.subtitle.length > 0)
                        Text(
                          menuAddOn.subtitle,
                          style: GoogleFonts.lato(
                            fontStyle: FontStyle.italic,
                            fontSize: SizeHelper.isMobilePortrait
                                ? 1.5 * SizeHelper.textMultiplier
                                : 1.5 * SizeHelper.textMultiplier,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              ButtonTheme(
                padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                minWidth: ScreenUtil().setWidth(20), //wraps child's width
                height: ScreenHelper.isLandScape(context)
                    ? SizeHelper.heightMultiplier * 6
                    : SizeHelper.heightMultiplier * 6, //wraps child's height
                child: FlatButton(
                  onPressed: () {
                    _detailAddOns(menuAddOn);
                  },
                  child: Text(
                      AppLocalizationHelper.of(context).translate('Details'),
                      style: GoogleFonts.lato(
                          fontSize: ScreenUtil().setSp(
                              ScreenHelper.getResponsiveTextBodyFontSize(
                                  context)))),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: borderColor,
                      width: 1,
                      style: BorderStyle.solid,
                    ),
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ), //your original button
              ),
              ButtonTheme(
                padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                minWidth: ScreenUtil().setWidth(10), //wraps child's width
                height: ScreenUtil().setHeight(70), //wraps child's height
                child: FlatButton(
                  onPressed: () {},
                  child: Icon(
                    Icons.open_with,
                    color: Colors.black,
                    size: SizeHelper.isMobilePortrait
                        ? 1.5 * SizeHelper.textMultiplier
                        : 3 * SizeHelper.textMultiplier,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ), //your original bu
              ),
              ButtonTheme(
                padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                minWidth: ScreenUtil().setWidth(20), //wraps child's width
                height: ScreenUtil().setWidth(70), //wraps child's height
                child: FlatButton(
                  onPressed: () {
                    deleteCallBack(menuAddOn);
                  },
                  child: Icon(
                    Icons.close_rounded,
                    color: Colors.red,
                    size: 20,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ), //your original bu
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _deleteButton() {
    showDialog(
        context: (context),
        builder: (context) => CustomDialog(
              child: Column(
                children: [
                  Center(
                    child: Text(
                      AppLocalizationHelper.of(context)
                          .translate('PleaseConfirmToDelete'),
                      style: GoogleFonts.lato(),
                    ),
                  ),
                  Center(
                    child: Text(widget.initMenuItem.menuItemName + '?',
                        style: GoogleFonts.lato()),
                  ),
                ],
              ),
              insideButtonList: [
                CustomDialogInsideCancelButton(callBack: () {
                  Navigator.pop(context);
                }),
                CustomDialogInsideButton(
                  buttonName:
                      AppLocalizationHelper.of(context).translate('Confirm'),
                  buttonEvent: () {
                    _deleteConfirmButton();
                  },
                ),
              ],
            ));
  }

  void _deleteConfirmButton() async {
    Navigator.pop(context);
    widget.deleteCallBack(menuItemID);
  }

  void _saveButton() {
    try {
      if (_createItemKey.currentState.validate()) {
        if (_itemNameCtrl.text.length >= 1 &&
            _itemNameCtrl.text.length <= 35 &&
            _itemSubNameCtrl.text.length <= 35) {
          if (double.parse(_itemPriceCtrl.text) < 10000 &&
              double.parse(_itemPriceCtrl.text) >= 0) {
            _createItemKey.currentState.save();

            // dismiss keyboard during async call
            FocusScope.of(context).requestFocus(new FocusNode());

            MenuItem menuItem = MenuItem(
              menuItemName: _itemNameCtrl.text,
              subtitle: _itemSubNameCtrl.text,
              price: double.parse(_itemPriceCtrl.text),
              menuAddOns:
                  selectedAddOnsObjects, //selectedAddOnsObjects.map((e) => e.menuAddOnId).toList(),
              isSoldOut: _isSoldOut,
              isPopular: _isPop,
              description: _itemDescrCtrl.text,
              image64: image64,
              menuItemId: menuItemID,
              storeKitchenId: (_itemKitchenIdCtrl.text == "null" ||
                      _itemKitchenIdCtrl.text == "")
                  ? null
                  : int.parse(_itemKitchenIdCtrl.text),
            );

            widget.submitCallBack(menuItem);
          } else {
            Helper().showToastError(
                '${AppLocalizationHelper.of(context).translate('InvalidPriceNote')}');
          }
        } else {
          Helper().showToastError(
              '${AppLocalizationHelper.of(context).translate('MaximumInputExcessedAlert')}');
        }
      }
    } catch (e) {
      print(e);
    }
  }

  _addonSelectedEvent(int index, bool value) {
    addOnsListWidgets[index]['isSelected'] = value;
    print(addOnsListWidgets[index]['isSelected']);
  }

  List<dynamic> addOnsListWidgets;
  void _addAddOnsButton() async {
    addOnsListWidgets = allAddOns.map((e) {
      return {"addOn": e, "isSelected": false};
    }).toList();

    var selectedAddOnsFromDialog = await showDialog(
      context: context,
      builder: (ctx) {
        return CustomDialog(
          insideButtonList: [
            CustomDialogInsideCancelButton(callBack: () {
              Navigator.pop(context);
            }),
            CustomDialogInsideButton(
                buttonName:
                    "${AppLocalizationHelper.of(context).translate('Confirm')}",
                buttonEvent: () {
                  Navigator.of(context).pop();
                })
          ],
          child: AddOnsMultiSelection(
            addOnsListWidgets,
            callback: _addonSelectedEvent,
          ),
        );
      },
    );

    addOnsListWidgets.removeWhere((e) => e['isSelected'] == false);
    selectedAddOnsObjects =
        addOnsListWidgets.map((e) => e['addOn'] as MenuAddOn).toList();

    Provider.of<CurrentMenuProvider>(context, listen: false)
        .setSelectedAddons(selectedAddOnsObjects);
  }
}

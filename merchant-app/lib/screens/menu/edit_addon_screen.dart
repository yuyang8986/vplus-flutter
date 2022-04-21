import 'dart:math';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vplus_merchant_app/helpers/apiHelper.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/helpers/screenHelper.dart';
import 'package:vplus_merchant_app/helpers/sizeHelper.dart';
import 'package:vplus_merchant_app/helpers/stringHelper.dart';
import 'package:vplus_merchant_app/models/extraCost.dart';
import 'package:vplus_merchant_app/models/menuAddOn.dart';
import 'package:vplus_merchant_app/models/menuAddOnOption.dart';
import 'package:vplus_merchant_app/providers/current_menu_provider.dart';
import 'package:vplus_merchant_app/styles/regex.dart';
import 'package:vplus_merchant_app/widgets/customAppBar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:vplus_merchant_app/widgets/custom_dialog.dart';
import 'package:vplus_merchant_app/widgets/dropdown_select.dart';
import 'package:vplus_merchant_app/widgets/emptyView.dart';
import 'package:vplus_merchant_app/widgets/components.dart';
import 'package:vplus_merchant_app/helpers/formValidationHelper.dart';

import 'package:vplus_merchant_app/widgets/pic_selection.dart';
import 'package:google_fonts/google_fonts.dart';

class EditAddon extends StatefulWidget {
  EditAddon(this.menuAddOn, this.isMenuLocked);

  MenuAddOn menuAddOn;
  bool isMenuLocked;
  @override
  _EditAddonState createState() => _EditAddonState();
}

class _EditAddonState extends State<EditAddon> {
  bool _isInAsyncCall = false;
  bool _isOptionMulti;
  MenuAddOn _menuAddOn;
  bool isMenuLocked;
  bool _inAsyncCall;

  final GlobalKey<FormState> _editAddonKey = GlobalKey<FormState>();

  TextEditingController _addOnNameCtrl = new TextEditingController();
  TextEditingController _addOnSubNameCtrl = new TextEditingController();
  TextEditingController _addOnNameDescrCtrl = new TextEditingController();
  List<MenuAddOnOption> newAddonOptions;

  final _optionNameCtrl = TextEditingController();
  final _optionSubtitleCtrl = TextEditingController();
  var imageNewAddOnOption = '';
  String imageUrl;
  AddonOptionPriceMethodType selectedPriceMethod;
  TextEditingController priceTextCtrl = TextEditingController();
  ScrollController _optionItemCtrl = new ScrollController();
  ExtraCostOptionViewModel optionExtraCostOptionViewModel;
  var selectedMethod;

  FormValidateService _formValidateService;

  @override
  void initState() {
    _menuAddOn = widget.menuAddOn;
    _isOptionMulti = _menuAddOn.isMulti;
    _addOnNameCtrl.text = _menuAddOn.menuAddOnName;
    if (_menuAddOn.subtitle != null)
      _addOnSubNameCtrl.text = _menuAddOn.subtitle;
    _addOnNameDescrCtrl.text = _menuAddOn.note;
    newAddonOptions = _menuAddOn.menuAddOnOptions;
    isMenuLocked = widget.isMenuLocked;
    _inAsyncCall = false;

    _formValidateService = FormValidateService(context);
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
        resizeToAvoidBottomInset: true,
        appBar: CustomAppBar.getAppBar(
          AppLocalizationHelper.of(context).translate('EditAddOn'),
          false,
          context: context,
          showLogo: false,
        ),
        body: ModalProgressHUD(
          inAsyncCall: _isInAsyncCall,
          child: SingleChildScrollView(
            child: Container(
              // height: ScreenUtil().setHeight(2500),
              child: ModalProgressHUD(
                child: buildNewMenuAddonForm(context),
                inAsyncCall: _isInAsyncCall,
                // demo of some additional parameters
                opacity: 0.5,
                progressIndicator: CircularProgressIndicator(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildNewMenuAddonForm(BuildContext context) {
    return Form(
      key: _editAddonKey,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: ScreenUtil().setHeight(20),
          horizontal: ScreenUtil().setWidth(50),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            VEmptyView(40),
            TextFieldRow(
              //isReadOnly: (isMenuLocked) ? true : false,
              textController: _addOnNameCtrl,
              inputFormatters: [
                FilteringTextInputFormatter.deny(
                    RegExp(spceialCharactersAllowWhiteSpace)),
              ],
              textGlobalKey: 'Add-on Name',
              context: context,
              isMandate: true,
              hintText:
                  AppLocalizationHelper.of(context).translate('AddOnName'),
              icon: ConstrainedBox(
                  constraints:
                      BoxConstraints(maxWidth: ScreenUtil().setHeight(300)),
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: ScreenUtil().setWidth(10)),
                        child: Text(
                          AppLocalizationHelper.of(context).translate('Name'),
                          style: GoogleFonts.lato(
                              color: Colors.black,
                              fontSize: SizeHelper.textMultiplier *
                                  (ScreenHelper.isLandScape(context) ? 1.3 : 2),
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  )),
              textValidator: _formValidateService.validateMenuItemName,
              onChanged: (value) {},
            ).textFieldRow(),
            VEmptyView(40),
            TextFieldRow(
              //isReadOnly: (isMenuLocked) ? true : false,
              textController: _addOnSubNameCtrl,
              inputFormatters: [
                FilteringTextInputFormatter.deny(
                    RegExp(spceialCharactersAllowWhiteSpace)),
              ],
              textGlobalKey: 'Sub title',
              context: context,
              isMandate: false,
              hintText:
                  AppLocalizationHelper.of(context).translate('AddOnSubtitle'),
              icon: ConstrainedBox(
                  constraints:
                      BoxConstraints(maxWidth: ScreenUtil().setHeight(300)),
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: ScreenUtil().setWidth(10)),
                        child: Text(
                          AppLocalizationHelper.of(context)
                              .translate('Subtitle'),
                          style: GoogleFonts.lato(
                              color: Colors.black,
                              fontSize: SizeHelper.textMultiplier *
                                  (ScreenHelper.isLandScape(context) ? 1.3 : 2),
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
            TextFieldRow(
              //isReadOnly: (isMenuLocked) ? true : false,
              textController: _addOnNameDescrCtrl,
              inputFormatters: [
                FilteringTextInputFormatter.deny(
                    RegExp(spceialCharactersAllowWhiteSpace)),
              ],
              textGlobalKey: 'Add-On Description',
              context: context,
              isMandate: false,
              hintText: AppLocalizationHelper.of(context)
                  .translate('AddOnDescription'),
              icon: ConstrainedBox(
                  constraints:
                      BoxConstraints(maxWidth: ScreenUtil().setHeight(300)),
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
                            fontSize: SizeHelper.textMultiplier *
                                (ScreenHelper.isLandScape(context) ? 1.3 : 2),
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  )),
              textValidator: _formValidateService.validateMenuItemDescription,
              onChanged: (value) {},
            ).textFieldRow(),
            VEmptyView(20),
            Container(
              //height: ScreenUtil().setHeight(550), //each row 120
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      AppLocalizationHelper.of(context)
                          .translate('CustomerSelectionOptions'),
                      style: GoogleFonts.lato(
                        fontSize: ScreenUtil().setSp(
                            ScreenHelper.getResponsiveTextBodyFontSize(
                                context)),
                        fontWeight: FontWeight.bold,
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
                                AppLocalizationHelper.of(context)
                                    .translate('SingleSelection'),
                                style: GoogleFonts.lato(
                                    fontSize: ScreenUtil().setSp(ScreenHelper
                                        .getResponsiveTextBodyFontSize(
                                            context)))),
                            value: false,
                            groupValue: _isOptionMulti,
                            onChanged: (selected) {
                              setState(() {
                                _isOptionMulti = selected;
                              });
                            }),
                      ),
                      Flexible(
                        fit: FlexFit.loose,
                        child: RadioListTile(
                          title: Text(
                              AppLocalizationHelper.of(context)
                                  .translate('MultiSelection'),
                              style: GoogleFonts.lato(
                                  fontSize: ScreenUtil().setSp(ScreenHelper
                                      .getResponsiveTextBodyFontSize(
                                          context)))),
                          value: true,
                          groupValue: _isOptionMulti,
                          onChanged: (selected) {
                            setState(() {
                              _isOptionMulti = selected;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            VEmptyView(40),
            _addOnOptionsList(),
           // if (isMenuLocked == false)
              Container(
                width: double.infinity,
                height: ScreenUtil().setHeight(120),
                child: Row(
                  children: [
                    Expanded(
                      child: RaisedButton(
                        onPressed: () {
                          _showDeleteAddOnDialog();
                        },
                        textColor: Colors.white,
                        color: Colors.red,
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
                                fontSize: ScreenUtil().setSp(
                                    ScreenHelper.getResponsiveTextBodyFontSize(
                                        context)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    WEmptyView(50),
                    Expanded(
                      child: RaisedButton(
                        onPressed: () {
                          _submitForm();
                        },
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
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _addOnOptionsList() {
    List<Widget> elements =
        newAddonOptions.map((o) => _generateSingleOption(o)).toList();
    return Container(
      // decoration: BoxDecoration(
      //     borderRadius: BorderRadius.circular(10.0),
      //     border: Border.all(
      //       color: borderColor,
      //       width: ScreenUtil().setSp(4),
      //     )),
      child: Column(
        children: [
          _selectedOptions(elements),
         // if (isMenuLocked == false)
            Center(
              child: FlatButton(
                onPressed: () {
                  _newOptionPopup();
                },
                child: Icon(
                  Icons.add_circle_outlined,
                  color: Color(0xff24a56a),
                  size: ScreenUtil()
                      .setSp(ScreenHelper.isLargeScreen(context) ? 40 : 80),
                ),
              ),
            ),
        ],
      ),
    );
  }

  _newOptionPopup() {
    showDialog(
        context: (context),
        builder: (context) => CustomDialog(
              title: AppLocalizationHelper.of(context)
                  .translate('NewAddOnOptions'),
              child: _getNewAddOnOptionPopUp(),
              insideButtonList: [
                CustomDialogInsideCancelButton(callBack: () {
                  _disposeFormElements();
                  Navigator.pop(context);
                }),
                CustomDialogInsideButton(
                  buttonName:
                      AppLocalizationHelper.of(context).translate('Confirm'),
                  buttonEvent: () {
                    if (_optionNameCtrl.text.length >= 1 &&
                        _optionNameCtrl.text.length <= 35 &&
                        _optionSubtitleCtrl.text.length <= 35) {
                      var menuAddOnOpton = new MenuAddOnOption(
                        menuAddOnOptionId:
                            Random().nextInt(9999), // TODO remove dummy data
                        image: imageNewAddOnOption,
                        isActive: true,
                        optionName: _optionNameCtrl.text,
                        optionSubtitle: _optionSubtitleCtrl.text,
                        extraCostOptionViewModel: ExtraCostOptionViewModel(
                            extraCostType: selectedPriceMethod.index,
                            fixedAmount: selectedPriceMethod ==
                                    AddonOptionPriceMethodType.FixedAmount
                                ? double.parse(priceTextCtrl.text)
                                : 0,
                            percent: selectedPriceMethod ==
                                    AddonOptionPriceMethodType.Percentage
                                ? double.parse(priceTextCtrl.text)
                                : 0),
                      );
                      setState(() {
                        newAddonOptions.add(menuAddOnOpton);
                      });
                      _disposeFormElements();
                      Navigator.pop(context);
                    } else {
                      var helper = Helper();
                      helper.showToastError(
                          '${AppLocalizationHelper.of(context).translate('MaximumInputExcessedAlert')}');
                    }
                    selectedPriceMethod = null;
                  },
                ),
              ],
            ));
  }

  _editOptionPopup(MenuAddOnOption o) {
    // get data
    imageUrl = o.imageUrl;
    imageNewAddOnOption = o.image;
    _optionNameCtrl.text = o.optionName;
    // get saved extra cost information
    selectedPriceMethod = AddonOptionPriceMethodType
        .values[o.extraCostOptionViewModel.extraCostType];
    if (AddonOptionPriceMethodType
            .values[o.extraCostOptionViewModel.extraCostType] ==
        AddonOptionPriceMethodType.FixedAmount) {
      priceTextCtrl.text = o.extraCostOptionViewModel.fixedAmount.toString();
    } else if (AddonOptionPriceMethodType
            .values[o.extraCostOptionViewModel.extraCostType] ==
        AddonOptionPriceMethodType.Percentage) {
      priceTextCtrl.text = o.extraCostOptionViewModel.percent.toString();
    } else {
      // Free
      priceTextCtrl.text = "";
    }
    if (o.optionSubtitle != null) _optionSubtitleCtrl.text = o.optionSubtitle;
    // selectedPriceMethod = o.priceMethodType;
    // priceTextCtrl.text = o.amount.toString();

    showDialog(
        context: (context),
        builder: (context) => CustomDialog(
              title: AppLocalizationHelper.of(context).translate('EditAddOn'),
              child: _getNewAddOnOptionPopUp(),
              insideButtonList: [
                CustomDialogInsideCancelButton(callBack: () {
                  _disposeFormElements();
                  Navigator.pop(context);
                }),
                CustomDialogInsideButton(
                  buttonName:
                      AppLocalizationHelper.of(context).translate('Confirm'),
                  buttonEvent: () {
                    if (selectedPriceMethod == null) {
                      Helper().showToastError(
                        AppLocalizationHelper.of(context)
                            .translate('NoPriceSelectedInfoNote'),
                      );
                      return;
                    }
                    if (_optionNameCtrl.text.length >= 1 &&
                        _optionNameCtrl.text.length <= 35 &&
                        _optionSubtitleCtrl.text.length <= 35) {
                      var menuAddOnOpton = new MenuAddOnOption(
                        menuAddOnOptionId: o.menuAddOnOptionId,
                        image: imageNewAddOnOption,
                        imageUrl: (imageNewAddOnOption == null)
                            ? o.imageUrl
                            : null, // use previous image if image not updated
                        isActive: o.isActive,
                        optionName: _optionNameCtrl.text,
                        optionSubtitle: _optionSubtitleCtrl.text,
                        extraCostOptionViewModel: ExtraCostOptionViewModel(
                            extraCostType: selectedPriceMethod.index,
                            fixedAmount: selectedPriceMethod ==
                                    AddonOptionPriceMethodType.FixedAmount
                                ? double.parse(priceTextCtrl.text)
                                : 0,
                            percent: selectedPriceMethod ==
                                    AddonOptionPriceMethodType.Percentage
                                ? double.parse(priceTextCtrl.text)
                                : 0),
                      );
                      setState(() {
                        newAddonOptions[newAddonOptions.indexOf(o)] =
                            menuAddOnOpton;
                      });

                      _disposeFormElements();

                      Navigator.pop(context);
                    } else {
                      var helper = Helper();
                      helper.showToastError(
                          '${AppLocalizationHelper.of(context).translate('MaximumInputExcessedAlert')}');
                    }
                  },
                ),
              ],
            ));
  }

  Widget _selectedOptions(List<Widget> elements) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: borderColor,
            width: ScreenUtil().setSp(4),
          )),
      constraints: BoxConstraints(
          minHeight: newAddonOptions == null || newAddonOptions.length == 0
              ? 0
              : SizeHelper.isMobilePortrait
                  ? SizeHelper.heightMultiplier * 30
                  : SizeHelper.heightMultiplier * 30),
      // maxHeight: ScreenUtil().setHeight(SizeHelper.isMobilePortrait
      //     ? SizeHelper.heightMultiplier * 200
      //     : 400)),
      height: (newAddonOptions?.length ?? 0) *
          (SizeHelper.isMobilePortrait
              ? SizeHelper.heightMultiplier * 14
              : SizeHelper.heightMultiplier * 15),
      // height: ScreenUtil()
      //     .setSp((newAddonOptions?.length ?? 0) * ScreenUtil().setHeight(500)),
      child: ReorderableListView(
        scrollController: _optionItemCtrl,
        children: elements,
        onReorder: (oldIndex, newIndex) {
          print('oldIndex: $oldIndex , newIndex: $newIndex');
          setState(() {
            if (newIndex == newAddonOptions.length) {
              newIndex = newAddonOptions.length - 1;
            }
            var item = newAddonOptions.removeAt(oldIndex);
            newAddonOptions.insert(newIndex, item);
          });
        },
      ),
    );
  }

  Widget _generateSingleOption(MenuAddOnOption o) {
    return Container(
      // padding: EdgeInsets.fromLTRB(
      //     ScreenUtil().setSp(SizeHelper.isMobilePortrait
      //         ? 0 * SizeHelper.textMultiplier
      //         : SizeHelper.isPortrait
      //             ? 10 * SizeHelper.textMultiplier
      //             : 10 * SizeHelper.textMultiplier),
      //     0,
      //     0,
      //     0),
      height: ScreenHelper.isLargeScreen(context)
          ? (o.optionSubtitle != null && o.optionSubtitle.length > 0)
              ? 15 * SizeHelper.widthMultiplier
              : 13 * SizeHelper.widthMultiplier
          : !(o.optionSubtitle != null && o.optionSubtitle.length > 0)
              ? 60
              : SizeHelper.isMobilePortrait
                  ? 12 * SizeHelper.heightMultiplier
                  : SizeHelper.isPortrait
                      ? 20 * SizeHelper.widthMultiplier
                      : 20 * SizeHelper.widthMultiplier,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ScreenUtil().setSp(11)),
          border: Border.all(
            color: Colors.grey,
            width: ScreenUtil().setSp(1),
          )),
      key: ValueKey(o.menuAddOnOptionId),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 7,
                // height: ScreenUtil().setSp(SizeHelper.isMobilePortrait
                //     ? !(o.optionSubtitle != null && o.optionSubtitle.length > 0)
                //         ? 15 * SizeHelper.heightMultiplier
                //         : 30 * SizeHelper.heightMultiplier
                //     : SizeHelper.isPortrait
                //         ? 5 * SizeHelper.widthMultiplier
                //         : (o.optionSubtitle != null &&
                //                 o.optionSubtitle.length > 0)
                //             ? 10 * SizeHelper.widthMultiplier
                //             : 8 * SizeHelper.widthMultiplier),
                // width: ScreenUtil().setSp(SizeHelper.isMobilePortrait
                //     ? 180 * SizeHelper.widthMultiplier
                //     : SizeHelper.isPortrait
                //         ? 55 * SizeHelper.heightMultiplier
                //         : 55 * SizeHelper.heightMultiplier),
                // height: ScreenUtil().setSp(SizeHelper.isMobilePortrait
                //     ? 10 * SizeHelper.heightMultiplier
                //     : SizeHelper.isPortrait
                //         ? 5 * SizeHelper.widthMultiplier
                //         : (o.optionSubtitle != null &&
                //                 o.optionSubtitle.length > 0)
                //             ? 10 * SizeHelper.widthMultiplier
                //             : 8 * SizeHelper.widthMultiplier),
                // width: ScreenUtil().setSp(SizeHelper.isMobilePortrait
                //     ? 50 * SizeHelper.widthMultiplier
                //     : SizeHelper.isPortrait
                //         ? 5 * SizeHelper.heightMultiplier
                //         : (o.optionSubtitle != null &&
                //                 o.optionSubtitle.length > 0)
                //             ? 10 * SizeHelper.widthMultiplier
                //             : 8 * SizeHelper.widthMultiplier),
                child: Row(
                  children: [
                    Switch(
                        value: o.isActive,
                        onChanged: (v) {
                          setState(() {
                            o.isActive = v;
                          });
                        }),
                    WEmptyView(ScreenHelper.isLandScape(context)
                        ? 5 * SizeHelper.heightMultiplier
                        : 2.5 * SizeHelper.heightMultiplier),
                    Container(
                      constraints: BoxConstraints(
                          maxWidth:
                              ScreenUtil().setWidth(SizeHelper.isMobilePortrait
                                  ? 80 * SizeHelper.widthMultiplier
                                  : SizeHelper.isPortrait
                                      ? 10 * SizeHelper.widthMultiplier
                                      : 20 * SizeHelper.widthMultiplier)),
                      // decoration: BoxDecoration(
                      //   borderRadius:
                      //       BorderRadius.circular(ScreenUtil().setSp(0)),
                      //   border: Border.all(
                      //     color: Colors.blue,
                      //     width: ScreenUtil().setSp(1),
                      //   ),
                      // ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            o.optionName +
                                ": " +
                                ((o.extraCostOptionViewModel.extraCostType ==
                                        AddonOptionPriceMethodType
                                            .FixedAmount.index)
                                    ? ("\$" +
                                        o.extraCostOptionViewModel.fixedAmount
                                            .toString())
                                    : (o.extraCostOptionViewModel
                                                .extraCostType ==
                                            AddonOptionPriceMethodType
                                                .Percentage.index)
                                        ? (o.extraCostOptionViewModel.percent
                                                .toString() +
                                            "%")
                                        : "Free"),
                            style: GoogleFonts.lato(
                                fontSize: ScreenHelper.isLandScape(context)
                                    ? SizeHelper.textMultiplier * 1.5
                                    : SizeHelper.textMultiplier * 2),
                          ),
                          if (o.optionSubtitle != null &&
                              o.optionSubtitle.length > 0)
                            Text(
                              '${o.optionSubtitle}',
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
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(ScreenUtil().setSp(20)),
                      child: o.imageUrl?.isNotEmpty ?? false
                          ? Container(
                              constraints: BoxConstraints(
                                maxHeight: ScreenUtil().setHeight(100),
                                maxWidth: ScreenUtil().setWidth(100),
                              ),
                              child: SquareFadeInImage(o.imageUrl))
                          : o.image != null
                              ? Image.memory(
                                  StringHelper.convertStringToByteArray(
                                      o.image),
                                  width: ScreenUtil().setSp(
                                      ScreenHelper.isLargeScreen(context)
                                          ? 100
                                          : 60),
                                  height: ScreenUtil().setSp(
                                      ScreenHelper.isLargeScreen(context)
                                          ? 100
                                          : 60),
                                  fit: BoxFit.cover,
                                )
                              : Container(),
                    ),
                  ],
                ),
              ),
            //  if (isMenuLocked == false)
                Expanded(
                  flex: 4,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ButtonTheme(
                        padding: EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 2.0),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        minWidth:
                            ScreenUtil().setWidth(20), //wraps child's width
                        height:
                            ScreenUtil().setHeight(70), //wraps child's height
                        child: FlatButton(
                          onPressed: () {},
                          child: Icon(
                            Icons.open_with,
                            color: Colors.black,
                            size: ScreenUtil().setSp((ScreenHelper.isLandScape(
                                    context))
                                ? SizeHelper.imageSizeMultiplier * 4
                                : ScreenHelper.getResponsiveTextBodyFontSize(
                                    context)),
                          ),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ), //your original bu
                      ),
                      ButtonTheme(
                        padding: EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 8.0),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        minWidth:
                            ScreenUtil().setWidth(20), //wraps child's width
                        height:
                            ScreenUtil().setWidth(70), //wraps child's height
                        child: FlatButton(
                          onPressed: () {
                            _editOptionPopup(o);
                          },
                          child: Icon(
                            Icons.edit,
                            color: Colors.black,
                            size: ScreenUtil().setSp((ScreenHelper.isLandScape(
                                    context))
                                ? SizeHelper.imageSizeMultiplier * 4
                                : ScreenHelper.getResponsiveTextBodyFontSize(
                                    context)),
                          ),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ), //your original bu
                      ),
                      ButtonTheme(
                        padding: EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 8.0),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        minWidth:
                            ScreenUtil().setWidth(20), //wraps child's width
                        height:
                            ScreenUtil().setWidth(70), //wraps child's height
                        child: FlatButton(
                          onPressed: () {
                            _showDeleteAddOnOptionDialog(o);
                          },
                          child: Icon(
                            Icons.close_rounded,
                            color: Colors.red,
                            size: ScreenUtil().setSp((ScreenHelper.isLandScape(
                                    context))
                                ? SizeHelper.imageSizeMultiplier * 4
                                : ScreenHelper.getResponsiveTextBodyFontSize(
                                    context)),
                          ),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ), //your original bu
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  _getNewAddOnOptionPopUp() {
    return StatefulBuilder(builder: (ctx, setPopupState) {
      return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          margin: EdgeInsets.all(ScreenUtil().setSp(20)),
          child: Column(
            children: [
              TextFieldRow(
                isReadOnly: false,
                textController: _optionNameCtrl,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(
                      RegExp(spceialCharactersAllowWhiteSpace)),
                ],
                textGlobalKey: 'Option Name',
                context: context,
                isMandate: true,
                hintText: AppLocalizationHelper.of(context)
                    .translate('AddOnOptionName'),
                icon: ConstrainedBox(
                  constraints:
                      BoxConstraints(maxWidth: ScreenUtil().setHeight(300)),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: ScreenUtil().setWidth(10)),
                      child: Text(
                        AppLocalizationHelper.of(context)
                            .translate('AddOnOptionName'),
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                textValidator: _formValidateService.validateMenuItemName,
                onChanged: (value) {},
              ).textFieldRow(),
              VEmptyView(40),
              TextFieldRow(
                isReadOnly: false,
                textController: _optionSubtitleCtrl,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(
                      RegExp(spceialCharactersAllowWhiteSpace)),
                ],
                textGlobalKey: 'Option Subtitle',
                context: context,
                isMandate: false,
                hintText: AppLocalizationHelper.of(context)
                    .translate('AddOnOptionSubtitle'),
                icon: ConstrainedBox(
                  constraints:
                      BoxConstraints(maxWidth: ScreenUtil().setHeight(300)),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: ScreenUtil().setWidth(10)),
                      child: Text(
                        AppLocalizationHelper.of(context)
                            .translate('AddOnOptionSubtitle'),
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                textValidator: _formValidateService.validateMenuItemSubtitle,
                onChanged: (value) {},
              ).textFieldRow(),
              VEmptyView(40),
              // PicSelection(
              //   (v) {
              //     setState(() {
              //       imageNewAddOnOption = v;
              //     });
              //   },
              //   componentHeight: ScreenUtil().setHeight(600),
              //   isComponentBorder: false,
              //   picFlex: 2,
              //   isChildCirclePic: false,
              //   childHeight: ScreenUtil().setHeight(SizeHelper.isMobilePortrait
              //       ? 60 * SizeHelper.heightMultiplier
              //       : SizeHelper.isPortrait
              //           ? 50 * SizeHelper.widthMultiplier
              //           : 90 * SizeHelper.widthMultiplier),
              //   childWidth: ScreenUtil().setWidth(SizeHelper.isMobilePortrait
              //       ? 80 * SizeHelper.heightMultiplier
              //       : SizeHelper.isPortrait
              //           ? 50 * SizeHelper.widthMultiplier
              //           : 15 * SizeHelper.widthMultiplier),
              //   child: (imageUrl != null && imageNewAddOnOption == null)
              //       // load previous image from image url
              //       ? Container(
              //           constraints: BoxConstraints(
              //             maxHeight: ScreenUtil().setHeight(100),
              //             maxWidth: ScreenUtil().setWidth(100),
              //           ),
              //           child: SquareFadeInImage(imageUrl))
              //       : (imageNewAddOnOption != null)
              //           // load local changed image
              //           ? Container(
              //               constraints: BoxConstraints(
              //                 maxHeight: ScreenUtil().setHeight(100),
              //                 maxWidth: ScreenUtil().setWidth(100),
              //               ),
              //               child: Image.memory(
              //                   Base64Decoder().convert(imageNewAddOnOption)))
              //           :
              //           //show no image popup
              //           Column(
              //               mainAxisAlignment: MainAxisAlignment.center,
              //               crossAxisAlignment: CrossAxisAlignment.center,
              //               children: [
              //                 Text(
              //                   'Upload',
              //                   style: GoogleFonts.lato(
              //                       color: Colors.black,
              //                       fontSize: ScreenUtil().setSp(ScreenHelper
              //                           .getResponsiveTextBodyFontSize(
              //                               context))),
              //                 ),
              //                 Text(
              //                   'Image',
              //                   style: GoogleFonts.lato(
              //                       color: Colors.black,
              //                       fontSize: ScreenUtil().setSp(ScreenHelper
              //                           .getResponsiveTextBodyFontSize(
              //                               context))),
              //                 ),
              //               ],
              //             ),
              // ),
              // VEmptyView(40),
              TextField(
                onTap: () async {
                  selectedMethod = await showDialog(
                    context: context,
                    builder: (ctx) {
                      return MultiSelectDialog(
                        items: [
                          MultiSelectDialogItem(
                              AddonOptionPriceMethodType.Free,
                              Text(
                                AppLocalizationHelper.of(context)
                                    .translate('FreePrice'),
                                style: GoogleFonts.lato(),
                              )),
                          MultiSelectDialogItem(
                              AddonOptionPriceMethodType.FixedAmount,
                              Text(
                                AppLocalizationHelper.of(context)
                                    .translate('FixedAmount'),
                                style: GoogleFonts.lato(),
                              )),
                          MultiSelectDialogItem(
                              AddonOptionPriceMethodType.Percentage,
                              Text(
                                AppLocalizationHelper.of(context)
                                    .translate('PercentagePrice'),
                                style: GoogleFonts.lato(),
                              )),
                        ],
                        allowMultiSelect: false,
                      );
                    },
                  );

                  print(selectedMethod);

                  setPopupState(() {
                    selectedPriceMethod = selectedMethod.first;
                    priceTextCtrl.text = "";
                  });
                },
                readOnly: true,
                decoration: CustomTextBox(
                        context: context,
                        hint: selectedPriceMethod ==
                                AddonOptionPriceMethodType.Free
                            ? AppLocalizationHelper.of(context)
                                .translate('FreePrice')
                            : selectedPriceMethod ==
                                    AddonOptionPriceMethodType.FixedAmount
                                ? AppLocalizationHelper.of(context)
                                    .translate('FixedAmount')
                                : selectedPriceMethod ==
                                        AddonOptionPriceMethodType.Percentage
                                    ? AppLocalizationHelper.of(context)
                                        .translate('PercentagePrice')
                                    : AppLocalizationHelper.of(context)
                                        .translate('NoPriceSelectedInfoNote'),
                        mandate: true,
                        suffixIcon: Padding(
                            padding:
                                const EdgeInsetsDirectional.only(end: 12.0),
                            child: Icon(FontAwesomeIcons.angleDown)))
                    .getTextboxDecoration(),
              ),
              // VEmptyView(40),
              selectedPriceMethod == AddonOptionPriceMethodType.FixedAmount
                  ? Container(
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: priceTextCtrl,
                              inputFormatters: [
                                DecimalTextInputFormatter(decimalRange: 2)
                              ],
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              decoration: CustomTextBox(
                                      context: context, hint: "", mandate: true)
                                  .getTextboxDecoration(),
                            ),
                          ),
                          WEmptyView(20),
                          Text(
                            "\$",
                            style: GoogleFonts.lato(),
                          )
                        ],
                      ),
                    )
                  : selectedPriceMethod == AddonOptionPriceMethodType.Percentage
                      ? Container(
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: priceTextCtrl,
                                  keyboardType: TextInputType.numberWithOptions(
                                      decimal: true),
                                  decoration: CustomTextBox(
                                          context: context,
                                          hint: "",
                                          mandate: true)
                                      .getTextboxDecoration(),
                                ),
                              ),
                              WEmptyView(20),
                              Text("%", style: GoogleFonts.lato()),
                            ],
                          ),
                        )
                      : selectedPriceMethod == AddonOptionPriceMethodType.Free
                          ? Container()
                          : Container()
            ],
          ),
        ),
      );
    });
  }

  _showDeleteAddOnOptionDialog(MenuAddOnOption o) {
    return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              AppLocalizationHelper.of(context).translate('ConfirmDelete'),
              style: GoogleFonts.lato(),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                      '${AppLocalizationHelper.of(context).translate('PleaseConfirmToDelete')} ',
                      style: GoogleFonts.lato()),
                  Text(
                      '${AppLocalizationHelper.of(context).translate('AddOnOption')}: ${o.optionName}',
                      style: GoogleFonts.lato()),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                    AppLocalizationHelper.of(context).translate('Cancel'),
                    style: GoogleFonts.lato()),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text(
                  AppLocalizationHelper.of(context).translate('Delete'),
                  style: GoogleFonts.lato(),
                ),
                onPressed: () {
                  setState(() {
                    newAddonOptions.remove(o);
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  _showDeleteAddOnDialog() {
    return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              AppLocalizationHelper.of(context).translate('ConfirmDelete'),
              style: GoogleFonts.lato(),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                    '${AppLocalizationHelper.of(context).translate('PleaseConfirmToDelete')} ',
                    style: GoogleFonts.lato(),
                  ),
                  Text(
                      '${AppLocalizationHelper.of(context).translate('CurrentAddOnOption')}',
                      style: GoogleFonts.lato()), // TODO pass the name here
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                    AppLocalizationHelper.of(context).translate('Cancel'),
                    style: GoogleFonts.lato()),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text(
                  AppLocalizationHelper.of(context).translate('Delete'),
                  style: GoogleFonts.lato(
                      textStyle: TextStyle(
                          fontSize: ScreenUtil().setSp(
                              ScreenHelper.getResponsiveTextBodyFontSize(
                                  context)))),
                ),
                onPressed: () async {
                  setState(() {
                    _isInAsyncCall = true;
                  });
                  var res = await Helper().deleteData(
                      "api/menu/addons/${_menuAddOn.menuAddOnId}",
                      context: context,
                      hasAuth: true);
                  var storeId =
                      Provider.of<CurrentMenuProvider>(context, listen: false)
                          .getStoreMenu
                          .storeId;
                  if (res.isSuccess) {
                    await Provider.of<CurrentMenuProvider>(context,
                            listen: false)
                        .getMenuFromAPI(context, storeId);
                    setState(() {
                      _isInAsyncCall = false;
                    });
                    Navigator.pop(context);
                  }
                  setState(() {
                    _isInAsyncCall = false;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  _submitForm() async {
    setState(() {
      _inAsyncCall = true;
    });
    if (_editAddonKey.currentState.validate() && newAddonOptions.length >= 1) {
      _editAddonKey.currentState.save();

      if (_addOnNameCtrl.text.length >= 1 &&
          _addOnNameCtrl.text.length <= 35 &&
          _addOnSubNameCtrl.text.length <= 35) {
        var storeMenuId =
            Provider.of<CurrentMenuProvider>(context, listen: false)
                .getStoreMenu
                .storeMenuId;
        var storeId = Provider.of<CurrentMenuProvider>(context, listen: false)
            .getStoreMenu
            .storeId;
        // dismiss keyboard during async call
        FocusScope.of(context).requestFocus(new FocusNode());

        Map<String, dynamic> data = {
          "menuAddOnName": _addOnNameCtrl.text,
          "subtitle": _addOnSubNameCtrl.text,
          "note": _addOnNameDescrCtrl.text,
          "isMulti": _isOptionMulti,
          "storeMenuId": storeMenuId,
          "addOnOptions": newAddonOptions
              .map((e) => MenuAddOnOption(
                      extraCostOptionViewModel: e.extraCostOptionViewModel,
                      image: e.image,
                      imageUrl: e.imageUrl,
                      isActive: e.isActive,
                      optionName: e.optionName,
                      optionSubtitle: e.optionSubtitle)
                  .toJson())
              .toList()
        };
        setState(() {
          _isInAsyncCall = true;
        });
        var res = await Helper().putData(
            "api/menu/addons/${_menuAddOn.menuAddOnId}", data,
            context: context, hasAuth: true);

        if (res.isSuccess) {
          await Provider.of<CurrentMenuProvider>(context, listen: false)
              .getMenuFromAPI(context, storeId);
          setState(() {
            _isInAsyncCall = false;
          });
          Navigator.pop(context);
        } else {
          // Helper().showToastError(res.data.toString());
        }
      } else {
        FocusScope.of(context).requestFocus(new FocusNode());
        Helper().showToastError(
            '${AppLocalizationHelper.of(context).translate('MaximumInputExcessedAlert')}');
      }
      // start the modal progress HUD
    } else {
      setState(() {
        _isInAsyncCall = false;
      });
      Helper().showToastError(
          "${AppLocalizationHelper.of(context).translate('NoOptionSelectedAlert')}");
    }
    setState(() {
      _inAsyncCall = false;
    });

    // // start the modal progress HUD
    // setState(() {
    //   _isInAsyncCall = true;
    // });

    // Map<String, dynamic> data = {
    //   "menuItemName": _itemNameCtrl.text,
    //   "price": _itemPriceCtrl.text,
    //   "menuAddOnIds": addOnsList,
    //   "isSoldOut": _isSoldOut,
    //   "description": _itemDescrCtrl.text,
    //   "image": image64
    // };

    // await Provider.of<CurrentMenuProvider>(context, listen: false)
    //     .addNewItem(context, data)
    //     .then((value) {
    //   if (value) {
    //     Navigator.pop(context);
    //   } else {
    //     print('add new item failed');
    //   }
    //   setState(() {
    //     _isInAsyncCall = false;
    //   });
    // });

    // setState(() {
    //   _isInAsyncCall = false;
    // });
  }

  _disposeFormElements() {
    // TODO dispose in a better way?
    _optionNameCtrl.clear();
    _optionSubtitleCtrl.clear();
    priceTextCtrl.clear();
    selectedPriceMethod = null;
    imageUrl = null;
    imageNewAddOnOption = null;
    selectedPriceMethod = null;
  }
}

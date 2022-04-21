import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vplus_merchant_app/helpers/apiHelper.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/helpers/screenHelper.dart';
import 'package:vplus_merchant_app/helpers/sizeHelper.dart';
import 'package:vplus_merchant_app/helpers/stringHelper.dart';
import 'package:vplus_merchant_app/models/extraCost.dart';
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
import 'package:provider/provider.dart';

class NewAddon extends StatefulWidget {
  @override
  _NewAddonState createState() => _NewAddonState();
}

class _NewAddonState extends State<NewAddon> {
  bool _isInAsyncCall = false;
  bool _isOptionMulti = false;

  final GlobalKey<FormState> _createAddonKey = GlobalKey<FormState>();

  TextEditingController _addOnNameCtrl = new TextEditingController();
  TextEditingController _addOnSubNameCtrl = new TextEditingController();
  TextEditingController _addOnNameDescrCtrl = new TextEditingController();
  List<MenuAddOnOption> newAddonOptions;

  final _optionNameCtrl = TextEditingController();
  final _optionSubCtrl = TextEditingController();
  var imageNewAddOnOption = '';
  AddonOptionPriceMethodType selectedPriceMethod;
  TextEditingController priceTextCtrl = TextEditingController();
  ScrollController _optionItemCtrl = new ScrollController();

  FormValidateService _formValidateService;

  @override
  void initState() {
    newAddonOptions = new List<MenuAddOnOption>();
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
        appBar: CustomAppBar.getAppBar(
          AppLocalizationHelper.of(context).translate('NewAddOn'),
          false,
          context: context,
          showLogo: false,
        ),
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          child: Container(
            child: ModalProgressHUD(
              // height: ScreenUtil().setHeight(2400),
              child: buildNewMenuAddonForm(context),
              inAsyncCall: _isInAsyncCall,
              opacity: 0.5,
              progressIndicator: CircularProgressIndicator(),
            ),
          ),

          // demo of some additional parameters
        ),
      ),
    );
  }

  Widget buildNewMenuAddonForm(BuildContext context) {
    return Form(
      key: _createAddonKey,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: ScreenUtil().setHeight(60),
          horizontal: ScreenUtil().setWidth(90),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            VEmptyView(40),
            TextFieldRow(
              isReadOnly: false,
              textController: _addOnNameCtrl,
              inputFormatters: [
                FilteringTextInputFormatter.deny(
                    RegExp(spceialCharactersAllowWhiteSpace)),
              ],
              textGlobalKey: 'Add-On Name',
              context: context,
              isMandate: true,
              hintText:
                  AppLocalizationHelper.of(context).translate('AddOnName'),
              icon: ConstrainedBox(
                constraints: BoxConstraints(
                    maxWidth: ScreenUtil().setHeight(
                        ScreenHelper.isLandScape(context) ? 330 : 220)),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: ScreenUtil().setWidth(10)),
                      child: Text(
                        AppLocalizationHelper.of(context).translate('Name'),
                        style: GoogleFonts.lato(
                            color: Colors.black, fontWeight: FontWeight.bold),
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
                  constraints: BoxConstraints(
                      maxWidth: ScreenUtil().setHeight(
                          ScreenHelper.isLandScape(context) ? 330 : 220)),
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: ScreenUtil().setWidth(10)),
                        child: Text(
                          AppLocalizationHelper.of(context)
                              .translate('Subtitle'),
                          style: GoogleFonts.lato(
                              color: Colors.black, fontWeight: FontWeight.bold),
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
              isReadOnly: false,
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
                  constraints: BoxConstraints(
                      maxWidth: ScreenUtil().setHeight(
                          ScreenHelper.isLandScape(context) ? 330 : 220)),
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
                            // fontSize: ScreenUtil().setSp(25)
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  )),
              textValidator: _formValidateService.validateMenuItemDescription,
              onChanged: (value) {},
            ).textFieldRow(),
            VEmptyView(40),
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
                              style: GoogleFonts.lato(),
                            ),
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
                            style: GoogleFonts.lato(),
                          ),
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
                  VEmptyView(20),
                  _addOnOptionsList()
                ],
              ),
            ),
            VEmptyView(20),
            Container(
              width: double.infinity,
              height: ScreenUtil().setHeight(100),
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
                      AppLocalizationHelper.of(context).translate('Save'),
                      style: GoogleFonts.lato(
                        fontWeight: FontWeight.bold,
                        fontSize: SizeHelper.textMultiplier *
                            (ScreenHelper.isLandScape(context) ? 2 : 2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addOnOptionsList() {
    return Container(
      // decoration: BoxDecoration(
      //     borderRadius: BorderRadius.circular(10.0),
      //     border: Border.all(
      //       color: borderColor,
      //       width: ScreenUtil().setSp(4),
      //     )),
      // constraints: BoxConstraints(
      //     maxHeight: ScreenUtil().setSp((newAddonOptions?.length ?? 0) *
      //         ScreenUtil()
      //             .setHeight(ScreenHelper.isLargeScreen(context) ? 250 : 300))),
      child: Column(
        children: [
          _selectedOptions(),
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
                  Navigator.pop(context);
                }),
                CustomDialogInsideButton(
                  buttonName:
                      AppLocalizationHelper.of(context).translate('Confirm'),
                  buttonEvent: () {
                    if (_optionNameCtrl.text.length >= 1 &&
                        _optionNameCtrl.text.length <= 35 &&
                        _optionSubCtrl.text.length <= 35) {
                      var menuAddOnOpton = new MenuAddOnOption(
                        image: imageNewAddOnOption,
                        isActive: true,
                        optionName: _optionNameCtrl.text,
                        optionSubtitle: _optionSubCtrl.text,
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

                      selectedPriceMethod = null;
                      _optionNameCtrl.clear();
                      _optionSubCtrl.clear();
                      Navigator.pop(context);
                    } else {
                      Helper().showToastError(
                          '${AppLocalizationHelper.of(context).translate('MaximumInputExcessedAlert')}');
                    }
                  },
                ),
              ],
            ));
  }

  _editOptionPopup(MenuAddOnOption o) {
    // get data
    imageNewAddOnOption = o.image;
    _optionNameCtrl.text = o.optionName;
    if (o.optionSubtitle != null && o.optionSubtitle.length > 0)
      _optionSubCtrl.text = o.optionSubtitle;
    // selectedPriceMethod = o.priceMethodType;
    // priceTextCtrl.text = o.amount.toString();

    showDialog(
        context: (context),
        builder: (context) => CustomDialog(
              title:
                  "${AppLocalizationHelper.of(context).translate('EditAddonOptionTitle')}",
              child: _getNewAddOnOptionPopUp(),
              insideButtonList: [
                CustomDialogInsideCancelButton(callBack: () {
                  Navigator.pop(context);
                }),
                CustomDialogInsideButton(
                  buttonName:
                      "${AppLocalizationHelper.of(context).translate('Confirm')}",
                  buttonEvent: () {
                    if (selectedPriceMethod == null) {
                      Helper().showToastError(
                          "${AppLocalizationHelper.of(context).translate('NoPriceMethodSelectedAlert')}");
                    }
                    if (_optionNameCtrl.text.length <= 35 &&
                        _optionNameCtrl.text.length >= 0 &&
                        _optionSubCtrl.text.length <= 35) {
                      var menuAddOnOpton = new MenuAddOnOption(
                        menuAddOnOptionId: o.menuAddOnOptionId,
                        image: imageNewAddOnOption,
                        isActive: o.isActive,
                        optionName: _optionNameCtrl.text,
                        optionSubtitle: _optionSubCtrl.text,
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

                      // TODO dispose in a better way?
                      _optionNameCtrl.clear();
                      _optionSubCtrl.clear();
                      priceTextCtrl.clear();
                      selectedPriceMethod = null;

                      Navigator.pop(context);
                    } else {
                      Helper().showToastError(
                          '${AppLocalizationHelper.of(context).translate('MaximumInputExcessedAlert')}');
                    }
                  },
                ),
              ],
            ));
  }

  Widget _selectedOptions() {
    return Container(
      constraints: BoxConstraints(
          minHeight: (newAddonOptions?.length ?? 0) *
              (SizeHelper.isMobilePortrait
                  ? SizeHelper.heightMultiplier * 5 * newAddonOptions?.length
                  : SizeHelper.heightMultiplier *
                      10 *
                      newAddonOptions?.length)),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: borderColor,
            width: ScreenUtil().setSp(0),
          )),
      height: (newAddonOptions?.length ?? 0) *
          (SizeHelper.isMobilePortrait
              ? SizeHelper.heightMultiplier * 11
              : SizeHelper.heightMultiplier * 10),
      child: ReorderableListView(
        scrollController: _optionItemCtrl,
        children: newAddonOptions.map((o) => _generateSingleOption(o)).toList(),
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
      //         ? 7 * SizeHelper.textMultiplier
      //         : SizeHelper.isPortrait
      //             ? 10 * SizeHelper.textMultiplier
      //             : 10 * SizeHelper.textMultiplier),
      //     0,
      //     0,
      //     0),
      height: ScreenHelper.isLargeScreen(context)
          ? (o.optionSubtitle != null && o.optionSubtitle.length > 0)
              ? SizeHelper.textMultiplier * 10
              : SizeHelper.textMultiplier * 10
          : !(o.optionSubtitle != null && o.optionSubtitle.length > 0)
              ? 20
              : SizeHelper.isMobilePortrait
                  ? 11 * SizeHelper.heightMultiplier
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
      key: ValueKey(o.hashCode),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                height: SizeHelper.isMobilePortrait
                    ? 10 * SizeHelper.heightMultiplier
                    : SizeHelper.isPortrait
                        ? 5 * SizeHelper.widthMultiplier
                        : 5 * SizeHelper.widthMultiplier,
                width: SizeHelper.isMobilePortrait
                    ? 15 * SizeHelper.widthMultiplier
                    : SizeHelper.isPortrait
                        ? 5 * SizeHelper.heightMultiplier
                        : 5 * SizeHelper.heightMultiplier,
                child: Switch(
                    value: o.isActive,
                    onChanged: (v) {
                      setState(() {
                        o.isActive = v;
                      });
                    }),
              ),
              Container(
                height: SizeHelper.isMobilePortrait
                    ? !(o.optionSubtitle != null && o.optionSubtitle.length > 0)
                        ? 15 * SizeHelper.heightMultiplier
                        : 10 * SizeHelper.heightMultiplier
                    : SizeHelper.isPortrait
                        ? 5 * SizeHelper.widthMultiplier
                        : (o.optionSubtitle != null &&
                                o.optionSubtitle.length > 0)
                            ? 10 * SizeHelper.widthMultiplier
                            : 8 * SizeHelper.widthMultiplier,
                width: SizeHelper.isMobilePortrait
                    ? 45 * SizeHelper.widthMultiplier
                    : SizeHelper.isPortrait
                        ? 55 * SizeHelper.heightMultiplier
                        : 55 * SizeHelper.heightMultiplier,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      constraints: BoxConstraints(
                          maxWidth: SizeHelper.isMobilePortrait
                              ? 30 * SizeHelper.widthMultiplier
                              : SizeHelper.isPortrait
                                  ? 10 * SizeHelper.widthMultiplier
                                  : 10 * SizeHelper.widthMultiplier),
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
                                        : "${AppLocalizationHelper.of(context).translate('FreePrice')}"),
                            style: TextStyle(
                              fontSize: ScreenHelper.isLandScape(context)
                                  ? SizeHelper.textMultiplier * 1.5
                                  : SizeHelper.textMultiplier * 1.5,
                            ),
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
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(ScreenUtil().setSp(20)),
                      child: o.image.isEmpty
                          ? Container()
                          : Image.memory(
                              StringHelper.convertStringToByteArray(o.image),
                              width: ScreenUtil().setSp(70),
                              height: ScreenUtil().setSp(70),
                              fit: BoxFit.cover,
                            ),
                    ),
                    Row(
                      children: [
                        ButtonTheme(
                          padding: EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 2.0),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          minWidth:
                              ScreenUtil().setWidth(10), //wraps child's width
                          height:
                              ScreenUtil().setHeight(70), //wraps child's height
                          child: FlatButton(
                            onPressed: () {},
                            child: Icon(
                              Icons.open_with,
                              color: Colors.black,
                              size: 20,
                            ),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ), //your original bu
                        ),
                        ButtonTheme(
                          padding: EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 8.0),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
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
                              size: 20,
                            ),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ), //your original bu
                        ),
                        ButtonTheme(
                          padding: EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 8.0),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          minWidth:
                              ScreenUtil().setWidth(20), //wraps child's width
                          height:
                              ScreenUtil().setWidth(70), //wraps child's height
                          child: FlatButton(
                            onPressed: () {
                              _showDeleteDialog(o);
                            },
                            child: Icon(
                              Icons.close_rounded,
                              color: Colors.red,
                              size: 20,
                            ),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ), //your original bu
                        ),
                      ],
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
          margin: EdgeInsets.all(ScreenUtil().setSp(10)),
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
                  constraints: BoxConstraints(
                      maxWidth: ScreenUtil().setWidth(
                          ScreenHelper.isLargeScreen(context) ? 100 : 200)),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: ScreenUtil().setWidth(10)),
                      child: Text(
                        AppLocalizationHelper.of(context).translate('Name'),
                        style: TextStyle(
                            fontSize: ScreenUtil().setSp(
                                ScreenHelper.isLandScape(context)
                                    ? 1.5 * SizeHelper.textMultiplier
                                    : 4 * SizeHelper.textMultiplier),
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
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
                textController: _optionSubCtrl,
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
                  constraints: BoxConstraints(
                      maxWidth: ScreenUtil().setWidth(
                          ScreenHelper.isLargeScreen(context) ? 100 : 200)),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: ScreenUtil().setWidth(10)),
                      child: Text(
                        AppLocalizationHelper.of(context).translate('Subtitle'),
                        style: TextStyle(
                            fontSize: ScreenUtil().setSp(
                                ScreenHelper.isLandScape(context)
                                    ? 1.5 * SizeHelper.textMultiplier
                                    : 4 * SizeHelper.textMultiplier),
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                textValidator: _formValidateService.validateMenuItemName,
                onChanged: (value) {},
              ).textFieldRow(),
              // VEmptyView(40),
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
              //       ? 80 * SizeHelper.heightMultiplier
              //       : SizeHelper.isPortrait
              //           ? 60 * SizeHelper.widthMultiplier
              //           : 80 * SizeHelper.widthMultiplier),
              //   childWidth: ScreenUtil().setWidth(SizeHelper.isMobilePortrait
              //       ? 80 * SizeHelper.heightMultiplier
              //       : SizeHelper.isPortrait
              //           ? 20 * SizeHelper.widthMultiplier
              //           : 15 * SizeHelper.widthMultiplier),
              //   child: Column(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     crossAxisAlignment: CrossAxisAlignment.center,
              //     children: [
              //       Text('Upload',
              //           style: TextStyle(
              //             color: Colors.black,
              //             fontSize: ScreenUtil().setSp(
              //                 ScreenHelper.getResponsiveTextBodyFontSize(
              //                     context)),
              //           )),
              //       Text(
              //         'Image',
              //         style: TextStyle(
              //             color: Colors.black,
              //             fontSize: ScreenUtil().setSp(
              //                 ScreenHelper.getResponsiveTextBodyFontSize(
              //                     context))),
              //       ),
              //     ],
              //   ),
              // ),
              VEmptyView(40),
              TextField(
                onTap: () async {
                  var selectedMethod = await showDialog(
                    context: context,
                    builder: (ctx) {
                      return MultiSelectDialog(
                        items: [
                          MultiSelectDialogItem(
                              AddonOptionPriceMethodType.Free,
                              Text(AppLocalizationHelper.of(context)
                                  .translate('FreePrice'))),
                          MultiSelectDialogItem(
                              AddonOptionPriceMethodType.FixedAmount,
                              Text(AppLocalizationHelper.of(context)
                                  .translate('FixedAmount'))),
                          MultiSelectDialogItem(
                              AddonOptionPriceMethodType.Percentage,
                              Text(AppLocalizationHelper.of(context)
                                  .translate('PercentagePrice'))),
                        ],
                        allowMultiSelect: false,
                      );
                    },
                  );

                  print(selectedMethod);

                  setPopupState(() {
                    selectedPriceMethod = selectedMethod?.first ?? null;
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
                                        .translate('SelectPriceMethodNote'),
                        mandate: true,
                        suffixIcon: Padding(
                            padding:
                                const EdgeInsetsDirectional.only(end: 12.0),
                            child: Icon(FontAwesomeIcons.angleDown)))
                    .getTextboxDecoration(),
              ),
              VEmptyView(40),
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
                          // WEmptyView(20),
                          Text("\$")
                        ],
                      ),
                    )
                  : selectedPriceMethod == AddonOptionPriceMethodType.Percentage
                      ? Container(
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  keyboardType: TextInputType.numberWithOptions(
                                      decimal: true),
                                  controller: priceTextCtrl,
                                  decoration: CustomTextBox(
                                          context: context,
                                          hint: "",
                                          mandate: true)
                                      .getTextboxDecoration(),
                                ),
                              ),
                              // WEmptyView(20),
                              Text("%")
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

  _showDeleteDialog(MenuAddOnOption o) {
    return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirm delete'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Please confirm to delete '),
                  Text('Add-On option: ${o.optionName}'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Delete'),
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

  _submitForm() async {
    if (_createAddonKey.currentState.validate() &&
        newAddonOptions.length >= 1) {
      //           TextEditingController _addOnNameCtrl = new TextEditingController();
      // TextEditingController _addOnSubNameCtrl = new TextEditingController();

      if (_addOnNameCtrl.text.length >= 1 &&
          _addOnNameCtrl.text.length <= 35 &&
          _addOnSubNameCtrl.text.length <= 35) {
        _createAddonKey.currentState.save();

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
                      isActive: e.isActive,
                      optionName: e.optionName,
                      optionSubtitle: e.optionSubtitle)
                  .toJson())
              .toList()
        };
        setState(() {
          _isInAsyncCall = true;
        });
        var res = await Helper().postData("api/menu/addons/$storeMenuId", data,
            context: context, hasAuth: true);

        if (res.isSuccess) {
          await Provider.of<CurrentMenuProvider>(context, listen: false)
              .getMenuFromAPI(context, storeId);

          Navigator.pop(context);
        } else {
          // Helper().showToastError(res.data.toString());
        }
        setState(() {
          _isInAsyncCall = false;
        });
      } else {
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
}

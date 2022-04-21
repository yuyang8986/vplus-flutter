import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_select/smart_select.dart';
import 'package:vplus/helper/sizeHelper.dart';
import 'package:vplus/models/menuAddOn.dart';

class AddOnPopUpListTile extends StatefulWidget {
  final MenuAddOn singleMenuAddOn;
  final Function onCallBack;

  AddOnPopUpListTile({this.singleMenuAddOn, this.onCallBack});
  @override
  _AddOnPopUpListTileState createState() => _AddOnPopUpListTileState();
}

class _AddOnPopUpListTileState extends State<AddOnPopUpListTile> {
  int _value;
  bool _isMulti;
  List<int> _values;
  List<S2Choice<int>> options;
  String menuAddOnName;
  Function _callBack;

  @override
  void initState() {
    _isMulti = widget.singleMenuAddOn.isMulti;
    menuAddOnName = widget.singleMenuAddOn.menuAddOnName;
    options = widget.singleMenuAddOn.menuAddOnOptions
        .map((e) =>
            S2Choice<int>(value: e.menuAddOnOptionId, title: e.optionName))
        .toList();
    _callBack = widget.onCallBack ?? (List<int> selectedOptionIds) {};
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        (_isMulti == true)
            ? SmartSelect<int>.multiple(
                title: menuAddOnName,
                placeholder: 'Select multiple',
                choiceType: S2ChoiceType.chips,
                modalType: S2ModalType.bottomSheet,
                modalConfig: S2ModalConfig(
                    headerStyle: S2ModalHeaderStyle(
                        textStyle: TextStyle(
                            fontSize: SizeHelper.isMobilePortrait
                                ? 3.5 * SizeHelper.textMultiplier
                                : 3.2 * SizeHelper.textMultiplier))),
                value: _values,
                choiceItems: options,
                onChange: (state) => setState(() {
                  _values = state.value;
                  _callBack(_values);
                }),
                choiceStyle: S2ChoiceStyle(
                    titleStyle: TextStyle(
                        fontSize: SizeHelper.isMobilePortrait
                            ? 3 * SizeHelper.textMultiplier
                            : 2.7 * SizeHelper.textMultiplier)),
                tileBuilder: (context, state) {
                  return S2Tile.fromState(state, isTwoLine: true);
                },
              )
            : SmartSelect<int>.single(
                title: menuAddOnName,
                placeholder: 'Select one',
                choiceType: S2ChoiceType.chips,
                modalType: S2ModalType.bottomSheet,
                modalConfig: S2ModalConfig(
                    headerStyle: S2ModalHeaderStyle(
                        textStyle: TextStyle(
                            fontSize: SizeHelper.isMobilePortrait
                                ? 3.5 * SizeHelper.textMultiplier
                                : 3.2 * SizeHelper.textMultiplier))),
                value: _value,
                choiceItems: options,
                onChange: (state) => setState(() {
                  _value = state.value;
                  _callBack([_value]);
                }),
                choiceStyle: S2ChoiceStyle(
                    titleStyle: GoogleFonts.lato(
                        fontSize: SizeHelper.isMobilePortrait
                            ? 3 * SizeHelper.textMultiplier
                            : 2.7 * SizeHelper.textMultiplier)),
                choiceHeaderStyle: S2ChoiceHeaderStyle(
                  textStyle: GoogleFonts.lato(
                      fontSize: SizeHelper.isMobilePortrait
                          ? 2 * SizeHelper.textMultiplier
                          : SizeHelper.textMultiplier
                      // fontSize: ScreenUtil().setSp((ScreenHelper.isLandScape(context)?MediaQuery.of(context).size.height*0.019:MediaQuery.of(context).size.height*0.02)),
                      ),
                ),
                tileBuilder: (context, state) {
                  return S2Tile.fromState(state, isTwoLine: true);
                },
              ),
        Divider(
          thickness: ScreenUtil().setSp(2),
        ),
      ],
    );
  }

  // Widget getListTileButton(IconData iconData, {Function callback}) {
  //   return ButtonTheme(
  //     padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
  //     materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  //     minWidth: ScreenUtil().setWidth(20), //wraps child's width
  //     height: ScreenUtil().setWidth(70), //wraps child's height
  //     child: FlatButton(
  //       onPressed: () {
  //         callback();
  //       },
  //       child: Icon(
  //         iconData,
  //         color: BottomBarUtils.getThemeColor(),
  //       ),
  //     ),
  //   );
  // }

}

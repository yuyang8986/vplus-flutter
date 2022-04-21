import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/helpers/screenHelper.dart';
import 'package:vplus_merchant_app/helpers/sizeHelper.dart';
import 'package:vplus_merchant_app/widgets/components.dart';
import 'package:vplus_merchant_app/widgets/dropdown_select.dart';

class BackgroundColorSelection extends StatefulWidget {
  final Function onSelectCallBack;
  String initColorHex;
  BackgroundColorSelection(this.onSelectCallBack, {this.initColorHex});
  @override
  _BackgroundColorSelectionState createState() =>
      _BackgroundColorSelectionState();
}

class _BackgroundColorSelectionState extends State<BackgroundColorSelection> {
  List<MultiSelectDialogItem> colorSelectItems =
      new List<MultiSelectDialogItem>();

  List<int> defaultColorHexList = new List<int>();
  String selectedColorHex;
  TextEditingController backgroundColorCtrl = new TextEditingController();

  @override
  void initState() {
    defaultColorHexList.add(Colors.black.value);
    defaultColorHexList.add(Colors.red.value);
    defaultColorHexList.add(Colors.grey.value);
    defaultColorHexList.add(Colors.amber.value);
    defaultColorHexList.add(Colors.blueGrey.value);
    defaultColorHexList.add(Colors.indigo.value);
    defaultColorHexList.add(Colors.green.value);
    defaultColorHexList.add(Colors.brown.value);
    defaultColorHexList.add(Colors.blue.value);
    defaultColorHexList.add(Colors.purple.value);

    defaultColorHexList.forEach((colorHex) {
      colorSelectItems.add(MultiSelectDialogItem(
          colorHex.toString(),
          CustomColorBar(
            colorHex: colorHex.toString(),
          )));
    });

    selectedColorHex = widget.initColorHex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        colorInputField(context),
      ],
    );
  }

  Widget colorInputField(BuildContext context) {
    var inkWell = InkWell(
        onTap: () async {
          final Set<dynamic> selectedColor = await showDialog(
              context: context,
              builder: (ctx) {
                return MultiSelectDialog(
                  allowMultiSelect: false,
                  items: colorSelectItems,
                );
              });

          if (selectedColor != null) {
            setState(() {
              // selectedColorHex = int.parse(selectedColor.first, radix: 16);
              selectedColorHex = selectedColor.first;
            });
          }
          widget.onSelectCallBack(selectedColorHex);
        },
        child: Container(
          padding: EdgeInsets.all(5),
          height: ScreenHelper.isLandScape(context)
              ? 5 * SizeHelper.heightMultiplier
              : 10 * SizeHelper.heightMultiplier,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            border: widget.initColorHex == null
                ? Border.all(
                    color: borderColor,
                    width: 2.0,
                  )
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 1,
                child: Container(),
              ),
              Expanded(
                  flex: ScreenHelper.isLandScape(context) ? 1 : 2,
                  child: Container(
                    height: widget.initColorHex == null
                        ? ScreenHelper.isLandScape(context)
                            ? 10 * SizeHelper.heightMultiplier
                            : 130
                        : 220,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          color: borderColor,
                          width: 2.0,
                        ),
                        color: selectedColorHex == null
                            ? null
                            : Color(int.parse(selectedColorHex))),
                    child: Center(
                      child: Container(
                        child: Text(
                          AppLocalizationHelper.of(context)
                              .translate('BackgroundLabel'),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                            textStyle: GoogleFonts.lato(
                                color: selectedColorHex == null
                                    ? Colors.grey[500]
                                    : Colors.white),
                            fontWeight: FontWeight.w700,
                            fontSize: SizeHelper.textMultiplier *
                                (ScreenHelper.isLandScape(context) ? 2 : 2),
                          ),
                        ),
                      ),
                    ),
                  )),
              Expanded(
                child: Center(
                  child: Text(
                    "*",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: ScreenUtil().setSp(40)),
                  ),
                ),
              ),
            ],
          ),
        ));
    return inkWell;
  }
}

class CustomColorBar extends StatelessWidget {
  CustomColorBar({
    @required this.colorHex,
  });

  final String colorHex;

  final int width = 400;
  final int height = 50;
  final double borderRadius = 20.0;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: ScreenUtil().setWidth(width),
        height: ScreenUtil().setHeight(height),
        child: ColoredBox(
          color: Color(
            int.parse(colorHex),
          ),
        ),
      ),
    );
  }
}

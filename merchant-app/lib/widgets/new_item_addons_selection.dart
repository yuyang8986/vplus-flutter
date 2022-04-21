import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/helpers/screenHelper.dart';
import 'package:vplus_merchant_app/helpers/sizeHelper.dart';

class AddOnsMultiSelection extends StatefulWidget {
  final List<dynamic> addOnsListWidgets;
  final Function callback;
  AddOnsMultiSelection(this.addOnsListWidgets, {this.callback});
  @override
  _AddOnsMultiSelectionState createState() => _AddOnsMultiSelectionState();
}

class _AddOnsMultiSelectionState extends State<AddOnsMultiSelection> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(30)),
            child: Text(
              AppLocalizationHelper.of(context)
                  .translate('SelectAddOnsTitleNote'),
              style: GoogleFonts.lato(
                fontSize: ScreenHelper.isLandScape(context)
                    ? SizeHelper.textMultiplier * 2.5
                    : SizeHelper.textMultiplier * 2.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Divider(
            height: 2,
            thickness: 2,
          ),
          Container(
            constraints: BoxConstraints(
                maxHeight: ScreenHelper.isLandScape(context)
                    ? widget.addOnsListWidgets.length * 50.toDouble()
                    : widget.addOnsListWidgets.length * 60.toDouble()),
            // decoration: BoxDecoration(
            //     borderRadius: BorderRadius.circular(10.0),
            //     border: Border.all(
            //       color: borderColor,
            //       width: ScreenUtil().setSp(0),
            //     )),
            child: ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              itemCount: widget.addOnsListWidgets.length,
              itemBuilder: (BuildContext _context, int i) {
                return getAddOnsListTile(widget.addOnsListWidgets[i], i);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget getAddOnsListTile(dynamic menuAddOn, int index) {
    return Column(
      children: [
        FlatButton(
          onPressed: () {
            setState(() {
              widget.callback(
                  index, !widget.addOnsListWidgets[index]['isSelected']);
            });
          },
          child: Row(
            children: [
              menuAddOn['isSelected'] == true
                  ? Icon(
                      Icons.check,
                      size: 30.0,
                      color: Color(0xff8492a6),
                    )
                  : Icon(
                      Icons.check_box_outline_blank,
                      size: 30.0,
                      color: Color(0xff8492a6),
                    ),
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20)),
                child: Text(menuAddOn['addOn'].menuAddOnName,
                    style: GoogleFonts.lato(
                        fontSize: ScreenHelper.isLandScape(context)
                            ? 2 * SizeHelper.textMultiplier
                            : 2 * SizeHelper.textMultiplier)),
              ),
            ],
          ),
        ),
        Divider(
          height: 2,
          thickness: 2,
        ),
      ],
    );
  }
}

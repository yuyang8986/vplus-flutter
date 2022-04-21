import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vplus/helper/screenHelper.dart';
import 'package:vplus/helper/sizeHelper.dart';
import 'package:vplus/providers/storeList_provider.dart';

class StoreListDropDown extends StatefulWidget {
  @override
  _StoreListDropDownState createState() => _StoreListDropDownState();
}

class _StoreListDropDownState extends State<StoreListDropDown> {
  String currentValue = "Shortest Distance";

  @override
  void instance() {
    currentValue = Provider.of<StoreListProvider>(context, listen: false)
        .getFilterString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
          maxHeight: ScreenHelper.isLandScape(context)
              ? 10
              : SizeHelper.heightMultiplier * 4),
      margin: EdgeInsets.fromLTRB(
          ScreenHelper.isLandScape(context)
              ? 10
              : SizeHelper.widthMultiplier * 2,
          ScreenHelper.isLandScape(context) ? 10 : 0,
          ScreenHelper.isLandScape(context)
              ? 10
              : SizeHelper.widthMultiplier * 2,
          ScreenHelper.isLandScape(context)
              ? 10
              : SizeHelper.heightMultiplier * 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ScreenUtil().setSp(20),
        ),
        border: Border.all(
          color: Colors.grey,
          width: ScreenUtil().setSp(2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DropdownButton<String>(
            value: currentValue,
            icon: Icon(Icons.arrow_downward,
                size: ScreenHelper.isLandScape(context)
                    ? 10
                    : SizeHelper.imageSizeMultiplier * 4),
            // iconSize: 24,
            elevation: 16,
            style: const TextStyle(color: Colors.deepPurple),
            underline: Container(
              height: 0,
              color: Colors.white,
            ),
            onChanged: (String newValue) {
              setState(() {
                currentValue = newValue;
              });
              Provider.of<StoreListProvider>(context, listen: false)
                  .setFilterString(currentValue);
            },
            items: Provider.of<StoreListProvider>(context, listen: false)
                .getSupportFilter()
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.bold,
                    fontSize: SizeHelper.isMobilePortrait
                        ? 2 * SizeHelper.textMultiplier
                        : 2 * SizeHelper.textMultiplier,
                    color: Colors.black,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

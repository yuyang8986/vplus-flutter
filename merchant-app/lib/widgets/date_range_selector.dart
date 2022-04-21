import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/generated/i18n.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vplus_merchant_app/helpers/apiHelper.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/helpers/date_time_helper.dart';
import 'package:vplus_merchant_app/helpers/screenHelper.dart';
import 'package:vplus_merchant_app/helpers/sizeHelper.dart';
import 'package:vplus_merchant_app/styles/color.dart';
import 'package:vplus_merchant_app/widgets/emptyView.dart';

class DateRangeSelector extends StatefulWidget {
  /// this widget generates a date range selector
  /// default value will be utilized in initState and reset button
  DateTime defaultStartDate;
  DateTime defaultEndDate;
  final Function onSelectCallBack;

  DateRangeSelector(this.onSelectCallBack,
      {DateTime this.defaultStartDate, DateTime this.defaultEndDate});

  @override
  State<StatefulWidget> createState() {
    return DateRangeSelectorState();
  }
}

class DateRangeSelectorState extends State<DateRangeSelector> {
  DateTime defaultStartDate;
  DateTime defaultEndDate;

  DateTime startDate;
  DateTime endDate;

  bool isStartDate;
  DateTime _selectedDate;
  bool timeBeenChanged;

  @override
  void initState() {
    isStartDate = false;
    _selectedDate = DateTime.now();
    defaultStartDate = this.widget.defaultStartDate;
    defaultEndDate = this.widget.defaultEndDate;
    if (defaultStartDate != null && defaultEndDate != null) {
      startDate = defaultStartDate;
      endDate = defaultEndDate;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: ScreenHelper.isLandScape(context)
          ? EdgeInsets.fromLTRB(0, SizeHelper.widthMultiplier * 3, 0,
              SizeHelper.widthMultiplier * 3)
          : EdgeInsets.fromLTRB(
              SizeHelper.widthMultiplier * 3,
              SizeHelper.widthMultiplier * 3,
              SizeHelper.widthMultiplier * 3,
              0),
      child: datePicker(),
    );
  }

  Widget datePicker() {
    return Container(
      padding: ScreenHelper.isLandScape(context)
          ? EdgeInsets.fromLTRB(
              0, SizeHelper.widthMultiplier, 0, SizeHelper.widthMultiplier * 5)
          : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Row(
                  children: [
                    InkWell(
                      onTap: () async {
                        await selectDate(context, true);
                      },
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.calendar_today,
                                size: ScreenHelper.isLandScape(context)
                                    ? 4 * SizeHelper.imageSizeMultiplier
                                    : 6 * SizeHelper.imageSizeMultiplier),
                            WEmptyView(ScreenHelper.isLandScape(context)
                                ? SizeHelper.heightMultiplier * 2
                                : SizeHelper.widthMultiplier * 3),
                            Container(
                                child: Center(
                                    child: Text(
                              (startDate == null)
                                  ? 'Choose A Start Date'
                                  : '${AppLocalizationHelper.of(context).translate('StartDate')} : ${DateTimeHelper.parseDateTimeToDate(startDate)}',
                              style: GoogleFonts.lato(
                                fontSize: SizeHelper.textMultiplier * 2,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ))),
                          ]),
                    ),
                  ],
                ),
              ),
              VEmptyView(ScreenHelper.isLandScape(context)
                  ? 0
                  : SizeHelper.heightMultiplier * 10),
              Container(
                child: Row(
                  children: [
                    InkWell(
                      onTap: () async {
                        await selectDate(context, false);
                      },
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(Icons.calendar_today,
                                size: ScreenHelper.isLandScape(context)
                                    ? 4 * SizeHelper.imageSizeMultiplier
                                    : 6 * SizeHelper.imageSizeMultiplier),
                            WEmptyView(ScreenHelper.isLandScape(context)
                                ? SizeHelper.heightMultiplier * 2
                                : SizeHelper.widthMultiplier * 3),
                            Container(
                                child: Center(
                                    child: Text(
                              (endDate == null)
                                  ? 'Choose An End Date'
                                  : '${AppLocalizationHelper.of(context).translate('EndDate')}: ${DateTimeHelper.parseDateTimeToDate(endDate)}',
                              style: GoogleFonts.lato(
                                fontSize: SizeHelper.textMultiplier * 2,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ))),
                          ]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          resetButton(),
        ],
      ),
    );
  }

  Widget emptyPadding() {
    /// this widget generate am empty container with
    /// resetButton for padding. Need to refactor all
    /// sizes to one style file for consistency.
    return Container(
      width: ScreenHelper.isLandScape(context)
          ? 10 * SizeHelper.heightMultiplier
          : 20 * SizeHelper.widthMultiplier,
      height: ScreenHelper.isLandScape(context)
          ? 4 * SizeHelper.heightMultiplier
          : 4 * SizeHelper.heightMultiplier,
      margin: const EdgeInsets.fromLTRB(5, 0, 0, 0),
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
    );
  }

  Widget resetButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          startDate = null;
          endDate = null;
          if (defaultStartDate != null && defaultEndDate != null) {
            startDate = defaultStartDate;
            endDate = defaultEndDate;
          }
        });
        onSelectDate();
      },
      child: Container(
        width: ScreenHelper.isLandScape(context)
            ? 10 * SizeHelper.heightMultiplier
            : 20 * SizeHelper.widthMultiplier,
        height: ScreenHelper.isLandScape(context)
            ? 4 * SizeHelper.heightMultiplier
            : 4 * SizeHelper.heightMultiplier,
        margin: const EdgeInsets.fromLTRB(5, 0, 0, 0),
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: cancelButtonColor,
        ),
        child: Text(
          "${AppLocalizationHelper.of(context).translate('Reset')}",
          // textAlign: TextAlign.center,
          style: GoogleFonts.lato(
              fontSize: ScreenHelper.isLandScape(context)
                  ? 2 * SizeHelper.textMultiplier
                  : 2 * SizeHelper.textMultiplier,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              textStyle: GoogleFonts.lato(
                decoration: null,
              )),
        ),
      ),
    );
  }

  //DateTime Picker in Android
  buildMaterialDatePicker(BuildContext context, bool isStartDate) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // TODO should be last user input
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light(),
          child: child,
        );
      },
    );
    if (picked != null)
      setState(() {
        if (isStartDate) {
          (endDate != null && picked.isAfter(endDate))
              ? Helper()
                  .showToastError("Start date should be earlier than end date")
              : startDate = picked;
        } else {
          (startDate != null && picked.isBefore(startDate))
              ? Helper().showToastError("End date should be after start date")
              : endDate = picked;
        }
        if (validateDateInput(startDate, endDate)) {
          onSelectDate();
        } else {
          Helper().showToastError("invalid date input");
        }
      });
  }

  /// This builds cupertion date picker in iOS
  buildCupertinoDatePicker(BuildContext context, bool isStartDate) async {
    await showModalBottomSheet(
        context: context,
        builder: (BuildContext builder) {
          return Container(
            // height: MediaQuery.of(context).copyWith().size.height / 3,
            color: Colors.white,
            child: Column(
              children: [
                SizedBox(
                  height: !ScreenHelper.isLandScape(context)
                      ? 35 * SizeHelper.heightMultiplier
                      : 35 * SizeHelper.widthMultiplier,
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    onDateTimeChanged: (_picked) {
                      if (_picked != null)
                        setState(() {
                          _selectedDate = _picked;
                          timeBeenChanged = true;
                        });
                    },
                    initialDateTime: DateTime.now(),
                    minimumYear: 2000,
                    maximumYear: DateTime.now().year,
                  ),
                ),
                CupertinoButton(
                  child: Text(
                    'Confirm',
                    style: GoogleFonts.lato(
                      fontSize: !ScreenHelper.isLandScape(context)
                          ? 2 * SizeHelper.textMultiplier
                          : 2 * SizeHelper.textMultiplier,
                    ),
                  ),
                  onPressed: () {
                    print('Selected Date: ${_selectedDate}');
                    setState(() {
                      if (isStartDate) {
                        (endDate != null && _selectedDate.isAfter(endDate))
                            ? Helper().showToastError(
                                "Start date should be earlier than end date")
                            : startDate = _selectedDate;
                      } else {
                        (startDate != null && _selectedDate.isBefore(startDate))
                            ? Helper().showToastError(
                                "End date should be after start date")
                            : endDate = _selectedDate;
                      }
                      if (validateDateInput(startDate, endDate)) {
                        onSelectDate();
                      } else {
                        Helper().showToastError("invalid date input");
                      }
                      Navigator.of(context).pop();
                    });
                  },
                )
              ],
            ),
          );
        });
  }

  Future<void> selectDate(BuildContext context, bool isStartDate) async {
    final ThemeData theme = Theme.of(context);
    assert(theme.platform != null);
    switch (theme.platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return await buildMaterialDatePicker(context, isStartDate);
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return await buildCupertinoDatePicker(context, isStartDate);
    }
  }

  void onSelectDate() {
    widget.onSelectCallBack(startDate, endDate);
  }

  bool validateDateInput(DateTime startDate, DateTime endDate) {
    // startDate == endDate is also valid
    if (startDate != null && endDate != null && !startDate.isAfter(endDate)) {
      return true;
    } else
      return false;
  }
}

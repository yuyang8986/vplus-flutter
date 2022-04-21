import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vplus_merchant_app/helpers/apiHelper.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/helpers/date_time_helper.dart';
import 'package:vplus_merchant_app/helpers/screenHelper.dart';
import 'package:vplus_merchant_app/helpers/sizeHelper.dart';
import 'package:vplus_merchant_app/styles/color.dart';
import 'package:vplus_merchant_app/widgets/components.dart';
import 'package:vplus_merchant_app/widgets/emptyView.dart';

class TimeRangeSelector extends StatefulWidget {
  /// this widget generates a date range selector
  /// default value will be utilized in initState and reset button
  final TimeOfDay defaultStartDate;
  final TimeOfDay defaultEndDate;
  final Function onSelectCallBack;
  TimeRangeSelector(this.onSelectCallBack,
      {this.defaultStartDate, this.defaultEndDate});
  @override
  State<StatefulWidget> createState() {
    return TimeRangeSelectorState();
  }
}

class TimeRangeSelectorState extends State<TimeRangeSelector> {
  TimeOfDay startTime;
  TimeOfDay endTime;
  @override
  void initState() {
    startTime = this.widget.defaultStartDate ?? null;
    endTime = this.widget.defaultEndDate ?? null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          timeBarListTile(startTime, true, (v) {
            startTime = v;
            OnTimeSelected();
          }),
          timeBarListTile(endTime, false, (v) {
            endTime = v;
            OnTimeSelected();
          }),
        ],
      ),
    );
  }

  Future<TimeOfDay> _selectTime(TimeOfDay _time) async {
    _time ??= TimeOfDay(hour: 0, minute: 0);
    TimeOfDay newTime;
    final ThemeData theme = Theme.of(context);
    assert(theme.platform != null);
    if (theme.platform == TargetPlatform.android) {
      newTime = await showTimePicker(
        context: context,
        initialTime: _time,
      );
    } else {
      await showModalBottomSheet(
          context: context,
          builder: (builder) {
            return CupertinoTimerPicker(
              mode: CupertinoTimerPickerMode.hm,
              onTimerDurationChanged: (Duration changedtimer) {
                newTime = TimeOfDay(
                    hour: changedtimer.inHours,
                    minute: changedtimer.inMinutes.remainder(60));
                print(newTime);
              },
            );
          });
    }
    if (newTime != null) {
      setState(() {
        _time = newTime;
      });
      return _time;
    }
  }

  Widget timeBarListTile(
    TimeOfDay _time,
    bool isStartTime,
    Function(TimeOfDay) onCallBack,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
            "${isStartTime ? 'start time' : 'end time'}: ${_time == null ? '' : _time.format(context)} ",
            style: GoogleFonts.lato()),
        RoundedSelectButton("select", () async {
          _time = await _selectTime(_time);
          setState(() {
            onCallBack(_time);
          });
        }),
      ],
    );
  }

  void OnTimeSelected() {
    if (startTime != null && endTime != null) {
      if (DateTimeHelper.compareTimeOfDays(startTime, endTime)) {
        widget.onSelectCallBack(startTime, endTime);
      } else {
        var hlp = Helper();
        hlp.showToastError("End time should be later than start time");
      }
    }
  }
}

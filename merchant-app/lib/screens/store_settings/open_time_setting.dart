import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vplus_merchant_app/helpers/sizeHelper.dart';
import 'package:vplus_merchant_app/providers/current_stores_provider.dart';
import 'package:vplus_merchant_app/widgets/components.dart';
import 'package:vplus_merchant_app/widgets/customAppBar.dart';
import 'package:vplus_merchant_app/widgets/emptyView.dart';
import 'package:vplus_merchant_app/widgets/time_range_selector.dart';

class StoreOpenTimeSettings extends StatefulWidget {
  StoreOpenTimeSettings({Key key}) : super(key: key);
  _StoreOpenTimeSettingsState createState() => _StoreOpenTimeSettingsState();
}

class _StoreOpenTimeSettingsState extends State<StoreOpenTimeSettings> {
  TimeOfDay startTime;
  TimeOfDay endTime;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
        "Store Open Time Settings",
        true,
        showLogo: false,
        context: context,
        screenPage: CustomAppBar.kitchenPage,
      ),
      body: Consumer<CurrentStoresProvider>(
        builder: (ctx, p, w) {
          startTime = p.getSelectedStore.openTime;
          endTime = p.getSelectedStore.closeTime;
          return Container(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: SizeHelper.heightMultiplier,
                      horizontal: SizeHelper.widthMultiplier * 2),
                  child: TimeRangeSelector((startTimeValue, endTimeValue) {
                    startTime = startTimeValue;
                    endTime = endTimeValue;
                  }, defaultStartDate: startTime, defaultEndDate: endTime),
                ),
                VEmptyView(SizeHelper.heightMultiplier * 20),
                RoundedVplusLongButton(
                    callBack: () async {
                      bool hasUpdated =
                          await p.setOpenTime(context, startTime, endTime);
                      if (hasUpdated) Navigator.pop(context);
                    },
                    text: "Update"),
              ],
            ),
          );
        },
      ),
    );
  }
}

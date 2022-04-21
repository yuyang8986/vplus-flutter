import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vplus/helper/appLocalizationHelper.dart';
import 'package:vplus/helper/order_helper.dart';
import 'package:vplus/providers/driver_order_list_provider.dart';
import 'package:vplus/providers/order_list_provider.dart';
import 'package:vplus/screens/order_list/order_driver_list_list_view.dart';
import 'package:vplus/screens/order_list/order_filter_bar.dart';
import 'package:vplus/screens/order_list/order_list_list_view.dart';
import 'package:vplus/widgets/appBar.dart';

import 'driver_order_filter_bar.dart';

class DriverOrderListScreen extends StatefulWidget {
  _OrderListScreenState createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<DriverOrderListScreen> {
  DriverOrderFilterType _selectedType;
  Key deliveringOrdersKey;
  Key deliveredOrdersKey;
  Key readyForPickKey;

  @override
  void initState() {
    super.initState();
    _selectedType = DriverOrderFilterType.MyOrder;
    deliveringOrdersKey = UniqueKey();
    deliveredOrdersKey = UniqueKey();
    readyForPickKey = UniqueKey();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
        "${AppLocalizationHelper.of(context).translate("Drivers")}",
        true,
        context: context,
      ),
      body: Column(
        children: [
          DriverOrderFilterBar(
            orderTypeButton: DriverOrderFilterType.values.map((e) {
              return DriverListTypeButton(
                isSelectedType: _selectedType,
                buttonType: e,
                buttonEvent: () {
                  setState(() {
                    _selectedType = e;

                    Provider.of<DriverOrderListProvider>(context, listen: false).setIsDelivered(
                     _selectedType == DriverOrderFilterType.MyOrder? false:true
                    );
                    (_selectedType == DriverOrderFilterType.MyOrder)

                    ? Provider.of<DriverOrderListProvider>(context, listen: false)
                        .setIsActive = "1"
                        :(_selectedType == DriverOrderFilterType.ReadyForPickOrder)
                        ? Provider.of<DriverOrderListProvider>(context, listen: false)
                        .setIsActive = "2"
                        :Provider.of<DriverOrderListProvider>(context, listen: false)
                        .setIsActive = "3";
                  });
                },
              );
            }).toList(),
          ),
          (_selectedType == DriverOrderFilterType.MyOrder)
              ? Expanded(child: OrderDriverListListView(key: deliveringOrdersKey))

              : (_selectedType == DriverOrderFilterType.ReadyForPickOrder)
              ? Expanded(child: OrderDriverListListView(key: readyForPickKey))
              : Expanded(child: OrderDriverListListView(key: deliveredOrdersKey)),
        ],
      ),
    );
  }
}

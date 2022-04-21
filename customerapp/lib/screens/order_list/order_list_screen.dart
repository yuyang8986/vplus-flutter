import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vplus/helper/appLocalizationHelper.dart';
import 'package:vplus/helper/order_helper.dart';
import 'package:vplus/providers/order_list_provider.dart';
import 'package:vplus/screens/order_list/order_filter_bar.dart';
import 'package:vplus/screens/order_list/order_list_list_view.dart';
import 'package:vplus/widgets/appBar.dart';

class OrderListScreen extends StatefulWidget {
  _OrderListScreenState createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  OrderFilterType _selectedType;
  Key activeOrdersKey;
  Key historyOrdersKey;
  @override
  void initState() {
    super.initState();
    _selectedType = OrderFilterType.ActiveOrder;
    activeOrdersKey = UniqueKey();
    historyOrdersKey = UniqueKey();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
        "${AppLocalizationHelper.of(context).translate("Orders")}",
        true,
        context: context,
      ),
      body: Column(
        children: [
          OrderFilterBar(
            orderTypeButton: OrderFilterType.values.map((e) {
              return ListTypeButton(
                isSelectedType: _selectedType,
                buttonType: e,
                buttonEvent: () {
                  setState(() {
                    _selectedType = e;
                    Provider.of<OrderListProvider>(context, listen: false)
                            .setIsActive =
                        _selectedType == OrderFilterType.ActiveOrder;
                  });
                },
              );
            }).toList(),
          ),
          (_selectedType == OrderFilterType.ActiveOrder)
              ? Expanded(child: OrderListListView(key: activeOrdersKey))
              : Expanded(child: OrderListListView(key: historyOrdersKey)),
        ],
      ),
    );
  }
}

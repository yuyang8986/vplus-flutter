import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:provider/provider.dart';
import 'package:vplus_merchant_app/helpers/apiHelper.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/models/StoreKitchen.dart';
import 'package:vplus_merchant_app/models/http/http_response.dart';
import 'package:vplus_merchant_app/models/storeBusinessType.dart';
import 'package:vplus_merchant_app/providers/current_stores_provider.dart';
import 'package:vplus_merchant_app/widgets/components.dart';
import 'package:vplus_merchant_app/widgets/dropdown_select.dart';
import 'package:vplus_merchant_app/widgets/emptyView.dart';

class StoreKitchenSelection extends StatefulWidget {
  final Function onSelectCallBack;
  final int defaultKitchenId;

  StoreKitchenSelection(
    this.onSelectCallBack, {
    this.defaultKitchenId,
  });
  @override
  _StoreKitchenSelectionState createState() => _StoreKitchenSelectionState();
}

class _StoreKitchenSelectionState extends State<StoreKitchenSelection> {
  TextEditingController _kitchenIdCtrl = new TextEditingController();
  List<StoreKitchen> storeKitchens;
  StoreKitchen selectedStoreKitchen;
  int defaultKitchenId;
  @override
  void initState() {
    storeKitchens = Provider.of<CurrentStoresProvider>(context, listen: false)
        .getSelectedStoreKitchens;
    defaultKitchenId = this.widget.defaultKitchenId;
    if (defaultKitchenId != null) {
      selectedStoreKitchen =
          storeKitchens.firstWhere((s) => s.storeKitchenId == defaultKitchenId);
    }
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void onSelectBusinessType() {
    widget.onSelectCallBack(selectedStoreKitchen?.storeKitchenId);
  }

  MultiSelectDialogItem _selectionItem(StoreKitchen availableStoreKitchen) {
    return MultiSelectDialogItem(
        availableStoreKitchen, Text(availableStoreKitchen.storeKitchenName));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          readOnly: true,
          controller: _kitchenIdCtrl,
          textAlign: TextAlign.center,
          // validator: (value) {
          //   if (value.isEmpty) {
          //     return 'Please select a store kitchen';
          //   }
          //   return null;
          // },
          decoration: CustomTextBox(
                  hint: (selectedStoreKitchen == null)
                      ? "${AppLocalizationHelper.of(context).translate('SelectKitchen')}"
                      : selectedStoreKitchen.storeKitchenName,
                  mandate: false,
                  context: context)
              .getTextboxDecoration(),
          onTap: () async {
            final Set<dynamic> selectedTypes = await showDialog(
                context: context,
                builder: (ctx) {
                  return Container(
                    child: MultiSelectDialog(
                      items:
                          storeKitchens.map((e) => _selectionItem(e)).toList(),
                    ),
                  );
                });

            if (selectedTypes != null) {
              setState(() {
                selectedStoreKitchen = selectedTypes.single;
              });
            }
            onSelectBusinessType();
          },
        ),
        VEmptyView(ScreenUtil().setHeight(100)),
      ],
    );
  }
}

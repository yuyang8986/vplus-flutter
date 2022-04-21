import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:vplus_merchant_app/helpers/apiHelper.dart';
import 'package:vplus_merchant_app/models/http/http_response.dart';
import 'package:vplus_merchant_app/models/storeBusinessType.dart';
import 'package:vplus_merchant_app/widgets/components.dart';
import 'package:vplus_merchant_app/widgets/dropdown_select.dart';
import 'package:vplus_merchant_app/widgets/emptyView.dart';

class BusinessTypeSelection extends StatefulWidget {
  final Function onSelectCallBack;
  final StoreBusinessType initParentBusType;
  final List<StoreBusinessType> initSubBusTypeList;
  BusinessTypeSelection(this.onSelectCallBack,
      {this.initParentBusType, this.initSubBusTypeList});
  @override
  _BusinessTypeSelectionState createState() => _BusinessTypeSelectionState();
}

class _BusinessTypeSelectionState extends State<BusinessTypeSelection> {
  List<StoreBusinessType> _businessTypesSelected =
      new List<StoreBusinessType>();
  TextEditingController _busTypesCtrl = new TextEditingController();
  TextEditingController _subBusTypesCtrl = new TextEditingController();
  bool _showFAndBSubType;
  // final String defaultCateName = "Food&Beverage";
  List<StoreBusinessType> businessTypes;
  List<StoreBusinessType> cuisineTypes;

  List<StoreBusinessType> initSubBusTypeList;

  @override
  void initState() {
    _showFAndBSubType = false;
    initSubBusTypeList = this.widget.initSubBusTypeList;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // if (widget.parentBusType != null) {
    //   _busTypesCtrl.text = widget.parentBusType.catName;
    // }

    // String subBusTypeStr = '';
    // if (widget.subBusTypeList != null) {
    //   List<StoreBusinessType> subBusTypeList = widget.subBusTypeList;
    //   subBusTypeList.removeWhere((e) =>
    //       e.storeBusinessCatTypeId ==
    //       widget.parentBusType.storeBusinessCatTypeId);

    //   if (subBusTypeList.length == 0) {
    //     _showFAndBSubType = false;
    //   } else {
    //     subBusTypeList.sort((a, b) => a.catName.compareTo(b.catName));
    //     for (int i = 0; i < subBusTypeList.length; i++) {
    //       if (subBusTypeList[i].storeBusinessCatTypeId !=
    //           widget.parentBusType.storeBusinessCatTypeId) {
    //         if (i == subBusTypeList.length - 1)
    //           subBusTypeStr += subBusTypeList[i].catName;
    //         else
    //           subBusTypeStr += subBusTypeList[i].catName + ', ';
    //       }
    //     }
    //     _showFAndBSubType = true;
    //   }
    // } else {
    //   _showFAndBSubType = false;
    // }
    // _subBusTypesCtrl.text = subBusTypeStr;
  }

  void onSelectBusinessType() {
    widget.onSelectCallBack(_businessTypesSelected);
  }

  Future getBusinessTypesFuture() {
    var hlp = Helper();
    return hlp.getData("api/StoreBusinessCatType/getAllCatTypes",
        hasAuth: true, context: context);
  }

  MultiSelectDialogItem _selectionItem(StoreBusinessType businessType) {
    return MultiSelectDialogItem(businessType, Text(businessType.catName));
  }

  // get _selectBusinessType {
  //   return FutureBuilder<HttpResponse>(
  //     builder: (ctx, ayncdata) {
  //       if (!ayncdata.hasData)
  //         return Container(child: Center(child: CircularProgressIndicator()));
  //       List<StoreBusinessType> businessTypes =
  //           (ayncdata.data.data["storeBusinessCatTypes"] as List)
  //               .map((e) => StoreBusinessType.fromJson(e))
  //               .toList();
  //       businessTypes.removeWhere((element) => element.parentId != null);
  //       return Container(
  //         child: MultiSelectDialog(
  //           items: businessTypes.map((e) => _selectionItem(e)).toList(),
  //         ),
  //       );
  //     },
  //     future: getBusinessTypesFuture(),
  //   );
  // }

  get _selectCuisionType {
    return FutureBuilder<HttpResponse>(
      builder: (ctx, ayncdata) {
        if (!ayncdata.hasData)
          return Container(child: Center(child: CircularProgressIndicator()));
        businessTypes = (ayncdata.data.data["storeBusinessCatTypes"] as List)
            .map((e) => StoreBusinessType.fromJson(e))
            .toList();
        cuisineTypes = businessTypes;
        return Container(
            child: MultiSelectDialog(
          items: cuisineTypes.map((e) => _selectionItem(e)).toList(),
          allowMultiSelect: true,
          maxMultiSelect: 3,
        ));
      },
      future: getBusinessTypesFuture(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // TextFormField(
        //   readOnly: true,
        //   controller: _busTypesCtrl,
        //   textAlign: TextAlign.center,
        //   validator: (value) {
        //     if (value.isEmpty) {
        //       return 'Please select a business type';
        //     }
        //     return null;
        //   },
        //   decoration: CustomTextBox(hint: "Business Type", mandate: true)
        //       .getTextboxDecoration(),
        //   onTap: () async {
        //     final Set<dynamic> selectedTypes = await showDialog(
        //         context: context,
        //         builder: (ctx) {
        //           return _selectBusinessType;
        //         });

        //     if (selectedTypes != null) {
        //       setState(() {
        //         _businessTypesSelected =
        //             List<StoreBusinessType>.from(selectedTypes);

        //         _busTypesCtrl.text =
        //             _businessTypesSelected.map((e) => e.catName).first;

        //         if (_busTypesCtrl.text == "Food&Beverage") {
        //           _showFAndBSubType = true;
        //         } else {
        //           _showFAndBSubType = false;
        //         }
        //       });
        //     }
        //     onSelectBusinessType();
        //   },
        // ),
        // VEmptyView(ScreenUtil().setHeight(100)),
        // _showFAndBSubType
        //?
        Column(
          children: [
            TextFormField(
              readOnly: true,
              controller: _subBusTypesCtrl,
              textAlign: TextAlign.center,
              validator: (value) {
                // if (value.isEmpty) {
                //   return 'Please select a cuisine type';
                // }
                return null;
              },
              decoration: CustomTextBox(
                      hint: (initSubBusTypeList == null)
                          ? "Cuisine Select"
                          : initSubBusTypeList
                              .map((type) => type.catName)
                              .join(", "),
                      context: context,
                      mandate: false)
                  .getTextboxDecoration(),
              onTap: () async {
                final Set<dynamic> selectedTypes = await showDialog(
                    context: context,
                    builder: (ctx) {
                      return _selectCuisionType;
                    });

                if (selectedTypes != null) {
                  setState(() {
                    _businessTypesSelected =
                        List<StoreBusinessType>.from(selectedTypes);
                    _subBusTypesCtrl.text = (_businessTypesSelected
                        .map((e) => e.catName)).join(', ');

                    // add the default category to store business type
                    // _businessTypesSelected.add(businessTypes
                    //     .firstWhere((type) => type.catName == defaultCateName));
                  });
                }
                onSelectBusinessType();
              },
            ),
            // VEmptyView(100),
          ],
        )
        // : Container()
      ],
    );
  }
}

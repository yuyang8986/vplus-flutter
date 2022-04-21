import 'package:flutter/material.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/models/StoreKitchen.dart';
import 'package:vplus_merchant_app/models/menuItem.dart';
import 'package:vplus_merchant_app/providers/current_stores_provider.dart';
import 'package:vplus_merchant_app/widgets/customAppBar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:vplus_merchant_app/providers/current_menu_provider.dart';
import 'package:vplus_merchant_app/screens/menu/menu_item_form.dart';
import 'package:vplus_merchant_app/models/menuAddOn.dart';
import 'package:vplus_merchant_app/widgets/pic_selection.dart';

class NewItem extends StatefulWidget {
  @override
  _NewItemState createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  bool _isInAsyncCall = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        width: 1080, height: 1920, allowFontScaling: false);
    return SafeArea(
      bottom: false,
      top: true,
      child: Scaffold(
        appBar: CustomAppBar.getAppBar(
          AppLocalizationHelper.of(context).translate('NewItem'),
          false,
          context: context,
          showLogo: false,
        ),
        resizeToAvoidBottomInset: true,
        body: ModalProgressHUD(
          child: SingleChildScrollView(
            child: Container(
              alignment: Alignment.center,
              child: MenuItemForm(submitCallBack: _submitForm),
            ),
          ),
          inAsyncCall: _isInAsyncCall,
          // demo of some additional parameters
          opacity: 0.5,
          progressIndicator: CircularProgressIndicator(),
        ),
      ),
    );
  }

  _submitForm(MenuItem menuItem) async {
    if (menuItem == null) return;

    // start the modal progress HUD
    setState(() {
      _isInAsyncCall = true;
    });

    Map<String, dynamic> data = {
      "menuItemName": menuItem.menuItemName,
      "subtitle": menuItem.subtitle,
      "price": menuItem.price,
      "menuAddOnIds": menuItem.menuAddOns.map((e) => e.menuAddOnId).toList(),
      "isSoldOut": menuItem.isSoldOut,
      "isPopular": menuItem.isPopular,
      "description": menuItem.description,
      "image": menuItem.image64,
      "storeKitchenId": menuItem.storeKitchenId
    };

    await Provider.of<CurrentMenuProvider>(context, listen: false)
        .addNewItem(context, data)
        .then((value) {
      if (value != null) {
        value['isSelectedForCategory'] = false;
        Navigator.pop(context, value);
      } else {
        print('add new item failed');
      }
      setState(() {
        _isInAsyncCall = false;
      });
    });
  }
}

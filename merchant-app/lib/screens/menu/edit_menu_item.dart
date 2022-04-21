import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/widgets/customAppBar.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:vplus_merchant_app/providers/current_menu_provider.dart';
import 'package:vplus_merchant_app/models/menuItem.dart';
import 'package:vplus_merchant_app/screens/menu/menu_item_form.dart';

class EditMenuItem extends StatefulWidget {
  @override
  _EditMenuItemState createState() => _EditMenuItemState();
}

class _EditMenuItemState extends State<EditMenuItem> {
  bool _isInAsyncCall = false;
  MenuItem item;
  MenuItem menuItem;

  @override
  void didChangeDependencies() {
    menuItem = Provider.of<CurrentMenuProvider>(context, listen: false)
        .getSelectedItemForItemMenu;
    super.didChangeDependencies();
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
          AppLocalizationHelper.of(context).translate('EditItem'),
          false,
          context: context,
          showLogo: false,
        ),
        resizeToAvoidBottomInset: true,
        body: ModalProgressHUD(
          child: SingleChildScrollView(
            child: Center(
              child: Container(
                child: MenuItemForm(
                  initMenuItem: menuItem,
                  submitCallBack: _submitUpdateItem,
                  deleteCallBack: _deleteItemButton,
                ),
              ),
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

  void _deleteItemButton(int menuItemID) async {
    setState(() {
      _isInAsyncCall = true;
    });

    bool isDeleted =
        await Provider.of<CurrentMenuProvider>(context, listen: false)
            .deleteItem(context, menuItemID);
    if (Provider.of<CurrentMenuProvider>(context, listen: false).getSearchedItems!=null){
      Provider.of<CurrentMenuProvider>(context, listen: false).removeFromSearchItems(menuItem);
    }
    if (isDeleted) {
      Navigator.pop(context);
    }
    setState(() {
      _isInAsyncCall = false;
    });
  }

  void _submitUpdateItem(MenuItem menuItem) async {
    setState(() {
      _isInAsyncCall = true;
    });
    Map<String, dynamic> data = {
      "menuItemName": menuItem.menuItemName,
      "subtitle": menuItem.subtitle,
      "price": menuItem.price,
      "menuAddOnIds": menuItem.menuAddOns.map((e) => e.menuAddOnId).toList(),
      "isSoldOut": menuItem.isSoldOut,
      "isPopular":menuItem.isPopular,
      "description": menuItem.description,
      "image": menuItem.image64,
      "menuItemId": menuItem.menuItemId,
      "storeKitchenId": menuItem.storeKitchenId,
    };

    await Provider.of<CurrentMenuProvider>(context, listen: false)
        .updateItem(context, data)
        .then((value) {
      if (value) {
        Navigator.pop(context);
      } else {
        print("update item failed");
      }
    });
    setState(() {
      _isInAsyncCall = true;
    });
  }
}

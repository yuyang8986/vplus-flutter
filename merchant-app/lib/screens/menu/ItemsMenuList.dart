import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/helpers/screenHelper.dart';
import 'package:vplus_merchant_app/helpers/sizeHelper.dart';
import 'package:vplus_merchant_app/models/menuAddOn.dart';
import 'package:vplus_merchant_app/models/menuItem.dart';
import 'package:vplus_merchant_app/providers/orderlist_provider.dart';
import 'package:vplus_merchant_app/widgets/CustomListTile.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:vplus_merchant_app/screens/menu/new_item_screen.dart';
import 'package:provider/provider.dart';
import 'package:vplus_merchant_app/providers/current_menu_provider.dart';
import 'package:vplus_merchant_app/screens/menu/edit_menu_item.dart';
import 'package:vplus_merchant_app/widgets/components.dart';
import 'package:vplus_merchant_app/widgets/emptyView.dart';

class ItemsMenuList extends StatefulWidget {
  @override
  _ItemsMenuListState createState() => _ItemsMenuListState();
}

class _ItemsMenuListState extends State<ItemsMenuList> {
  bool isMenuLocked;
  TextEditingController searchBarController;
  FocusNode searchBarFocus;
  @override
  void initState() {
    isMenuLocked = Provider.of<OrderListProvider>(context, listen: false)
        .isMenuLocked(context);
    searchBarController = new TextEditingController();
    searchBarFocus = new FocusNode();
    super.initState();
  }

  // @override
  // void didChangeDependencies() {
  //   isMenuLocked = Provider.of<OrderListProvider>(context, listen: true)
  //       .isMenuLocked(context);
  //   super.didChangeDependencies();
  // }

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentMenuProvider>(
      builder: (ctx, p, w) {
        var allItems = p.getStoreMenu.menuItems;
        if(p.getSearchedItems==null||searchBarController.text=="") {
          p.setSearchItems(allItems);
        }

        List<MenuItem> searchedItems = p.getSearchedItems;
        if (allItems == null || allItems.length == 0) {
          return Expanded(
            child: Column(
              children: [
                _getNewItemButton(),
              ],
            ),
          );
        }
        return Expanded(
          child: Column(
            children: [
              if (isMenuLocked == false) _getNewItemButton(),
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: SizeHelper.heightMultiplier * 1,
                    horizontal: SizeHelper.widthMultiplier * 4.7),
                child: TextFieldRow(
                  isReadOnly: false,
                  context: context,
                  textController: searchBarController,
                  icon: Icon(Icons.search),
                  isMandate: false,
                  focusNode: searchBarFocus,
                  suffixIcon: IconButton(
                    onPressed: () {
                      searchBarController.clear();
                      p.setSearchItems(allItems);
                    },
                    icon: Icon(Icons.clear),
                  ),
                  hintText:
                  "itemsSearch",
                  onChanged: (v) {
                    if (v != null && v != "")
                      p.searchItems(v);
                    else
                      p.setSearchItems(allItems);
                  },
                ).textFieldRow(),
              ),
              VEmptyView(20),
              Flexible(
                flex: 10,
                child: ListView.builder(
                  padding: EdgeInsets.only(bottom: ScreenUtil().setSp(200)),
                  itemCount: searchedItems.length,
                  itemBuilder: (BuildContext _context, int i) {
                    return _generateItems(searchedItems[i]);
                  },
                ),
              ),
              // Flexible(flex: 1, child: Container())
            ],
          ),
        );
      },
    );
  }

  Widget _getNewItemButton() {
    return Container(
      height:
          ScreenUtil().setHeight(ScreenHelper.isLandScape(context) ? 120 : 100),
      margin: EdgeInsets.symmetric(
        vertical: ScreenUtil().setSp(20),
        horizontal: ScreenUtil().setSp(50),
      ),
      width: double.infinity,
      child: RaisedButton(
        onPressed: _newItem,
        textColor: Colors.white,
        color: Color(0xff5352ec),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Text(
          AppLocalizationHelper.of(context).translate('NewItem'),
          style: GoogleFonts.lato(
            fontSize: ScreenHelper.isLandScape(context)
                ? SizeHelper.textMultiplier * 2
                : SizeHelper.textMultiplier * 2,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _generateItems(MenuItem menuItem) {
    return CustomListTile(
      menuItem: menuItem,
      soldOutCallback: _changeSoldOut,
      editCallback: _editItem,
      isMenuLocked: false,
    );
  }

  Future<bool> _changeSoldOut(int id, bool value) async {
    bool isChanged =
        await Provider.of<CurrentMenuProvider>(context, listen: false)
            .setSoldoutInAllItemMenu(context, id, value);
    return isChanged;
  }

  _editItem(int id) {
    Provider.of<CurrentMenuProvider>(context, listen: false)
        .setSelectedMenuItemID(id);
    MenuItem m = Provider.of<CurrentMenuProvider>(context, listen: false)
        .getSelectedItemForItemMenu;

    Provider.of<CurrentMenuProvider>(context, listen: false)
        .setSelectedAddons(m.menuAddOns ?? List<MenuAddOn>());
    pushNewScreen(
      context,
      screen: EditMenuItem(),
      withNavBar: false,
    );
  }

  _newItem() {
    Provider.of<CurrentMenuProvider>(context, listen: false)
        .removeSelectedAddons();
    pushNewScreen(
      context,
      screen: NewItem(),
      withNavBar: false,
      pageTransitionAnimation: PageTransitionAnimation.cupertino,
    );
  }
}
